-- =============================================================================
-- 0001 — extensions, helper schema, Arabic normalizer, single owner
-- =============================================================================
-- Personal knowledge app (owner decisions v0.2, docs/discovery/00-foundation.md):
--   * readers use the anon key, no login;
--   * exactly ONE owner account (row in public.app_owner) writes everything;
--   * workflow draft -> published -> archived;
--   * no employees/roles/branches tables, no per-user progress on the server.
-- =============================================================================

-- pg_trgm: typo tolerance + partial code matching. Installed in the
-- Supabase-standard "extensions" schema; always referenced schema-qualified.
create extension if not exists pg_trgm with schema extensions;
-- No unaccent (our own normalizer is used), no pgcrypto (gen_random_uuid() is
-- built into PostgreSQL 13+).

-- Internal helper schema. NOT exposed through PostgREST (only "public" and
-- "graphql_public" are in [api].schemas). anon/authenticated get USAGE only so
-- that RLS policies can call the few helper functions we explicitly grant.
create schema if not exists app;
revoke all on schema app from public;
grant usage on schema app to anon, authenticated, service_role;

-- -----------------------------------------------------------------------------
-- public.normalize_ar(text)
-- -----------------------------------------------------------------------------
-- Byte-for-byte mirror of lib/core/search/arabic_normalizer.dart (rules 1-14)
-- and verified against test/core/search/fixtures/normalizer_cases.json.
-- Locale-independent on purpose: lower() is NOT used (its result depends on
-- the database ctype); the lowercase table below is the exact one-to-one set
-- the Dart side uses (A-Z, U+00C0-024F, Greek U+0370-03FF, Cyrillic
-- U+0400-052F, U+1E00-1EFF).
--
-- Pipeline:
--   a) multi-character compatibility forms: lam-alef ligatures U+FEF5-FEFC
--      -> 'لا', U+FDF2 -> 'الله', U+FDFC -> 'ريال';
--   b) ONE translate() that does every single-character mapping:
--        Presentation Forms-B letters (U+FE80-FEF4) -> folded base letters,
--        spacing tashkeel forms U+FE70..FE7E (even) -> space, odd -> dropped,
--        selected Presentation Forms-A (alef wasla, keheh, farsi yeh),
--        fullwidth ASCII U+FF01-FF5E -> ASCII (lowercased),
--        whitespace set -> ' ',
--        invisible chars U+200B-200F, U+202A-202E, U+2066-2069, U+FEFF -> dropped,
--        tashkeel U+064B-065F, U+0670, Quranic U+06D6-06ED, tatweel U+0640 -> dropped
--          (two separate ranges: U+0660-0669 digits are NOT in the drop set),
--        أ إ آ ٱ -> ا ; ى ی -> ي ; ة -> ه ; ؤ -> و ; ئ -> ي ; ک -> ك
--          (standalone hamza ء is kept),
--        Arabic-Indic / Persian digits -> 0-9,
--        ، ؛ ؟ -> , ; ?   (* # + & . - % are kept),
--        Latin/Greek/Cyrillic uppercase -> lowercase;
--      translate() deletes every "from" character that has no counterpart in
--      "to"; the drop set is therefore appended at the END of "from".
--   c) runs of 3+ identical Arabic letters (U+0621-064A, after folding) -> one;
--   d) collapse runs of spaces, trim.
-- The translate tables are GENERATED from the Dart table (do not hand-edit;
-- see docs/dev/database.md "Normalizer parity").
create or replace function public.normalize_ar(input text)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $fn$
  select pg_catalog.btrim(
    pg_catalog.regexp_replace(
      pg_catalog.regexp_replace(
        pg_catalog.translate(
          pg_catalog.replace(
            pg_catalog.replace(
              pg_catalog.regexp_replace(input, U&'[\FEF5-\FEFC]', 'لا', 'g'),
              U&'\FDF2', 'الله'),
            U&'\FDFC', 'ريال'),
      U&'\0009\000A\000B\000C\000DABCDEFGHIJKLMNOPQRSTUVWXYZ\0085\00A0\00C0\00C1\00C2\00C3\00C4\00C5\00C6' ||
      U&'\00C7\00C8\00C9\00CA\00CB\00CC\00CD\00CE\00CF\00D0\00D1\00D2\00D3\00D4\00D5\00D6\00D8\00D9\00DA\00DB\00DC\00DD\00DE\0100\0102\0104\0106\0108\010A\010C\010E\0110\0112\0114\0116\0118\011A\011C\011E\0120' ||
      U&'\0122\0124\0126\0128\012A\012C\012E\0132\0134\0136\0139\013B\013D\013F\0141\0143\0145\0147\014A\014C\014E\0150\0152\0154\0156\0158\015A\015C\015E\0160\0162\0164\0166\0168\016A\016C\016E\0170\0172\0174' ||
      U&'\0176\0178\0179\017B\017D\0181\0182\0184\0186\0187\0189\018A\018B\018E\018F\0190\0191\0193\0194\0196\0197\0198\019C\019D\019F\01A0\01A2\01A4\01A6\01A7\01A9\01AC\01AE\01AF\01B1\01B2\01B3\01B5\01B7\01B8' ||
      U&'\01BC\01C4\01C5\01C7\01C8\01CA\01CB\01CD\01CF\01D1\01D3\01D5\01D7\01D9\01DB\01DE\01E0\01E2\01E4\01E6\01E8\01EA\01EC\01EE\01F1\01F2\01F4\01F6\01F7\01F8\01FA\01FC\01FE\0200\0202\0204\0206\0208\020A\020C' ||
      U&'\020E\0210\0212\0214\0216\0218\021A\021C\021E\0220\0222\0224\0226\0228\022A\022C\022E\0230\0232\023A\023B\023D\023E\0241\0243\0244\0245\0246\0248\024A\024C\024E\0370\0372\0376\037F\0386\0388\0389\038A' ||
      U&'\038C\038E\038F\0391\0392\0393\0394\0395\0396\0397\0398\0399\039A\039B\039C\039D\039E\039F\03A0\03A1\03A3\03A4\03A5\03A6\03A7\03A8\03A9\03AA\03AB\03CF\03D8\03DA\03DC\03DE\03E0\03E2\03E4\03E6\03E8\03EA' ||
      U&'\03EC\03EE\03F4\03F7\03F9\03FA\03FD\03FE\03FF\0400\0401\0402\0403\0404\0405\0406\0407\0408\0409\040A\040B\040C\040D\040E\040F\0410\0411\0412\0413\0414\0415\0416\0417\0418\0419\041A\041B\041C\041D\041E' ||
      U&'\041F\0420\0421\0422\0423\0424\0425\0426\0427\0428\0429\042A\042B\042C\042D\042E\042F\0460\0462\0464\0466\0468\046A\046C\046E\0470\0472\0474\0476\0478\047A\047C\047E\0480\048A\048C\048E\0490\0492\0494' ||
      U&'\0496\0498\049A\049C\049E\04A0\04A2\04A4\04A6\04A8\04AA\04AC\04AE\04B0\04B2\04B4\04B6\04B8\04BA\04BC\04BE\04C0\04C1\04C3\04C5\04C7\04C9\04CB\04CD\04D0\04D2\04D4\04D6\04D8\04DA\04DC\04DE\04E0\04E2\04E4' ||
      U&'\04E6\04E8\04EA\04EC\04EE\04F0\04F2\04F4\04F6\04F8\04FA\04FC\04FE\0500\0502\0504\0506\0508\050A\050C\050E\0510\0512\0514\0516\0518\051A\051C\051E\0520\0522\0524\0526\0528\052A\052C\052E\060C\061B\061F' ||
      U&'\0622\0623\0624\0625\0626\0629\0649\0660\0661\0662\0663\0664\0665\0666\0667\0668\0669\0671\06A9\06CC\06F0\06F1\06F2\06F3\06F4\06F5\06F6\06F7\06F8\06F9\1680\1E00\1E02\1E04\1E06\1E08\1E0A\1E0C\1E0E\1E10' ||
      U&'\1E12\1E14\1E16\1E18\1E1A\1E1C\1E1E\1E20\1E22\1E24\1E26\1E28\1E2A\1E2C\1E2E\1E30\1E32\1E34\1E36\1E38\1E3A\1E3C\1E3E\1E40\1E42\1E44\1E46\1E48\1E4A\1E4C\1E4E\1E50\1E52\1E54\1E56\1E58\1E5A\1E5C\1E5E\1E60' ||
      U&'\1E62\1E64\1E66\1E68\1E6A\1E6C\1E6E\1E70\1E72\1E74\1E76\1E78\1E7A\1E7C\1E7E\1E80\1E82\1E84\1E86\1E88\1E8A\1E8C\1E8E\1E90\1E92\1E94\1E9E\1EA0\1EA2\1EA4\1EA6\1EA8\1EAA\1EAC\1EAE\1EB0\1EB2\1EB4\1EB6\1EB8' ||
      U&'\1EBA\1EBC\1EBE\1EC0\1EC2\1EC4\1EC6\1EC8\1ECA\1ECC\1ECE\1ED0\1ED2\1ED4\1ED6\1ED8\1EDA\1EDC\1EDE\1EE0\1EE2\1EE4\1EE6\1EE8\1EEA\1EEC\1EEE\1EF0\1EF2\1EF4\1EF6\1EF8\1EFA\1EFC\1EFE\2000\2001\2002\2003\2004' ||
      U&'\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000\FB50\FB51\FB8E\FB8F\FB90\FB91\FBFC\FBFD\FBFE\FBFF\FE70\FE72\FE74\FE76\FE78\FE7A\FE7C\FE7E\FE80\FE81\FE82\FE83\FE84\FE85\FE86\FE87\FE88\FE89\FE8A' ||
      U&'\FE8B\FE8C\FE8D\FE8E\FE8F\FE90\FE91\FE92\FE93\FE94\FE95\FE96\FE97\FE98\FE99\FE9A\FE9B\FE9C\FE9D\FE9E\FE9F\FEA0\FEA1\FEA2\FEA3\FEA4\FEA5\FEA6\FEA7\FEA8\FEA9\FEAA\FEAB\FEAC\FEAD\FEAE\FEAF\FEB0\FEB1\FEB2' ||
      U&'\FEB3\FEB4\FEB5\FEB6\FEB7\FEB8\FEB9\FEBA\FEBB\FEBC\FEBD\FEBE\FEBF\FEC0\FEC1\FEC2\FEC3\FEC4\FEC5\FEC6\FEC7\FEC8\FEC9\FECA\FECB\FECC\FECD\FECE\FECF\FED0\FED1\FED2\FED3\FED4\FED5\FED6\FED7\FED8\FED9\FEDA' ||
      U&'\FEDB\FEDC\FEDD\FEDE\FEDF\FEE0\FEE1\FEE2\FEE3\FEE4\FEE5\FEE6\FEE7\FEE8\FEE9\FEEA\FEEB\FEEC\FEED\FEEE\FEEF\FEF0\FEF1\FEF2\FEF3\FEF4\FF01\FF02\FF03\FF04\FF05\FF06\FF07\FF08\FF09\FF0A\FF0B\FF0C\FF0D\FF0E' ||
      U&'\FF0F\FF10\FF11\FF12\FF13\FF14\FF15\FF16\FF17\FF18\FF19\FF1A\FF1B\FF1C\FF1D\FF1E\FF1F\FF20\FF21\FF22\FF23\FF24\FF25\FF26\FF27\FF28\FF29\FF2A\FF2B\FF2C\FF2D\FF2E\FF2F\FF30\FF31\FF32\FF33\FF34\FF35\FF36' ||
      U&'\FF37\FF38\FF39\FF3A\FF3B\FF3C\FF3D\FF3E\FF3F\FF40\FF41\FF42\FF43\FF44\FF45\FF46\FF47\FF48\FF49\FF4A\FF4B\FF4C\FF4D\FF4E\FF4F\FF50\FF51\FF52\FF53\FF54\FF55\FF56\FF57\FF58\FF59\FF5A\FF5B\FF5C\FF5D\FF5E' ||
      U&'\0640\064B\064C\064D\064E\064F\0650\0651\0652\0653\0654\0655\0656\0657\0658\0659\065A\065B\065C\065D\065E\065F\0670\06D6\06D7\06D8\06D9\06DA\06DB\06DC\06DD\06DE\06DF\06E0\06E1\06E2\06E3\06E4\06E5\06E6' ||
      U&'\06E7\06E8\06E9\06EA\06EB\06EC\06ED\200B\200C\200D\200E\200F\202A\202B\202C\202D\202E\2066\2067\2068\2069\FE71\FE77\FE79\FE7B\FE7D\FE7F\FEFF',
      U&'     abcdefghijklmnopqrstuvwxyz  \00E0\00E1\00E2\00E3\00E4\00E5\00E6' ||
      U&'\00E7\00E8\00E9\00EA\00EB\00EC\00ED\00EE\00EF\00F0\00F1\00F2\00F3\00F4\00F5\00F6\00F8\00F9\00FA\00FB\00FC\00FD\00FE\0101\0103\0105\0107\0109\010B\010D\010F\0111\0113\0115\0117\0119\011B\011D\011F\0121' ||
      U&'\0123\0125\0127\0129\012B\012D\012F\0133\0135\0137\013A\013C\013E\0140\0142\0144\0146\0148\014B\014D\014F\0151\0153\0155\0157\0159\015B\015D\015F\0161\0163\0165\0167\0169\016B\016D\016F\0171\0173\0175' ||
      U&'\0177\00FF\017A\017C\017E\0253\0183\0185\0254\0188\0256\0257\018C\01DD\0259\025B\0192\0260\0263\0269\0268\0199\026F\0272\0275\01A1\01A3\01A5\0280\01A8\0283\01AD\0288\01B0\028A\028B\01B4\01B6\0292\01B9' ||
      U&'\01BD\01C6\01C6\01C9\01C9\01CC\01CC\01CE\01D0\01D2\01D4\01D6\01D8\01DA\01DC\01DF\01E1\01E3\01E5\01E7\01E9\01EB\01ED\01EF\01F3\01F3\01F5\0195\01BF\01F9\01FB\01FD\01FF\0201\0203\0205\0207\0209\020B\020D' ||
      U&'\020F\0211\0213\0215\0217\0219\021B\021D\021F\019E\0223\0225\0227\0229\022B\022D\022F\0231\0233\2C65\023C\019A\2C66\0242\0180\0289\028C\0247\0249\024B\024D\024F\0371\0373\0377\03F3\03AC\03AD\03AE\03AF' ||
      U&'\03CC\03CD\03CE\03B1\03B2\03B3\03B4\03B5\03B6\03B7\03B8\03B9\03BA\03BB\03BC\03BD\03BE\03BF\03C0\03C1\03C3\03C4\03C5\03C6\03C7\03C8\03C9\03CA\03CB\03D7\03D9\03DB\03DD\03DF\03E1\03E3\03E5\03E7\03E9\03EB' ||
      U&'\03ED\03EF\03B8\03F8\03F2\03FB\037B\037C\037D\0450\0451\0452\0453\0454\0455\0456\0457\0458\0459\045A\045B\045C\045D\045E\045F\0430\0431\0432\0433\0434\0435\0436\0437\0438\0439\043A\043B\043C\043D\043E' ||
      U&'\043F\0440\0441\0442\0443\0444\0445\0446\0447\0448\0449\044A\044B\044C\044D\044E\044F\0461\0463\0465\0467\0469\046B\046D\046F\0471\0473\0475\0477\0479\047B\047D\047F\0481\048B\048D\048F\0491\0493\0495' ||
      U&'\0497\0499\049B\049D\049F\04A1\04A3\04A5\04A7\04A9\04AB\04AD\04AF\04B1\04B3\04B5\04B7\04B9\04BB\04BD\04BF\04CF\04C2\04C4\04C6\04C8\04CA\04CC\04CE\04D1\04D3\04D5\04D7\04D9\04DB\04DD\04DF\04E1\04E3\04E5' ||
      U&'\04E7\04E9\04EB\04ED\04EF\04F1\04F3\04F5\04F7\04F9\04FB\04FD\04FF\0501\0503\0505\0507\0509\050B\050D\050F\0511\0513\0515\0517\0519\051B\051D\051F\0521\0523\0525\0527\0529\052B\052D\052F,;?' ||
      U&'\0627\0627\0648\0627\064A\0647\064A0123456789\0627\0643\064A0123456789 \1E01\1E03\1E05\1E07\1E09\1E0B\1E0D\1E0F\1E11' ||
      U&'\1E13\1E15\1E17\1E19\1E1B\1E1D\1E1F\1E21\1E23\1E25\1E27\1E29\1E2B\1E2D\1E2F\1E31\1E33\1E35\1E37\1E39\1E3B\1E3D\1E3F\1E41\1E43\1E45\1E47\1E49\1E4B\1E4D\1E4F\1E51\1E53\1E55\1E57\1E59\1E5B\1E5D\1E5F\1E61' ||
      U&'\1E63\1E65\1E67\1E69\1E6B\1E6D\1E6F\1E71\1E73\1E75\1E77\1E79\1E7B\1E7D\1E7F\1E81\1E83\1E85\1E87\1E89\1E8B\1E8D\1E8F\1E91\1E93\1E95\00DF\1EA1\1EA3\1EA5\1EA7\1EA9\1EAB\1EAD\1EAF\1EB1\1EB3\1EB5\1EB7\1EB9' ||
      U&'\1EBB\1EBD\1EBF\1EC1\1EC3\1EC5\1EC7\1EC9\1ECB\1ECD\1ECF\1ED1\1ED3\1ED5\1ED7\1ED9\1EDB\1EDD\1EDF\1EE1\1EE3\1EE5\1EE7\1EE9\1EEB\1EED\1EEF\1EF1\1EF3\1EF5\1EF7\1EF9\1EFB\1EFD\1EFF     ' ||
      U&'           \0627\0627\0643\0643\0643\0643\064A\064A\064A\064A        \0621\0627\0627\0627\0627\0648\0648\0627\0627\064A\064A' ||
      U&'\064A\064A\0627\0627\0628\0628\0628\0628\0647\0647\062A\062A\062A\062A\062B\062B\062B\062B\062C\062C\062C\062C\062D\062D\062D\062D\062E\062E\062E\062E\062F\062F\0630\0630\0631\0631\0632\0632\0633\0633' ||
      U&'\0633\0633\0634\0634\0634\0634\0635\0635\0635\0635\0636\0636\0636\0636\0637\0637\0637\0637\0638\0638\0638\0638\0639\0639\0639\0639\063A\063A\063A\063A\0641\0641\0641\0641\0642\0642\0642\0642\0643\0643' ||
      U&'\0643\0643\0644\0644\0644\0644\0645\0645\0645\0645\0646\0646\0646\0646\0647\0647\0647\0647\0648\0648\064A\064A\064A\064A\064A\064A\0021\0022#\0024\0025\0026\0027\0028\0029*+,-.' ||
      U&'\002F0123456789\003A;\003C\003D\003E?\0040abcdefghijklmnopqrstuv' ||
      U&'wxyz\005B\005C\005D\005E\005F\0060abcdefghijklmnopqrstuvwxyz\007B\007C\007D\007E'
        ),
        '([ء-ي])\1\1+', '\1', 'g'),
      ' +', ' ', 'g'),
    ' ');
$fn$;

comment on function public.normalize_ar(text) is
  'Search normalizer. MUST stay identical to lib/core/search/arabic_normalizer.dart; '
  'both are tested against test/core/search/fixtures/normalizer_cases.json.';

-- USSD/service code key: normalized, then keep only digits * # +
-- ('* ١٢٣ #' -> '*123#').
create or replace function public.normalize_code(input text)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $fn$
  select pg_catalog.regexp_replace(public.normalize_ar(input), '[^0-9*#+]', '', 'g');
$fn$;

-- Phone number key: digits only ('+20 100-123' -> '20100123', '١٦٠٠٠' -> '16000').
-- No country-code rewriting (documented in docs/dev/database.md).
create or replace function public.normalize_number(input text)
returns text
language sql
immutable
strict
parallel safe
set search_path = ''
as $fn$
  select pg_catalog.regexp_replace(public.normalize_ar(input), '[^0-9]', '', 'g');
$fn$;

-- -----------------------------------------------------------------------------
-- Single owner
-- -----------------------------------------------------------------------------
-- Exactly one row (singleton PK). Set it once from the SQL editor:
--   insert into public.app_owner (user_id) values ('<auth.users.id of the owner>');
create table public.app_owner (
  singleton  boolean primary key default true check (singleton),
  user_id    uuid not null unique references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
comment on table public.app_owner is
  'The ONE account allowed to write. Single row. Managed only from the SQL editor (no API write policy).';

-- SECURITY DEFINER so it can read app_owner regardless of the caller's RLS;
-- empty search_path + fully-qualified names prevent search_path hijacking.
create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select exists (
    select 1
    from public.app_owner o
    where o.user_id = (select auth.uid())
  );
$fn$;

comment on function public.is_owner() is
  'True only when the request JWT belongs to the single owner in public.app_owner.';
