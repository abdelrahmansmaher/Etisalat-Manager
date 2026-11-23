import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/capsules.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';

/// "Me": appearance + language (segmented capsules, persisted, follow the
/// device by default), disclaimer, and the (disabled) editor-mode entry.
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
          icon: Icons.palette_rounded,
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
                icon: Icons.brightness_auto_rounded,
                label: l10n.themeSystem,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-light'),
                value: ThemeMode.light,
                icon: Icons.light_mode_rounded,
                label: l10n.themeLight,
              ),
              CapsuleSegment(
                key: const ValueKey('theme-dark'),
                value: ThemeMode.dark,
                icon: Icons.dark_mode_rounded,
                label: l10n.themeDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingGroup(
          icon: Icons.translate_rounded,
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
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.xxs,
          ),
          child: ListTile(
            key: const ValueKey('editor-mode'),
            enabled: false,
            leading: Icon(Icons.edit_note_rounded, color: c.textTertiary),
            title: Text(l10n.editorModeTitle),
            subtitle: Text(l10n.editorModeSubtitle),
            trailing: Icon(Icons.lock_rounded, color: c.textTertiary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.aboutTitle),
        const SizedBox(height: AppSpacing.sm),
        const UnofficialDisclaimer.full(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TintedIcon(icon, size: 36),
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
