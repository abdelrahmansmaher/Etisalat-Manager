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

  @override
  Widget build(BuildContext context) {
    final parts = segments(text);
    if (parts.every((p) => !p.$2)) {
      return Text(
        parts.map((p) => p.$1).join(),
        style: style,
        maxLines: maxLines,
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
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(s, style: effective),
                ),
              )
            else
              TextSpan(text: s),
        ],
      ),
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
    );
  }
}
