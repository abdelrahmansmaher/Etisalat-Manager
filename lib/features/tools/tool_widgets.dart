import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content.dart';
import '../../core/search/arabic_normalizer.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/prose_text.dart';
import '../../l10n/app_localizations.dart';
import '../../core/user/json_store.dart' show isoDate;
import 'dial_template.dart';
import 'package_info.dart';

/// Short message at the bottom.
void showToolMessage(BuildContext context, String text) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Bottom sheet above everything, lifted over the keyboard, scrollable at
/// any text size; its slide follows the reduced-motion setting.
Future<T?> showToolSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(
        duration: AppMotion.resolve(context, AppMotion.emphasized),
        reverseDuration: AppMotion.resolve(context, AppMotion.normal),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: builder(context),
      ),
    );

/// A text controller that lives as long as its sheet: it is disposed with the
/// sheet, after the closing animation, never while its field is still shown.
class SheetTextController extends StatefulWidget {
  const SheetTextController({super.key, this.text = '', required this.builder});

  final String text;
  final Widget Function(BuildContext context, TextEditingController controller)
  builder;

  @override
  State<SheetTextController> createState() => _SheetTextControllerState();
}

class _SheetTextControllerState extends State<SheetTextController> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

/// Scrolling column with sheet padding.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.md,
      0,
      AppSpacing.md,
      AppSpacing.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    ),
  );
}

/// Yes/no question; `true` only when confirmed.
Future<bool> askToConfirm(
  BuildContext context, {
  required String title,
  String? body,
  required String confirm,
  String? cancel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    animationStyle: AnimationStyle(
      duration: AppMotion.resolve(context, AppMotion.normal),
    ),
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancel ?? AppLocalizations.of(context).toolsCancel),
        ),
        FilledButton(
          key: const ValueKey('confirm-yes'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Where an item stands: icon + words. Green only for confirmed.
class ItemStatusTag extends StatelessWidget {
  const ItemStatusTag(this.item, {super.key});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final edited = item.editedAt;
    final (IconData icon, String label, Color color) = edited != null
        ? (
            AppIcons.toolEdits,
            l10n.toolsEditedOn(isoDate(edited)),
            c.textSecondary,
          )
        : switch (item.status) {
            ItemStatus.confirmed => (
              AppIcons.confirmed,
              l10n.toolsStatusConfirmed,
              c.verified,
            ),
            ItemStatus.unconfirmed => (
              AppIcons.unconfirmed,
              l10n.toolsStatusUnconfirmed,
              c.onWarningContainer,
            ),
            ItemStatus.conflict => (
              AppIcons.conflict,
              l10n.toolsStatusConflict,
              c.error,
            ),
          };
    return IconLine(icon: icon, text: label, color: color);
  }
}

/// Small icon + text line that wraps.
class IconLine extends StatelessWidget {
  const IconLine({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.textColor,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: AppIconSize.inline, color: color),
      ),
      const SizedBox(width: AppSpacing.xxs + 2),
      Flexible(
        child: ProseText(
          text,
          style: AppTypography.bodyM.copyWith(color: textColor ?? color),
        ),
      ),
    ],
  );
}

/// Number typed by the owner; accepts Arabic digits. `null` = empty or not
/// a number.
double? parseTypedNumber(String text) {
  final s = toAsciiDigits(text)
      .replaceAll(String.fromCharCode(0x66B), '.')
      .replaceAll(',', '')
      .trim();
  return RegExp(r'^\d{1,9}(\.\d{1,3})?$').hasMatch(s) ? double.parse(s) : null;
}

/// Labelled number field.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bad =
        controller.text.trim().isNotEmpty &&
        parseTypedNumber(controller.text) == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: AppTypography.labelL.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            textAlign: Directionality.of(context) == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            inputFormatters: [LengthLimitingTextInputFormatter(12)],
            decoration: InputDecoration(
              errorText: bad ? l10n.toolsInvalidNumber : null,
              errorMaxLines: 3,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// Price amount, whole and left-to-right, in gold (prices only).
class GoldAmount extends StatelessWidget {
  const GoldAmount(this.value, {super.key, this.large = false});

  final String value;
  final bool large;

  @override
  Widget build(BuildContext context) => ProseText(
    value,
    style: (large ? AppTypography.price : AppTypography.titleM).copyWith(
      color: context.colors.accentText,
    ),
  );
}

/// A value that may be a code (always left-to-right), or "not stated".
class ToolValue extends StatelessWidget {
  const ToolValue(this.value, {super.key, this.isCode = false, this.style});

  final String? value;
  final bool isCode;
  final TextStyle? style;

  static final RegExp _arabic = RegExp('[ء-ي]');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return Text(
        AppLocalizations.of(context).toolsNotStated,
        style: AppTypography.bodyM.copyWith(color: c.textTertiary),
      );
    }
    if (isCode && !_arabic.hasMatch(v)) {
      return CodeValue(v, style: style);
    }
    return ProseText(v, style: style ?? AppTypography.bodyM);
  }
}

/// Searchable list of packages; returns the chosen one.
Future<PackageInfo?> showPackagePicker(
  BuildContext context, {
  Set<String> exclude = const {},
}) => showToolSheet<PackageInfo>(
  context,
  (context) => _PackagePicker(exclude: exclude),
);

class _PackagePicker extends ConsumerStatefulWidget {
  const _PackagePicker({required this.exclude});

  final Set<String> exclude;

  @override
  ConsumerState<_PackagePicker> createState() => _PackagePickerState();
}

class _PackagePickerState extends ConsumerState<_PackagePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final words = normalizeArabic(_query)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    final found = [
      for (final p in ref.watch(packageInfosProvider))
        if (!widget.exclude.contains(p.item.id) && _matches(p, words)) p,
    ];
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.toolsPickPackage,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    key: const ValueKey('package-picker-search'),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.toolsSearchPackage,
                      prefixIcon: const Icon(AppIcons.search),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (found.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        l10n.toolsNoMatches,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyM.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemCount: found.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final p = found[i];
              return ListTile(
                key: ValueKey('pick-${p.item.id}'),
                title: ProseText(p.item.title),
                subtitle: p.priceText == null ? null : GoldAmount(p.priceText!),
                onTap: () => Navigator.pop(context, p),
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _matches(PackageInfo p, List<String> words) {
    if (words.isEmpty) return true;
    final i = p.item;
    final hay = normalizeArabic(
      '${i.title} ${i.titleEn ?? ''} ${p.family} ${p.priceText ?? ''} '
      '${p.codeText ?? ''} ${i.tags.join(' ')}',
    );
    return words.every(hay.contains);
  }
}
