import 'package:flutter/material.dart';

import '../../core/content/content_models.dart';
import '../../core/search/arabic_normalizer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/sim_shape.dart';

/// Where a package lives in the Packages tab.
enum PackageSegment {
  /// Voice and mixed bundles, prepaid and postpaid.
  mobile,

  /// Data for a mobile line.
  mobileInternet,

  /// Home internet (wireless, DSL) and the landline.
  home;

  static PackageSegment? fromKey(String? key) {
    for (final s in values) {
      if (s.name == key) return s;
    }
    return null;
  }

  static const _homeWords = [
    'منزلي',
    'ارضي',
    'هوايي',
    'لاسلكي',
    'dsl',
    'home',
    'wireless',
    'landline',
    'راوتر',
  ];

  /// Bundles listed with the internet content that are really mobile lines.
  static const _mobileWords = [
    'كارت اقوي',
    'اقوي كارت',
    'انظمه اليوم',
    'حكايه ميكس',
    'حكايه الشهريه',
  ];

  static PackageSegment of(ContentItem i) {
    // Listed next to the landline plans, but used on a mobile line.
    if (i.family == 'ro2ya') return mobile;
    final text = ArabicNormalizer.normalize('${i.category} ${i.family ?? ''}');
    bool has(List<String> words) => words.any(text.contains);
    if (has(_homeWords)) return home;
    if (has(_mobileWords)) return mobile;
    final net = text.contains('انترنت');
    return i.section == ContentSection.internet || net
        ? mobileInternet
        : mobile;
  }
}

/// Families whose name differs from the group they are listed in.
const Map<String, String> _familyNames = {
  'landline': 'الخط الأرضي',
  'ro2ya': 'رؤية',
};

final RegExp _slug = RegExp(r'^[a-z0-9-]+$');

/// Family name of a package, always in readable words: a data slug
/// (`super-connect`) becomes its Arabic name or the item's group; anything
/// else is shown as written.
String familyOf(ContentItem item) {
  final f = item.family;
  if (f != null) {
    final named = _familyNames[f];
    if (named != null) return named;
    if (!_slug.hasMatch(f)) return f;
  }
  final c = item.category.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  return c.isEmpty ? item.category : c;
}

/// Colour and monogram of a package family.
///
/// Calm, distinct hues. Gold, green and red are excluded on purpose: they
/// mean price, confirmed and error.
@immutable
class FamilyStyle {
  const FamilyStyle._(this.color, this.darkColor, this.monogram);

  final Color color;
  final Color darkColor;
  final String monogram;

  Color fill(Brightness b) => b == Brightness.dark ? darkColor : color;

  /// (light fill, dark fill); white text is AA on every one.
  static const List<(Color, Color)> palette = [
    (Color(0xFF2446A6), Color(0xFF3355B8)), // royal blue
    (Color(0xFF0B6A94), Color(0xFF13719B)), // azure
    (Color(0xFF5A3DA6), Color(0xFF6A4DB8)), // violet
    (Color(0xFF8A2E66), Color(0xFF9A3F77)), // plum
    (Color(0xFF3F5E86), Color(0xFF4C6C96)), // steel
    (Color(0xFF0E7280), Color(0xFF137582)), // cyan
    (Color(0xFF7A4A5E), Color(0xFF87566B)), // mauve
    (Color(0xFF3B3F8F), Color(0xFF5155AB)), // indigo
  ];

  /// Known families first (specific before general), so they keep their
  /// colour whatever else the content holds.
  static const List<(List<String>, int, String)> _known = [
    (['اضاف', 'booster'], 4, '+'),
    (['super connect', 'سوبر كونكت'], 5, 'سك'),
    (['super hours', 'sa3at', 'ساعات'], 2, 'سا'),
    (['super mega', 'سوبر ميجا', 'mbs', 'ميجابايتس'], 1, 'سم'),
    (['emerald', 'ايميرالد'], 7, 'إي'),
    (['ميني'], 6, 'مح'),
    (['حكايه انترنت'], 1, 'حن'),
    (['حكايه', 'hekaya'], 0, 'ح'),
    (['اقوي'], 3, 'كأ'),
    (['data line', 'داتا'], 4, 'د'),
    (['بريمو', 'primo'], 2, 'ب'),
    (['رويه'], 5, 'ر'),
    (['خط ارضي', 'الخط الارضي', 'landline'], 4, 'أ'),
    (['ارضي', 'dsl'], 0, 'DSL'),
    (['هوايي', 'لاسلكي', 'wireless', 'home'], 2, '4G'),
    (['فاتوره'], 7, 'ف'),
    (['انظمه اليوم'], 6, 'يوم'),
    (['تجوال'], 1, 'ت'),
    (['زوار'], 5, 'ز'),
  ];

  static final Map<String, FamilyStyle> _cache = {};

  static FamilyStyle of(String family) => _cache.putIfAbsent(family, () {
    final n = ArabicNormalizer.normalize(family);
    for (final (words, hue, mono) in _known) {
      if (words.any((w) => n.contains(w))) {
        return FamilyStyle._(palette[hue].$1, palette[hue].$2, mono);
      }
    }
    final hash = n.codeUnits.fold(7, (a, b) => (a * 31 + b) & 0xffffff);
    final (light, dark) = palette[hash % palette.length];
    return FamilyStyle._(light, dark, _initial(n));
  });

  static String _initial(String normalized) {
    final words = [
      for (final w in normalized.split(' '))
        if (w.isNotEmpty && !const {'باقه', 'باقات', 'انظمه'}.contains(w)) w,
    ];
    if (words.isEmpty) return '•';
    var w = words.first;
    if (w.startsWith('ال') && w.length > 3) w = w.substring(2);
    return w.characters.first.toUpperCase();
  }
}

/// SIM-shaped tile in the family colour with its monogram.
class FamilyTile extends StatelessWidget {
  const FamilyTile(this.family, {super.key});

  final String family;

  static const double width = 32;
  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final style = FamilyStyle.of(family);
    final fill = style.fill(
      context.colors.isDark ? Brightness.dark : Brightness.light,
    );
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        // A small glass SIM: lit from the top, with a bright rim and a
        // glow in its own colour.
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(Colors.white.withValues(alpha: 0.22), fill),
              fill,
            ],
          ),
          shape: SimShape(
            radius: 6,
            cut: 9,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
          ),
          shadows: [
            BoxShadow(
              color: fill.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: -2,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            style.monogram,
            textScaler: TextScaler.noScaling,
            style: AppTypography.titleS.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
