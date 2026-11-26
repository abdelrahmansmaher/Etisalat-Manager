import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import 'glass_popups.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import 'prose_text.dart';

/// Unicode bidi isolation helpers (doc 04 §2.9).
abstract final class Bidi {
  /// LEFT-TO-RIGHT ISOLATE.
  static final String lri = String.fromCharCode(0x2066);

  /// POP DIRECTIONAL ISOLATE.
  static final String pdi = String.fromCharCode(0x2069);

  /// Wraps [value] in LRI…PDI so it keeps LTR order when embedded in flowing
  /// RTL text (e.g. `'اطلب ${Bidi.ltr('*999#')} من الهاتف'`).
  static String ltr(String value) => '$lri$value$pdi';
}

/// Text that always lays out left-to-right, even inside an RTL tree.
///
/// Approach (doc 04 §2.9 "inside a component"): the paragraph gets its own
/// `TextDirection.ltr` base direction, so neutral characters like `*`, `#`,
/// `+` resolve LTR. No invisible isolate characters are inserted, so text
/// selection/copy yields the exact value. For values embedded in flowing
/// Arabic text use [Bidi.ltr] instead. Alignment follows the *outer*
/// direction, so in Arabic the value still sits at the visual start (right).
class LtrText extends StatelessWidget {
  const LtrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final outer = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final align =
        textAlign ??
        (outer == TextDirection.rtl ? TextAlign.right : TextAlign.left);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        text,
        style: style,
        textAlign: align,
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        semanticsLabel: semanticsLabel ?? text,
      ),
    );
  }
}

/// A code or phone number, whole and strictly left-to-right: it scales down
/// when space is short, it is never cut. Screen readers spell it.
class CodeValue extends StatelessWidget {
  const CodeValue(this.value, {super.key, this.style});

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: CodeText.spell(value, l10n),
      excludeSemantics: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        heightFactor: 1,
        child: CodeRuns(
          value,
          style: AppTypography.code
              .copyWith(color: context.colors.textPrimary)
              .merge(style),
        ),
      ),
    );
  }
}

/// Dial / copy buttons of a code or phone number.
class CodeActions extends StatelessWidget {
  const CodeActions(this.value, {super.key, this.onCall});

  final String value;

  /// Shown only for values a phone can dial (see [isDialable]).
  final ValueChanged<String>? onCall;

  static final RegExp _dialable = RegExp(r'^[0-9*#+\s\-]+$');

  /// Digits and `* # +` only: `*556*رقم الكارت#` must be completed first.
  static bool isDialable(String value) => _dialable.hasMatch(value.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onCall != null && isDialable(value))
          IconButton(
            key: ValueKey('dial-$value'),
            icon: const Icon(AppIcons.call, size: AppIconSize.action),
            color: c.primary,
            tooltip: l10n.callValueSemantics(value),
            onPressed: () => onCall!(value),
          ),
        IconButton(
          key: ValueKey('copy-$value'),
          icon: const Icon(AppIcons.copy, size: AppIconSize.action),
          color: c.primary,
          tooltip: l10n.copyValueSemantics(value),
          onPressed: () => CodeText.copyToClipboard(context, value),
        ),
      ],
    );
  }
}

/// A code with its copy (and dial) buttons, on a soft chip.
class CodeText extends StatelessWidget {
  const CodeText(this.value, {super.key, this.onCall});

  final String value;
  final ValueChanged<String>? onCall;

  /// Spoken form of a code for TalkBack, character by character.
  static String spell(String value, AppLocalizations l10n) {
    final parts = <String>[];
    for (final ch in value.split('')) {
      switch (ch) {
        case '*':
          parts.add(l10n.symbolStar);
        case '#':
          parts.add(l10n.symbolHash);
        case '+':
          parts.add(l10n.symbolPlus);
        case ' ':
          break;
        default:
          parts.add(ch);
      }
    }
    return parts.join(' ');
  }

  /// Copies [value] exactly and confirms with a short snackbar (<= 1.5 s).
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
  ) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
    showGlassToast(
      context,
      l10n.copiedMessage,
      icon: AppIcons.copy,
      duration: AppMotion.copyConfirmation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: AppRadius.smAll,
              ),
              child: CodeValue(value),
            ),
          ),
        ),
        CodeActions(value, onCall: onCall),
      ],
    );
  }
}
