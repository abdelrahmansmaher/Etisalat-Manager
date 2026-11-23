"""Generator for the SQL normalizer tables and the pgTAP fixture assertions.

Mirrors the lookup table in lib/core/search/arabic_normalizer.dart (keep in sync!).

Usage (from the repo root):
    python -I supabase/tools/gen_normalizer.py

Writes to supabase/tools/out/ (not committed):
    translate_from.sql / translate_to.sql  -> the two translate() arguments in public.normalize_ar
    normalize_fixture_cases.sql            -> the fixture block of supabase/tests/normalize.test.sql

It also runs a randomized parity check between a Python port of the Dart
algorithm and the SQL pipeline (multi-char replace -> translate -> collapse
3+ repeated Arabic letters -> collapse spaces -> trim), and checks every case in
test/core/search/fixtures/normalizer_cases.json against both.
"""
import json
import os
import random
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
BS = chr(92)  # backslash
LF = chr(10)
DROP, MULTI, SP = -1, -2, 0x20

# ---------------------------------------------------------------- Dart table
t = list(range(0x10000))
for a, b in [(0x41, 0x5A), (0xC0, 0x24F), (0x370, 0x3FF), (0x400, 0x52F), (0x1E00, 0x1EFF)]:
    for c in range(a, b + 1):
        low = chr(c).lower()
        if len(low) == 1:
            t[c] = ord(low)
for c in range(0xFF01, 0xFF5F):
    t[c] = t[c - 0xFEE0]
for c in [0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0x85, 0xA0, 0x1680, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000]:
    t[c] = SP
for c in range(0x2000, 0x200B):
    t[c] = SP


def drop(a, b):
    for c in range(a, b + 1):
        t[c] = DROP


drop(0x200B, 0x200F)
drop(0x202A, 0x202E)
drop(0x2066, 0x2069)
t[0xFEFF] = DROP
drop(0x064B, 0x065F)
t[0x0670] = DROP
drop(0x06D6, 0x06ED)
t[0x0640] = DROP
ALEF, YEH, HEH, WAW, KAF = 0x627, 0x64A, 0x647, 0x648, 0x643
for c, v in [(0x623, ALEF), (0x625, ALEF), (0x622, ALEF), (0x671, ALEF), (0x649, YEH), (0x6CC, YEH),
             (0x629, HEH), (0x624, WAW), (0x626, YEH), (0x6A9, KAF)]:
    t[c] = v
for d in range(10):
    t[0x660 + d] = 0x30 + d
    t[0x6F0 + d] = 0x30 + d
t[0x60C], t[0x61B], t[0x61F] = 0x2C, 0x3B, 0x3F
for c in range(0xFE70, 0xFE80):
    if c in (0xFE73, 0xFE75):
        continue
    t[c] = SP if c % 2 == 0 else DROP
FORMS_B = [(0x0621, 1), (0x0622, 2), (0x0623, 2), (0x0624, 2), (0x0625, 2), (0x0626, 4), (0x0627, 2),
           (0x0628, 4), (0x0629, 2), (0x062A, 4), (0x062B, 4), (0x062C, 4), (0x062D, 4), (0x062E, 4),
           (0x062F, 2), (0x0630, 2), (0x0631, 2), (0x0632, 2), (0x0633, 4), (0x0634, 4), (0x0635, 4),
           (0x0636, 4), (0x0637, 4), (0x0638, 4), (0x0639, 4), (0x063A, 4), (0x0641, 4), (0x0642, 4),
           (0x0643, 4), (0x0644, 4), (0x0645, 4), (0x0646, 4), (0x0647, 4), (0x0648, 2), (0x0649, 2),
           (0x064A, 4)]
p = 0xFE80
for base, n in FORMS_B:
    for _ in range(n):
        t[p] = t[base]
        p += 1
assert p == 0xFEF5
for c in range(0xFEF5, 0xFEFD):
    t[c] = MULTI
for c in (0xFB50, 0xFB51):
    t[c] = ALEF
for c in range(0xFB8E, 0xFB92):
    t[c] = KAF
for c in range(0xFBFC, 0xFC00):
    t[c] = YEH
t[0xFDF2] = MULTI
t[0xFDFC] = MULTI
MULTI_MAP = {**{c: 'لا' for c in range(0xFEF5, 0xFEFD)}, 0xFDF2: 'الله', 0xFDFC: 'ريال'}


def dart(s):
    """Python port of ArabicNormalizer.normalize."""
    out, pend, last, run = [], False, -1, 0

    def emit(c):
        nonlocal pend, last, run
        if c == SP:
            if out:
                pend = True
            last, run = -1, 0
            return
        if pend:
            out.append(SP)
            pend = False
        if 0x621 <= c <= 0x64A:
            if c == last:
                run += 1
                if run == 3:
                    out.pop()
                if run >= 3:
                    return
            else:
                last, run = c, 1
        else:
            last, run = -1, 0
        out.append(c)

    for ch in s:
        c = ord(ch)
        if c > 0xFFFF:
            emit(c)
            continue
        m = t[c]
        if m == DROP or c == 0:
            continue
        if m == MULTI:
            for x in MULTI_MAP[c]:
                emit(ord(x))
            continue
        emit(m)
    return ''.join(map(chr, out))


# --------------------------------------------------------- SQL translate args
frm, to, drops = [], [], []
for c in range(1, 0x10000):
    m = t[c]
    if m == MULTI or m == c:
        continue
    if m == DROP:
        drops.append(c)
    else:
        frm.append(c)
        to.append(m)
FRM = ''.join(map(chr, frm + drops))
TO = ''.join(map(chr, to))
TRANS = {ord(a): (TO[i] if i < len(TO) else None) for i, a in enumerate(FRM)}


def sqlpipe(s):
    """What public.normalize_ar does, step by step."""
    for c, r in MULTI_MAP.items():
        s = s.replace(chr(c), r)
    s = s.translate(TRANS)
    s = re.sub('([ء-ي])\\1\\1+', '\\1', s)
    s = re.sub(' +', ' ', s).strip(' ')
    return s


def u(s):
    """Render as a PostgreSQL U&'' literal (safe for invisible characters)."""
    o = []
    for ch in s:
        if ch.isascii() and (ch.isalnum() or ch in ' ,;?*#+-.'):
            o.append(ch)
        else:
            o.append(BS + '%04X' % ord(ch))
    return "U&'" + ''.join(o) + "'"


def chunks(s, n=40):
    return ' ||\n      '.join(u(s[i:i + n]) for i in range(0, len(s), n))


def main():
    pool = [chr(c) for c in list(range(0x600, 0x700)) + list(range(0xFE70, 0xFF00)) + list(range(0x20, 0x7F))
            + list(range(0xC0, 0x180)) + [0x200B, 0x200F, 0xA0, 0x3000, 0xFF0A, 0xFF21, 0x2009, 0xFB50, 0xFDF2]]
    pool += ['ا', 'ا', 'ا', 'ة', ' ', ' ']
    random.seed(1)
    bad = 0
    for _ in range(100000):
        s = ''.join(random.choice(pool) for _ in range(random.randint(0, 12)))
        if dart(s) != sqlpipe(s):
            bad += 1
    print('random parity mismatches:', bad)

    out = os.path.join(ROOT, 'supabase', 'tools', 'out')
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, 'translate_from.sql'), 'w', encoding='utf-8', newline=LF) as f:
        f.write(chunks(FRM))
    with open(os.path.join(out, 'translate_to.sql'), 'w', encoding='utf-8', newline=LF) as f:
        f.write(chunks(TO))

    path = os.path.join(ROOT, 'test', 'core', 'search', 'fixtures', 'normalizer_cases.json')
    with open(path, encoding='utf-8') as f:
        fx = json.load(f)
    lines, fbad = [], 0
    for c in fx['cases']:
        for fn, name in ((dart, 'dart-port'), (sqlpipe, 'sql-pipeline')):
            if fn(c['input']) != c['expected']:
                fbad += 1
                print('FIXTURE MISMATCH', name, repr(c['name']))
        desc = ''.join(ch for ch in c['name'] if ch.isascii() and ch not in ("'", BS))[:60]
        lines.append("select is(public.normalize_ar(%s), %s, 'normalize_ar fixture: %s');"
                     % (u(c['input']), u(c['expected']), desc))
    with open(os.path.join(out, 'normalize_fixture_cases.sql'), 'w', encoding='utf-8', newline=LF) as f:
        f.write('\n'.join(lines) + '\n')
    print('fixture mismatches:', fbad, '| written to', out)


if __name__ == '__main__':
    main()
