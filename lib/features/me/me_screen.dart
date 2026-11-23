import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/trust/unofficial_disclaimer.dart';
import '../../l10n/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';

/// "Me": appearance + language switches, disclaimer, and the (disabled)
/// owner editor-mode entry.
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
        SectionHeader(l10n.settingsAppearance),
        const SizedBox(height: AppSpacing.sm),
        _GroupCard(
          child: RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (m) {
              if (m != null) ref.read(themeModeProvider.notifier).setMode(m);
            },
            child: Column(
              children: [
                _RadioRow(
                  key: const ValueKey('theme-system'),
                  value: ThemeMode.system,
                  icon: Icons.brightness_auto_outlined,
                  label: l10n.themeSystem,
                ),
                const _Divider(),
                _RadioRow(
                  key: const ValueKey('theme-light'),
                  value: ThemeMode.light,
                  icon: Icons.light_mode_outlined,
                  label: l10n.themeLight,
                ),
                const _Divider(),
                _RadioRow(
                  key: const ValueKey('theme-dark'),
                  value: ThemeMode.dark,
                  icon: Icons.dark_mode_outlined,
                  label: l10n.themeDark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(l10n.settingsLanguage),
        const SizedBox(height: AppSpacing.sm),
        _GroupCard(
          child: RadioGroup<String>(
            groupValue: locale.languageCode,
            onChanged: (code) {
              if (code != null) {
                ref.read(localeProvider.notifier).setLocale(Locale(code));
              }
            },
            child: Column(
              children: [
                _RadioRow(
                  key: const ValueKey('lang-ar'),
                  value: 'ar',
                  icon: Icons.translate,
                  label: l10n.languageArabic,
                ),
                const _Divider(),
                _RadioRow(
                  key: const ValueKey('lang-en'),
                  value: 'en',
                  icon: Icons.translate,
                  label: l10n.languageEnglish,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _GroupCard(
          child: ListTile(
            key: const ValueKey('editor-mode'),
            enabled: false,
            leading: Icon(Icons.edit_note_rounded, color: c.textTertiary),
            title: Text(l10n.editorModeTitle),
            subtitle: Text(l10n.editorModeSubtitle),
            trailing: Icon(Icons.lock_outline, color: c.textTertiary),
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xxs),
    child: child,
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md);
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({
    super.key,
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      value: value,
      title: Text(label),
      secondary: Icon(icon),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
