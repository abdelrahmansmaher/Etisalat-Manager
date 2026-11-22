# خريطة المعرفة ومصادرها — Employee Knowledge Hub لموظفي فروع e& مصر (اسم مؤقت)

> **⚠️ تحديث v0.2 (2026-11-22):** المالك قرر أن التطبيق **أداة شخصية بدون تسجيل دخول للقراءة، والمالك هو المحرر الوحيد**. أي شيء هنا عن الأدوار المتعددة، invite-only، الـ Pilot، لوحة المدرب، أو workflow المراجعة متعدد الأشخاص **مُلغى** — المرجع الملزم هو قسم «قرارات المالك» في [00-foundation.md](00-foundation.md).


> **الحالة:** مسودة اكتشاف (Discovery) — لا كود في هذه المرحلة.
> **تاريخ الوصول لكل المصادر المذكورة:** 2026-11-22 (ما لم يُذكر غير ذلك).
> **أعدّها:** Telecom Domain Researcher (بحث آلي عبر WebSearch/WebFetch + متصفح فعلي لعرض الصفحات المبنية بـ JavaScript).
> **تنبيه:** هذا تطبيق **غير رسمي** ومستقل. لا شيء في هذه الوثيقة صادر عن e& مصر أو معتمد منها. كل معلومة مذكورة كحقيقة هنا مُرفق بها مصدرها، وما لم نتحقق منه موجود في قسم "Missing / Unverified" وليس كحقيقة.

---

## 0. ملخص تنفيذي

- **النطاقات الرسمية الحية (2026-11-22):**
  - `https://www.eand.com.eg/portal/...` ← **الموقع الرسمي الفعلي للمحتوى** (Angular SPA، المحتوى يُرسم بالـ JavaScript).
  - `https://www.etisalat.eg/` ← حيّ لكنه صفحة وسيطة (stub) تحمّل `js/main.js` فقط؛ ويستضيف **المتجر** `https://www.etisalat.eg/eshop2/`.
  - `https://www.eand.com.eg/selfcare/index.html` ← بوابة الخدمة الذاتية (تتطلب تسجيل دخول — خارج نطاق الجمع).
  - `https://eandbusiness.com.eg/web/EBU-Portal/#/` ← بوابة الأعمال (مرتبطة من الموقع الرسمي؛ فحص `curl` على النطاق المجرد فشل بخطأ شهادة TLS).
- **العلامة التجارية غير مستقرة:** الموقع بالإنجليزية يستخدم الآن "etisalat Egypt" وبالعربية "اتصالات مصر"، مع بقايا "e&" في نص عربي واحد على الأقل، وحسابات سوشيال باسم `eandEgypt`. الصحافة (The National، 2026-10-06) تذكر أن **مجموعة** e& قررت العودة لاسم Etisalat. ← يحتاج قرارًا من المنتج بخصوص اسم المشروع (انظر قسم 7).
- **موقع المنظّم NTRA (`tra.gov.eg`) كان "تحت الصيانة" يوم 2026-11-22**؛ ملفات PDF القديمة التي ظهرت في البحث تُرجع 404. لم نستطع التحقق من أي قاعدة تنظيمية من مصدرها اليوم.
- **تم جرد 22 مصدرًا** (قسم 2)، و**التحقق من 15 حقيقة بذرية** (قسم 5) من صفحات رسمية معروضة فعليًا.
- **أكبر الفجوات:** H (إجراءات الفرع)، I (الأنظمة/Siebel)، J (Siebel Academy) لا يمكن بناؤها من مصادر عامة إطلاقًا؛ وفي C/D: المستندات المطلوبة، رسوم SIM swap، تواريخ بدء/انتهاء العروض، وأسعار El Kart غير منشورة بشكل كامل.

---

## 1. المنهجية وتسلسل المصادر وحالات التحقق

### 1.1 تسلسل الثقة (Source Hierarchy)

| المستوى | نوع المصدر (`source_type`) | أمثلة | الاستخدام |
|---|---|---|---|
| 1 | `official_site` | `eand.com.eg/portal/*`، نوافذ (modals) الموقع الرسمي، صفحة العقود | مصدر الحقيقة الأساسي للأسعار والأكواد والأرقام |
| 1 | `official_app` | My etisalat (App Store / Google Play)، etisalat money app | مكمّل؛ صعب الاستشهاد به (لا URL لكل شاشة) — يُوثّق بلقطة شاشة + رقم الإصدار |
| 1 | `official_internal` | مستندات داخلية **مُصرّح بها** من e& مصر (أدلة Siebel، إجراءات الفرع، SLAs) | المصدر **الوحيد** الممكن لـ H/I/J |
| 2 | `regulator` | NTRA: `tra.gov.eg`، `digital.tra.gov.eg`، `complaints.tra.gov.eg` | القواعد العامة (MNP، تسجيل الخطوط، حقوق المستخدم) |
| 3 | `press` | مواقع إخبارية موثوقة، بيانات صحفية | سياق وتواريخ إطلاق؛ **لا** تُستخدم كمصدر لسعر |
| 4 | `unofficial` | فيسبوك، منتديات، مدونات، ويكيبيديا | **"خيوط" (leads) فقط** — لا تُنشر كحقيقة أبدًا |
| — | `official_social` | صفحات e& مصر الرسمية على السوشيال | إعلانات عروض (leads قوية)؛ يجب تأكيدها من الموقع |

### 1.2 حالات التحقق (Verification States)

| الحالة | المعنى | يظهر للموظف؟ |
|---|---|---|
| `verified_official` | تم التحقق من صفحة رسمية معروضة (rendered) مع URL + تاريخ وصول + لغة | نعم |
| `verified_internal` | من مستند داخلي مصرّح به (مع رقم/إصدار المستند) | نعم (للمصرّح لهم) |
| `regulator_only` | مصدره NTRA فقط ولم يُؤكَّد على موقع الشركة | نعم مع وسم |
| `conflict` | مصدران رسميان (أو أكثر) متعارضان | نعم مع تحذير ظاهر وعرض القيمتين |
| `stale_suspected` | المصدر رسمي لكن يبدو قديمًا (مثل "العرض متاح طوال الصيف" في نوفمبر) | نعم مع تحذير |
| `lead_unverified` | من مصدر غير رسمي/صحافة فقط | **لا** (لوحة المحررين فقط) |
| `expired` | تجاوز `valid_until` أو اختفى من المصدر | لا (أرشيف) |

### 1.3 طريقة العمل في هذا المسح

1. فحص النطاقات بـ `curl` (الحالة، التحويلات، الحجم).
2. اكتشاف أن `eand.com.eg/portal` تطبيق Angular؛ استخراج **جدول المسارات (routes)** من ملف `main.js` للحصول على خريطة الموقع الكاملة (ملف `sitemap.xml` الموجود قديم من 2018 ويشير لمسارات `etisalat.eg/etisalat/portal/*` لم تعد تعمل).
3. عرض الصفحات فعليًا في متصفح حقيقي وقراءة النص المعروض (rendered text) — **هذا هو مصدر الحقائق البذرية**، وليس ملفات JS الخام.
4. البحث عن مصادر NTRA والصحافة.

---

## 2. جرد المصادر الرسمية (Official Source Inventory)

تاريخ الوصول لكل الصفوف: **2026-11-22**.

| # | اسم المصدر | URL | النوع | اللغة | الموسوعات | ملاحظات تقنية |
|---|---|---|---|---|---|---|
| S1 | الموقع الرسمي — البوابة (Personal) | https://www.eand.com.eg/portal/home | official_site | EN + AR (نفس الـ URL) | A–G | Angular SPA؛ `<app-root>` فارغ بدون JS؛ اللغة تُخزَّن في `localStorage` بالمفتاح `lang` ← **نفس الرابط للغتين**، لذا يجب تسجيل اللغة مع كل استشهاد. آخر نشر لـ `main.js`: Last-Modified 18 Nov 2026 |
| S2 | صفحات Mobile/* (24 مسارًا) | https://www.eand.com.eg/portal/Mobile/… (مثل `eSIM`، `Switch-to-etisalat-Egypt`، `khatein-services`، `convert5G`، `emerald`، `primo`، `hekaya-mixat`، `hekaya-internet`، `el-kart-plans`، `ro2ya`، `international-roaming`، `international-calls`، `traveling-to-egypt`، `parental-control-service`، `super-connect`، `super-sa3at`، `internet-megabits`، `call-keeper`، `video-call`، `voice-mail`، `multi-media-SMS`، `call-filter`، `WIFI-calling`، `balance-transfer`، `super-salefni`، `raseedy`) | official_site | EN/AR | B، C، D | JS-rendered؛ تحتوي جداول باقات + أكواد USSD + Terms and Conditions في نفس الصفحة؛ **لا يوجد تاريخ "آخر تحديث" ولا تاريخ بدء/انتهاء للعروض** |
| S3 | صفحات eHome/* | https://www.eand.com.eg/portal/eHome/eHome-DSL ، `eHome-wireless` ، `fixed-lines` ، `data-line-bundles` ، `gated-community` | official_site | EN/AR | E | JS-rendered؛ أسعار DSL **غير شاملة الضريبة** (يُذكر VAT 14%) — بخلاف باقات الموبايل "شاملة ضريبة الشحن" |
| S4 | صفحات etisalat money | https://www.eand.com.eg/portal/etisalat_money/etisalat_money ، `pensions` ، `International_Money_Remittance` | official_site | EN/AR | F | JS-rendered؛ أكواد `*777*N#`؛ رسوم؛ زر "Download All" لملفات؛ **تعارضات داخلية في الرسوم** (قسم 7) |
| S5 | صفحات etisalat World | https://www.eand.com.eg/portal/etisalat_World/7070-directory ، `twist-music` ، `twist-sport` ، `emerald-gto` ، `more-program` ، `coins-program` ، `spin-and-win` ، `coupons` ، `tracking-service-car` ، `our-partners` ، `world-of-deals` | official_site | EN/AR | C (VAS/ولاء)، G (7070) | حملات تسويقية — متقلبة |
| S6 | نافذة "Call Us" (modal `#callUsModal`) | https://www.eand.com.eg/portal/home (زر Call Us في قسم Need Guidance) | official_site | EN/AR | G | **الرابط `/portal/call-us` لا يعمل كصفحة مستقلة** (يعود للرئيسية)؛ المحتوى نافذة منبثقة في الصفحة الرئيسية — لا URL مستقل للاستشهاد |
| S7 | نوافذ Privacy Policy / Terms & Conditions | https://www.eand.com.eg/portal/home (روابط التذييل → `#privacyModal`, `#termsModal`) | official_site | EN/AR | A، قانوني | سياسة الخصوصية "Last updated on November 2026"؛ تذكر الـ Contact Centre 333 وبريد DPO؛ Terms لم تُقرأ بعد |
| S8 | العقود | https://www.eand.com.eg/portal/contracts | official_site | EN/AR | A، B، D، H (عام) | عقد خط الموبايل، عقد VDSL، التزامات الشركة/العميل، الشروط العامة — مصدر ممتاز للقواعد العامة |
| S9 | الحقوق والواجبات | https://www.eand.com.eg/portal/rights-duties | official_site | EN/AR | D، F، H (عام) | يعكس قواعد NTRA (حدود الخطوط، MNP، المحافظ) |
| S10 | من نحن | https://www.eand.com.eg/portal/about-us | official_site | EN/AR | A | فريق الإدارة، الرؤية، تاريخ البدء؛ أخطاء نسخ/لصق في العناوين |
| S11 | FAQ | https://www.eand.com.eg/portal/faq | official_site | EN/AR | D، troubleshooting | محتوى ضعيف جدًا حاليًا (أسئلة eSIM فقط ظاهرة) |
| S12 | صفحات مساعدة إضافية | `/portal/eligible-handsets` ، `/portal/activation-steps` ، `/portal/configuration-steps` | official_site | EN/AR | D، E | مكتشفة من جدول المسارات — **لم تُقرأ بعد** |
| S13 | ملفات الترجمة i18n | https://www.eand.com.eg/portal/assets/i18n/ar.json ، `/en.json` | official_site (أصل تقني) | AR/EN | كل | JSON ثابت (Last-Modified 18 Nov 2026)؛ يحتوي نصوصًا عربية للواجهة وبعض القيم (رسوم، أكواد). مفيد لكشف التغيير، **لكن لا يُستشهد به للموظف** — الاستشهاد يكون بالصفحة المعروضة |
| S14 | المتجر الإلكتروني | https://www.etisalat.eg/eshop2/#/ (و `#/dials` لاختيار الأرقام) | official_site | EN/AR | C (أجهزة/خطوط)، D | SPA بـ hash routing؛ أسعار أجهزة متغيرة يوميًا — **خارج نطاق v1 مقترح** |
| S15 | stub النطاق القديم | https://www.etisalat.eg/ → `/StaticFiles/portal/etisalat/index.html` | official_site | AR | — | صفحة 409 بايت تحمّل `js/main.js`؛ تحميل السكربت عبر curl فشل (اتصال أُغلق) |
| S16 | Self-care | https://www.eand.com.eg/selfcare/index.html | official_site (مغلق) | — | — | يتطلب تسجيل دخول عميل — **ممنوع الاستخدام** في الجمع |
| S17 | بوابة الأعمال | https://eandbusiness.com.eg/web/EBU-Portal/#/ | official_site | EN | (خارج نطاق الفروع غالبًا) | `curl` على `eandbusiness.com.eg` فشل بخطأ شهادة TLS (SEC_E_WRONG_PRINCIPAL) |
| S18 | تطبيق My etisalat (iOS) | https://apps.apple.com/eg/app/my-etisalat/id558287646 | official_app | EN/AR | B، C، D، F | الاسم "My etisalat"، البائع Etisalat Egypt، الإصدار 37.4.0 (9 نوفمبر)؛ نتائج بحث أخرى تُظهر الاسم "My e& - EG" (قسم 7) |
| S19 | تطبيق My etisalat (Android) | https://play.google.com/store/apps/details?id=com.etisalat | official_app | — | B، C، D، F | عنوان الصفحة "My etisalat"؛ باقي التفاصيل لم تُستخرج |
| S20 | تطبيق etisalat money (iOS) | https://apps.apple.com/eg/app/etisalat-money-eg/id1123428821 | official_app | — | F | مرتبط من الموقع الرسمي؛ **لم يُفحص** |
| S21 | NTRA — الموقع الرئيسي | https://www.tra.gov.eg/ | regulator | AR/EN | D، F، G، H (عام) | **تحت الصيانة يوم 2026-11-22**؛ يعرض روابط بوابة الخدمات والشكاوى والخط الساخن 155. مسارات `/en/` تُرجع 404، وملفات PDF القديمة (دليل MNP، قواعد حقوق المستخدمين) تُرجع 404 |
| S22 | NTRA — بوابة الخدمات / الشكاوى | https://digital.tra.gov.eg/ ، https://complaints.tra.gov.eg/ | regulator | AR | G، troubleshooting | HTTP 200؛ لم يُقرأ محتواهما |

**مصادر رسمية ثانوية (مسجّلة، غير مُستخدمة كمصدر حقائق):** حسابات السوشيال المرتبطة من التذييل: `facebook.com/eandEgypt`، `x.com/EtisalatEgypt`، `instagram.com/etisalategypt`، `tiktok.com/@eandegypt`، `youtube.com/Etisalatmasr`، `linkedin.com/company/etisalat-misr`؛ صفحة الاستدامة `https://www.eand.com.eg/etisalat/notification/sustainability/#/home`؛ الوظائف `https://www.eand.com.eg/StaticFiles/career/#/home`؛ ملف `https://www.eand.com.eg/portal/assets/pdf/Suppliers_COC_English.pdf`؛ رابط "Nearest Store" يفتح بحث Google Maps عام (ليس دليل فروع رسميًا).

**مصادر صحفية/غير رسمية (leads):**
- The National، 2026-10-06 (حُدّث 2026-11-02): https://www.thenationalnews.com/business/2026/10/06/uaes-e-revives-original-etisalat-branding-as-it-focuses-on-ai-growth/ — `press` — مجموعة e& تعود لاسم Etisalat؛ **لا يذكر مصر**.
- ويكيبيديا ونسخها — `unofficial` — تتعارض في الموقع الرسمي (etisalat.eg مقابل eand.com.eg).

**ملاحظات على البنية التقنية (تؤثر على الجمع):**
- المحتوى **مُضمَّن في ملفات JS (lazy chunks)** وليس من API/CMS عام — أي تغيير في العروض = نشر كود جديد، وأسماء ملفات chunks تتغير مع كل build. لذلك كشف التغيير يجب أن يكون على **النص المعروض** لكل مسار، لا على الملفات.
- `robots.txt` موجود ويمنع مسارات قديمة (`/StaticFiles/js`، `/StaticFiles/css` …)؛ `sitemap.xml` قديم (2018) وغير مفيد.
- لا يوجد في الصفحات تاريخ "آخر تحديث" ولا `valid_from/valid_until` للعروض.

---

## 3. خريطة المعرفة لكل موسوعة

**مفاتيح الأعمدة:**
- **التقلب (Volatility):** `static` (سنوي أو أقل) / `monthly` / `weekly` / `campaign` (مرتبط بحملة لها بداية ونهاية).
- **مستند داخلي؟** هل لا يمكن البناء بدون مستندات داخلية مُصرّح بها.
- **الأولوية:** P0 = MVP، P1 = بعد الإطلاق مباشرة، P2 = لاحقًا.

### A — الشركة (Company)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| A1 الهوية | الاسم القانوني، العلامة التجارية الحالية، تاريخ البدء، السجل التجاري، العنوان | `legal_name`, `brand_name_en/ar`, `start_date`, `cr_number`, `hq_address` | S8، S10 (عام) | static (لكن العلامة متقلبة حاليًا) | لا | P1 |
| A2 الإدارة | فريق الإدارة والمناصب | `name`, `title`, `as_of` | S10 | monthly-quarterly | لا | P2 |
| A3 الرؤية/الرسالة/السياسات | الرؤية، الرسالة، سياسة الجودة، الخصوصية، ميثاق الموردين | `text_summary`, `source_url` | S7، S10 | static | لا | P2 |
| A4 الهيكل الداخلي | الإدارات، القنوات (فروع ملك/فرانشايز)، المناطق | — | — | static | **نعم** | P2 |

### B — أنظمة الموبايل (Mobile Systems)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| B1 عائلات الأنظمة | Prepaid (El Kart/Akwa Kart، Hekaya Mixat، Hekaya Internet، Ro2ya، Super Sa3at…) / Postpaid (Emerald، …) / Control? | `system_name`, `type` (prepaid/postpaid/hybrid), `family`, `status`, `source_url` | S2 | monthly | جزئيًا | **P0** |
| B2 قواعد النظام | التسعير الافتراضي، الوحدات (Mix)، معامل التحويل (دقيقة لشبكة أخرى = 5 Mix)، الفواتير، الحد الائتماني | `unit_rules`, `default_rates`, `billing_cycle`, `credit_limit` | S2 + S8 | monthly | **نعم** للحدود الائتمانية وقواعد الأهلية | P0 |
| B3 الانتقال بين الأنظمة | من/إلى، الشروط، الرسوم، ما يُفقد من رصيد | `from_system`, `to_system`, `conditions`, `fees`, `balance_effect` | غير منشور عامًا | monthly | **نعم** | P0 |
| B4 الأنظمة الموقوفة (Legacy) | أنظمة لم تعد تُباع لكن عملاء عليها | `system_name`, `sale_status`, `end_of_sale_date` | غير منشور | static | **نعم** | P1 |

### C — الباقات والعروض (Packages & Offers)

| القسم | الموضوعات | الحقول المطلوبة (لكل باقة) | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| C1 باقات Prepaid الرئيسية | Hekaya Mixat، Hekaya Internet، El Kart، Ro2ya، Super Sa3at، Primo | `official_name_en/ar`, `type`, `linked_system`, `price`, `price_tax_basis` (شامل/غير شامل)، `quota`, `validity_days`, `subscription_code`, `auto_renewal`, `early_renewal`, `cancellation_code`, `out_of_bundle_rate`, `taxes_fees`, `addons[]`, `restrictions`, `fup`, `faq[]`, `valid_from`, `valid_until`, `last_reviewed`, `source_url`, `source_lang` | S2 | **weekly–monthly** | جزئيًا (قواعد الأهلية، العروض المخصصة) | **P0** |
| C2 باقات Postpaid | Emerald وغيرها | نفس الحقول + `monthly_fee`, `contract_term`, `credit_limit`, `family_lines` | S2 (`/Mobile/emerald`) | monthly | جزئيًا | **P0** |
| C3 الإضافات (Add-ons) | Super Connect، Extra Add-ons (`*626#`)، Internet Megabytes، ميني باقات | `parent_compatibility`, `price`, `quota`, `validity`, `code`, `consumption_priority` | S2 | weekly–monthly | لا | P0 |
| C4 العروض الترويجية | شحنات، مكافآت Coins، كاش باك، عروض موسمية | `offer_name`, `eligibility`, `mechanic`, **`valid_from`**, **`valid_until`**, `code` | S2، S5، سوشيال (lead) | **campaign** | غالبًا نعم (العروض المستهدفة) | P1 |
| C5 التجوال الدولي | باقات التجوال، الدول المشمولة، الأسعار | `bundle`, `price`, `quota`, `countries[]`, `code`, `tax_basis` | S2 (`/Mobile/international-roaming`) | monthly + تنبيهات تشغيلية | لا | P1 |
| C6 المكالمات الدولية | أسعار الدقيقة حسب الدولة، باقات دولية | `country`, `rate`, `bundle` | S2 (`/Mobile/international-calls`) — لم تُقرأ | monthly | لا | P1 |
| C7 الولاء و VAS التسويقي | MORE، Coins، Spin & Win، Twist، 7070 | `program`, `earn_rules`, `redeem_rules`, `code` | S5 | campaign | لا | P2 |
| C8 الأجهزة والخطوط المميزة | أسعار الأجهزة، اختيار الرقم | — | S14 | يومي | لا | P2 (مقترح استبعاده من v1) |

### D — خدمات الموبايل (Mobile Services)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| D1 SIM swap / بدل فاقد | الشروط، الرسوم، المستندات، من يحق له | `eligibility`, `fee`, `documents[]`, `channel` (فرع/تطبيق), `branch_allowed`, `steps` | غير منشور عامًا (عدا مبدأ عام في العقد) | monthly | **نعم** | **P0** |
| D2 eSIM | الشراء، التحويل من SIM، الاستبدال، صلاحية QR، الأجهزة المؤهلة | `channels`, `fee`, `qr_validity`, `geo_restriction`, `eligible_devices_url` | S2 (`/Mobile/eSIM`)، S11، S12 | monthly | جزئيًا (رسوم الفرع) | **P0** |
| D3 نقل الرقم (MNP) | شروط النقل إلى e&، المدة، الرسوم، ما يمنع النقل | `ownership_min_months`, `postpaid_dues`, `sla_hours`, `fee`, `documents[]` | S2 (`Switch-to-etisalat-Egypt`)، S9، NTRA (S21 — غير متاح) | static | جزئيًا (إجراء الفرع) | **P0** |
| D4 تغيير النظام | (انظر B3) | — | — | monthly | **نعم** | P0 |
| D5 تفعيل/إيقاف الخدمات | أكواد التفعيل والإلغاء لكل خدمة | `service`, `on_code`, `off_code`, `fee` | S2 (متفرق) | monthly | جزئيًا | P0 |
| D6 خدمات المكالمات | Call Keeper، Call Filter، Voice Mail، Video Call، WiFi Calling، Khattein | `service`, `description`, `code`, `fee`, `device_req` | S2 | static–monthly | لا | P1 |
| D7 الإنترنت والـ 5G | Convert to 5G، إعدادات APN، الأجهزة المؤهلة | `settings`, `eligibility` | S2، S12 | static | جزئيًا | P1 |
| D8 الرصيد والسلفة | Balance Transfer، Super Sallefny، Raseedy | `code`, `fee`, `limits`, `eligibility` | S2 | monthly | لا | P1 |
| D9 الرقابة الأبوية و MMS وغيرها | Parental Control، MMS | — | S2 | static | لا | P2 |
| D10 المستندات المطلوبة | لكل خدمة: مصري/أجنبي، توكيل، شركات | `customer_type`, `service`, `documents[]` | العقد (عام فقط) | static | **نعم** | **P0** |
| D11 ما المسموح في الفرع | صلاحيات الفرع لكل خدمة | `service`, `branch_allowed`, `role_required` | — | static | **نعم** | **P0** |

### E — الإنترنت والمنزل (Internet & Home)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| E1 eHome DSL (ADSL/VDSL) | الباقات بالسرعة، الحصص، الأسعار، الإضافات، Boosters، مزايا Emerald | `speed`, `quota_gb`, `price`, `tax_basis`, `gift`, `fup_after_quota`, `addons[]` | S3 | monthly | لا | P0 |
| E2 eHome Wireless | باقات الإنترنت اللاسلكي المنزلي | نفس الحقول + `device` | S3 — لم تُقرأ | monthly | لا | P1 |
| E3 الخطوط الأرضية | Fixed Lines | `plan`, `price`, `features` | S3 — لم تُقرأ | static | لا | P1 |
| E4 Data Lines | باقات خطوط البيانات | `bundle`, `quota`, `price`, `validity` | S3 — لم تُقرأ | monthly | لا | P1 |
| E5 الراوترات | الطرازات، السعر، التقسيط، الخصم | `model`, `cash_price`, `installment` | S3 (مبدأ الخصم 50%) | monthly | جزئيًا | P1 |
| E6 التفعيل والإلغاء والأعطال | مدد التفعيل، إجراءات الأعطال | `activation_sla`, `cancel_sla`, `fault_steps` | S9 (حقوق عامة)، S3 | static | **نعم** (تذاكر الأعطال) | P1 |
| E7 Gated Community / FTTH | — | — | S3 — لم تُقرأ | static | جزئيًا | P2 |

### F — e& money / etisalat money

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| F1 فتح المحفظة | التسجيل، المستندات، الأهلية، حد المحافظ لكل رقم قومي | `documents[]`, `fee`, `eligibility`, `max_wallets_per_id` | S4، S9 | static | جزئيًا (KYC الفرع) | **P0** |
| F2 الإيداع والسحب | فروع، فوري، ATM (Meeza) والبنوك المشاركة، الرسوم | `channel`, `fee_rule`, `min_fee`, `max_fee` | S4 + نافذة ATM Cash Service Fees | monthly | لا | P0 |
| F3 التحويل | داخل/خارج الشبكة، الرسوم، المجاني الشهري | `fee_on_net`, `fee_off_net`, `free_tier` | S4 (**متعارض** — قسم 7) | monthly / campaign | لا | P0 |
| F4 الحدود (Limits) | حدود يومية/شهرية/للمعاملة، مستويات KYC | `limit_type`, `amount`, `kyc_tier` | **غير منشور** | static | **نعم** (أو تنظيمي CBE) | **P0** |
| F5 الأكواد | `*777*N#` لكل خدمة، الخروج من العروض | `code`, `function` | S4 | monthly | لا | P0 |
| F6 خدمات أخرى | كارت الدفع أونلاين، الفواتير، الشحن، المعاشات، التحويلات الدولية، التبرعات | `service`, `fee`, `limits`, `steps` | S4، S7 | monthly | لا | P1 |
| F7 إغلاق المحفظة واسترداد الرصيد | — | `steps`, `refund_rule` | S9 (مبدأ عام) | static | **نعم** | P1 |

### G — دليل خدمة العملاء (Customer Service Directory)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| G1 أرقام e& | Customer Care، Cash Customer Care، Emerald Hotline، Smart ADSL، 7070، اشتراك eHome | `number`, `service`, `dial_from` (e& line / landline / other network / abroad), `cost`, `hours`, `source_url`, `last_verified` | S6، S8، S3، S5 | static (لكن تحقق ربع سنوي) | لا | **P0** |
| G2 أكواد قصيرة للخدمات | 999 (Khattein)، 138، 4070/4080، `*319#`… | `code`, `type` (USSD/SMS/IVR), `function`, `system` | S2، S4 | monthly | لا | P0 |
| G3 أرقام المنظّم | خط NTRA الساخن، بوابة الشكاوى | `number`, `url` | S21، S22 | static | لا | P1 |
| G4 أرقام الطوارئ | (مجانية حسب العقد — الأرقام نفسها غير مذكورة على الصفحة) | `number`, `service` | S9 (المبدأ فقط) | static | لا | P2 |
| G5 أرقام/مُرسِلين للتعرّف ("مين بيكلمني؟") | أسماء المرسلين في SMS، أرقام الحملات | — | — | weekly | **نعم** | P1 |

### H — إجراءات الفرع (Branch Procedures)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| H1 فتح خط جديد | التحقق من الهوية، العقد، حدود الخطوط | `steps`, `documents[]`, `checks[]`, `system_screens` | S8، S9 (قواعد عامة فقط) | static | **نعم** | P0 |
| H2 SIM swap/eSIM في الفرع | خطوات، تحقق، رسوم | نفس الحقول | — | static | **نعم** | P0 |
| H3 MNP في الفرع | النموذج، التحقق، المتابعة | — | S2 (3 خطوات عامة فقط) | static | **نعم** | P0 |
| H4 التعامل النقدي و e& money | KYC، إيداع/سحب نقدي في الفرع | — | — | static | **نعم** | P0 |
| H5 الشكاوى والتصعيد | مسارات التصعيد، SLAs | `level`, `owner`, `sla` | S9 (حق التصعيد لـ NTRA فقط) | static | **نعم** | P0 |
| H6 السياسات التشغيلية | سياسة الخصوصية في الفرع، الاحتيال، تسجيل المكالمات | — | S7 (عام) | static | **نعم** | P1 |

### I — الأنظمة (Systems: Oracle Siebel CRM وغيرها)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| I1 Siebel CRM | الشاشات، الـ Views، إنشاء Service Request، البحث عن عميل | `screen`, `purpose`, `steps`, `screenshots` (مموهة) | **لا يوجد أي مصدر عام** يربط e& مصر بإعداد Siebel محدد. وثائق Oracle العامة تشرح المنتج القياسي فقط، لا تخصيصات e& | static | **نعم** | P1 |
| I2 أنظمة أخرى | Billing، POS، أنظمة KYC، أدوات e& money | — | — | static | **نعم** | P2 |
| I3 الصلاحيات والأدوار | — | — | — | static | **نعم** | P2 |

### J — Siebel Academy (نموذج الحالات)

| القسم | الموضوعات | الحقول المطلوبة | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| J1 كتالوج الحالات | تصنيفات Category/Subcategory الفعلية في Siebel | `case_name`, `description`, `symptoms`, `eligibility`, `category`, `subcategory`, `required_info`, `procedure`, `sla`, `escalation`, `resolution`, `closure`, `related_services` | **لا مصدر عام** | static | **نعم (100%)** | P1 |
| J2 سيناريوهات تدريبية | حالات تمثيلية مشتقة من J1 | نفس الحقول + `difficulty` | مشتق من J1 | static | **نعم** | P2 |

### المسرد والاختصارات (Glossary)

| القسم | أمثلة | الحقول | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| GL1 مصطلحات الاتصالات العامة | MNP، eSIM، USSD، APN، FUP، VDSL، KYC، OOB، VAS | `term`, `ar`, `en`, `definition`, `source` | معايير عامة + S2/S8 | static | لا | P0 |
| GL2 مصطلحات e& التسويقية | Mix، Sha7net، Saytara، Coins، Emerald، Khattein | `term`, `meaning`, `source_url` | S2، S5 | monthly | لا | P0 |
| GL3 اختصارات داخلية | اختصارات Siebel، أكواد الحالات، أسماء الإدارات | — | — | static | **نعم** | P1 |

### استكشاف الأعطال (Troubleshooting)

| القسم | أمثلة | الحقول | المصدر | التقلب | داخلي؟ | الأولوية |
|---|---|---|---|---|---|---|
| T1 إنترنت الموبايل | لا يعمل، بطء بعد انتهاء الحصة، إعدادات | `symptom`, `checks[]`, `customer_steps`, `escalate_when` | S2 (قواعد الحصص)، S12 | static | جزئيًا | P1 |
| T2 eSIM | QR منتهي (5 أيام)، التحميل خارج مصر | نفس الحقول | S2 | static | جزئيًا | P1 |
| T3 إنترنت المنزل | انقطاع، سرعة | — | S3 | static | **نعم** | P1 |
| T4 التجوال | انقطاعات معروفة في دول | `country`, `issue`, `as_of` | S2 (تنبيه تشغيلي على صفحة التجوال) | **weekly** | لا | P1 |
| T5 e& money | فشل معاملة، استرداد | — | S4 (FAQ) | static | **نعم** | P1 |

---

## 4. ما تغطيه المصادر العامة مقابل ما يحتاج مستندات داخلية مُصرّح بها

### 4.1 يمكن بناؤه من مصادر عامة (بمستوى ثقة جيد)
- **C** (معظم الباقات الرئيسية والإضافات والتجوال): الأسماء، الأسعار، الحصص، الأكواد، الصلاحية، شروط الاستخدام المنشورة.
- **E1** (eHome DSL): الأسعار والحصص والإضافات.
- **F5/F2** (أكواد e& money وبعض الرسوم) — مع تعارضات يجب حسمها.
- **G1/G2** (أرقام خدمة العملاء الرئيسية والأكواد القصيرة).
- **A** (الهوية والإدارة).
- **قواعد عامة في D و H** من صفحتي العقود والحقوق (حدود الخطوط، MNP خلال 24 ساعة، حد المحافظ، مدد تفعيل الإنترنت).

### 4.2 يمكن بناؤه جزئيًا فقط
- **B** (الأنظمة): الأسماء موجودة، لكن قواعد الانتقال بين الأنظمة، الأنظمة الموقوفة، والحدود الائتمانية غير منشورة.
- **D** (الخدمات): وصف الخدمة والكود متاح، لكن **المستندات المطلوبة، رسوم الفرع، وصلاحيات الفرع غير منشورة**.
- **F4** (حدود المحفظة ومستويات KYC) غير منشورة على صفحة e& money التي قرأناها.

### 4.3 لا يمكن بناؤه إطلاقًا من مصادر عامة — يتطلب مستندات داخلية مُصرّح بها كتابيًا
| المحتوى | الموسوعة | لماذا |
|---|---|---|
| إجراءات الفرع خطوة بخطوة (SOPs) | H | وثائق تشغيل داخلية |
| أدلة Oracle Siebel CRM الخاصة بـ e& مصر (شاشات، تخصيصات، حقول) | I | نظام داخلي؛ لقطات الشاشة قد تكون سرية |
| كتالوج الحالات (Category/Subcategory) وإجراءات الحل والإغلاق | J | تكوين داخلي في Siebel |
| مصفوفات التصعيد (Escalation Matrices) | H، J | تنظيمية داخلية |
| SLAs الداخلية | H، J | الصفحات العامة تذكر حقوقًا تنظيمية فقط (مثل MNP 24 ساعة)، لا SLAs داخلية |
| المواد التدريبية الرسمية | J، تدريب | ملكية فكرية داخلية |
| السياسات التشغيلية (KYC، مكافحة الاحتيال، النقدية) | H، F | داخلية وحساسة |
| الأكواد الداخلية (أكواد الأنظمة، أكواد الحالات، أكواد العروض المستهدفة) | B، C، J | غير منشورة؛ نشرها قد يمثل خطرًا أمنيًا |
| العروض المستهدفة (Targeted / Retention offers) | C4 | تُدار داخليًا |
| صلاحيات الأدوار | D11، I3 | داخلية |

**الخلاصة الصريحة:** **جزء كبير من H و I و J (تقديريًا ≥ 90% منها) لا يمكن بناؤه من بيانات عامة.** أي محتوى في هذه الموسوعات بدون مستندات داخلية مصرّح بها سيكون إمّا تخمينًا (ممنوع حسب قواعد المشروع) أو منسوخًا من مستندات غير مصرّح بها (مخاطرة قانونية وأمنية). التوصية: إطلاق v1 بدون H/I/J أو بهياكل فارغة واضحة الوسم ("بانتظار مصدر داخلي معتمد")، والحصول على تفويض مكتوب قبل أي محتوى داخلي.

---

## 5. حقائق بذرية تم التحقق منها (Verified Seed Samples)

الهدف: إثبات أن خط الجمع (pipeline) يعمل — **ليست بيانات إنتاج**. كل البنود تم التحقق منها من **النص المعروض فعليًا** في متصفح بتاريخ **2026-11-22**، لغة العرض الإنجليزية ما لم يُذكر غير ذلك. نوع المصدر لكلها: `official_site`، عدا #15 (`regulator`).

| # | الحقيقة (ملخّصة) | الموسوعة | URL | ملاحظات |
|---|---|---|---|---|
| 1 | رقم خدمة العملاء من خط e& هو **333**؛ بسعر ثابت للمكالمة أيًا كانت مدتها، على مدار 24/7 | G | https://www.eand.com.eg/portal/contracts ، وأيضًا نافذة Call Us على https://www.eand.com.eg/portal/home | تم التحقق بالإنجليزية **والعربية** (صفحة العقود)، ومذكور أيضًا في سياسة الخصوصية |
| 2 | Cash Customer Care من خط e&: **778** | G، F | نافذة Call Us (`#callUsModal`) على https://www.eand.com.eg/portal/home | الرقم الدولي المقابل المعروض: +201111234778 |
| 3 | Emerald Hotline: **800** | G | نافذة Call Us — https://www.eand.com.eg/portal/home | — |
| 4 | Smart ADSL Customer Care من خط e&: **7333** | G، E | نافذة Call Us — https://www.eand.com.eg/portal/home | انظر التعارض C3 |
| 5 | خدمة العملاء من أي خط أرضي: **0235346333** | G | نافذة Call Us — https://www.eand.com.eg/portal/home | الأرقام المعروضة "من أي موبايل/من الخارج" مُدرجة في التعارضات (C2) وليست هنا |
| 6 | الاشتراك في eHome DSL ممكن عبر الفرع، أو خدمة العملاء على **16511**، أو تطبيق My etisalat لعملاء e& الحاليين | E، G | https://www.eand.com.eg/portal/eHome/eHome-DSL | — |
| 7 | كود QR لتفعيل eSIM صالح **5 أيام** من تاريخ الشراء أو الاستبدال؛ وملف eSIM لا يمكن تحميله إلا **من داخل مصر** | D | https://www.eand.com.eg/portal/Mobile/eSIM | — |
| 8 | للنقل إلى e& (MNP): يجب أن يكون الخط مسجلًا باسم العميل مع **4 أشهر ملكية على الأقل** لدى المشغل الحالي؛ وعلى عميل الفاتورة سداد المستحقات؛ والتفعيل خلال 24 ساعة | D | https://www.eand.com.eg/portal/Mobile/Switch-to-etisalat-Egypt | شرط الأشهر الأربعة لم نؤكده من NTRA (الموقع تحت الصيانة) |
| 9 | الحد الأقصى: **10 خطوط صوت و5 خطوط بيانات** لكل رقم قومي (للمواطنين)؛ و**5 صوت و5 بيانات** لكل جواز سفر (للأجانب)؛ و**3 محافظ إلكترونية** كحد أقصى لكل رقم قومي | D، F، H | https://www.eand.com.eg/portal/rights-duties | — |
| 10 | كود الاستعلام عن رصيد محفظة etisalat money: **`*777*4#`** (ضمن قائمة أكواد `*777*1#` إلى `*777*15#`) | F | https://www.eand.com.eg/portal/etisalat_money/etisalat_money | — |
| 11 | باقة **Hekaya Mixat 52**: 74.29 جنيه شهريًا شاملة ضريبة الشحن، 1900 Mix، كود الاشتراك `*319*52#`؛ وصلاحية باقات Hekaya Mixat الشهرية 28 يومًا | C | https://www.eand.com.eg/portal/Mobile/hekaya-mixat | الصلاحية من قسم Terms and Conditions في نفس الصفحة |
| 12 | بعد استهلاك باقة Hekaya Mixat: سعر ثابت **19 قرشًا** لكل دقيقة أو ميجابايت | C | https://www.eand.com.eg/portal/Mobile/hekaya-mixat | — |
| 13 | eHome DSL: باقة **100 GB بسعر 150 جنيه**؛ والأسعار **غير شاملة الضريبة** (ضريبة قيمة مضافة 14%) | E | https://www.eand.com.eg/portal/eHome/eHome-DSL | — |
| 14 | الكيان القانوني: شركة مساهمة مصرية مسجلة بالسجل التجاري رقم **107361**، العنوان: مبنى S4 — Down Town Mall — شارع التسعين — التجمع الخامس — القاهرة الجديدة | A | https://www.eand.com.eg/portal/contracts | سياسة الخصوصية تسمّي الكيان "Etisalat Misr (S.A.E.)" |
| 15 | الخط الساخن لـ NTRA: **155** | G | https://www.tra.gov.eg/ | ظاهر على صفحة "الموقع تحت الصيانة" نفسها |

---

## 6. المعرفة الناقصة / غير المُتحقق منها (Missing / Unverified — أولي)

### 6.1 غير منشور على أي صفحة قرأناها (يحتاج مصدرًا داخليًا أو تأكيدًا رسميًا)
1. **رسوم ومستندات وخطوات SIM swap / بدل فاقد** (للمصري والأجنبي والشركات).
2. **رسوم eSIM في الفرع** (إجابة FAQ تقول إن التقنية متاحة لكل العملاء، لكن الرسوم غير ظاهرة في النص المعروض).
3. **قواعد تغيير النظام** (Prepaid ↔ Postpaid، بين باقات Prepaid) والرسوم وأثرها على الرصيد.
4. **المستندات المطلوبة لكل خدمة** وما يُسمح بتنفيذه في الفرع.
5. **حدود e& money** (يومي/شهري/للمعاملة) ومستويات KYC.
6. **تواريخ بدء وانتهاء العروض** (`valid_from` / `valid_until`) — لا تظهر في أي صفحة.
7. **أسعار باقات El Kart بالجنيه لكل باقة** (الصفحة تعرض الحصص والصلاحية وكود `*811#` فقط، مع نطاق عام "من 13 إلى 65 جنيه").
8. أرقام خدمة العملاء **من شبكات أخرى** لكل الخدمات (مثلًا لـ Emerald و Cash Care)، و**من الخارج** لخدمة Smart ADSL بشكل موثوق.
9. معنى "ضريبة الشحن" (recharge tax) ونسبتها الحالية لباقات Prepaid.
10. قائمة الأنظمة الموقوفة (Legacy) التي ما زال عليها عملاء.
11. كل محتوى H و I و J (انظر 4.3).
12. أسماء المرسلين/الأرقام التي يستخدمها e& في SMS والمكالمات (للتعرّف على الاحتيال).

### 6.2 صفحات رسمية موجودة لكن لم تُقرأ في هذا المسح (أولوية للمسح القادم)
`/Mobile/emerald`، `/Mobile/primo`، `/Mobile/hekaya-internet`، `/Mobile/ro2ya`، `/Mobile/super-sa3at`، `/Mobile/super-connect`، `/Mobile/internet-megabits`، `/Mobile/international-calls`، `/Mobile/traveling-to-egypt`، `/Mobile/convert5G`، `/Mobile/balance-transfer`، `/Mobile/super-salefni`، `/Mobile/raseedy`، `/Mobile/call-keeper`، `/Mobile/call-filter`، `/Mobile/voice-mail`، `/Mobile/video-call`، `/Mobile/WIFI-calling`، `/Mobile/multi-media-SMS`، `/Mobile/parental-control-service`، `/eHome/eHome-wireless`، `/eHome/fixed-lines`، `/eHome/data-line-bundles`، `/eHome/gated-community`، `/etisalat_money/pensions`، `/etisalat_money/International_Money_Remittance`، كل صفحات `etisalat_World/*` عدا 7070، `/eligible-handsets`، `/activation-steps`، `/configuration-steps`، نافذة Terms & Conditions، ونسخة كل الصفحات **بالعربية**.

### 6.3 قواعد تنظيمية لم نستطع التحقق منها من NTRA (الموقع تحت الصيانة في 2026-11-22)
- قواعد MNP الرسمية (المدة، الرسوم، الحد الأدنى لمدة الملكية، أسباب الرفض). نتائج البحث (snippets فقط، غير مُتحقق منها) تشير إلى: النقل مجاني وخلال 24 ساعة، وتقديم الطلب في منفذ المشغل المستقبِل، وأن المديونيات قد تمنع النقل — **lead_unverified**.
- قواعد تسجيل الخطوط وحدودها (الحقيقة #9 مصدرها موقع e& وليس NTRA مباشرة).
- إطار حقوق المستخدمين الرسمي (ملفات PDF على `tra.gov.eg/wp-content/uploads/...` تُرجع 404 الآن).
- قواعد البنك المركزي المصري (CBE) للمحافظ الإلكترونية — لم تُبحث في هذا المسح.

### 6.4 أمور تحتاج حسمًا قبل أي نشر
- **الاسم الرسمي الحالي للعلامة في مصر** (انظر C6).
- اسم التطبيق الرسمي الحالي ("My etisalat" مقابل "My e& - EG").

---

## 7. التعارضات المكتشفة (Conflicts)

| # | الموضوع | القيمة / المصدر 1 | القيمة / المصدر 2 | الحالة المقترحة |
|---|---|---|---|---|
| C1 | **رسوم etisalat money** | قسم "Fixed Low Fees": 5 جنيه للسحب النقدي و1 جنيه للتحويل لأي محفظة في مصر | قسم "Fee Details": 1 جنيه لمحفظة etisalat، و0.5% بحد أقصى 15 جنيه لأي محفظة أخرى، وأول معاملة شهريًا مجانية حتى 2,000 جنيه. ونافذة "ATM Cash Service Fees": 1% بحد أدنى 2 جنيه من الفرع/فوري و1% بحد أدنى 1 جنيه من ATM. وT&C العرض: حد 5000 جنيه شهريًا وإلا 1% | `conflict` — كلها على https://www.eand.com.eg/portal/etisalat_money/etisalat_money (+ نافذة على الرئيسية). على الأرجح عرض ترويجي فوق رسوم أساسية، لكن لا يوجد ما يوضح ذلك صراحة |
| C1b | **صلاحية عرض التحويل** | "The Offer Is Available Throughout The Summer Period" | تاريخ الوصول 2026-11-22 (نوفمبر) | `stale_suspected` |
| C2 | **أرقام خدمة العملاء من موبايل/من الخارج** | نافذة Call Us: "From Any Mobile Number" = 0111123433 و"From Any International Number" = +20111123433 | أرقام الموبايل المصرية عادة 11 رقمًا (01X + 8 أرقام)؛ الرقم المعروض 10 أرقام فقط. بالمقابل رقم Cash Care الدولي +201111234778 بطول طبيعي | `conflict` / **احتمال خطأ مطبعي على الموقع** — **لا يُنشر** حتى يُؤكَّد بالاتصال الفعلي أو من مصدر رسمي آخر |
| C3 | **رقم خدمة إنترنت المنزل** | نافذة Call Us: Smart ADSL Customer Care = 7333 | صفحة eHome DSL: الاشتراك عبر خدمة العملاء 16511 | ربما أغراض مختلفة (دعم مقابل مبيعات) — يُعرضان معًا مع توضيح الغرض حتى الحسم |
| C4 | **Hekaya Mixat — بيانات قديمة داخل نفس الصفحة** | قائمة الباقات الحالية: 52/69/92/120/180/270 | نفس الصفحة: "Home VDSL Included — Available with Hekaya Mixat 155 & 235"، وFUP لـ "Hekaya Mixat 45 / 60" — باقات غير موجودة في القائمة | `stale_suspected` |
| C5 | **سعر بداية شحنات Hekaya** | "Hekaya Mini Renewal starting 16.5 EGP" | "Shahnet Hekaya Mixat: This service starts at 19 LE" | `conflict` (قد يكونان منتجين مختلفين: Mini مقابل Mixat) |
| C5b | **كود إعادة الشحن** | "recharge using code 5569#" | "dialing 5569*recharge code#" و"*556*9*Code#" في جدول USSD | `conflict` في صيغة الكود — لا يُنشر حتى التأكد |
| C5c | **صلاحية الشحنات** | Hekaya Mixat T&C: "New sha7net Hekaya Mixat packages are valid for 6 to 10 days" | صفحة El Kart: صلاحيات من 2 إلى 28 يومًا لباقات تتضمن Sha7net Hekaya Mini | ربما منتجات مختلفة — يحتاج توضيحًا |
| C6 | **اسم العلامة التجارية** | الموقع بالإنجليزية: "etisalat Egypt"؛ بالعربية: "اتصالات مصر"؛ سياسة الخصوصية: "Etisalat Misr (S.A.E.)"؛ App Store: "My etisalat" بحقوق "© e& Egypt" | صفحة العقود بالعربية تحتوي "مع &e"؛ حسابات السوشيال `eandEgypt`/`@eandegypt`؛ نتائج بحث App Store تُظهر "My e& - EG"؛ الصحافة: مجموعة e& تعود لاسم Etisalat (The National، 2026-10-06، لا يذكر مصر) | يبدو أن الشركة في مصر تنتقل للاسم "etisalat/اتصالات" — **قرار منتج مطلوب** بخصوص اسم المشروع "e& Employee Knowledge Hub" |
| C7 | **النطاق الرسمي** | ويكيبيديا (نسخة): etisalat.eg | ويكيبيديا (نسخة أخرى): eand.com.eg | تم الحسم بالفحص المباشر: **الاثنان حيّان**، والمحتوى على eand.com.eg والمتجر على etisalat.eg |
| C8 | **CEO في صفحة من نحن** | "Hazem Metwally — Chief Executive Officer (CEO)" | "Sherif Attia — Chief Executive Officer (CEO)" في نفس القائمة | غامض (ربما CEO لكيان تابع) — لا يُنشر كحقيقة حتى التوضيح |
| C9 | **محتوى eSIM مكرر** | "Replacing the eSIM" | نصّه مطابق حرفيًا لنص "Switching to an eSIM" | خطأ محتوى على الموقع — لا يُستخدم قسم "Replacing" كمصدر |
| C10 | **مدة تفعيل إنترنت المنزل** | صفحة الحقوق: تفعيل الإنترنت الثابت خلال 48 ساعة (72 ساعة للنحاس) | صفحة eHome DSL: التفعيل خلال 24 ساعة | ليس تعارضًا بالضرورة (حد أقصى تنظيمي مقابل وعد تجاري) — يُعرضان مع التوضيح |

---

## 8. توصيات إدخال المحتوى وتحديثه (Content Ingestion)

### 8.1 نموذج البيانات
- كل حقيقة = سجل له: `value`, `source_url`, `source_type`, `source_lang` (ضروري لأن نفس الـ URL يخدم اللغتين)، `accessed_at`, `verified_by`, `verification_state`, `valid_from`, `valid_until`, `last_reviewed_at`, `next_review_due`, `evidence` (لقطة شاشة/نسخة نصية مؤرخة من الصفحة المعروضة).
- العروض بدون `valid_until` رسمي تأخذ `valid_until = null` + وسم "بدون تاريخ انتهاء معلن" + مراجعة إلزامية كل 7 أيام.
- حقل `price_tax_basis` إلزامي (شامل ضريبة الشحن / غير شامل + VAT 14%) — الموقع نفسه يخلط بين الأساسين.

### 8.2 وتيرة المراجعة اليدوية
| النوع | الوتيرة |
|---|---|
| عروض الحملات (C4، C7) | كل 3–7 أيام + عند أي إعلان رسمي |
| الباقات الرئيسية والإضافات (C1–C3، E1) | أسبوعيًا |
| e& money (F) | أسبوعيًا (الرسوم متعارضة حاليًا وعروض موسمية) |
| أرقام خدمة العملاء (G) | شهريًا + اختبار اتصال فعلي ربع سنوي من موظف مخول |
| التجوال (C5) والتنبيهات التشغيلية (T4) | أسبوعيًا |
| A، العقود، الحقوق | ربع سنوي |
| محتوى داخلي (H/I/J) | مع كل إصدار جديد من المستند الداخلي |

### 8.3 كشف التغيير على الصفحات الرسمية (Change Detection)
- **لا تعتمد على HTML الخام** — الصفحات فارغة بدون JavaScript. استخدم متصفحًا headless بمعدل منخفض (مثلًا مرة يوميًا لكل مسار، باللغتين عبر ضبط `localStorage.lang`)، استخرج نص `<main>`، طبّعه، واحسب hash. عند تغيّر الـ hash → افتح مهمة مراجعة للمحرر مع diff نصي. **لا نشر تلقائي** للتغييرات.
- قائمة المسارات تُستخرج من جدول routes في `main.js` (يتغير مع كل build) — راقب ظهور/اختفاء مسارات كإشارة لإطلاق/إيقاف منتجات.
- مؤشر رخيص إضافي: ترويسة `Last-Modified` لملفات `main.js` و`assets/i18n/ar.json` (كلاهما 18 Nov 2026) — تغيّرها يعني نشرًا جديدًا للموقع.
- راقب `tra.gov.eg` أسبوعيًا حتى يعود من الصيانة، ثم أعد التحقق من قواعد MNP وحقوق المستخدمين.

### 8.4 ملاحظة قانونية (Scraping / ToS / المحتوى الرسمي في تطبيق غير رسمي)
- **لم نقرأ بعد شروط الاستخدام** (نافذة Terms & Conditions على الموقع) — يجب قراءتها ومراجعتها قانونيًا قبل أي جمع آلي منتظم.
- `robots.txt` على eand.com.eg يمنع مسارات تقنية قديمة (`/StaticFiles/js`، `/StaticFiles/css`، …). الالتزام به إلزامي، والجمع الآلي — إن وُجد — يكون بمعدل منخفض جدًا، وللمراجعة الداخلية فقط، لا لإعادة النشر.
- **عدم نسخ النصوص الطويلة**: نخزّن الحقائق (أرقام، أسعار، أكواد) ونلخّص الشروط بأسلوبنا مع رابط للمصدر — لا نسخ لنصوص العقود أو سياسة الخصوصية.
- **العلامات التجارية**: لا استخدام لشعار e& / etisalat ولا هويتها البصرية؛ إخلاء مسؤولية واضح في كل شاشة: "تطبيق غير رسمي وغير تابع لـ e& مصر؛ المرجع النهائي هو القنوات الرسمية".
- **المحتوى الداخلي** (H/I/J): لا يُستخدم إلا بتفويض **مكتوب** من جهة مخوّلة في الشركة؛ إدخال مستندات داخلية دون تفويض قد يخالف اتفاقيات السرية وقواعد حماية البيانات (سياسة الخصوصية على الموقع تشير لتطبيق القوانين المصرية). لا لقطات شاشة Siebel تحتوي بيانات عملاء أبدًا.
- **بيانات العملاء**: التطبيق لا يجب أن يخزن أو يطلب أي بيانات عملاء.
- يُفضّل السعي للحصول على **موافقة رسمية** من e& مصر (أو تحويل المشروع لمبادرة داخلية معتمدة) — هذا يحل مشكلتي المصدر الداخلي والمسؤولية القانونية معًا.

---

## 9. ما لا تغطيه هذه الخريطة بعد (بصراحة)

1. **قرأنا 14 صفحة رسمية + نافذتين (Call Us، Privacy) فقط** من أصل ~60 مسارًا مكتشفًا؛ ما لم يُقرأ مذكور في 6.2.
2. **النسخة العربية** تم التحقق منها لصفحة واحدة (العقود) فقط؛ باقي الحقائق من النسخة الإنجليزية. قد توجد فروق في الصياغة أو القيم بين اللغتين.
3. **لم نفحص التطبيقات من الداخل** (My etisalat، etisalat money) — فقط صفحات المتاجر.
4. **NTRA غير متاح** اليوم؛ لا توجد أي حقيقة تنظيمية مُتحقق منها مباشرة من المنظّم سوى الخط الساخن 155.
5. **لم نبحث في البنك المركزي المصري (CBE)** بخصوص قواعد المحافظ الإلكترونية، ولا في **ITIDA**/حماية البيانات.
6. **لم نغطِّ قطاع الأعمال (B2B)** ولا بوابة eandbusiness.
7. **لم نتحقق من الأرقام بالاتصال الفعلي** — التحقق كان من نص الموقع فقط.
8. **لا يوجد أي محتوى داخلي** (H/I/J، SLAs، Siebel) — ولن يوجد بدون تفويض.
9. **لم نجمع أرشيفًا زمنيًا** (مثل Wayback Machine) لقياس معدل تغيّر الأسعار فعليًا؛ تقديرات التقلب في قسم 3 مبنية على طبيعة المحتوى وعلى مؤشرات مثل نشر الموقع في 18 نوفمبر 2026 ووجود عروض موسمية قديمة على الصفحات.
10. **لم نقرأ نافذة Terms & Conditions** على الموقع.
