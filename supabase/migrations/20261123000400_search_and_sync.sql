-- =============================================================================
-- 0004 — read RPCs: search() and sync_since()
-- =============================================================================
-- Both are SECURITY INVOKER: they run with the caller's role, so RLS on
-- search_documents & friends filters private/draft rows BEFORE ranking,
-- snippets or counts are computed (no leakage through the RPC).
-- =============================================================================

-- Prefix tsquery for one (already normalized) token: 'باق' -> 'باق':*
-- Returns NULL when the token has no lexemes (e.g. '*' or '#').
create or replace function app.prefix_tsquery(term text)
returns tsquery
language sql
immutable
set search_path = ''
as $fn$
  select case
           when pg_catalog.count(*) = 0 then null
           else pg_catalog.to_tsquery(
                  'pg_catalog.simple'::pg_catalog.regconfig,
                  pg_catalog.string_agg(
                    '''' || pg_catalog.replace(pg_catalog.replace(u.lexeme, '\', '\\'), '''', '''''') || ''':*',
                    ' & '))
         end
  from pg_catalog.unnest(pg_catalog.to_tsvector('pg_catalog.simple'::pg_catalog.regconfig,
                                                coalesce(term, ''))) as u;
$fn$;

-- Phrase tsquery for a (normalized, possibly multi-word) synonym; NULL if empty.
create or replace function app.phrase_tsquery(term text)
returns tsquery
language sql
immutable
set search_path = ''
as $fn$
  select case when pg_catalog.numnode(x.q) = 0 then null else x.q end
  from (select pg_catalog.phraseto_tsquery('pg_catalog.simple'::pg_catalog.regconfig,
                                           coalesce(term, '')) as q) as x;
$fn$;

-- -----------------------------------------------------------------------------
-- public.search(q, filter_types, lim)
-- -----------------------------------------------------------------------------
-- 1. Exact code/number lookup when the whole query looks like a code or a
--    number ('*999#', '٩٩٩', '0 123-456'): pinned to the top.
-- 2. Full-text search on search_documents.tsv ('simple' config over
--    normalize_ar text). Each token is prefix-matched and OR-expanded with
--    synonyms; tokens are ANDed (list "fts") and also ORed (list "fts_any",
--    lower weight) as a recall fallback.
-- 3. Trigram similarity (typos): greatest(similarity(q, title_norm),
--    word_similarity(q, search_text)) >= 0.3.
-- 4. Reciprocal Rank Fusion: sum(w / (60 + rank)), w = exact 1.0 (+1000 pin),
--    fts 1.0, fts_any 0.5, trigram 0.6.
-- 5. Demotions: expired (valid_until < today) x0.3, conflict x0.7;
--    editorial boost x(1 + 0.05 * priority).
-- Returned snippet: ts_headline() over the DISPLAY text with <mark>...</mark>
-- markers. Because the index is normalized and the display text is not,
-- highlights can be missing for words whose spelling differs only by
-- normalization (e.g. ة/ه); the client may re-highlight with the shared
-- Dart normalizer.
create or replace function public.search(
  q            text,
  filter_types text[]  default null,
  lim          integer default 20)
returns table (
  item_id      uuid,
  type         text,
  title        text,
  snippet      text,
  rank         double precision,
  valid_until  date,
  verification text)
language plpgsql
stable
security invoker
set search_path = ''
as $fn$
#variable_conflict use_column
declare
  qn       text := public.normalize_ar(coalesce(q, ''));
  q_key    text;
  q_code   text := '';
  q_digits text := '';
  is_code  boolean := false;
  tok      text;
  alt      text;
  tq_tok   tsquery;
  tq_alt   tsquery;
  tq_and   tsquery;
  tq_or    tsquery;
  n_tokens integer := 0;
  lim_     integer := least(greatest(coalesce(lim, 20), 1), 100);
begin
  if qn = '' then
    return;
  end if;

  -- 1. code / number detection (whole query only)
  q_key := pg_catalog.replace(pg_catalog.replace(qn, ' ', ''), '-', '');
  if q_key ~ '^[*#+]*[0-9][0-9*#]*$' then
    is_code  := true;
    q_code   := public.normalize_code(q_key);
    q_digits := pg_catalog.regexp_replace(q_code, '[^0-9]', '', 'g');
  end if;

  -- 2. build tsqueries with synonym expansion
  foreach tok in array pg_catalog.string_to_array(qn, ' ') loop
    tq_tok := app.prefix_tsquery(tok);
    for alt in
      select a.x
      from public.synonyms s
      cross join lateral pg_catalog.unnest(pg_catalog.array_prepend(s.term, s.variants)) as a(x)
      where s.term = tok or s.variants @> array[tok]
    loop
      tq_alt := app.phrase_tsquery(alt);
      if tq_alt is not null then
        tq_tok := case when tq_tok is null then tq_alt else tq_tok || tq_alt end;
      end if;
    end loop;
    if tq_tok is not null then
      n_tokens := n_tokens + 1;
      tq_and := case when tq_and is null then tq_tok else tq_and && tq_tok end;
      tq_or  := case when tq_or  is null then tq_tok else tq_or  || tq_tok end;
    end if;
  end loop;

  -- multi-word synonym matching the whole query ('باقه انترنت' <-> 'نت')
  if pg_catalog.strpos(qn, ' ') > 0 then
    for alt in
      select a.x
      from public.synonyms s
      cross join lateral pg_catalog.unnest(pg_catalog.array_prepend(s.term, s.variants)) as a(x)
      where s.term = qn or s.variants @> array[qn]
    loop
      tq_alt := app.phrase_tsquery(alt);
      if tq_alt is not null then
        tq_and := case when tq_and is null then tq_alt else tq_and || tq_alt end;
        tq_or  := case when tq_or  is null then tq_alt else tq_or  || tq_alt end;
      end if;
    end loop;
  end if;

  return query
  with
  exact as (
    select sd.item_id as iid, 1::bigint as r
    from public.search_documents sd
    where is_code
      and (sd.codes @> array[q_code]
           or (q_digits <> '' and sd.codes @> array[q_digits]))
      and (filter_types is null or sd.type = any (filter_types))
  ),
  fts as (
    select s.iid, s.r
    from (
      select sd.item_id as iid,
             pg_catalog.row_number() over (
               order by pg_catalog.ts_rank_cd(sd.tsv, tq_and) desc, sd.item_id) as r
      from public.search_documents sd
      where tq_and is not null
        and sd.tsv @@ tq_and
        and (filter_types is null or sd.type = any (filter_types))
    ) as s
    where s.r <= 100
  ),
  fts_any as (
    select s.iid, s.r
    from (
      select sd.item_id as iid,
             pg_catalog.row_number() over (
               order by pg_catalog.ts_rank_cd(sd.tsv, tq_or) desc, sd.item_id) as r
      from public.search_documents sd
      where n_tokens > 1
        and tq_or is not null
        and sd.tsv @@ tq_or
        and (filter_types is null or sd.type = any (filter_types))
    ) as s
    where s.r <= 100
  ),
  trg as (
    select s.iid, s.r
    from (
      select x.iid,
             pg_catalog.row_number() over (order by x.sim desc, x.iid) as r
      from (
        select sd.item_id as iid,
               greatest(extensions.similarity(qn, sd.title_norm),
                        extensions.word_similarity(qn, sd.search_text)) as sim
        from public.search_documents sd
        where (filter_types is null or sd.type = any (filter_types))
      ) as x
      where x.sim >= 0.3
    ) as s
    where s.r <= 50
  ),
  fused as (
    select u.iid,
           sum(u.w / (60.0::double precision + u.r)) as rrf,
           bool_or(u.pinned) as pinned
    from (
      select e.iid, e.r, 1.0::double precision as w, true as pinned from exact e
      union all
      select f.iid, f.r, 1.0::double precision, false from fts f
      union all
      select f.iid, f.r, 0.5::double precision, false from fts_any f
      union all
      select t.iid, t.r, 0.6::double precision, false from trg t
    ) as u
    group by u.iid
  ),
  ranked as (
    select sd.item_id   as iid,
           sd.type      as itype,
           sd.title     as ititle,
           coalesce(nullif(sd.summary, ''), nullif(sd.body, ''), sd.title) as display_text,
           sd.valid_until as ivalid_until,
           case
             when sd.verification in ('verified_official', 'regulator_only', 'unverified')
                  and sd.review_due_at < current_date then 'stale_suspected'
             else sd.verification
           end as iverification,
           ((f.rrf + case when f.pinned then 1000.0::double precision else 0.0::double precision end)
             * case when sd.valid_until < current_date then 0.3::double precision else 1.0::double precision end
             * case when sd.has_open_conflict or sd.verification = 'conflict'
                    then 0.7::double precision else 1.0::double precision end
             * (1.0::double precision + 0.05::double precision * sd.priority)) as score
    from fused f
    join public.search_documents sd on sd.item_id = f.iid
    order by score desc, iid
    limit lim_
  )
  select rk.iid,
         rk.itype,
         rk.ititle,
         coalesce(
           pg_catalog.ts_headline('pg_catalog.simple'::pg_catalog.regconfig,
                                  rk.display_text,
                                  coalesce(tq_or, tq_and),
                                  'MaxWords=30, MinWords=12, MaxFragments=1, StartSel=<mark>, StopSel=</mark>'),
           pg_catalog.left(rk.display_text, 200)),
         rk.score,
         rk.ivalid_until,
         rk.iverification
  from ranked rk
  order by rk.score desc, rk.iid;
end;
$fn$;

comment on function public.search(text, text[], integer) is
  'Hybrid search (exact code/number pin + FTS + trigram, merged with RRF). SECURITY INVOKER: RLS applies.';

-- -----------------------------------------------------------------------------
-- public.sync_since(ts)
-- -----------------------------------------------------------------------------
-- Delta feed for the offline SQLite snapshot. ONLY published public/generic
-- items, whoever calls it (private content never leaves the server through
-- this RPC, even for the owner).
--   kind = 'item'      : full item payload (version, projections, citations, relations, open conflicts)
--   kind = 'tombstone' : item left the public set since ts (archived/reclassified) -> delete locally
--   kind = 'synonyms'  : the full synonym dictionary (always sent; it is small)
--   kind = 'meta'      : server_time -> pass it (minus a small overlap) as ts next time
-- ts = null -> full snapshot (client should replace its local store; no tombstones).
create or replace function public.sync_since(ts timestamptz default null)
returns table (
  kind       text,
  item_id    uuid,
  changed_at timestamptz,
  payload    jsonb)
language sql
stable
security invoker
set search_path = ''
as $fn$
  with pub as (
    select i.id, i.type, i.classification, i.slug, i.title_ar, i.title_en, i.summary_ar, i.summary_en,
           i.tags, i.priority, i.published_at,
           v.id as v_id, v.version_no, v.body_ar, v.body_en, v.data,
           v.valid_from, v.valid_until, v.review_due_at, v.verified_at,
           sd.verification, sd.has_open_conflict, sd.codes,
           greatest(i.updated_at, coalesce(sd.updated_at, i.updated_at)) as changed
    from public.knowledge_items i
    join public.knowledge_versions v on v.id = i.published_version_id
    left join public.search_documents sd on sd.item_id = i.id
    where i.status = 'published'
      and i.classification in ('public', 'generic')
  )
  select 'item'::text,
         p.id,
         p.changed,
         pg_catalog.jsonb_build_object(
           'id', p.id,
           'type', p.type,
           'classification', p.classification,
           'slug', p.slug,
           'title_ar', p.title_ar,
           'title_en', p.title_en,
           'summary_ar', p.summary_ar,
           'summary_en', p.summary_en,
           'tags', pg_catalog.to_jsonb(p.tags),
           'priority', p.priority,
           'published_at', p.published_at,
           'version', pg_catalog.jsonb_build_object(
              'id', p.v_id, 'version_no', p.version_no,
              'body_ar', p.body_ar, 'body_en', p.body_en, 'data', p.data,
              'valid_from', p.valid_from, 'valid_until', p.valid_until,
              'review_due_at', p.review_due_at, 'verified_at', p.verified_at),
           'verification', case
              when p.verification in ('verified_official', 'regulator_only', 'unverified')
                   and p.review_due_at < current_date then 'stale_suspected'
              else coalesce(p.verification, 'unverified') end,
           'has_open_conflict', coalesce(p.has_open_conflict, false),
           'codes', pg_catalog.to_jsonb(coalesce(p.codes, '{}'::text[])),
           'package', (select pg_catalog.to_jsonb(pk) - 'item_id'
                       from public.packages pk where pk.item_id = p.id),
           'contact_numbers', coalesce((select pg_catalog.jsonb_agg(pg_catalog.to_jsonb(cn) - 'item_id' order by cn.id)
                                        from public.contact_numbers cn where cn.item_id = p.id), '[]'::jsonb),
           'service_codes', coalesce((select pg_catalog.jsonb_agg(pg_catalog.to_jsonb(sc) - 'item_id' order by sc.id)
                                      from public.service_codes sc where sc.item_id = p.id), '[]'::jsonb),
           'citations', coalesce((
              select pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
                       'id', c.id,
                       'field_path', c.field_path,
                       'source_url', c.source_url,
                       'source_lang', c.source_lang,
                       'accessed_at', c.accessed_at,
                       'verification_state', c.verification_state,
                       'note', c.note,
                       'source', case when s.id is null then null else pg_catalog.jsonb_build_object(
                                   'id', s.id, 'name', s.name, 'source_type', s.source_type,
                                   'url', s.url, 'publisher', s.publisher) end)
                     order by c.field_path, c.id)
              from public.citations c
              left join public.knowledge_sources s on s.id = c.source_id
              where c.version_id = p.v_id), '[]'::jsonb),
           'relations', coalesce((
              select pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
                       'to_item', r.to_item, 'relation_type', r.relation_type, 'position', r.position)
                     order by r.position, r.to_item)
              from public.knowledge_relations r
              join public.knowledge_items ti on ti.id = r.to_item
              where r.from_item = p.id
                and ti.status = 'published'
                and ti.classification in ('public', 'generic')), '[]'::jsonb),
           'conflicts', coalesce((
              select pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
                       'id', k.id, 'field_path', k.field_path,
                       'value_a', k.value_a, 'value_b', k.value_b)
                     order by k.created_at)
              from public.conflicts k
              where k.item_id = p.id and k.status = 'open' and k.recorded_public), '[]'::jsonb)
         )
  from pub p
  where ts is null or p.changed > ts

  union all

  select 'tombstone'::text, t.item_id, t.removed_at, null::jsonb
  from public.sync_tombstones t
  where ts is not null and t.removed_at > ts

  union all

  select 'synonyms'::text, null::uuid, pg_catalog.now(),
         coalesce((select pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object('term', s.term, 'variants', s.variants)
                                               order by s.term)
                   from public.synonyms s), '[]'::jsonb)

  union all

  select 'meta'::text, null::uuid, pg_catalog.now(),
         pg_catalog.jsonb_build_object('server_time', pg_catalog.now(),
                                       'schema_version', 1,
                                       'full', ts is null);
$fn$;

comment on function public.sync_since(timestamptz) is
  'Offline delta feed: published public/generic items changed since ts + tombstones + synonyms. Never returns private content.';
