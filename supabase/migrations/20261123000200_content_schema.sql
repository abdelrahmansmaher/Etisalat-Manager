-- =============================================================================
-- 0002 — content schema: spine, immutable versions, sources/citations,
--        projections, relations, change log, conflicts, synonyms,
--        search documents, sync tombstones
-- =============================================================================
-- Value sets are CHECK constraints on text (not enums): easier to extend with
-- a one-line migration and maps 1:1 to Dart string constants.
--
--   type            : package | service | contact_number | service_code |
--                     glossary_term | faq | article | private_note
--   classification  : public  (from official public sources)
--                     generic (general know-how, not company-internal)
--                     private (internal / personal — OWNER ONLY, never synced)
--   status          : draft | published | archived
--   source_type     : official_site | official_app | regulator | press |
--                     unofficial | personal_experience
--   verification    : verified_official | regulator_only | conflict |
--                     stale_suspected | unverified
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Sources
-- -----------------------------------------------------------------------------
create table public.knowledge_sources (
  id             uuid primary key default gen_random_uuid(),
  name           text not null check (pg_catalog.length(pg_catalog.btrim(name)) > 0),
  source_type    text not null check (source_type in
                   ('official_site','official_app','regulator','press','unofficial','personal_experience')),
  -- 'private' sources (e.g. something seen at work) may only back private items.
  classification text not null default 'public' check (classification in ('public','private')),
  url            text,
  publisher      text,
  lang           text check (lang in ('ar','en','mixed')),
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
comment on table public.knowledge_sources is
  'Where facts come from. Private sources can never be cited by a published public/generic item (enforced by triggers).';

-- -----------------------------------------------------------------------------
-- Spine
-- -----------------------------------------------------------------------------
create table public.knowledge_items (
  id                   uuid primary key default gen_random_uuid(),
  type                 text not null check (type in
                         ('package','service','contact_number','service_code',
                          'glossary_term','faq','article','private_note')),
  classification       text not null default 'public'
                         check (classification in ('public','generic','private')),
  status               text not null default 'draft'
                         check (status in ('draft','published','archived')),
  slug                 text not null unique
                         check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  -- Display copies. Editable while drafting; overwritten from the version on publish.
  title_ar             text not null check (pg_catalog.length(pg_catalog.btrim(title_ar)) > 0),
  title_en             text,
  summary_ar           text,
  summary_en           text,
  published_version_id uuid,          -- FK added below (circular reference)
  tags                 text[] not null default '{}',
  priority             smallint not null default 0 check (priority between 0 and 5),
  published_at         timestamptz,
  archived_at          timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  constraint knowledge_items_published_has_version
    check (status <> 'published' or published_version_id is not null),
  constraint knowledge_items_private_note_is_private
    check (type <> 'private_note' or classification = 'private')
);
comment on table public.knowledge_items is
  'Stable identity of every piece of knowledge. Never hard-deleted once it has versions: archive instead.';

-- -----------------------------------------------------------------------------
-- Immutable versions
-- -----------------------------------------------------------------------------
create table public.knowledge_versions (
  id            uuid primary key default gen_random_uuid(),
  item_id       uuid not null references public.knowledge_items (id) on delete restrict,
  version_no    integer not null check (version_no > 0),   -- assigned by trigger when omitted
  title_ar      text not null check (pg_catalog.length(pg_catalog.btrim(title_ar)) > 0),
  title_en      text,
  summary_ar    text,
  summary_en    text,
  body_ar       text,          -- Markdown
  body_en       text,
  data          jsonb not null default '{}'::jsonb
                  check (pg_catalog.jsonb_typeof(data) = 'object'),
  valid_from    date,
  valid_until   date,
  review_due_at date,
  verified_at   timestamptz,   -- "source checked on" (replaces the review workflow, v0.2)
  change_note   text,
  created_by    uuid default auth.uid(),
  created_at    timestamptz not null default now(),
  unique (item_id, version_no),
  check (valid_until is null or valid_from is null or valid_until >= valid_from)
);
comment on table public.knowledge_versions is
  'Append-only snapshots. UPDATE/DELETE/TRUNCATE are rejected by triggers. data is validated per item type.';

alter table public.knowledge_items
  add constraint knowledge_items_published_version_fk
  foreign key (published_version_id) references public.knowledge_versions (id)
  on delete restrict
  deferrable initially deferred;

-- -----------------------------------------------------------------------------
-- Citations (one row per supported fact)
-- -----------------------------------------------------------------------------
create table public.citations (
  id                 uuid primary key default gen_random_uuid(),
  version_id         uuid not null references public.knowledge_versions (id) on delete restrict,
  source_id          uuid references public.knowledge_sources (id) on delete restrict,
  field_path         text not null default '/',    -- JSON pointer into the version ('/price'); '/' = whole version
  source_url         text,
  source_lang        text check (source_lang in ('ar','en','mixed')),
  accessed_at        timestamptz,
  evidence_path      text,                         -- Storage path of the screenshot/PDF snapshot
  verification_state text not null default 'unverified' check (verification_state in
                       ('verified_official','regulator_only','conflict','stale_suspected','unverified')),
  note               text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  check (source_id is not null or source_url is not null)
);

-- -----------------------------------------------------------------------------
-- Typed projections (derived; rebuilt by trigger whenever an item is published,
-- deleted when it is archived). Never written by clients.
-- -----------------------------------------------------------------------------
create table public.packages (
  item_id                   uuid primary key references public.knowledge_items (id) on delete cascade,
  version_id                uuid not null references public.knowledge_versions (id) on delete restrict,
  price                     numeric(12,2) not null check (price >= 0),
  price_tax_basis           text not null check (price_tax_basis in ('incl_vat','excl_vat','unknown')),
  currency                  char(3) not null default 'EGP',
  validity_days             integer not null check (validity_days > 0),
  line_type                 text check (line_type in ('prepaid','postpaid','control','home','other')),
  subscribe_code            text,
  subscribe_code_normalized text,
  valid_from                date,
  valid_until               date
);

create table public.contact_numbers (
  id                bigint generated always as identity primary key,
  item_id           uuid not null references public.knowledge_items (id) on delete cascade,
  version_id        uuid not null references public.knowledge_versions (id) on delete restrict,
  number            text not null,                 -- as displayed
  number_normalized text not null check (number_normalized ~ '^[0-9]+$'),
  service           text not null,
  from_network      text not null check (from_network in ('own','other','landline','abroad')),
  hours             text,
  cost_note         text
);

create table public.service_codes (
  id              bigint generated always as identity primary key,
  item_id         uuid not null references public.knowledge_items (id) on delete cascade,
  version_id      uuid not null references public.knowledge_versions (id) on delete restrict,
  code            text not null,                   -- as displayed ('*999#')
  code_normalized text not null check (code_normalized ~ '^[0-9*#+]+$'),
  purpose         text
);

-- -----------------------------------------------------------------------------
-- Relations graph
-- -----------------------------------------------------------------------------
create table public.knowledge_relations (
  from_item     uuid not null references public.knowledge_items (id) on delete cascade,
  to_item       uuid not null references public.knowledge_items (id) on delete cascade,
  relation_type text not null check (relation_type in
                  ('related','part_of','replaces','alternative_to','uses_code',
                   'contact_for','explained_in','see_also')),
  position      integer not null default 0,
  created_at    timestamptz not null default now(),
  primary key (from_item, to_item, relation_type),
  check (from_item <> to_item)
);

-- -----------------------------------------------------------------------------
-- Change log ("What's new") — written by the publish trigger only
-- -----------------------------------------------------------------------------
create table public.change_log (
  id         bigint generated always as identity primary key,
  item_id    uuid not null references public.knowledge_items (id) on delete cascade,
  version_id uuid references public.knowledge_versions (id) on delete restrict,
  field      text not null,     -- 'title_ar', 'data.price', ... or '_published' / '_archived'
  old_value  jsonb,
  new_value  jsonb,
  -- Frozen at write time by the publish trigger: true only if the item was
  -- public/generic (and, for diffs, already public before the change). Rows
  -- recorded while private never become readable, even after reclassification.
  recorded_public boolean not null default false,
  changed_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Conflicts between sources
-- -----------------------------------------------------------------------------
create table public.conflicts (
  id          uuid primary key default gen_random_uuid(),
  item_id     uuid not null references public.knowledge_items (id) on delete cascade,
  field_path  text not null,
  value_a     text not null,
  source_a    uuid references public.knowledge_sources (id) on delete restrict,
  value_b     text not null,
  source_b    uuid references public.knowledge_sources (id) on delete restrict,
  status      text not null default 'open' check (status in ('open','resolved','dismissed')),
  note        text,
  -- Set by trigger on every insert/update: was the item public/generic when
  -- this conflict was written? Readers only see rows with true.
  recorded_public boolean not null default false,
  resolved_at timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Synonyms (query-time expansion; term and variants stored normalized)
-- -----------------------------------------------------------------------------
create table public.synonyms (
  id         bigint generated always as identity primary key,
  term       text not null unique check (term <> ''),
  variants   text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Search documents (one per PUBLISHED item, incl. private ones — RLS hides
-- private rows from everyone but the owner). Maintained by triggers.
-- -----------------------------------------------------------------------------
create table public.search_documents (
  item_id           uuid primary key references public.knowledge_items (id) on delete cascade,
  version_id        uuid not null references public.knowledge_versions (id) on delete restrict,
  type              text not null,
  classification    text not null check (classification in ('public','generic','private')),
  title             text not null,          -- display (Arabic)
  title_en          text,
  summary           text,
  body              text not null default '',
  title_norm        text not null,
  search_text       text not null,          -- normalize_ar(everything searchable)
  tsv               tsvector not null,      -- 'simple' config over normalized text, weighted A/B/C
  codes             text[] not null default '{}',   -- normalized codes + digit-only forms + numbers
  tags              text[] not null default '{}',
  valid_from        date,
  valid_until       date,
  review_due_at     date,
  verified_at       timestamptz,
  verification      text not null default 'unverified' check (verification in
                      ('verified_official','regulator_only','conflict','stale_suspected','unverified')),
  has_open_conflict boolean not null default false,
  priority          smallint not null default 0,
  published_at      timestamptz,
  updated_at        timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Sync tombstones: items that LEFT the public set (archived or reclassified to
-- private). Deliberately carries no reason/title so it leaks nothing.
-- -----------------------------------------------------------------------------
create table public.sync_tombstones (
  item_id    uuid primary key references public.knowledge_items (id) on delete cascade,
  removed_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Indexes (every FK + common filters)
-- -----------------------------------------------------------------------------
create index knowledge_items_status_class_idx  on public.knowledge_items (status, classification);
create index knowledge_items_type_idx          on public.knowledge_items (type);
create index knowledge_items_published_ver_idx on public.knowledge_items (published_version_id);
create index knowledge_items_updated_at_idx    on public.knowledge_items (updated_at);
create index knowledge_items_tags_idx          on public.knowledge_items using gin (tags);
-- knowledge_versions(item_id) is covered by unique (item_id, version_no)
create index citations_version_idx             on public.citations (version_id);
create index citations_source_idx              on public.citations (source_id);
create index packages_version_idx              on public.packages (version_id);
create index contact_numbers_item_idx          on public.contact_numbers (item_id);
create index contact_numbers_version_idx       on public.contact_numbers (version_id);
create index contact_numbers_number_idx        on public.contact_numbers (number_normalized);
create index service_codes_item_idx            on public.service_codes (item_id);
create index service_codes_version_idx         on public.service_codes (version_id);
create index service_codes_code_idx            on public.service_codes (code_normalized);
create index knowledge_relations_to_idx        on public.knowledge_relations (to_item);
create index change_log_item_idx               on public.change_log (item_id);
create index change_log_version_idx            on public.change_log (version_id);
create index change_log_changed_at_idx         on public.change_log (changed_at desc);
create index conflicts_item_idx                on public.conflicts (item_id);
create index conflicts_source_a_idx            on public.conflicts (source_a);
create index conflicts_source_b_idx            on public.conflicts (source_b);
create index conflicts_open_idx                on public.conflicts (item_id) where status = 'open';
create index synonyms_variants_idx             on public.synonyms using gin (variants);
create index search_documents_version_idx      on public.search_documents (version_id);
create index search_documents_filter_idx       on public.search_documents (classification, type);
create index search_documents_updated_idx      on public.search_documents (updated_at);
create index search_documents_tsv_idx          on public.search_documents using gin (tsv);
create index search_documents_codes_idx        on public.search_documents using gin (codes);
create index search_documents_text_trgm_idx    on public.search_documents using gin (search_text extensions.gin_trgm_ops);
create index search_documents_title_trgm_idx   on public.search_documents using gin (title_norm extensions.gin_trgm_ops);
create index sync_tombstones_removed_idx       on public.sync_tombstones (removed_at);
