import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/masthead.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';
import '../content/content_widgets.dart';
import '../content/section_ui.dart';
import '../tools/tool_routes.dart';

/// "More" tab: the remaining sections, the owner's tools, appearance and
/// language.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    Widget section(ContentSection s) => _MoreRow(
      key: ValueKey('more-${s.key}'),
      icon: s.icon,
      label: s.title(l10n),
      onTap: () => context.push(ContentRoutes.section(s.key)),
    );
    Widget tool(String key, IconData icon, String label, String route) =>
        _MoreRow(
          key: ValueKey('more-$key'),
          icon: icon,
          label: label,
          onTap: () => context.push(route),
        );

    return TabScaffold(
      scrollKey: const ValueKey('more-scroll'),
      top: MastheadTitle(l10n.navMore),
      children: [
        GroupHeader(l10n.homeSectionsTitle),
        ListSurface(
          children: [
            section(ContentSection.procedures),
            section(ContentSection.wallet),
            section(ContentSection.glossary),
            section(ContentSection.company),
          ],
        ),
        GroupHeader(l10n.moreToolsTitle),
        ListSurface(
          children: [
            tool(
              'training',
              AppIcons.training,
              l10n.trainingTitle,
              ToolRoutes.training,
            ),
            tool(
              'notes',
              AppIcons.toolNotes,
              l10n.moreNotes,
              ToolRoutes.notes,
            ),
            tool('editor', AppIcons.toolEdits, l10n.moreEditor, ToolRoutes.editor),
            tool(
              'whats-new',
              AppIcons.toolWhatsNew,
              l10n.moreWhatsNew,
              ToolRoutes.whatsNew,
            ),
          ],
        ),
        GroupHeader(l10n.moreSettingsTitle),
        AppCard(
          role: CardRole.flat,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingLabel(l10n.settingsAppearance),
              SegmentedCapsule<ThemeMode>(
                key: const ValueKey('theme-segments'),
                selected: themeMode,
                onChanged: (m) =>
                    ref.read(themeModeProvider.notifier).setMode(m),
                segments: [
                  CapsuleSegment(
                    key: const ValueKey('theme-system'),
                    value: ThemeMode.system,
                    label: l10n.themeSystem,
                  ),
                  CapsuleSegment(
                    key: const ValueKey('theme-light'),
                    value: ThemeMode.light,
                    label: l10n.themeLight,
                  ),
                  CapsuleSegment(
                    key: const ValueKey('theme-dark'),
                    value: ThemeMode.dark,
                    label: l10n.themeDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _SettingLabel(l10n.settingsLanguage),
              SegmentedCapsule<String>(
                key: const ValueKey('lang-segments'),
                selected: locale?.languageCode ?? 'system',
                onChanged: (code) => ref
                    .read(localeProvider.notifier)
                    .setLocale(code == 'system' ? null : Locale(code)),
                segments: [
                  CapsuleSegment(
                    key: const ValueKey('lang-system'),
                    value: 'system',
                    label: l10n.languageSystem,
                  ),
                  CapsuleSegment(
                    key: const ValueKey('lang-ar'),
                    value: 'ar',
                    label: l10n.languageArabic,
                  ),
                  CapsuleSegment(
                    key: const ValueKey('lang-en'),
                    value: 'en',
                    label: l10n.languageEnglish,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: AppSpacing.xxs,
      bottom: AppSpacing.xs,
    ),
    child: Text(
      text,
      style: AppTypography.labelL.copyWith(
        color: context.colors.textSecondary,
      ),
    ),
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppIconSize.nav, color: c.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.titleM.copyWith(color: c.textPrimary),
                ),
              ),
              Icon(
                AppIcons.chevron, // mirrors in RTL
                size: AppIconSize.action,
                color: c.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
