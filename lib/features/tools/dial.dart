import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/ltr_text.dart';
import '../../l10n/app_localizations.dart';
import 'dial_template.dart';
import 'tool_widgets.dart';

/// Opens a `tel:` link; replaced in tests.
typedef DialOpener = Future<bool> Function(Uri uri);

final dialOpenerProvider = Provider<DialOpener>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Opens the phone's dialer with [value] filled in; the user presses call.
///
/// A value with placeholders (`*557*رقم المستلم*المبلغ#`) asks for each one
/// first, and a value listing several codes asks which. Nothing typed is
/// stored. When the dialer does not open, the code is copied and said so.
Future<void> launchDial(BuildContext context, String value) =>
    launchDialAny(context, [value]);

/// Like [launchDial] when an item has several codes or numbers.
Future<void> launchDialAny(BuildContext context, List<String> values) async {
  final l10n = AppLocalizations.of(context);
  final open = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(dialOpenerProvider);

  final all = <String, DialTemplate>{
    for (final v in values)
      for (final t in DialTemplate.parseAll(v)) t.display: t,
  };
  if (all.isEmpty) {
    if (values.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: values.first));
    if (context.mounted) showToolMessage(context, l10n.toolsDialNothing);
    return;
  }

  DialTemplate? template = all.values.first;
  if (all.length > 1) {
    template = await showToolSheet<DialTemplate>(
      context,
      (context) => _ChooseSheet(options: all.values.toList()),
    );
  }
  if (template == null || !context.mounted) return;

  var number = template.display;
  if (template.needsInput) {
    final filled = await showToolSheet<String>(
      context,
      (context) => _FillSheet(template: template!),
    );
    if (filled == null || !context.mounted) return;
    number = filled;
  }

  bool opened;
  try {
    opened = await open(telUri(number));
  } catch (_) {
    opened = false;
  }
  if (opened) return;
  // What was typed may be a PIN or a customer's number, so only the code as
  // written goes to the clipboard.
  await Clipboard.setData(ClipboardData(text: template.display));
  if (!context.mounted) return;
  showToolMessage(
    context,
    template.needsInput
        ? l10n.toolsDialFailedTemplate
        : l10n.toolsDialFailed(Bidi.ltr(template.display)),
  );
}

class _ChooseSheet extends StatelessWidget {
  const _ChooseSheet({required this.options});

  final List<DialTemplate> options;

  @override
  Widget build(BuildContext context) => SheetBody(
    title: AppLocalizations.of(context).toolsDialChoose,
    children: [
      for (final o in options)
        ListTile(
          key: ValueKey('dial-option-${o.display}'),
          contentPadding: EdgeInsets.zero,
          leading: Icon(AppIcons.call, color: context.colors.primary),
          title: ToolValue(o.display, isCode: true),
          onTap: () => Navigator.pop(context, o),
        ),
    ],
  );
}

class _FillSheet extends StatefulWidget {
  const _FillSheet({required this.template});

  final DialTemplate template;

  @override
  State<_FillSheet> createState() => _FillSheetState();
}

class _FillSheetState extends State<_FillSheet> {
  late final Map<String, TextEditingController> _fields = {
    for (final p in widget.template.placeholders) p: TextEditingController(),
  };
  bool _tried = false;

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  String _digits(String name) => toAsciiDigits(_fields[name]!.text).trim();

  bool _valid(String name) => RegExp(r'^[0-9]+$').hasMatch(_digits(name));

  void _submit() {
    setState(() => _tried = true);
    if (!_fields.keys.every(_valid)) return;
    Navigator.pop(
      context,
      widget.template.fill({for (final n in _fields.keys) n: _digits(n)}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SheetBody(
      title: l10n.toolsDialFillTitle,
      children: [
        Text(
          l10n.toolsDialFillHint,
          style: AppTypography.bodyM.copyWith(color: c.textSecondary),
        ),
        for (final (i, name) in _fields.keys.indexed) ...[
          const SizedBox(height: AppSpacing.sm),
          ExcludeSemantics(
            child: Text(
              name,
              style: AppTypography.labelL.copyWith(color: c.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Semantics(
            label: name,
            child: TextField(
              key: ValueKey('dial-field-$i'),
              controller: _fields[name],
              autofocus: i == 0,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]')),
                LengthLimitingTextInputFormatter(24),
              ],
              decoration: InputDecoration(
                isDense: true,
                errorText: _tried && !_valid(name)
                    ? l10n.toolsDialDigitsOnly
                    : null,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          key: const ValueKey('dial-open'),
          onPressed: _submit,
          icon: const Icon(AppIcons.call),
          label: Text(l10n.toolsDialOpen),
        ),
      ],
    );
  }
}
