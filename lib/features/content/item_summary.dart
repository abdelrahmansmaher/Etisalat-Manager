import '../../core/content/content_models.dart';

/// Without the invisible direction marks added around codes for display.
String _plain(String s) => s.replaceAll(String.fromCharCode(0x200E), '');

/// Plain text of an item, ready to send to a customer: name, summary, every
/// stated value and the steps. No sources, notes or internal conditions.
String customerSummary(ContentItem item) {
  final summary = _plain(item.summary);
  final facts = [
    for (final f in item.facts)
      if (!f.isBlank) '${f.label}: ${_plain(f.display)}',
  ];
  // Codes and numbers that no fact mentions.
  final stated = facts.join('\n');
  final extra = [
    for (final v in [...item.codes, ...item.phones])
      if (!stated.contains(v) && !summary.contains(v)) v,
  ];
  return [
    item.title,
    if (facts.isEmpty && summary.isNotEmpty) summary,
    ...facts,
    ...extra,
    for (final (i, s) in item.steps.indexed) '${i + 1}. ${_plain(s)}',
  ].join('\n');
}
