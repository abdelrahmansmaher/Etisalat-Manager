-- =============================================================================
-- pgTAP: public.search() behaviour. FAKE fixtures only ("باقة تجريبية",
-- "*999#", "000 999 000") — never real prices, codes or numbers.
-- =============================================================================
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- -----------------------------------------------------------------------------
-- Fixtures (privileged role)
-- -----------------------------------------------------------------------------
insert into public.knowledge_items (id, type, classification, slug, title_ar, priority) values
  ('00000000-0000-4000-9000-000000000001', 'package',        'public',  'fake-test-package',    'باقة تجريبية', 0),
  ('00000000-0000-4000-9000-000000000002', 'package',        'public',  'fake-expired-package', 'باقة اختبار منتهية', 0),
  ('00000000-0000-4000-9000-000000000003', 'glossary_term',  'generic', 'fake-term',            'إشتراك وهمي', 0),
  ('00000000-0000-4000-9000-000000000004', 'contact_number', 'public',  'fake-contact',         'رقم خدمة تجريبي', 0),
  ('00000000-0000-4000-9000-000000000005', 'service_code',   'public',  'fake-balance-code',    'كود رصيد وهمي', 0);

insert into public.knowledge_versions (id, item_id, title_ar, summary_ar, body_ar, data, valid_until) values
  ('00000000-0000-4000-9000-0000000000a1', '00000000-0000-4000-9000-000000000001',
   'باقة تجريبية', 'باقة وهمية لأغراض الاختبار فقط', 'تفاصيل الباقة التجريبية',
   '{"price":0,"price_tax_basis":"unknown","currency":"EGP","validity_days":30,"subscribe_code":"*999#"}', null),
  ('00000000-0000-4000-9000-0000000000a2', '00000000-0000-4000-9000-000000000002',
   'باقة اختبار منتهية', 'باقة تجريبية قديمة', 'انتهت',
   '{"price":0,"price_tax_basis":"unknown","currency":"EGP","validity_days":7}', date '2000-01-02'),
  ('00000000-0000-4000-9000-0000000000a3', '00000000-0000-4000-9000-000000000003',
   'إشتراك وهمي', null, 'تعريف مصطلح وهمي', '{}', null),
  ('00000000-0000-4000-9000-0000000000a4', '00000000-0000-4000-9000-000000000004',
   'رقم خدمة تجريبي', null, null,
   '{"service":"خدمة تجريبية","numbers":[{"number":"000 999 000","from_network":"own"}]}', null),
  ('00000000-0000-4000-9000-0000000000a5', '00000000-0000-4000-9000-000000000005',
   'كود رصيد وهمي', null, null,
   '{"code":"*١٢٣٤#","purpose":"معرفة رصيد وهمي"}', null);

update public.knowledge_items i
   set status = 'published', published_version_id = v.id
  from public.knowledge_versions v
 where v.item_id = i.id
   and i.id::text like '00000000-0000-4000-9000-%';

insert into public.synonyms (term, variants) values ('بكدج', array['باقة', 'package']);

-- -----------------------------------------------------------------------------
-- Run as anon (what the app does)
-- -----------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"role":"anon"}', true);
set local role anon;

select ok(coalesce(array_length(extensions.show_trgm('باقه'), 1), 0) > 0,
  'pg_trgm extracts trigrams from Arabic text (database ctype is not plain C)');

select is((select count(*)::int from public.search('')), 0, 'empty query returns nothing');
select is((select count(*)::int from public.search('   ')), 0, 'blank query returns nothing');

-- exact code / number lookup
select is((select s.item_id from public.search('*999#') s limit 1),
  '00000000-0000-4000-9000-000000000001'::uuid, 'exact USSD code is pinned first');
select is((select s.item_id from public.search('* 999 #') s limit 1),
  '00000000-0000-4000-9000-000000000001'::uuid, 'code with spaces is pinned first');
select is((select s.item_id from public.search('٩٩٩') s limit 1),
  '00000000-0000-4000-9000-000000000001'::uuid, 'Arabic-Indic digits match the code (digit-only form)');
select is((select s.item_id from public.search('*1234#') s limit 1),
  '00000000-0000-4000-9000-000000000005'::uuid, 'code stored with Arabic digits matches Latin-digit query');
select is((select s.item_id from public.search('*١٢٣٤#') s limit 1),
  '00000000-0000-4000-9000-000000000005'::uuid, 'Arabic-digit query matches');
select is((select s.item_id from public.search('000-999-000') s limit 1),
  '00000000-0000-4000-9000-000000000004'::uuid, 'phone number with dashes matches normalized number');
select ok((select s.rank from public.search('*999#') s limit 1) >= 1000,
  'exact match carries the pin bonus');

-- normalization-insensitive text search
select ok(exists (select 1 from public.search('باقه تجريبيه') s
                  where s.item_id = '00000000-0000-4000-9000-000000000001'),
  'ta marbuta: "باقه تجريبيه" finds "باقة تجريبية"');
select ok(exists (select 1 from public.search('اشتراك وهمي') s
                  where s.item_id = '00000000-0000-4000-9000-000000000003'),
  'alef: "اشتراك" finds "إشتراك"');
select ok(exists (select 1 from public.search('إشْتِراك') s
                  where s.item_id = '00000000-0000-4000-9000-000000000003'),
  'tashkeel + hamza in the query are ignored');
select ok(exists (select 1 from public.search('باق') s
                  where s.item_id = '00000000-0000-4000-9000-000000000001'),
  'prefix matching on the last token');

-- typo tolerance (trigram)
select ok(exists (select 1 from public.search('تجربية') s
                  where s.item_id = '00000000-0000-4000-9000-000000000001'),
  'typo "تجربية" still finds "باقة تجريبية"');
select ok(exists (select 1 from public.search('وهمى رصيد كود') s
                  where s.item_id = '00000000-0000-4000-9000-000000000005'),
  'word order / alef maqsura variations still find the item');

-- synonyms
select ok(exists (select 1 from public.search('بكدج تجريبية') s
                  where s.item_id = '00000000-0000-4000-9000-000000000001'),
  'synonym "بكدج" expands to "باقه"');

-- ranking / demotion / filters / output
select ok(
  (select s.rank from public.search('باقة') s where s.item_id = '00000000-0000-4000-9000-000000000001')
  > (select s.rank from public.search('باقة') s where s.item_id = '00000000-0000-4000-9000-000000000002'),
  'expired item is ranked below an active one');
select is((select count(*)::int from public.search('باقة', array['glossary_term']) s where s.type = 'package'), 0,
  'filter_types excludes other types');
select is((select s.verification from public.search('*999#') s limit 1), 'unverified',
  'item without citations is flagged unverified');
select isnt((select s.snippet from public.search('باقة تجريبية') s
             where s.item_id = '00000000-0000-4000-9000-000000000001'), null,
  'snippet is returned');
select is((select s.valid_until from public.search('منتهية') s
           where s.item_id = '00000000-0000-4000-9000-000000000002'), date '2000-01-02',
  'valid_until is returned so the app can show the expired badge');
select ok((select count(*) from public.search('باقة', null, 1)) <= 1, 'lim is respected');

reset role;
select * from finish();
rollback;
