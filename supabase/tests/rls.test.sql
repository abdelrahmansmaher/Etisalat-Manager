-- =============================================================================
-- pgTAP: Row Level Security, privileges, workflow integrity, immutability.
-- Run with:  supabase start && supabase test db
-- All data here is FAKE and lives only inside this rolled-back transaction.
-- =============================================================================
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- -----------------------------------------------------------------------------
-- Test helpers (rolled back with the transaction)
-- -----------------------------------------------------------------------------
create schema rls_test;
grant usage on schema rls_test to anon, authenticated;

-- Run a statement as the CURRENT role; return 'ok:<rows>' or the SQLSTATE.
create function rls_test.try(cmd text) returns text
language plpgsql as $$
declare n bigint;
begin
  execute cmd;
  get diagnostics n = row_count;
  return 'ok:' || n;
exception when others then
  return sqlstate;
end $$;

-- First ordinary (non-identity, non-generated) column of a public table.
create function rls_test.first_col(tbl text) returns text
language sql stable as $$
  select a.attname::text
  from pg_catalog.pg_attribute a
  where a.attrelid = ('public.' || quote_ident(tbl))::regclass
    and a.attnum > 0 and not a.attisdropped
    and a.attidentity = '' and a.attgenerated = ''
  order by a.attnum
  limit 1;
$$;

-- Attempt INSERT / UPDATE / DELETE on every table; return 'table:op=result'.
create function rls_test.write_matrix() returns setof text
language sql as $$
  select t.tbl || ':' || o.op || '=' || rls_test.try(
           case o.op
             when 'insert' then format('insert into public.%I default values', t.tbl)
             when 'update' then format('update public.%I set %I = %I', t.tbl,
                                       rls_test.first_col(t.tbl), rls_test.first_col(t.tbl))
             else format('delete from public.%I', t.tbl)
           end)
  from unnest(array[
         'app_owner','knowledge_sources','knowledge_items','knowledge_versions','citations',
         'packages','contact_numbers','service_codes','knowledge_relations','change_log',
         'conflicts','synonyms','search_documents','sync_tombstones']) as t(tbl)
  cross join unnest(array['insert','update','delete']) as o(op);
$$;

-- Switch identity like PostgREST does (role + JWT claims). Go back with
-- `reset role` + clearing claims.
create function rls_test.act_as(p_role text, p_sub uuid default null) returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
                     json_build_object('role', p_role, 'sub', p_sub)::text, true);
  perform set_config('role', p_role, true);
end $$;

grant execute on all functions in schema rls_test to anon, authenticated;

-- -----------------------------------------------------------------------------
-- Fixtures (as the privileged migration role; FAKE data only)
-- -----------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-0000000000a1', 'owner@example.test'),
  ('00000000-0000-4000-8000-0000000000a2', 'stranger@example.test');
insert into public.app_owner (user_id) values ('00000000-0000-4000-8000-0000000000a1');

insert into public.knowledge_sources (id, name, source_type, classification, url) values
  ('00000000-0000-4000-8000-00000000005a', 'مصدر عام تجريبي', 'official_site', 'public',  'https://example.test/fake'),
  ('00000000-0000-4000-8000-00000000005b', 'مصدر خاص تجريبي', 'personal_experience', 'private', null);

insert into public.knowledge_items (id, type, classification, slug, title_ar) values
  ('00000000-0000-4000-8000-000000000001', 'contact_number', 'public',  'fake-hotline',        'رقم تجريبي عام'),
  ('00000000-0000-4000-8000-000000000002', 'glossary_term',  'generic', 'fake-term',           'مصطلح تجريبي'),
  ('00000000-0000-4000-8000-000000000003', 'article',        'public',  'fake-draft',          'مسودة تجريبية'),
  ('00000000-0000-4000-8000-000000000004', 'faq',            'public',  'fake-archived',       'سؤال مؤرشف تجريبي'),
  ('00000000-0000-4000-8000-000000000005', 'private_note',   'private', 'fake-private-note',   'ملاحظة سرية تجريبية');

insert into public.knowledge_versions (id, item_id, title_ar, body_ar, data) values
  ('00000000-0000-4000-8000-0000000001a1', '00000000-0000-4000-8000-000000000001', 'رقم تجريبي عام', 'نص عام',
   '{"service":"خدمة عملاء تجريبية","numbers":[{"number":"000 111","from_network":"own","hours":"24/7"}]}'),
  ('00000000-0000-4000-8000-0000000001a2', '00000000-0000-4000-8000-000000000001', 'رقم تجريبي عام (مسودة أحدث)', 'نسخة غير منشورة',
   '{"service":"خدمة عملاء تجريبية","numbers":[{"number":"000 222","from_network":"other"}]}'),
  ('00000000-0000-4000-8000-000000000002a', '00000000-0000-4000-8000-000000000002', 'مصطلح تجريبي', 'شرح عام', '{}'),
  ('00000000-0000-4000-8000-000000000003a', '00000000-0000-4000-8000-000000000003', 'مسودة تجريبية', 'لم تنشر', '{}'),
  ('00000000-0000-4000-8000-000000000004a', '00000000-0000-4000-8000-000000000004', 'سؤال مؤرشف تجريبي', 'قديم', '{}'),
  ('00000000-0000-4000-8000-000000000005a', '00000000-0000-4000-8000-000000000005', 'ملاحظة سرية تجريبية', 'محتوى داخلي سري',
   '{"codes":[{"code":"*000#","purpose":"كود سري تجريبي"}]}');

update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-0000000001a1'
 where id = '00000000-0000-4000-8000-000000000001';
update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-000000000002a'
 where id = '00000000-0000-4000-8000-000000000002';
update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-000000000004a'
 where id = '00000000-0000-4000-8000-000000000004';
update public.knowledge_items set status = 'archived'
 where id = '00000000-0000-4000-8000-000000000004';
update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-000000000005a'
 where id = '00000000-0000-4000-8000-000000000005';

insert into public.citations (id, version_id, source_id, field_path, verification_state) values
  ('00000000-0000-4000-8000-0000000c0001', '00000000-0000-4000-8000-0000000001a1', '00000000-0000-4000-8000-00000000005a', '/numbers/0/number', 'verified_official'),
  ('00000000-0000-4000-8000-0000000c0005', '00000000-0000-4000-8000-000000000005a', '00000000-0000-4000-8000-00000000005b', '/', 'unverified');

insert into public.conflicts (id, item_id, field_path, value_a, value_b) values
  ('00000000-0000-4000-8000-0000000d0001', '00000000-0000-4000-8000-000000000001', '/numbers/0/hours', '24/7', '9-5'),
  ('00000000-0000-4000-8000-0000000d0005', '00000000-0000-4000-8000-000000000005', '/', 'أ', 'ب');

insert into public.knowledge_relations (from_item, to_item, relation_type) values
  ('00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000002', 'related'),
  ('00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000005', 'see_also');

insert into public.synonyms (term, variants) values ('نمرة', array['رقم']);

-- =============================================================================
-- Sanity: RLS enabled on every public table
-- =============================================================================
select is(
  (select coalesce(array_agg(c.relname::text order by c.relname), '{}')
   from pg_catalog.pg_class c
   join pg_catalog.pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity),
  '{}'::text[],
  'every table in public has RLS enabled');

select is(
  (select coalesce(array_agg(c.relname::text order by c.relname), '{}')
   from pg_catalog.pg_class c
   join pg_catalog.pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind = 'r'
     and (has_table_privilege('anon', c.oid, 'INSERT') or has_table_privilege('anon', c.oid, 'UPDATE')
          or has_table_privilege('anon', c.oid, 'DELETE') or has_table_privilege('anon', c.oid, 'TRUNCATE'))),
  '{}'::text[],
  'anon holds no write privilege on any public table');

-- =============================================================================
-- ANON
-- =============================================================================
select rls_test.act_as('anon');

select is(public.is_owner(), false, 'anon: is_owner() is false');

select set_eq('select id from public.knowledge_items',
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002']::uuid[],
  'anon: sees only published public/generic items (no draft, archived or private)');

select set_eq('select id from public.knowledge_versions',
  array['00000000-0000-4000-8000-0000000001a1','00000000-0000-4000-8000-000000000002a']::uuid[],
  'anon: sees only the currently published version of public items');

select set_eq('select id from public.citations',
  array['00000000-0000-4000-8000-0000000c0001']::uuid[],
  'anon: citations of private/unpublished versions are hidden');

select set_eq('select id from public.knowledge_sources',
  array['00000000-0000-4000-8000-00000000005a']::uuid[],
  'anon: private sources are hidden');

select set_eq('select id from public.conflicts',
  array['00000000-0000-4000-8000-0000000d0001']::uuid[],
  'anon: conflicts of private items are hidden');

select set_eq('select to_item from public.knowledge_relations',
  array['00000000-0000-4000-8000-000000000002']::uuid[],
  'anon: relations pointing to private items are hidden');

select set_eq('select item_id from public.search_documents',
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002']::uuid[],
  'anon: search_documents contain no private/draft/archived rows');

select is((select count(*)::int from public.service_codes), 0,
  'anon: service codes projected from a private note are hidden');

select set_eq('select number_normalized from public.contact_numbers', array['000111'],
  'anon: contact_numbers show only the published version of public items');

select ok(not exists (select 1 from public.change_log
                      where item_id not in ('00000000-0000-4000-8000-000000000001',
                                            '00000000-0000-4000-8000-000000000002')),
  'anon: change_log only for public items');

select throws_ok('select count(*) from public.app_owner', '42501', null, 'anon: app_owner is not readable at all');

select ok(not exists (select 1 from public.search('ملاحظة سرية')
                      where item_id = '00000000-0000-4000-8000-000000000005'),
  'anon: search() never returns private items (text)');
select ok(not exists (select 1 from public.search('*000#')
                      where item_id = '00000000-0000-4000-8000-000000000005'),
  'anon: search() never returns private items (exact code)');
select ok(not exists (select 1 from public.search('مسودة تجريبية')
                      where item_id = '00000000-0000-4000-8000-000000000003'),
  'anon: search() never returns drafts');

select set_eq($$select item_id from public.sync_since(null) where kind = 'item'$$,
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002']::uuid[],
  'anon: sync_since(null) returns only public/generic published items');
select ok(not exists (select 1 from public.sync_since(null) s where s.payload::text like '%سري%'),
  'anon: no private text anywhere in the sync payload');
select is((select jsonb_array_length(s.payload -> 'relations') from public.sync_since(null) s
           where s.item_id = '00000000-0000-4000-8000-000000000001'), 1,
  'anon: sync payload omits relations to private items');

select is(
  (select coalesce(array_agg(m), '{}') from rls_test.write_matrix() m where m not like '%=42501'),
  '{}'::text[],
  'anon: every INSERT/UPDATE/DELETE on every table fails with 42501');

select throws_ok($$select public.publish_item('00000000-0000-4000-8000-000000000003','00000000-0000-4000-8000-000000000003a')$$,
  '42501', null, 'anon: cannot execute publish_item');
select throws_ok($$select public.reindex_all()$$, '42501', null, 'anon: cannot execute reindex_all');

reset role;
select set_config('request.jwt.claims', '', true);

-- =============================================================================
-- AUTHENTICATED, NOT THE OWNER
-- =============================================================================
select rls_test.act_as('authenticated', '00000000-0000-4000-8000-0000000000a2');

select is(public.is_owner(), false, 'stranger: is_owner() is false');
select set_eq('select id from public.knowledge_items',
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002']::uuid[],
  'stranger: same item visibility as anon');
select set_eq('select id from public.knowledge_versions',
  array['00000000-0000-4000-8000-0000000001a1','00000000-0000-4000-8000-000000000002a']::uuid[],
  'stranger: same version visibility as anon');
select set_eq('select item_id from public.search_documents',
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002']::uuid[],
  'stranger: same search_documents visibility as anon');
select is((select count(*)::int from public.app_owner), 0, 'stranger: cannot read app_owner');
select ok(not exists (select 1 from public.search('ملاحظة سرية')
                      where item_id = '00000000-0000-4000-8000-000000000005'),
  'stranger: search() never returns private items');

select throws_ok($$insert into public.app_owner (user_id) values ('00000000-0000-4000-8000-0000000000a2')$$,
  '42501', null, 'stranger: cannot make themselves owner');
select throws_ok($$insert into public.knowledge_items (type, slug, title_ar) values ('article','evil','x')$$,
  '42501', null, 'stranger: cannot insert items');
select throws_ok($$insert into public.knowledge_versions (item_id, title_ar) values ('00000000-0000-4000-8000-000000000001','x')$$,
  '42501', null, 'stranger: cannot insert versions');
select throws_ok($$insert into public.citations (version_id, source_url) values ('00000000-0000-4000-8000-0000000001a1','https://evil.test')$$,
  '42501', null, 'stranger: cannot insert citations');
select throws_ok($$insert into public.knowledge_sources (name, source_type) values ('x','press')$$,
  '42501', null, 'stranger: cannot insert sources');
select throws_ok($$insert into public.synonyms (term, variants) values ('x', array['y'])$$,
  '42501', null, 'stranger: cannot insert synonyms');
select throws_ok($$insert into public.conflicts (item_id, field_path, value_a, value_b) values ('00000000-0000-4000-8000-000000000001','/','a','b')$$,
  '42501', null, 'stranger: cannot insert conflicts');
select throws_ok($$insert into public.search_documents (item_id) values ('00000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'stranger: cannot write derived tables');

select is(rls_test.try($$update public.knowledge_items set title_ar = 'hacked'$$), 'ok:0',
  'stranger: UPDATE on items affects 0 rows');
select is(rls_test.try($$delete from public.synonyms$$), 'ok:0',
  'stranger: DELETE on synonyms affects 0 rows');

select is(
  (select coalesce(array_agg(m), '{}') from rls_test.write_matrix() m
   where m like '%:insert=ok%' or (m not like '%=42501' and m not like '%=ok:0')),
  '{}'::text[],
  'stranger: no INSERT succeeds and every UPDATE/DELETE is denied or touches 0 rows');

select throws_ok($$select public.publish_item('00000000-0000-4000-8000-000000000003','00000000-0000-4000-8000-000000000003a')$$,
  '42501', null, 'stranger: publish_item refuses non-owners');
select throws_ok($$select public.archive_item('00000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'stranger: archive_item refuses non-owners');
select throws_ok($$select public.reindex_all()$$, '42501', null, 'stranger: reindex_all refuses non-owners');

reset role;
select set_config('request.jwt.claims', '', true);

select is((select title_ar from public.knowledge_items where id = '00000000-0000-4000-8000-000000000001'),
  'رقم تجريبي عام', 'stranger attempts left the data unchanged');
select is((select count(*)::int from public.synonyms), 1, 'stranger attempts left synonyms unchanged');
select is((select count(*)::int from public.app_owner), 1, 'still exactly one owner');

-- =============================================================================
-- OWNER
-- =============================================================================
select rls_test.act_as('authenticated', '00000000-0000-4000-8000-0000000000a1');

select is(public.is_owner(), true, 'owner: is_owner() is true');
select is((select count(*)::int from public.knowledge_items), 5, 'owner: sees all items incl. draft/archived/private');
select is((select count(*)::int from public.knowledge_versions), 6, 'owner: sees every version');
select is((select count(*)::int from public.knowledge_sources), 2, 'owner: sees private sources');
select is((select count(*)::int from public.app_owner), 1, 'owner: can read own app_owner row');
select ok(exists (select 1 from public.search('ملاحظة سرية')
                  where item_id = '00000000-0000-4000-8000-000000000005'),
  'owner: search() finds private notes');
select ok(not exists (select 1 from public.sync_since(null)
                      where item_id = '00000000-0000-4000-8000-000000000005'),
  'owner: sync_since still never exports private items');

select lives_ok($$
  insert into public.knowledge_items (id, type, classification, slug, title_ar)
  values ('00000000-0000-4000-8000-000000000006', 'service_code', 'public', 'fake-new-code', 'كود جديد تجريبي');
  insert into public.knowledge_versions (id, item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000006a', '00000000-0000-4000-8000-000000000006', 'كود جديد تجريبي',
          '{"code":"*111#","purpose":"غرض تجريبي"}');
$$, 'owner: can create an item and a version');
select is((select version_no from public.knowledge_versions where id = '00000000-0000-4000-8000-000000000006a'), 1,
  'owner: version_no assigned automatically');
select lives_ok($$select public.publish_item('00000000-0000-4000-8000-000000000006','00000000-0000-4000-8000-000000000006a')$$,
  'owner: can publish');
select is((select code_normalized from public.service_codes where item_id = '00000000-0000-4000-8000-000000000006'), '*111#',
  'owner: publish rebuilt the service_codes projection');
select ok(exists (select 1 from public.change_log
                  where item_id = '00000000-0000-4000-8000-000000000006' and field = '_published'),
  'owner: publish wrote the change log');

select lives_ok($$
  insert into public.knowledge_versions (id, item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000006b', '00000000-0000-4000-8000-000000000006', 'كود جديد تجريبي',
          '{"code":"*112#","purpose":"غرض تجريبي"}');
  select public.publish_item('00000000-0000-4000-8000-000000000006','00000000-0000-4000-8000-000000000006b');
$$, 'owner: can publish a second version');
select ok(exists (select 1 from public.change_log
                  where item_id = '00000000-0000-4000-8000-000000000006' and field = 'data.code'
                    and old_value = '"*111#"'::jsonb and new_value = '"*112#"'::jsonb),
  'owner: change log records the field diff between versions');

select lives_ok($$
  insert into public.knowledge_sources (name, source_type) values ('مصدر إضافي تجريبي', 'press');
  insert into public.conflicts (item_id, field_path, value_a, value_b)
    values ('00000000-0000-4000-8000-000000000002', '/', 'x', 'y');
  insert into public.knowledge_relations (from_item, to_item, relation_type)
    values ('00000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000006', 'related');
  update public.synonyms set variants = array['رقم','نمره'] where term = 'نمره';
  insert into public.synonyms (term, variants) values ('كود', array['رمز']);
$$, 'owner: can write sources, conflicts, relations, synonyms');

select lives_ok($$select public.archive_item('00000000-0000-4000-8000-000000000002')$$, 'owner: can archive');

select throws_ok($$update public.knowledge_versions set title_ar = 'x' where id = '00000000-0000-4000-8000-0000000001a1'$$,
  '42501', null, 'owner: versions cannot be updated (no privilege)');
select throws_ok($$delete from public.knowledge_versions where id = '00000000-0000-4000-8000-0000000001a1'$$,
  '42501', null, 'owner: versions cannot be deleted (no privilege)');
select throws_ok($$insert into public.search_documents (item_id) values ('00000000-0000-4000-8000-000000000003')$$,
  '42501', null, 'owner: derived tables are trigger-maintained only');
select throws_ok($$update public.knowledge_items set status = 'draft' where id = '00000000-0000-4000-8000-000000000001'$$,
  '22023', null, 'owner: published -> draft is rejected (archive instead)');

reset role;
select set_config('request.jwt.claims', '', true);

-- =============================================================================
-- Tombstones & reclassification
-- =============================================================================
select ok(exists (select 1 from public.sync_tombstones where item_id = '00000000-0000-4000-8000-000000000004'),
  'archiving a public item writes a tombstone');
select ok(exists (select 1 from public.sync_tombstones where item_id = '00000000-0000-4000-8000-000000000002'),
  'archive_item wrote a tombstone');

update public.knowledge_items set classification = 'private' where id = '00000000-0000-4000-8000-000000000001';

select rls_test.act_as('anon');
select ok(not exists (select 1 from public.knowledge_items where id = '00000000-0000-4000-8000-000000000001'),
  'anon: item reclassified to private disappears immediately');
select ok(not exists (select 1 from public.search_documents where item_id = '00000000-0000-4000-8000-000000000001'),
  'anon: reclassified item disappears from search_documents');
select ok(not exists (select 1 from public.contact_numbers),
  'anon: reclassified item projections disappear');
select set_eq($$select item_id from public.sync_since(now() - interval '1 minute') where kind = 'tombstone'$$,
  array['00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002',
        '00000000-0000-4000-8000-000000000004']::uuid[],
  'anon: sync_since(ts) returns tombstones for archived and reclassified items');
reset role;
select set_config('request.jwt.claims', '', true);

-- =============================================================================
-- Integrity (as privileged role)
-- =============================================================================
select throws_ok($$update public.knowledge_versions set title_ar = 'x' where id = '00000000-0000-4000-8000-0000000001a1'$$,
  'P0001', null, 'versions are immutable even for privileged roles (UPDATE)');
select throws_ok($$delete from public.knowledge_versions where id = '00000000-0000-4000-8000-0000000001a2'$$,
  'P0001', null, 'versions are immutable even for privileged roles (DELETE)');
select throws_ok($$truncate public.knowledge_versions cascade$$,
  'P0001', null, 'versions cannot be truncated');

select throws_ok($$
  insert into public.citations (version_id, source_id)
  values ('00000000-0000-4000-8000-000000000006b', '00000000-0000-4000-8000-00000000005b')
$$, '22023', null, 'a public item cannot cite a private source');

insert into public.citations (version_id, source_id)
values ('00000000-0000-4000-8000-000000000006b', '00000000-0000-4000-8000-00000000005a');
select throws_ok($$
  update public.knowledge_sources set classification = 'private' where id = '00000000-0000-4000-8000-00000000005a'
$$, '22023', null, 'a source cited by non-private items cannot become private');

insert into public.knowledge_items (id, type, slug, title_ar)
values ('00000000-0000-4000-8000-000000000007', 'package', 'fake-package-validation', 'باقة تجريبية للتحقق');
select throws_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000007', 'باقة', '{"currency":"EGP","validity_days":30,"price_tax_basis":"incl_vat"}')
$$, '22023', null, 'package without price is rejected');
select throws_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000007', 'باقة', '{"price":10,"currency":"egp","validity_days":30,"price_tax_basis":"incl_vat"}')
$$, '22023', null, 'package with invalid currency is rejected');
select lives_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000007', 'باقة', '{"price":0,"currency":"EGP","validity_days":30,"price_tax_basis":"unknown","subscribe_code":"*000#"}')
$$, 'valid package data is accepted');

insert into public.knowledge_items (id, type, slug, title_ar)
values ('00000000-0000-4000-8000-000000000008', 'contact_number', 'fake-contact-validation', 'رقم تجريبي للتحقق');
select throws_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000008', 'رقم', '{"service":"خدمة تجريبية"}')
$$, '22023', null, 'contact_number without numbers is rejected');
select throws_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000008', 'رقم', '{"service":"خدمة تجريبية","numbers":[{"number":"000","from_network":"mars"}]}')
$$, '22023', null, 'contact_number with invalid from_network is rejected');
select lives_ok($$
  insert into public.knowledge_versions (item_id, title_ar, data)
  values ('00000000-0000-4000-8000-000000000008', 'رقم', '{"service":"خدمة تجريبية","numbers":[{"number":"000 999","from_network":"landline"}]}')
$$, 'valid contact_number data is accepted');

-- =============================================================================
-- History must not leak after private -> public reclassification
-- =============================================================================
-- P: private item, two versions published while private, a conflict recorded
-- while private; then reclassified public; then a third version published.
insert into public.knowledge_items (id, type, classification, slug, title_ar)
values ('00000000-0000-4000-8000-000000000009', 'article', 'private', 'fake-reclass-history', 'مقال تجريبي للتاريخ');
insert into public.knowledge_versions (id, item_id, title_ar, body_ar, data) values
  ('00000000-0000-4000-8000-0000000009a1', '00000000-0000-4000-8000-000000000009', 'مقال تجريبي للتاريخ', 'نص خاص قديم', '{}'),
  ('00000000-0000-4000-8000-0000000009a2', '00000000-0000-4000-8000-000000000009', 'مقال تجريبي للتاريخ', 'نص ثاني', '{}'),
  ('00000000-0000-4000-8000-0000000009a3', '00000000-0000-4000-8000-000000000009', 'مقال تجريبي للتاريخ', 'نص ثالث', '{}');
update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-0000000009a1'
 where id = '00000000-0000-4000-8000-000000000009';
update public.knowledge_items set published_version_id = '00000000-0000-4000-8000-0000000009a2'
 where id = '00000000-0000-4000-8000-000000000009';
insert into public.conflicts (id, item_id, field_path, value_a, value_b)
values ('00000000-0000-4000-8000-0000000d0009', '00000000-0000-4000-8000-000000000009', '/body_ar', 'قيمة خاصة أ', 'قيمة خاصة ب');
update public.knowledge_items set classification = 'public'
 where id = '00000000-0000-4000-8000-000000000009';
update public.knowledge_items set published_version_id = '00000000-0000-4000-8000-0000000009a3'
 where id = '00000000-0000-4000-8000-000000000009';

-- Q: private item, reclassified public AND moved to a new version in ONE update.
insert into public.knowledge_items (id, type, classification, slug, title_ar)
values ('00000000-0000-4000-8000-000000000010', 'article', 'private', 'fake-reclass-same-update', 'مقال تجريبي آخر');
insert into public.knowledge_versions (id, item_id, title_ar, body_ar, data) values
  ('00000000-0000-4000-8000-0000000010a1', '00000000-0000-4000-8000-000000000010', 'مقال تجريبي آخر', 'محتوى داخلي قديم', '{}'),
  ('00000000-0000-4000-8000-0000000010a2', '00000000-0000-4000-8000-000000000010', 'مقال تجريبي آخر', 'محتوى عام جديد', '{}');
update public.knowledge_items set status = 'published', published_version_id = '00000000-0000-4000-8000-0000000010a1'
 where id = '00000000-0000-4000-8000-000000000010';
update public.knowledge_items set classification = 'public', published_version_id = '00000000-0000-4000-8000-0000000010a2'
 where id = '00000000-0000-4000-8000-000000000010';

select is((select count(*)::int from public.change_log
           where item_id = '00000000-0000-4000-8000-000000000009' and not recorded_public), 2,
  'history recorded while private is flagged recorded_public = false (first publish + v1->v2 diff)');

select rls_test.act_as('anon');
select set_eq($$select field || ':' || version_id from public.change_log
                where item_id = '00000000-0000-4000-8000-000000000009'$$,
  array['_published:00000000-0000-4000-8000-0000000009a2', 'body_ar:00000000-0000-4000-8000-0000000009a3'],
  'anon: after private->public only change_log rows recorded while public are visible');
select ok(not exists (select 1 from public.change_log
                      where old_value::text like '%نص خاص قديم%' or new_value::text like '%نص خاص قديم%'),
  'anon: old private values never appear in change_log');
select set_eq($$select field from public.change_log
                where item_id = '00000000-0000-4000-8000-000000000010'$$,
  array['_published'],
  'anon: reclassify + new version in one update hides the diff (old values were private)');
select ok(not exists (select 1 from public.change_log where old_value::text like '%محتوى داخلي قديم%'),
  'anon: old private body of Q never appears');
select is((select count(*)::int from public.conflicts
           where item_id = '00000000-0000-4000-8000-000000000009'), 0,
  'anon: conflict recorded while private stays hidden after reclassification');
select is((select has_open_conflict from public.search_documents
           where item_id = '00000000-0000-4000-8000-000000000009'), false,
  'anon: hidden conflict does not leak as a search flag');
select ok(not exists (select 1 from public.sync_since(null) s
                      where s.item_id = '00000000-0000-4000-8000-000000000009'
                        and jsonb_array_length(s.payload -> 'conflicts') > 0),
  'anon: hidden conflict is not exported by sync_since');
select ok(exists (select 1 from public.knowledge_versions
                  where id = '00000000-0000-4000-8000-0000000009a3'),
  'anon: the current version of the reclassified item is readable (intended)');
select ok(not exists (select 1 from public.knowledge_versions
                      where id in ('00000000-0000-4000-8000-0000000009a1','00000000-0000-4000-8000-0000000009a2')),
  'anon: older versions of the reclassified item stay hidden');
reset role;
select set_config('request.jwt.claims', '', true);

select rls_test.act_as('authenticated', '00000000-0000-4000-8000-0000000000a1');
select is((select count(*)::int from public.change_log
           where item_id = '00000000-0000-4000-8000-000000000009'), 4,
  'owner: still sees the full history');
select is((select count(*)::int from public.conflicts
           where item_id = '00000000-0000-4000-8000-000000000009'), 1,
  'owner: still sees the private-era conflict');
select lives_ok($$update public.conflicts set note = 'reviewed' where id = '00000000-0000-4000-8000-0000000d0009'$$,
  'owner: re-saving the conflict while the item is public');
reset role;
select set_config('request.jwt.claims', '', true);
select rls_test.act_as('anon');
select is((select count(*)::int from public.conflicts
           where item_id = '00000000-0000-4000-8000-000000000009'), 1,
  'anon: conflict becomes visible only after the owner re-saves it while public');
reset role;
select set_config('request.jwt.claims', '', true);

select * from finish();
rollback;
