import 'package:flutter/material.dart';

/// Arabic prose that may contain USSD/MMI codes such as `*319#`.
///
/// Each code is rendered as its own left-to-right inline widget, so it can
/// never be reordered by the bidi algorithm (in RTL text `*319#` would
/// otherwise be able to show as `#319*`). This does not depend on the text
/// engine honouring invisible direction marks, which the web renderer does
/// not reliably do.
class ProseText extends StatelessWidget {
  const ProseText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Matches codes like `*319#`, `*566*2375#`, `##002#`, `*#06#`.
  static final RegExp codePattern = RegExp(r'[*#]+[0-9][0-9*#]*#?');

  static final RegExp _marks = RegExp(
    '[${String.fromCharCode(0x200E)}${String.fromCharCode(0x200F)}'
    '${String.fromCharCode(0x2066)}-${String.fromCharCode(0x2069)}]',
  );

  /// Splits [text] into plain and code segments (code = `true`).
  static List<(String, bool)> segments(String text) {
    final clean = text.replaceAll(_marks, '');
    final out = <(String, bool)>[];
    var last = 0;
    for (final m in codePattern.allMatches(clean)) {
      if (m.start > last) out.add((clean.substring(last, m.start), false));
      out.add((m[0]!, true));
      last = m.end;
    }
    if (last < clean.length) out.add((clean.substring(last), false));
    return out;
  }

  static final RegExp _arabic = RegExp('[\u0600-\u06FF]');

  @override
  Widget build(BuildContext context) {
    final parts = segments(text);
    // Arabic content keeps a right-to-left paragraph even in the English UI
    // (otherwise "28 يوم (شهرية)" or a trailing code reorders), aligned to
    // the outer start edge.
    final outer = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final arabicInLtr = outer == TextDirection.ltr && _arabic.hasMatch(text);
    final direction = arabicInLtr ? TextDirection.rtl : null;
    final align = arabicInLtr ? TextAlign.left : null;
    if (parts.every((p) => !p.$2)) {
      return Text(
        parts.map((p) => p.$1).join(),
        style: style,
        maxLines: maxLines,
        textDirection: direction,
        textAlign: align,
        overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
      );
    }
    final effective = DefaultTextStyle.of(context).style.merge(style);
    return Text.rich(
      TextSpan(
        children: [
          for (final (s, isCode) in parts)
            if (isCode)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: CodeRuns(s, style: effective),
              )
            else
              TextSpan(text: s),
        ],
      ),
      style: style,
      maxLines: maxLines,
      textDirection: direction,
      textAlign: align,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
    );
  }
}

/// A USSD/MMI code laid out strictly left-to-right as a row of runs (digit
/// groups and single `*` / `#` / `+` symbols).
///
/// The order comes from widget layout, not from the text engine's bidi
/// algorithm, so it is identical on every renderer — the web renderer was
/// seen to reorder a lone code like `*319*52#` into `#52*319*` when it wraps
/// onto its own line inside right-to-left prose. Screen readers get the
/// whole code as one label.
class CodeRuns extends StatelessWidget {
  const CodeRuns(this.code, {super.key, this.style});

  final String code;
  final TextStyle? style;

  static final RegExp _runs = RegExp(r'[0-9]+|[^0-9]');

  @override
  Widget build(BuildContext context) {
    final runs = [for (final m in _runs.allMatches(code)) m[0]!];
    return Semantics(
      label: code,
      excludeSemantics: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        // Never wider than the line: shrinks instead of overflowing at
        // large text scales.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            key: ValueKey('code-runs-$code'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              for (final r in runs)
                Text(r, style: style, textDirection: TextDirection.ltr),
            ],
          ),
        ),
      ),
    );
  }
}
