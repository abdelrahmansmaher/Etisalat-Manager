import 'package:flutter/foundation.dart';

/// One piece of a dialable code: literal characters, or a value to ask for.
@immutable
class DialPart {
  const DialPart.literal(this.text) : isPlaceholder = false;
  const DialPart.placeholder(this.text) : isPlaceholder = true;

  final String text;
  final bool isPlaceholder;
}

/// A code or phone number that can be opened in the dialer, possibly with
/// placeholders such as `*557*رقم المستلم*المبلغ#`.
@immutable
class DialTemplate {
  const DialTemplate(this.parts);

  final List<DialPart> parts;

  /// Distinct placeholder names, in order. The same name is asked once.
  List<String> get placeholders => [
    ...{
      for (final p in parts)
        if (p.isPlaceholder) p.text,
    },
  ];

  bool get needsInput => parts.any((p) => p.isPlaceholder);

  /// The code as written.
  String get display => parts.map((p) => p.text).join();

  /// The code with every placeholder replaced.
  String fill(Map<String, String> values) => parts
      .map((p) => p.isPlaceholder ? toAsciiDigits(values[p.text] ?? '') : p.text)
      .join();

  static final RegExp _marks = RegExp('[\u200E\u200F\u2066-\u2069]');
  static final RegExp _plain = RegExp(r'^[*#+0-9]+$');
  static final RegExp _phone = RegExp(r'^\+?[0-9][0-9\s\-().]*$');
  static final RegExp _segment = RegExp(r'[*#]+|[^*#]+');
  static final RegExp _digits = RegExp(r'^[0-9]+$');

  /// Words of a placeholder: letters and spaces, optionally digits.
  static final RegExp _placeholder = RegExp(
    r'^[A-Za-z\u0621-\u064A][A-Za-z0-9\u0621-\u064A\u064B-\u0652 ]*$',
  );

  /// Words that make the text a sentence, not a placeholder.
  static final RegExp _sentence = RegExp(
    r'(^|\s)(ثم|أو|او|من|واختار|اختار|اتبع|على|My)(\s|$)',
  );
  static final RegExp _codeInText = RegExp(r'[*#]+[0-9][0-9*#]*#?');
  static final RegExp _phoneInText = RegExp(r'\+?[0-9][0-9\-]{2,}');

  /// Every dialable code in [value]: usually one; several when the text
  /// lists alternatives; empty when there is nothing to dial.
  static List<DialTemplate> parseAll(String value) {
    final v = toAsciiDigits(value.replaceAll(_marks, '')).trim();
    if (v.isEmpty) return const [];
    if (_plain.hasMatch(v) && _digitsOf(v).isNotEmpty) {
      return [
        DialTemplate([DialPart.literal(v)]),
      ];
    }
    if (_phone.hasMatch(v)) {
      return [
        DialTemplate([DialPart.literal(v.replaceAll(RegExp(r'[^0-9+]'), ''))]),
      ];
    }
    final template = _template(v);
    if (template != null) return [template];

    final codes = {for (final m in _codeInText.allMatches(v)) m[0]!};
    final found = codes.isNotEmpty
        ? codes
        : {
            for (final m in _phoneInText.allMatches(v))
              m[0]!.replaceAll('-', ''),
          };
    return [
      for (final c in found) DialTemplate([DialPart.literal(c)]),
    ];
  }

  static DialTemplate? _template(String v) {
    if (!v.startsWith('*') && !v.startsWith('#')) return null;
    final parts = <DialPart>[];
    for (final m in _segment.allMatches(v)) {
      final s = m[0]!.trim();
      if (s.isEmpty) return null;
      if (s.startsWith('*') || s.startsWith('#') || _digits.hasMatch(s)) {
        parts.add(DialPart.literal(s));
      } else if (_placeholder.hasMatch(s) && !_sentence.hasMatch(s)) {
        parts.add(DialPart.placeholder(s));
      } else {
        return null;
      }
    }
    final t = DialTemplate(parts);
    return t.needsInput ? t : null;
  }

  static String _digitsOf(String s) => s.replaceAll(RegExp('[^0-9]'), '');
}

/// `tel:` link of a filled code; `#` must be percent-encoded.
Uri telUri(String dialable) =>
    Uri.parse('tel:${dialable.replaceAll('#', '%23')}');

/// Arabic-Indic and Persian digits as ASCII.
String toAsciiDigits(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      b.writeCharCode(r - 0x0660 + 0x30);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      b.writeCharCode(r - 0x06F0 + 0x30);
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}
