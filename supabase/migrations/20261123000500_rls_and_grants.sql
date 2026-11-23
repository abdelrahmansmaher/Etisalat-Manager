-- =============================================================================
-- 0005 — Row Level Security, table grants, function grants
-- =============================================================================
-- Model (v0.2):
--   anon + authenticated non-owner : SELECT only published public/generic
--                                    content (and rows that belong to it).
--                                    No INSERT/UPDATE/DELETE anywhere.
--   owner (public.is_owner())      : full access to authored tables,
--                                    including private items; SELECT on
--                                    derived tables (written by triggers only).
--
-- RLS is ENABLED on every table but NOT FORCED: the table owner (the
-- migration role) must bypass RLS so that the SECURITY DEFINER trigger
-- functions can maintain derived tables and is_owner() can read app_owner
-- without recursion. anon/authenticated never own tables, so FORCE would add
-- nothing for them.
--
-- Defence in depth: besides RLS, write privileges are simply not granted to
-- anon at all, and authenticated only gets them on authored tables.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Visibility helpers used by policies (SECURITY DEFINER, independent of the
-- caller's own RLS, in the non-exposed "app" schema).
-- -----------------------------------------------------------------------------
create or replace function app.is_item_public(p_item uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select exists (
    select 1 from public.knowledge_items i
    where i.id = p_item
      and i.status = 'published'
      and i.classification in ('public', 'generic'));
$fn$;

-- Only the CURRENTLY published version of a public item is readable;
-- older versions (history) and unpublished versions are owner-only.
create or replace function app.is_version_public(p_version uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select exists (
    select 1 from public.knowledge_items i
    where i.published_version_id = p_version
      and i.status = 'published'
      and i.classification in ('public', 'generic'));
$fn$;

-- -----------------------------------------------------------------------------
-- Enable RLS everywhere
-- -----------------------------------------------------------------------------
alter table public.app_owner           enable row level security;
alter table public.knowledge_sources   enable row level security;
alter table public.knowledge_items     enable row level security;
alter table public.knowledge_versions  enable row level security;
alter table public.citations           enable row level security;
alter table public.packages            enable row level security;
alter table public.contact_numbers     enable row level security;
alter table public.service_codes       enable row level security;
alter table public.knowledge_relations enable row level security;
alter table public.change_log          enable row level security;
alter table public.conflicts           enable row level security;
alter table public.synonyms            enable row level security;
alter table public.search_documents    enable row level security;
alter table public.sync_tombstones     enable row level security;

-- -----------------------------------------------------------------------------
-- Policies
-- -----------------------------------------------------------------------------
-- app_owner: the owner may read their own row (lets the app confirm editor
-- mode). No write policy: set the owner from the SQL editor only.
create policy app_owner_self_read on public.app_owner
  for select to authenticated
  using (user_id = (select auth.uid()));

-- knowledge_items
create policy items_public_read on public.knowledge_items
  for select to anon, authenticated
  using (status = 'published' and classification in ('public', 'generic'));
create policy items_owner_all on public.knowledge_items
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- knowledge_versions (insert-only for the owner; no update/delete policy)
create policy versions_public_read on public.knowledge_versions
  for select to anon, authenticated
  using (app.is_version_public(id));
create policy versions_owner_read on public.knowledge_versions
  for select to authenticated
  using ((select public.is_owner()));
create policy versions_owner_insert on public.knowledge_versions
  for insert to authenticated
  with check ((select public.is_owner()));

-- citations
create policy citations_public_read on public.citations
  for select to anon, authenticated
  using (app.is_version_public(version_id));
create policy citations_owner_all on public.citations
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- knowledge_sources
create policy sources_public_read on public.knowledge_sources
  for select to anon, authenticated
  using (classification = 'public');
create policy sources_owner_all on public.knowledge_sources
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- derived projections: read-only (public rows for everyone, all for owner)
create policy packages_public_read on public.packages
  for select to anon, authenticated
  using (app.is_item_public(item_id));
create policy packages_owner_read on public.packages
  for select to authenticated
  using ((select public.is_owner()));

create policy contact_numbers_public_read on public.contact_numbers
  for select to anon, authenticated
  using (app.is_item_public(item_id));
create policy contact_numbers_owner_read on public.contact_numbers
  for select to authenticated
  using ((select public.is_owner()));

create policy service_codes_public_read on public.service_codes
  for select to anon, authenticated
  using (app.is_item_public(item_id));
create policy service_codes_owner_read on public.service_codes
  for select to authenticated
  using ((select public.is_owner()));

-- relations: visible only when BOTH ends are public
create policy relations_public_read on public.knowledge_relations
  for select to anon, authenticated
  using (app.is_item_public(from_item) and app.is_item_public(to_item));
create policy relations_owner_all on public.knowledge_relations
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- change_log (derived)
-- recorded_public: history written while the item was private never leaks,
-- even if the item is reclassified public later.
create policy change_log_public_read on public.change_log
  for select to anon, authenticated
  using (recorded_public and app.is_item_public(item_id));
create policy change_log_owner_read on public.change_log
  for select to authenticated
  using ((select public.is_owner()));

-- conflicts
create policy conflicts_public_read on public.conflicts
  for select to anon, authenticated
  using (recorded_public and app.is_item_public(item_id));
create policy conflicts_owner_all on public.conflicts
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- synonyms: public dictionary, owner edits
create policy synonyms_public_read on public.synonyms
  for select to anon, authenticated
  using (true);
create policy synonyms_owner_all on public.synonyms
  for all to authenticated
  using ((select public.is_owner()))
  with check ((select public.is_owner()));

-- search_documents (derived). Rows only exist for published items; the
-- classification column is a copy kept in sync by triggers, and the policy
-- re-checks it so private rows are invisible to non-owners.
create policy search_documents_public_read on public.search_documents
  for select to anon, authenticated
  using (classification in ('public', 'generic'));
create policy search_documents_owner_read on public.search_documents
  for select to authenticated
  using ((select public.is_owner()));

-- sync_tombstones (derived; ids only, no content)
create policy sync_tombstones_read on public.sync_tombstones
  for select to anon, authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- Table privileges (Supabase grants ALL to anon/authenticated by default —
-- reset to the minimum).
-- -----------------------------------------------------------------------------
revoke all on table
  public.app_owner, public.knowledge_sources, public.knowledge_items, public.knowledge_versions,
  public.citations, public.packages, public.contact_numbers, public.service_codes,
  public.knowledge_relations, public.change_log, public.conflicts, public.synonyms,
  public.search_documents, public.sync_tombstones
from anon, authenticated, public;

grant select on table
  public.knowledge_sources, public.knowledge_items, public.knowledge_versions,
  public.citations, public.packages, public.contact_numbers, public.service_codes,
  public.knowledge_relations, public.change_log, public.conflicts, public.synonyms,
  public.search_documents, public.sync_tombstones
to anon, authenticated;

grant select on table public.app_owner to authenticated;

-- owner writes (RLS restricts these to is_owner())
grant insert, update, delete on table
  public.knowledge_sources, public.knowledge_items, public.citations,
  public.knowledge_relations, public.conflicts, public.synonyms
to authenticated;
grant insert on table public.knowledge_versions to authenticated;   -- versions are append-only

-- identity sequences used by owner inserts
grant usage on sequence public.synonyms_id_seq to authenticated;

-- -----------------------------------------------------------------------------
-- Function privileges (PostgreSQL grants EXECUTE to PUBLIC by default and
-- Supabase adds anon/authenticated — revoke everything, then grant explicitly).
-- -----------------------------------------------------------------------------
revoke execute on all functions in schema app from public, anon, authenticated;

revoke execute on function
  public.normalize_ar(text), public.normalize_code(text), public.normalize_number(text),
  public.is_owner(), public.search(text, text[], integer), public.sync_since(timestamptz),
  public.publish_item(uuid, uuid), public.archive_item(uuid), public.reindex_all()
from public, anon, authenticated;

-- public read API
grant execute on function
  public.normalize_ar(text), public.normalize_code(text), public.normalize_number(text),
  public.is_owner(), public.search(text, text[], integer), public.sync_since(timestamptz)
to anon, authenticated;

-- owner API (each checks is_owner() itself)
grant execute on function
  public.publish_item(uuid, uuid), public.archive_item(uuid), public.reindex_all()
to authenticated;

-- helpers that policies / invoker RPCs call on behalf of anon & authenticated
grant execute on function
  app.is_item_public(uuid), app.is_version_public(uuid),
  app.prefix_tsquery(text), app.phrase_tsquery(text)
to anon, authenticated;

-- service_role keeps Supabase defaults (it bypasses RLS; never ship its key in the app).
