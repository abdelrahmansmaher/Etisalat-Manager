-- pgTAP: public.normalize_ar parity with the Dart normalizer.
-- The 50 "fixture" assertions below are GENERATED 1:1 from
-- test/core/search/fixtures/normalizer_cases.json (inputs/expected written as
-- U&'' escapes so invisible characters survive editors). Regenerate them
-- whenever that fixture changes (see docs/dev/database.md).
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

select is(public.normalize_ar(U&''), U&'', 'normalize_ar fixture: empty');
select is(public.normalize_ar(U&' \0009\000A \00A0 '), U&'', 'normalize_ar fixture: whitespace only');
select is(public.normalize_ar(U&'\0623\062D\0645\062F'), U&'\0627\062D\0645\062F', 'normalize_ar fixture: alef hamza above');
select is(public.normalize_ar(U&'\0625\0644\063A\0627\0621'), U&'\0627\0644\063A\0627\0621', 'normalize_ar fixture: alef hamza below');
select is(public.normalize_ar(U&'\0622\062E\0631'), U&'\0627\062E\0631', 'normalize_ar fixture: alef madda');
select is(public.normalize_ar(U&'\0671\0644\0627\0634\062A\0631\0627\0643'), U&'\0627\0644\0627\0634\062A\0631\0627\0643', 'normalize_ar fixture: alef wasla');
select is(public.normalize_ar(U&'\0628\0627\0642\0629'), U&'\0628\0627\0642\0647', 'normalize_ar fixture: teh marbuta');
select is(public.normalize_ar(U&'\0641\0627\062A\0648\0631\0629 \0627\0644\0634\0647\0631'), U&'\0641\0627\062A\0648\0631\0647 \0627\0644\0634\0647\0631', 'normalize_ar fixture: teh marbuta plural phrase');
select is(public.normalize_ar(U&'\0645\0633\062A\0648\0649'), U&'\0645\0633\062A\0648\064A', 'normalize_ar fixture: alef maqsura');
select is(public.normalize_ar(U&'\06CC'), U&'\064A', 'normalize_ar fixture: farsi yeh');
select is(public.normalize_ar(U&'\06A9\0627\0631\062A'), U&'\0643\0627\0631\062A', 'normalize_ar fixture: farsi keheh');
select is(public.normalize_ar(U&'\0645\0633\0624\0648\0644'), U&'\0645\0633\0648\0648\0644', 'normalize_ar fixture: waw hamza');
select is(public.normalize_ar(U&'\0631\0633\0627\0626\0644'), U&'\0631\0633\0627\064A\0644', 'normalize_ar fixture: yeh hamza');
select is(public.normalize_ar(U&'\0645\0627\0621 \0633\0645\0627\0621'), U&'\0645\0627\0621 \0633\0645\0627\0621', 'normalize_ar fixture: standalone hamza kept');
select is(public.normalize_ar(U&'\0627\0634\0652\062A\0650\0631\064E\0627\0643\064C'), U&'\0627\0634\062A\0631\0627\0643', 'normalize_ar fixture: tashkeel');
select is(public.normalize_ar(U&'\0645\064F\062D\064E\0645\064E\0651\062F\064C \0631\064E\0635\0650\064A\062F\064B\0627'), U&'\0645\062D\0645\062F \0631\0635\064A\062F\0627', 'normalize_ar fixture: shadda and tanween');
select is(public.normalize_ar(U&'\0647\0670\0630\0627'), U&'\0647\0630\0627', 'normalize_ar fixture: dagger alef');
select is(public.normalize_ar(U&'\0643\0644\0645\0629\06D6'), U&'\0643\0644\0645\0647', 'normalize_ar fixture: quranic marks');
select is(public.normalize_ar(U&'\0631\0635\0640\0640\0640\064A\062F'), U&'\0631\0635\064A\062F', 'normalize_ar fixture: tatweel');
select is(public.normalize_ar(U&'\0660\0661\0662\0663\0664\0665\0666\0667\0668\0669'), U&'0123456789', 'normalize_ar fixture: arabic-indic digits');
select is(public.normalize_ar(U&'\06F0\06F1\06F2\06F3\06F4\06F5\06F6\06F7\06F8\06F9'), U&'0123456789', 'normalize_ar fixture: persian digits');
select is(public.normalize_ar(U&'*\0669\0669\0669#'), U&'*999#', 'normalize_ar fixture: arabic digits in ussd');
select is(public.normalize_ar(U&'\0646\0639\0645\060C \0644\0627\061B \0645\0627\0630\0627\061F'), U&'\0646\0639\0645, \0644\0627; \0645\0627\0630\0627?', 'normalize_ar fixture: arabic punctuation');
select is(public.normalize_ar(U&'SIM Card'), U&'sim card', 'normalize_ar fixture: latin lowercase');
select is(public.normalize_ar(U&'\0628\0627\0642\0629 DATA \0661\0660 GB'), U&'\0628\0627\0642\0647 data 10 gb', 'normalize_ar fixture: mixed ar en');
select is(public.normalize_ar(U&'  \0631\0635\064A\062F \0009\000A  \0627\0644\062E\0637  '), U&'\0631\0635\064A\062F \0627\0644\062E\0637', 'normalize_ar fixture: collapse whitespace');
select is(public.normalize_ar(U&'\0631\0635\064A\062F\00A0\0627\0644\062E\0637'), U&'\0631\0635\064A\062F \0627\0644\062E\0637', 'normalize_ar fixture: nbsp');
select is(public.normalize_ar(U&'\0631\200C\0635\200D\064A\062F\200B'), U&'\0631\0635\064A\062F', 'normalize_ar fixture: zero width removed');
select is(public.normalize_ar(U&'\200F*999#\200E'), U&'*999#', 'normalize_ar fixture: bidi marks removed');
select is(public.normalize_ar(U&'\202B\0646\062A\202C \2067data\2069'), U&'\0646\062A data', 'normalize_ar fixture: bidi embeddings removed');
select is(public.normalize_ar(U&'\FEFF\0631\0635\064A\062F'), U&'\0631\0635\064A\062F', 'normalize_ar fixture: bom removed');
select is(public.normalize_ar(U&'\0639\0627\0627\0627\0627\062C\0644'), U&'\0639\0627\062C\0644', 'normalize_ar fixture: elongation collapsed');
select is(public.normalize_ar(U&'\0647\0647\0647\0647\0647'), U&'\0647', 'normalize_ar fixture: elongation of three');
select is(public.normalize_ar(U&'\0627\0644\0644\0647 \0645\062F\062F'), U&'\0627\0644\0644\0647 \0645\062F\062F', 'normalize_ar fixture: double letter kept');
select is(public.normalize_ar(U&'\0627\0623\0625\0622'), U&'\0627', 'normalize_ar fixture: elongation after folding');
select is(public.normalize_ar(U&'\064A\064E\0627\0627\0627\0627'), U&'\064A\0627', 'normalize_ar fixture: elongation through tashkeel');
select is(public.normalize_ar(U&'10000'), U&'10000', 'normalize_ar fixture: digits never collapsed');
select is(public.normalize_ar(U&'goooal'), U&'goooal', 'normalize_ar fixture: latin never collapsed');
select is(public.normalize_ar(U&'\0627\0637\0644\0628 *999*1#'), U&'\0627\0637\0644\0628 *999*1#', 'normalize_ar fixture: ussd symbols kept');
select is(public.normalize_ar(U&'+20 100-000-0000'), U&'+20 100-000-0000', 'normalize_ar fixture: plus and dash kept');
select is(public.normalize_ar(U&'ba2a 3arabi'), U&'ba2a 3arabi', 'normalize_ar fixture: franco digits not converted');
select is(public.normalize_ar(U&'E\0026 Money'), U&'e\0026 money', 'normalize_ar fixture: brand ampersand kept');
select is(public.normalize_ar(U&'\FEFB\062A\0635\0627\0644'), U&'\0644\0627\062A\0635\0627\0644', 'normalize_ar fixture: lam alef ligature');
select is(public.normalize_ar(U&'\FEF7\0643\062B\0631'), U&'\0644\0627\0643\062B\0631', 'normalize_ar fixture: lam alef hamza ligature');
select is(public.normalize_ar(U&'\FE91\FE8E\FED7\FE94'), U&'\0628\0627\0642\0647', 'normalize_ar fixture: presentation forms letters');
select is(public.normalize_ar(U&'\FF0A\FF19\FF19\FF19\FF03'), U&'*999#', 'normalize_ar fixture: fullwidth ussd');
select is(public.normalize_ar(U&'\FF33\FF29\FF2D'), U&'sim', 'normalize_ar fixture: fullwidth latin');
select is(public.normalize_ar(U&'\0627\0654\062D\0645\062F'), U&'\0627\062D\0645\062F', 'normalize_ar fixture: decomposed hamza');
select is(public.normalize_ar(U&'\0665\0660 \062C\0646\064A\0647\064B\0627'), U&'50 \062C\0646\064A\0647\0627', 'normalize_ar fixture: price text');
select is(public.normalize_ar(U&'1.5 \062C\064A\062C\0627'), U&'1.5 \062C\064A\062C\0627', 'normalize_ar fixture: decimal kept');

-- extra properties
select is(public.normalize_ar(null), null, 'normalize_ar(NULL) is NULL (STRICT)');
select is(public.normalize_ar(public.normalize_ar(U&'\0625\0650\0634\0652\062A\0631\0627\0627\0627\0643 \0661\0662\0663 \0629')),
          public.normalize_ar(U&'\0625\0650\0634\0652\062A\0631\0627\0627\0627\0643 \0661\0662\0663 \0629'),
          'normalize_ar is idempotent');
select is(public.normalize_ar(U&'\0660\0661\0662'), '012',
          'Arabic-Indic digits are converted, not dropped as tashkeel');
select is(public.normalize_code(U&'* \0669\0669\0669 #'), '*999#',
          'normalize_code keeps digits * # only');
select is(public.normalize_number(U&'+20 \0661\0660\0660-123'), '20100123',
          'normalize_number keeps digits only');

select * from finish();
rollback;
