import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';

/// "Me": appearance + language (segmented capsules, persisted, follow the
/// device by default) and the (disabled) editor-mode entry.
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return PageScaffold(
      title: l10n.meTitle,
      subtitle: AppIdentity.of(context),
      children: [
        _SettingGroup(
          icon: AppIcons.appearance,
          title: l10n.settingsAppearance,
          hint: l10n.settingsAppearanceHint,
          child: SegmentedCapsule<ThemeMode>(
            key: const ValueKey('theme-segments'),
            selected: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setMode(m),
            segments: [
              CapsuleSegment(
                key: const ValueKey('theme-system'),
                value: ThemeMode.system,
                icon: AppIcons.themeSystem,
                label: l10n.themeSystem,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-light'),
                value: ThemeMode.light,
                icon: AppIcons.themeLight,
                label: l10n.themeLight,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-dark'),
                value: ThemeMode.dark,
                icon: AppIcons.themeDark,
                label: l10n.themeDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingGroup(
          icon: AppIcons.language,
          title: l10n.settingsLanguage,
          child: SegmentedCapsule<String>(
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
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          role: CardRole.flat,
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.xxs,
          ),
          child: ListTile(
            key: const ValueKey('editor-mode'),
            enabled: false,
            leading: Icon(AppIcons.edit, color: c.textTertiary),
            title: Text(l10n.editorModeTitle),
            subtitle: Text(l10n.editorModeSubtitle),
            trailing: Icon(AppIcons.lock, color: c.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({
    required this.icon,
    required this.title,
    required this.child,
    this.hint,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return AppCard(
      role: CardRole.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TintedIcon(icon, tile: IconTile.sm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (hint != null)
                      Text(
                        hint!,
                        style: AppTypography.labelS.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
