import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';

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

/// A copyable USSD code / phone number / ID rendered LTR in monospace.
///
/// * Copy button (one tap) puts the exact [value] on the clipboard and shows a
///   short snackbar (≤ 1.5 s); [onCopied] lets callers log it.
/// * [onCall] shows a call button — wiring to a dialer (url_launcher) is the
///   caller's job; this widget only exposes the hook.
/// * Screen readers spell the code ("star, 9, 9, 9, hash").
class CodeText extends StatelessWidget {
  const CodeText(
    this.value, {
    super.key,
    this.copyable = true,
    this.onCopied,
    this.onCall,
    this.style,
    this.dense = false,
  });

  final String value;
  final bool copyable;
  final ValueChanged<String>? onCopied;
  final ValueChanged<String>? onCall;
  final TextStyle? style;

  /// Text only, no chip background (for inline use).
  final bool dense;

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

  Future<void> _copy(BuildContext context, AppLocalizations l10n) async {
    onCopied?.call(value);
    await copyToClipboard(context, value);
  }

  /// Copies [value] exactly and confirms with a short snackbar (<= 1.5 s).
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
  ) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.copiedMessage),
          duration: AppMotion.copyConfirmation,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final textStyle = (style ?? AppTypography.code).copyWith(
      color: style?.color ?? c.textPrimary,
    );

    final text = LtrText(
      value,
      style: textStyle,
      semanticsLabel: spell(value, l10n),
    );

    if (dense && !copyable && onCall == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: dense
              ? text
              : Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: c.surfaceVariant,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: text,
                ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(AppIcons.copy, size: AppIconSize.action),
            tooltip: l10n.copyValueSemantics(value),
            onPressed: () => _copy(context, l10n),
          ),
        if (onCall != null) ...[
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(AppIcons.call, size: AppIconSize.action),
            tooltip: l10n.callAction,
            onPressed: () => onCall!(value),
          ),
        ],
      ],
    );
  }
}
