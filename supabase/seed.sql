-- =============================================================================
-- DEV SEED — FAKE DATA ONLY
-- =============================================================================
-- !!! NEVER load this file into staging or production. !!!
-- Every name, price, code and number below is invented ("تجريبي", "وهمي",
-- "*999#", "000 ...") and does NOT describe any real e&/Etisalat product.
-- `supabase db reset` loads it into the LOCAL database only ([db.seed] in
-- config.toml). Remote databases are never seeded by `supabase db push`
-- unless you pass --include-seed: don't.
--
-- The owner is NOT seeded (there is no auth user locally until you create
-- one). After creating a user in the local Studio (Authentication > Add user):
--   insert into public.app_owner (user_id) values ('<that user id>');
-- =============================================================================

insert into public.knowledge_sources (id, name, source_type, classification, url, lang) values
  ('5eed0000-0000-4000-8000-000000000001', '[FAKE] موقع رسمي تجريبي', 'official_site', 'public',  'https://example.test/fake-offers', 'ar'),
  ('5eed0000-0000-4000-8000-000000000002', '[FAKE] ملاحظة شخصية',     'personal_experience', 'private', null, 'ar');

insert into public.knowledge_items (id, type, classification, slug, title_ar, title_en, tags, priority) values
  ('5eed0000-0000-4000-8000-0000000000a1', 'package',        'public',  'fake-package-1',  'باقة تجريبية ١',     'Fake package 1', array['تجريبي','dev'], 2),
  ('5eed0000-0000-4000-8000-0000000000a2', 'package',        'public',  'fake-package-2',  'باقة تجريبية منتهية', 'Fake expired package', array['تجريبي'], 0),
  ('5eed0000-0000-4000-8000-0000000000a3', 'contact_number', 'public',  'fake-hotline',    'خط ساخن وهمي',       'Fake hotline', array['تجريبي'], 1),
  ('5eed0000-0000-4000-8000-0000000000a4', 'service_code',   'public',  'fake-balance',    'كود رصيد وهمي',      'Fake balance code', array['تجريبي'], 1),
  ('5eed0000-0000-4000-8000-0000000000a5', 'glossary_term',  'generic', 'fake-term',       'مصطلح تجريبي',       'Fake term', '{}', 0),
  ('5eed0000-0000-4000-8000-0000000000a6', 'faq',            'public',  'fake-faq',        'سؤال شائع تجريبي',   'Fake FAQ', '{}', 0),
  ('5eed0000-0000-4000-8000-0000000000a7', 'article',        'public',  'fake-draft',      'مقال تجريبي (مسودة)', 'Fake draft', '{}', 0),
  ('5eed0000-0000-4000-8000-0000000000a8', 'private_note',   'private', 'fake-private',    'ملاحظة خاصة تجريبية', 'Fake private note', '{}', 0);

insert into public.knowledge_versions (id, item_id, title_ar, title_en, summary_ar, body_ar, data, valid_from, valid_until, review_due_at, verified_at) values
  ('5eed0000-0000-4000-8000-0000000001a1', '5eed0000-0000-4000-8000-0000000000a1', 'باقة تجريبية ١', 'Fake package 1',
   'باقة وهمية لاختبار الواجهة', 'كل الأرقام هنا وهمية.',
   '{"price":1.00,"price_tax_basis":"unknown","currency":"EGP","validity_days":30,"subscribe_code":"*999#","line_type":"prepaid"}',
   current_date - 10, null, current_date + 80, now()),
  ('5eed0000-0000-4000-8000-0000000001a2', '5eed0000-0000-4000-8000-0000000000a2', 'باقة تجريبية منتهية', 'Fake expired package',
   'باقة وهمية انتهت صلاحيتها', 'لاختبار شارة "منتهي".',
   '{"price":2.00,"price_tax_basis":"incl_vat","currency":"EGP","validity_days":7,"subscribe_code":"*998#"}',
   date '2000-01-01', date '2000-02-01', null, null),
  ('5eed0000-0000-4000-8000-0000000001a3', '5eed0000-0000-4000-8000-0000000000a3', 'خط ساخن وهمي', 'Fake hotline',
   'رقم وهمي للاختبار', null,
   '{"service":"خدمة عملاء وهمية","numbers":[{"number":"000 999","from_network":"own","hours":"24/7"},{"number":"000 998 000","from_network":"landline","hours":"9-17"}]}',
   null, null, current_date - 1, null),
  ('5eed0000-0000-4000-8000-0000000001a4', '5eed0000-0000-4000-8000-0000000000a4', 'كود رصيد وهمي', 'Fake balance code',
   null, null, '{"code":"*٩٠٠#","purpose":"معرفة الرصيد (وهمي)"}', null, null, null, null),
  ('5eed0000-0000-4000-8000-0000000001a5', '5eed0000-0000-4000-8000-0000000000a5', 'مصطلح تجريبي', 'Fake term',
   'تعريف وهمي', 'نص تعريف وهمي لمصطلح عام.', '{}', null, null, null, null),
  ('5eed0000-0000-4000-8000-0000000001a6', '5eed0000-0000-4000-8000-0000000000a6', 'سؤال شائع تجريبي', 'Fake FAQ',
   null, 'س: سؤال وهمي؟ ج: إجابة وهمية.', '{}', null, null, null, null),
  ('5eed0000-0000-4000-8000-0000000001a7', '5eed0000-0000-4000-8000-0000000000a7', 'مقال تجريبي (مسودة)', 'Fake draft',
   null, 'مسودة لم تنشر.', '{}', null, null, null, null),
  ('5eed0000-0000-4000-8000-0000000001a8', '5eed0000-0000-4000-8000-0000000000a8', 'ملاحظة خاصة تجريبية', 'Fake private note',
   null, 'يجب ألا تظهر أبدًا لغير المالك.', '{"codes":[{"code":"*000#","purpose":"كود خاص وهمي"}]}', null, null, null, null);

-- publish everything except the draft
update public.knowledge_items i
   set status = 'published', published_version_id = v.id
  from public.knowledge_versions v
 where v.item_id = i.id
   and i.id <> '5eed0000-0000-4000-8000-0000000000a7';

insert into public.citations (version_id, source_id, field_path, source_url, source_lang, accessed_at, verification_state) values
  ('5eed0000-0000-4000-8000-0000000001a1', '5eed0000-0000-4000-8000-000000000001', '/price', 'https://example.test/fake-offers', 'ar', now(), 'verified_official'),
  ('5eed0000-0000-4000-8000-0000000001a1', '5eed0000-0000-4000-8000-000000000001', '/subscribe_code', 'https://example.test/fake-offers', 'ar', now(), 'verified_official'),
  ('5eed0000-0000-4000-8000-0000000001a3', '5eed0000-0000-4000-8000-000000000001', '/numbers/0/number', 'https://example.test/fake-offers', 'ar', now(), 'regulator_only'),
  ('5eed0000-0000-4000-8000-0000000001a8', '5eed0000-0000-4000-8000-000000000002', '/', null, 'ar', now(), 'unverified');

insert into public.conflicts (item_id, field_path, value_a, source_a, value_b, note) values
  ('5eed0000-0000-4000-8000-0000000000a3', '/numbers/1/hours', '9-17', '5eed0000-0000-4000-8000-000000000001', '10-18', '[FAKE] تعارض تجريبي');

insert into public.knowledge_relations (from_item, to_item, relation_type) values
  ('5eed0000-0000-4000-8000-0000000000a1', '5eed0000-0000-4000-8000-0000000000a4', 'uses_code'),
  ('5eed0000-0000-4000-8000-0000000000a3', '5eed0000-0000-4000-8000-0000000000a1', 'contact_for');

insert into public.synonyms (term, variants) values
  ('باقة', array['بكدج', 'باكدج', 'package']),
  ('رصيد', array['شحن', 'كارت', 'كرت']),
  ('رقم',  array['نمرة']),
  ('انترنت', array['نت', 'داتا', 'internet', 'data']);
