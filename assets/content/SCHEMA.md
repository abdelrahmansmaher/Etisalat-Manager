# Content schema (bundled offline content)

Content ships with the app as JSON under `assets/content/`, one file per section.
Source of the first content batch: the owner's PDF
"الدليل الشامل لموظف فرع اتصالات مصر — إصدار نوفمبر 2026" (72 pages), which itself
says it is an **unofficial compilation of public sources** and marks items as
"مؤكد" or "(غير مؤكد)". We keep those labels exactly; we never upgrade an
unconfirmed item to confirmed.

## Files

| File | Section key | Content |
|---|---|---|
| `company.json` | `company` | Company profile, brand history, network, app, loyalty, VAS, business, competitors, price-increase history |
| `packages.json` | `packages` | Prepaid & postpaid systems, base tariff, balance services, migration, add-ons, line price, FAQ |
| `internet.json` | `internet` | Mobile data bundles, home wireless/router, ADSL/VDSL, 5G, eSIM |
| `wallet.json` | `wallet` | e& cash / e& money: registration, codes, services, limits, fees, PIN, loss, closing, wrong transfer, complaints, branch cases |
| `numbers.json` | `numbers` | Customer-service numbers & hotlines, and ALL USSD/MMI codes (balance, recharge, internet, cancel VAS, call services, wallet, promos, app, line ownership, GSM codes) |
| `procedures.json` | `procedures` | Branch procedures & cases, 2026 rules, roaming |
| `glossary.json` | `glossary` | Terms & abbreviations (from every section) |


The PDF's own "unconfirmed items to check internally" lists go in the section file they belong to, as items with `"type": "unverified"`, `"status": "unconfirmed"`, `category_ar: "بنود غير مؤكدة"`.

## File shape

```json
{
  "section": "packages",
  "source_document": "pdf_guide_2026_11",
  "as_of": "2026-11-22",
  "items": [ Item, ... ]
}
```

## Item

```json
{
  "id": "pkg-hekaya-mixat-52",            // kebab-case, unique across ALL files, stable
  "type": "package",                       // see types below
  "category_ar": "حكاية ميكسات",           // sub-group shown as a header in the section list
  "title_ar": "حكاية ميكسات 52",
  "title_en": "Hekaya Mixat 52",           // optional
  "summary_ar": "باقة شهرية 1,900 ميكس ...", // one line, shown in lists and search results
  "body_ar": "فقرة 1\n\nفقرة 2\n- نقطة",   // optional; plain text, paragraphs split by blank line, bullets start with "- "
  "facts": [                               // the Answer Card + details table
    {"label_ar": "يُخصم من الرصيد", "value": "52", "unit": "ج", "kind": "price"},
    {"label_ar": "تحتاج تشحن تقريبًا", "value": "74.29", "unit": "ج", "kind": "price"},
    {"label_ar": "الميكسات", "value": "1,900", "kind": "quantity"},
    {"label_ar": "كود الاشتراك", "value": "*319*52#", "kind": "code"}
  ],
  "steps_ar": ["خطوة 1", "خطوة 2"],        // optional, for procedures/how-to
  "codes": ["*319*52#"],                   // every USSD/MMI code mentioned in the item, verbatim
  "phones": ["333"],                       // every phone/hotline number mentioned, verbatim
  "tags": ["حكاية", "ميكسات", "كارت"],     // extra search words incl. Egyptian dialect / English
  "status": "confirmed",                   // confirmed | unconfirmed | conflict
  "status_note_ar": "مؤكد (ويكيبيديا)",    // optional: the PDF's own wording about the status/source
  "sources": [ {"name": "الموقع الرسمي", "url": "https://...", "type": "official_site"} ],
  "pdf_pages": [71],
  "related": ["pkg-hekaya-mixat-69"]       // optional ids
}
```

### `type`
`article` · `package` · `service` · `contact` · `code` · `fee` · `limit` · `procedure` · `rule` · `faq` · `glossary` · `unverified`

### `facts[].kind`
`price` · `code` · `phone` · `quantity` · `duration` · `percent` · `date` · `text`

### `status` rules (strict)
- `confirmed` — the PDF labels it "مؤكد" or presents it as fact **without** a "(غير مؤكد)" mark.
- `unconfirmed` — the PDF marks it "(غير مؤكد)", "لم نجد", "راجع النظام الداخلي", "فيه مصادر بتقول …", or similar. If ANY fact inside an item is unconfirmed, either split it into its own item or set the whole item to `unconfirmed` and explain in `status_note_ar`.
- `conflict` — the PDF itself gives two different values for the same thing. Put both in `facts` and explain.

### `sources[].type`
`pdf_guide` (always add `{"name":"الدليل الشامل لموظف فرع اتصالات مصر (نوفمبر 2026)","type":"pdf_guide"}` first) · `official_site` · `regulator` · `press` · `wikipedia` · `app_store` · `other` — add the PDF's cited sources for the section when it lists them (each section ends with a sources list).

## Hard rules
1. Never invent or "fix" a number, price, code or phone. Copy verbatim from the PDF. If text extraction is garbled (RTL tables), check the page image.
2. Never drop the PDF's "(غير مؤكد)" marks.
3. Arabic wording may be lightly cleaned, but meaning must not change.
4. Don't copy long paragraphs verbatim — summarize prose; keep tables/facts exact.
