-- =============================================================================
-- 0003 — integrity triggers, per-type validation, publish pipeline
--        (projections, search documents, change log, tombstones)
-- =============================================================================
-- Every function: explicit `set search_path = ''` and fully-qualified names.
-- Trigger functions that maintain DERIVED tables are SECURITY DEFINER (owned
-- by the migration role, which owns the tables and therefore bypasses RLS —
-- RLS is intentionally NOT forced, see 0005). Clients get no write grants on
-- derived tables at all.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Who may write?  The owner, or a privileged backend session (SQL editor /
-- migrations / seed / service_role) — i.e. anything that is NOT a PostgREST
-- request running as anon/authenticated. Used as an early guard inside
-- SECURITY DEFINER triggers so non-owners get a clean 42501 before any lookup.
-- -----------------------------------------------------------------------------
create or replace function app.is_privileged_writer()
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select public.is_owner()
      or coalesce(pg_catalog.current_setting('role', true), 'none') not in ('anon', 'authenticated');
$fn$;

-- -----------------------------------------------------------------------------
-- updated_at maintenance (plain trigger, invoker)
-- -----------------------------------------------------------------------------
create or replace function app.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $fn$
begin
  new.updated_at := pg_catalog.now();
  return new;
end;
$fn$;

create trigger knowledge_sources_touch before update on public.knowledge_sources
  for each row execute function app.touch_updated_at();
create trigger citations_touch before update on public.citations
  for each row execute function app.touch_updated_at();
create trigger conflicts_touch before update on public.conflicts
  for each row execute function app.touch_updated_at();

-- -----------------------------------------------------------------------------
-- Per-type JSONB validation of knowledge_versions.data
-- -----------------------------------------------------------------------------
--   package        required: price (number >= 0), price_tax_basis
--                  (incl_vat|excl_vat|unknown), currency (ISO-4217, 3 upper
--                  letters), validity_days (positive integer)
--                  optional: subscribe_code (string with a digit), line_type
--   contact_number required: service (non-empty string), numbers (non-empty
--                  array of {number: string with digits, from_network:
--                  own|other|landline|abroad, hours?: string, cost_note?: string})
--   service_code   required: code (string with a digit), purpose (non-empty string)
--   any type       optional: codes (array of {code: string with a digit, purpose?: string})
create or replace function app.validate_version_data(p_type text, d jsonb)
returns void
language plpgsql
immutable
set search_path = ''
as $fn$
declare
  e jsonb;
begin
  if d is null or pg_catalog.jsonb_typeof(d) <> 'object' then
    raise exception 'version data must be a JSON object' using errcode = '22023';
  end if;

  if d ? 'codes' then
    if pg_catalog.jsonb_typeof(d -> 'codes') <> 'array' then
      raise exception 'data.codes must be an array' using errcode = '22023';
    end if;
    for e in select x.value from pg_catalog.jsonb_array_elements(d -> 'codes') as x(value) loop
      if pg_catalog.jsonb_typeof(e) is distinct from 'object'
         or pg_catalog.jsonb_typeof(e -> 'code') is distinct from 'string'
         or coalesce(public.normalize_code(e ->> 'code'), '') !~ '[0-9]' then
        raise exception 'data.codes[] entries need a "code" string containing digits' using errcode = '22023';
      end if;
    end loop;
  end if;

  if p_type = 'package' then
    if pg_catalog.jsonb_typeof(d -> 'price') is distinct from 'number'
       or (d ->> 'price')::numeric < 0 then
      raise exception 'package: "price" must be a non-negative number' using errcode = '22023';
    end if;
    if coalesce(d ->> 'price_tax_basis', '') not in ('incl_vat', 'excl_vat', 'unknown') then
      raise exception 'package: "price_tax_basis" must be incl_vat|excl_vat|unknown' using errcode = '22023';
    end if;
    if pg_catalog.jsonb_typeof(d -> 'currency') is distinct from 'string'
       or (d ->> 'currency') !~ '^[A-Z]{3}$' then
      raise exception 'package: "currency" must be a 3-letter ISO code' using errcode = '22023';
    end if;
    if pg_catalog.jsonb_typeof(d -> 'validity_days') is distinct from 'number'
       or (d ->> 'validity_days') !~ '^[1-9][0-9]{0,4}$' then
      raise exception 'package: "validity_days" must be a positive integer' using errcode = '22023';
    end if;
    if d ? 'subscribe_code' and (
         pg_catalog.jsonb_typeof(d -> 'subscribe_code') is distinct from 'string'
         or coalesce(public.normalize_code(d ->> 'subscribe_code'), '') !~ '[0-9]') then
      raise exception 'package: "subscribe_code" must be a string containing digits' using errcode = '22023';
    end if;
    if d ? 'line_type'
       and coalesce(d ->> 'line_type', '') not in ('prepaid', 'postpaid', 'control', 'home', 'other') then
      raise exception 'package: invalid "line_type"' using errcode = '22023';
    end if;

  elsif p_type = 'contact_number' then
    if pg_catalog.jsonb_typeof(d -> 'service') is distinct from 'string'
       or pg_catalog.btrim(d ->> 'service') = '' then
      raise exception 'contact_number: "service" is required' using errcode = '22023';
    end if;
    if pg_catalog.jsonb_typeof(d -> 'numbers') is distinct from 'array'
       or pg_catalog.jsonb_array_length(d -> 'numbers') = 0 then
      raise exception 'contact_number: "numbers" must be a non-empty array' using errcode = '22023';
    end if;
    for e in select x.value from pg_catalog.jsonb_array_elements(d -> 'numbers') as x(value) loop
      if pg_catalog.jsonb_typeof(e) is distinct from 'object'
         or pg_catalog.jsonb_typeof(e -> 'number') is distinct from 'string'
         or coalesce(public.normalize_number(e ->> 'number'), '') = ''
         or coalesce(e ->> 'from_network', '') not in ('own', 'other', 'landline', 'abroad') then
        raise exception 'contact_number: each numbers[] entry needs "number" (digits) and "from_network" (own|other|landline|abroad)'
          using errcode = '22023';
      end if;
      if e ? 'hours' and pg_catalog.jsonb_typeof(e -> 'hours') is distinct from 'string' then
        raise exception 'contact_number: "hours" must be a string' using errcode = '22023';
      end if;
    end loop;

  elsif p_type = 'service_code' then
    if pg_catalog.jsonb_typeof(d -> 'code') is distinct from 'string'
       or coalesce(public.normalize_code(d ->> 'code'), '') !~ '[0-9]' then
      raise exception 'service_code: "code" must be a string containing digits' using errcode = '22023';
    end if;
    if pg_catalog.jsonb_typeof(d -> 'purpose') is distinct from 'string'
       or pg_catalog.btrim(d ->> 'purpose') = '' then
      raise exception 'service_code: "purpose" is required' using errcode = '22023';
    end if;
  end if;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- knowledge_versions: numbering + validation on insert; immutability
-- -----------------------------------------------------------------------------
create or replace function app.versions_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_type text;
begin
  if not app.is_privileged_writer() then
    raise exception 'only the owner can write' using errcode = '42501';
  end if;

  -- Row lock serialises concurrent version numbering for the same item.
  select i.type into v_type
  from public.knowledge_items i
  where i.id = new.item_id
  for update;
  if not found then
    raise exception 'knowledge item % not found', new.item_id using errcode = '23503';
  end if;

  if new.version_no is null then
    select coalesce(max(v.version_no), 0) + 1 into new.version_no
    from public.knowledge_versions v
    where v.item_id = new.item_id;
  end if;

  perform app.validate_version_data(v_type, new.data);
  new.created_at := pg_catalog.now();
  return new;
end;
$fn$;

create or replace function app.forbid_version_mutation()
returns trigger
language plpgsql
set search_path = ''
as $fn$
begin
  raise exception 'knowledge_versions are immutable (% rejected); insert a new version instead', tg_op
    using errcode = 'P0001';
end;
$fn$;

create trigger knowledge_versions_before_insert
  before insert on public.knowledge_versions
  for each row execute function app.versions_before_insert();
create trigger knowledge_versions_immutable
  before update or delete on public.knowledge_versions
  for each row execute function app.forbid_version_mutation();
create trigger knowledge_versions_no_truncate
  before truncate on public.knowledge_versions
  for each statement execute function app.forbid_version_mutation();

-- -----------------------------------------------------------------------------
-- Derived data builders
-- -----------------------------------------------------------------------------
-- Typed projections from the PUBLISHED version's data.
create or replace function app.rebuild_projections(p_item uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  i public.knowledge_items%rowtype;
  v public.knowledge_versions%rowtype;
begin
  delete from public.packages        where item_id = p_item;
  delete from public.contact_numbers where item_id = p_item;
  delete from public.service_codes   where item_id = p_item;

  select * into i from public.knowledge_items where id = p_item;
  if not found or i.status <> 'published' then
    return;
  end if;
  select * into v from public.knowledge_versions where id = i.published_version_id;

  if i.type = 'package' then
    insert into public.packages (item_id, version_id, price, price_tax_basis, currency, validity_days,
                                 line_type, subscribe_code, subscribe_code_normalized, valid_from, valid_until)
    values (p_item, v.id,
            (v.data ->> 'price')::numeric,
            v.data ->> 'price_tax_basis',
            coalesce(v.data ->> 'currency', 'EGP'),
            (v.data ->> 'validity_days')::integer,
            v.data ->> 'line_type',
            v.data ->> 'subscribe_code',
            nullif(public.normalize_code(v.data ->> 'subscribe_code'), ''),
            v.valid_from, v.valid_until);
    if coalesce(public.normalize_code(v.data ->> 'subscribe_code'), '') <> '' then
      insert into public.service_codes (item_id, version_id, code, code_normalized, purpose)
      values (p_item, v.id, v.data ->> 'subscribe_code', public.normalize_code(v.data ->> 'subscribe_code'), 'اشتراك');
    end if;

  elsif i.type = 'contact_number' then
    insert into public.contact_numbers (item_id, version_id, number, number_normalized, service,
                                        from_network, hours, cost_note)
    select p_item, v.id, e ->> 'number', public.normalize_number(e ->> 'number'), v.data ->> 'service',
           e ->> 'from_network', e ->> 'hours', e ->> 'cost_note'
    from pg_catalog.jsonb_array_elements(v.data -> 'numbers') as x(e);

  elsif i.type = 'service_code' then
    insert into public.service_codes (item_id, version_id, code, code_normalized, purpose)
    values (p_item, v.id, v.data ->> 'code', public.normalize_code(v.data ->> 'code'), v.data ->> 'purpose');
  end if;

  if pg_catalog.jsonb_typeof(v.data -> 'codes') = 'array' then
    insert into public.service_codes (item_id, version_id, code, code_normalized, purpose)
    select p_item, v.id, e ->> 'code', public.normalize_code(e ->> 'code'), e ->> 'purpose'
    from pg_catalog.jsonb_array_elements(v.data -> 'codes') as x(e)
    where coalesce(public.normalize_code(e ->> 'code'), '') <> '';
  end if;
end;
$fn$;

-- One denormalized search row per published item (any classification; RLS
-- decides who sees it). Must run AFTER rebuild_projections (uses its codes).
create or replace function app.refresh_search_document(p_item uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  i            public.knowledge_items%rowtype;
  v            public.knowledge_versions%rowtype;
  v_codes      text[];
  v_data_text  text;
  v_header     text;
  v_summary    text;
  v_body       text;
  v_conflict   boolean;
  v_verif      text;
begin
  select * into i from public.knowledge_items where id = p_item;
  if not found or i.status <> 'published' then
    delete from public.search_documents where item_id = p_item;
    return;
  end if;
  select * into v from public.knowledge_versions where id = i.published_version_id;

  -- Exact-lookup keys: normalized codes, their digit-only form ('*999#' and
  -- '999'), and normalized phone numbers.
  select coalesce(pg_catalog.array_agg(distinct k.c order by k.c), '{}') into v_codes
  from (
    select sc.code_normalized as c from public.service_codes sc where sc.item_id = p_item
    union all
    select pg_catalog.regexp_replace(sc.code_normalized, '[^0-9]', '', 'g') from public.service_codes sc where sc.item_id = p_item
    union all
    select cn.number_normalized from public.contact_numbers cn where cn.item_id = p_item
  ) as k
  where k.c <> '';

  -- Every scalar value inside data (service names, purposes, hours, ...).
  select pg_catalog.string_agg(j.val #>> '{}', ' ') into v_data_text
  from pg_catalog.jsonb_path_query(v.data, 'strict $.**') as j(val)
  where pg_catalog.jsonb_typeof(j.val) in ('string', 'number');

  v_header  := public.normalize_ar(pg_catalog.concat_ws(' ', v.title_ar, v.title_en,
                                                        pg_catalog.array_to_string(i.tags, ' ')));
  v_summary := public.normalize_ar(pg_catalog.concat_ws(' ', v.summary_ar, v.summary_en));
  v_body    := public.normalize_ar(pg_catalog.concat_ws(' ', v.body_ar, v.body_en, v_data_text,
                                                        pg_catalog.array_to_string(v_codes, ' ')));

  -- Only conflicts readers may see count for non-private items, so a conflict
  -- recorded while the item was private doesn't even leak as a flag.
  v_conflict := exists (select 1 from public.conflicts c
                        where c.item_id = p_item and c.status = 'open'
                          and (c.recorded_public or i.classification = 'private'));

  v_verif := case
    when v_conflict
      or exists (select 1 from public.citations c where c.version_id = v.id and c.verification_state = 'conflict')
      then 'conflict'
    when exists (select 1 from public.citations c where c.version_id = v.id and c.verification_state = 'stale_suspected')
      then 'stale_suspected'
    when not exists (select 1 from public.citations c where c.version_id = v.id)
      or exists (select 1 from public.citations c where c.version_id = v.id and c.verification_state = 'unverified')
      then 'unverified'
    when exists (select 1 from public.citations c where c.version_id = v.id and c.verification_state = 'regulator_only')
      then 'regulator_only'
    else 'verified_official'
  end;
  -- Note: review_due_at in the past is applied at read time (search/sync),
  -- because a stored flag would silently go stale.

  insert into public.search_documents as sd (
    item_id, version_id, type, classification, title, title_en, summary, body,
    title_norm, search_text, tsv, codes, tags, valid_from, valid_until, review_due_at,
    verified_at, verification, has_open_conflict, priority, published_at, updated_at)
  values (
    p_item, v.id, i.type, i.classification, v.title_ar, v.title_en,
    coalesce(v.summary_ar, v.summary_en),
    coalesce(v.body_ar, v.body_en, ''),
    public.normalize_ar(pg_catalog.concat_ws(' ', v.title_ar, v.title_en)),
    public.normalize_ar(pg_catalog.concat_ws(' ', v_header, v_summary, v_body)),
    pg_catalog.setweight(pg_catalog.to_tsvector('pg_catalog.simple'::pg_catalog.regconfig, v_header), 'A')
      || pg_catalog.setweight(pg_catalog.to_tsvector('pg_catalog.simple'::pg_catalog.regconfig, v_summary), 'B')
      || pg_catalog.setweight(pg_catalog.to_tsvector('pg_catalog.simple'::pg_catalog.regconfig, v_body), 'C'),
    v_codes, i.tags, v.valid_from, v.valid_until, v.review_due_at,
    v.verified_at, v_verif, v_conflict, i.priority, i.published_at, pg_catalog.now())
  on conflict (item_id) do update set
    version_id        = excluded.version_id,
    type              = excluded.type,
    classification    = excluded.classification,
    title             = excluded.title,
    title_en          = excluded.title_en,
    summary           = excluded.summary,
    body              = excluded.body,
    title_norm        = excluded.title_norm,
    search_text       = excluded.search_text,
    tsv               = excluded.tsv,
    codes             = excluded.codes,
    tags              = excluded.tags,
    valid_from        = excluded.valid_from,
    valid_until       = excluded.valid_until,
    review_due_at     = excluded.review_due_at,
    verified_at       = excluded.verified_at,
    verification      = excluded.verification,
    has_open_conflict = excluded.has_open_conflict,
    priority          = excluded.priority,
    published_at      = excluded.published_at,
    updated_at        = pg_catalog.now();
end;
$fn$;

-- Flat field map of a version, for diffing ('title_ar', 'data.price', ...).
create or replace function app.version_fields(p_version uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $fn$
  select pg_catalog.jsonb_build_object(
           'title_ar', v.title_ar, 'title_en', v.title_en,
           'summary_ar', v.summary_ar, 'summary_en', v.summary_en,
           'body_ar', v.body_ar, 'body_en', v.body_en,
           'valid_from', v.valid_from, 'valid_until', v.valid_until,
           'review_due_at', v.review_due_at)
         || coalesce((select pg_catalog.jsonb_object_agg('data.' || d.key, d.value)
                      from pg_catalog.jsonb_each(v.data) as d(key, value)), '{}'::jsonb)
  from public.knowledge_versions v
  where v.id = p_version;
$fn$;

-- p_public: may readers ever see these rows? (see items_after_update)
create or replace function app.log_version_diff(p_item uuid, p_old uuid, p_new uuid, p_public boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  o jsonb := coalesce(app.version_fields(p_old), '{}'::jsonb);
  n jsonb := coalesce(app.version_fields(p_new), '{}'::jsonb);
begin
  insert into public.change_log (item_id, version_id, field, old_value, new_value, recorded_public)
  select p_item, p_new, k.key, o -> k.key, n -> k.key, coalesce(p_public, false)
  from (select pg_catalog.jsonb_object_keys(o) as key
        union
        select pg_catalog.jsonb_object_keys(n)) as k
  where (o -> k.key) is distinct from (n -> k.key)
  order by k.key;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- knowledge_items: workflow + publish pipeline
-- -----------------------------------------------------------------------------
-- Allowed transitions: draft->draft|published, published->published (new
-- version)|archived, archived->archived|draft|published. published->draft is
-- rejected (archive instead, so readers get a tombstone).
create or replace function app.items_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  ver public.knowledge_versions%rowtype;
begin
  if not app.is_privileged_writer() then
    raise exception 'only the owner can write' using errcode = '42501';
  end if;

  if tg_op = 'INSERT' then
    if new.status <> 'draft' or new.published_version_id is not null then
      raise exception 'new items start as draft without a published version; use publish_item()'
        using errcode = '22023';
    end if;
    new.published_at := null;
    new.archived_at  := null;
    new.created_at   := pg_catalog.now();
    new.updated_at   := pg_catalog.now();
    return new;
  end if;

  -- UPDATE
  if new.id <> old.id then
    raise exception 'item id is immutable' using errcode = '22023';
  end if;
  if new.type <> old.type
     and exists (select 1 from public.knowledge_versions v where v.item_id = old.id) then
    raise exception 'type cannot change once versions exist' using errcode = '22023';
  end if;
  if old.status = 'published' and new.status = 'draft' then
    raise exception 'a published item cannot go back to draft; archive it instead' using errcode = '22023';
  end if;

  if new.status = 'published' then
    select * into ver from public.knowledge_versions v where v.id = new.published_version_id;
    if not found or ver.item_id <> new.id then
      raise exception 'published_version_id must reference a version of this item' using errcode = '22023';
    end if;
    if old.status is distinct from 'published'
       or old.published_version_id is distinct from new.published_version_id then
      new.title_ar     := ver.title_ar;
      new.title_en     := ver.title_en;
      new.summary_ar   := ver.summary_ar;
      new.summary_en   := ver.summary_en;
      new.published_at := pg_catalog.now();
      new.archived_at  := null;
    end if;
    if new.classification in ('public', 'generic')
       and exists (select 1
                   from public.citations c
                   join public.knowledge_sources s on s.id = c.source_id
                   where c.version_id = new.published_version_id
                     and s.classification = 'private') then
      raise exception 'a public/generic item cannot cite a private source' using errcode = '22023';
    end if;
  elsif new.status = 'archived' and old.status <> 'archived' then
    new.archived_at := pg_catalog.now();
  end if;

  new.updated_at := pg_catalog.now();
  return new;
end;
$fn$;

create or replace function app.items_after_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  was_public boolean := old.status = 'published' and old.classification in ('public', 'generic');
  is_public  boolean := new.status = 'published' and new.classification in ('public', 'generic');
begin
  -- Change log ("What's new").
  -- recorded_public is frozen at write time: readers may see a row only if
  -- everything it contains was already public when it was written. Rows
  -- written while the item was private stay owner-only forever, even if the
  -- item is reclassified public later (no leak of old private values).
  --   * '_published' rows carry no old value -> public iff the item is public now.
  --   * field diffs carry OLD values -> public only if the item was ALREADY
  --     public before this update and still is (a version published while the
  --     item was private, or the update that makes it public, stays hidden).
  if new.status = 'published' then
    if old.status <> 'published' or (is_public and not was_public) then
      insert into public.change_log (item_id, version_id, field, old_value, new_value, recorded_public)
      select new.id, new.published_version_id, '_published', null, pg_catalog.to_jsonb(v.version_no), is_public
      from public.knowledge_versions v where v.id = new.published_version_id;
    end if;
    if old.published_version_id is not null
       and old.published_version_id is distinct from new.published_version_id then
      perform app.log_version_diff(new.id, old.published_version_id, new.published_version_id,
                                   is_public and was_public);
    end if;
  elsif new.status = 'archived' and old.status <> 'archived' then
    insert into public.change_log (item_id, version_id, field, old_value, new_value, recorded_public)
    values (new.id, new.published_version_id, '_archived', null, null, false);
  end if;

  -- Projections + search document
  if new.status = 'published' or old.status = 'published' then
    perform app.rebuild_projections(new.id);      -- deletes when not published
    perform app.refresh_search_document(new.id);  -- deletes when not published
  end if;

  -- Tombstones for the offline snapshot
  if is_public then
    delete from public.sync_tombstones where item_id = new.id;
  elsif was_public then
    insert into public.sync_tombstones (item_id, removed_at)
    values (new.id, pg_catalog.now())
    on conflict (item_id) do update set removed_at = excluded.removed_at;
  end if;

  return null;
end;
$fn$;

create trigger knowledge_items_before_write
  before insert or update on public.knowledge_items
  for each row execute function app.items_before_write();
create trigger knowledge_items_after_update
  after update on public.knowledge_items
  for each row execute function app.items_after_update();

-- -----------------------------------------------------------------------------
-- Citations / sources: no private source behind public content
-- -----------------------------------------------------------------------------
create or replace function app.citations_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if not app.is_privileged_writer() then
    raise exception 'only the owner can write' using errcode = '42501';
  end if;
  if new.source_id is not null
     and exists (select 1 from public.knowledge_sources s
                 where s.id = new.source_id and s.classification = 'private')
     and exists (select 1 from public.knowledge_versions v
                 join public.knowledge_items i on i.id = v.item_id
                 where v.id = new.version_id and i.classification <> 'private') then
    raise exception 'a private source can only be cited by private items' using errcode = '22023';
  end if;
  return new;
end;
$fn$;

create or replace function app.sources_before_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if new.classification = 'private' and old.classification <> 'private'
     and exists (select 1
                 from public.citations c
                 join public.knowledge_versions v on v.id = c.version_id
                 join public.knowledge_items i on i.id = v.item_id
                 where c.source_id = new.id and i.classification <> 'private') then
    raise exception 'source is cited by non-private items; it cannot become private' using errcode = '22023';
  end if;
  return new;
end;
$fn$;

create trigger citations_before_write
  before insert or update on public.citations
  for each row execute function app.citations_before_write();
create trigger knowledge_sources_before_update
  before update on public.knowledge_sources
  for each row execute function app.sources_before_update();

-- -----------------------------------------------------------------------------
-- Keep search_documents (verification flag, sync timestamp) fresh when
-- citations, conflicts or relations change.
-- -----------------------------------------------------------------------------
create or replace function app.citations_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  r       record;
  v_new   uuid;
  v_old   uuid;
begin
  -- NEW/OLD are read only in the branch where they exist.
  if tg_op <> 'DELETE' then
    v_new := new.version_id;
  end if;
  if tg_op <> 'INSERT' then
    v_old := old.version_id;
  end if;
  for r in
    select i.id
    from public.knowledge_items i
    where i.published_version_id = v_new
       or i.published_version_id = v_old
  loop
    perform app.refresh_search_document(r.id);
  end loop;
  return null;
end;
$fn$;

-- Conflicts: freeze reader visibility at write time, like change_log.
-- A conflict written (or last edited) while its item was private stays
-- owner-only even if the item later becomes public; the owner re-saves it to
-- expose it deliberately.
create or replace function app.conflicts_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if not app.is_privileged_writer() then
    raise exception 'only the owner can write' using errcode = '42501';
  end if;
  new.recorded_public := exists (
    select 1 from public.knowledge_items i
    where i.id = new.item_id and i.classification in ('public', 'generic'));
  return new;
end;
$fn$;

create trigger conflicts_before_write
  before insert or update on public.conflicts
  for each row execute function app.conflicts_before_write();

create or replace function app.conflicts_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if tg_op <> 'DELETE' then
    perform app.refresh_search_document(new.item_id);
  end if;
  if tg_op = 'DELETE' then
    perform app.refresh_search_document(old.item_id);
  elsif tg_op = 'UPDATE' then
    if old.item_id <> new.item_id then
      perform app.refresh_search_document(old.item_id);
    end if;
  end if;
  return null;
end;
$fn$;

create or replace function app.relations_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if tg_op <> 'DELETE' then
    perform app.refresh_search_document(new.from_item);
    perform app.refresh_search_document(new.to_item);
  end if;
  if tg_op <> 'INSERT' then
    perform app.refresh_search_document(old.from_item);
    perform app.refresh_search_document(old.to_item);
  end if;
  return null;
end;
$fn$;

create trigger citations_after_write
  after insert or update or delete on public.citations
  for each row execute function app.citations_after_write();
create trigger conflicts_after_write
  after insert or update or delete on public.conflicts
  for each row execute function app.conflicts_after_write();
create trigger knowledge_relations_after_write
  after insert or update or delete on public.knowledge_relations
  for each row execute function app.relations_after_write();

-- -----------------------------------------------------------------------------
-- Synonyms are stored normalized
-- -----------------------------------------------------------------------------
create or replace function app.synonyms_normalize()
returns trigger
language plpgsql
set search_path = ''
as $fn$
begin
  new.term := public.normalize_ar(new.term);
  new.variants := coalesce((
    select pg_catalog.array_agg(distinct n.v order by n.v)
    from (select public.normalize_ar(x) as v from pg_catalog.unnest(new.variants) as u(x)) as n
    where n.v is not null and n.v <> '' and n.v <> new.term), '{}');
  new.updated_at := pg_catalog.now();
  return new;
end;
$fn$;

create trigger synonyms_normalize
  before insert or update on public.synonyms
  for each row execute function app.synonyms_normalize();

-- -----------------------------------------------------------------------------
-- Owner RPCs
-- -----------------------------------------------------------------------------
-- SECURITY INVOKER: RLS and grants still apply; the explicit check just gives
-- a clear error. The real work happens in the triggers above.
create or replace function public.publish_item(p_item_id uuid, p_version_id uuid)
returns public.knowledge_items
language plpgsql
security invoker
set search_path = ''
as $fn$
declare
  r public.knowledge_items%rowtype;
begin
  if not public.is_owner() then
    raise exception 'only the owner can publish' using errcode = '42501';
  end if;
  update public.knowledge_items
     set status = 'published', published_version_id = p_version_id
   where id = p_item_id
  returning * into r;
  if not found then
    raise exception 'item % not found', p_item_id using errcode = 'P0002';
  end if;
  return r;
end;
$fn$;

create or replace function public.archive_item(p_item_id uuid)
returns public.knowledge_items
language plpgsql
security invoker
set search_path = ''
as $fn$
declare
  r public.knowledge_items%rowtype;
begin
  if not public.is_owner() then
    raise exception 'only the owner can archive' using errcode = '42501';
  end if;
  update public.knowledge_items
     set status = 'archived'
   where id = p_item_id
  returning * into r;
  if not found then
    raise exception 'item % not found', p_item_id using errcode = 'P0002';
  end if;
  return r;
end;
$fn$;

-- Full rebuild of derived data (after changing the normalizer or projections).
create or replace function public.reindex_all()
returns integer
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  r record;
  n integer := 0;
begin
  if not app.is_privileged_writer() then
    raise exception 'only the owner can reindex' using errcode = '42501';
  end if;
  for r in select i.id from public.knowledge_items i where i.status = 'published' loop
    perform app.rebuild_projections(r.id);
    perform app.refresh_search_document(r.id);
    n := n + 1;
  end loop;
  delete from public.search_documents sd
  where not exists (select 1 from public.knowledge_items i where i.id = sd.item_id and i.status = 'published');
  -- re-normalize synonyms with the current normalizer
  update public.synonyms set term = term;
  return n;
end;
$fn$;
