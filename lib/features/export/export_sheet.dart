import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/glass_menu.dart';
import '../../core/widgets/glass_popups.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import 'export_pdf.dart';

/// Opens the share sheet: a formatted PDF, a text message, or a copy.
///
/// [pdf] builds the document; [text] is the plain version (omit it when
/// only a PDF makes sense, as for a comparison table).
Future<void> showExportSheet(
  BuildContext context, {
  required String title,
  required Future<Uint8List> Function(PdfExport pdf) pdf,
  String? text,
}) => showGlassSheet<void>(
  context,
  (context) => _ExportSheet(title: title, pdf: pdf, text: text),
);

/// Builds a PDF and hands it to the share sheet, with a toast on failure.
/// Used by buttons that export directly, without the sheet.
Future<bool> sharePdf(
  BuildContext context, {
  required String title,
  required Future<Uint8List> Function(PdfExport pdf) pdf,
}) async {
  final l10n = AppLocalizations.of(context);
  try {
    final bytes = await pdf(await PdfExport.create(l10n));
    final name = pdfFileName(title);
    final r = await SharePlus.instance.share(
      ShareParams(
        title: title,
        subject: title,
        files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: name)],
        fileNameOverrides: [name],
      ),
    );
    if (r.status == ShareResultStatus.unavailable) {
      if (context.mounted) showGlassToast(context, l10n.exportUnavailable);
      return false;
    }
    return true;
  } catch (e) {
    debugPrint('PDF export failed: $e');
    if (context.mounted) {
      showGlassToast(context, l10n.exportFailed, icon: AppIcons.conflict);
    }
    return false;
  }
}

/// `N-Core - <title>.pdf`, without characters file systems refuse.
String pdfFileName(String title) {
  final clean = title
      .replaceAll(RegExp('[\\/:*?"<>|\u200E\u200F\u2066-\u2069]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final short = clean.length > 60 ? clean.substring(0, 60).trim() : clean;
  return '${AppIdentity.nameEn} - $short.pdf';
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({required this.title, required this.pdf, this.text});

  final String title;
  final Future<Uint8List> Function(PdfExport pdf) pdf;
  final String? text;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _busy = false;

  Future<void> _sharePdf() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await sharePdf(context, title: widget.title, pdf: widget.pdf);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).maybePop();
  }

  Future<void> _shareText() async {
    final l10n = AppLocalizations.of(context);
    final text = widget.text!;
    var shared = false;
    try {
      final r = await SharePlus.instance.share(ShareParams(text: text));
      shared = r.status != ShareResultStatus.unavailable;
    } catch (_) {
      // No share sheet on this device or browser.
    }
    if (!mounted) return;
    if (!shared) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) showGlassToast(context, l10n.toolsSummaryCopied);
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: widget.text!));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    showGlassToast(context, l10n.exportCopied);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.exportTitle,
              style: AppTypography.titleL.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyM.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _PdfOption(busy: _busy, onTap: _sharePdf),
          if (widget.text != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _Option(
                    key: const ValueKey('export-text'),
                    icon: AppIcons.exportText,
                    hue: Hue.teal,
                    title: l10n.exportText,
                    hint: l10n.exportTextHint,
                    onTap: _shareText,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _Option(
                    key: const ValueKey('export-copy'),
                    icon: AppIcons.copy,
                    hue: Hue.slate,
                    title: l10n.exportCopy,
                    hint: l10n.exportCopyHint,
                    onTap: _copy,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The main option: a picture of the page beside its name.
class _PdfOption extends StatelessWidget {
  const _PdfOption({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      key: const ValueKey('export-pdf'),
      role: CardRole.flat,
      semanticLabel: l10n.exportPdf,
      onTap: busy ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const _PagePicture(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GlyphBadge(
                      icon: AppIcons.exportPdf,
                      hue: Hue.coral.of(c),
                      size: 30,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.exportPdf,
                        style: AppTypography.titleS.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: busy
                      ? Row(
                          key: const ValueKey('busy'),
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.exportPreparing,
                              style: AppTypography.bodyS.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.exportPdfHint,
                          key: const ValueKey('hint'),
                          style: AppTypography.bodyS.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.chevron,
            size: AppIconSize.action,
            color: c.textTertiary,
          ),
        ],
      ),
    );
  }
}

/// A small drawing of the exported page: navy header, a gold price and
/// lines of text.
class _PagePicture extends StatelessWidget {
  const _PagePicture();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget line(double w, {Color? color}) => Container(
      width: w,
      height: 3,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFD5DAE6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Container(
      width: 62,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF14246B), Color(0xFF0A1340)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 4, 7, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line(34, color: const Color(0xFF101828)),
                Container(
                  width: 48,
                  height: 12,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6DD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: line(16, color: const Color(0xFF9A6A00)),
                ),
                line(48),
                line(40),
                line(46),
                line(30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.icon,
    required this.hue,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final Hue hue;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      semanticLabel: title,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlyphBadge(icon: icon, hue: hue.of(c), size: 30),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.labelL.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            hint,
            style: AppTypography.bodyS.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Share button for page bars: opens [showExportSheet].
class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.title,
    required this.pdf,
    this.text,
  });

  final String title;
  final Future<Uint8List> Function(PdfExport pdf) pdf;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      key: const ValueKey('export-open'),
      tooltip: l10n.exportTitle,
      icon: const Icon(AppIcons.share),
      color: context.colors.primary,
      onPressed: () =>
          showExportSheet(context, title: title, pdf: pdf, text: text),
    );
  }
}
