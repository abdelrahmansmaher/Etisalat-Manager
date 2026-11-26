import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/list_surface.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/prose_text.dart';
import '../../core/widgets/trust/trust.dart';
import '../../l10n/app_localizations.dart';
import '../content/content_widgets.dart';
import 'whats_new.dart';

/// Changelog of bundled prices, codes, and added/removed items across updates.
class WhatsNewScreen extends ConsumerStatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  ConsumerState<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends ConsumerState<WhatsNewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(whatsNewProvider.notifier).markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final async = ref.watch(whatsNewProvider);
    final updates = async.value ?? const <ContentUpdate>[];
    final locale = Localizations.localeOf(context);

    return PageScaffold(
      title: l10n.toolsWhatsNewTitle,
      children: [
        if (async.isLoading && async.value == null)
          const ContentLoading()
        else if (updates.isEmpty)
          PlaceholderPanel(
            icon: AppIcons.toolWhatsNew,
            title: l10n.toolsWhatsNewEmpty,
            body: l10n.toolsWhatsNewEmptyBody,
          )
        else
          for (final u in updates) ...[
            GroupHeader(l10n.toolsWhatsNewOn(TrustFormat.date(u.at, locale))),
            if (u.added.isNotEmpty || u.removed > 0) ...[
              AppCard(
                role: CardRole.flat,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (u.added.isNotEmpty)
                      Text(
                        l10n.toolsWhatsNewAdded(u.added.length),
                        style: AppTypography.titleS.copyWith(color: c.verified),
                      ),
                    for (final (id, title) in u.added.take(6))
                      InkWell(
                        onTap: () => context.push(ContentRoutes.item(id)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ProseText(
                            '• $title',
                            style: AppTypography.bodyM.copyWith(
                              color: c.primary,
                            ),
                          ),
                        ),
                      ),
                    if (u.added.length > 6)
                      Text(
                        l10n.toolsWhatsNewMore(u.added.length - 6),
                        style: AppTypography.labelS.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    if (u.removed > 0) ...[
                      if (u.added.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        l10n.toolsWhatsNewRemoved(u.removed),
                        style: AppTypography.bodyM.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (u.changes.isNotEmpty)
              ListSurface(
                children: [
                  for (final ch in u.changes)
                    InkWell(
                      onTap: () => context.push(ContentRoutes.item(ch.id)),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProseText(
                              ch.title,
                              style: AppTypography.titleS.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _DiffPill(
                                  label: l10n.toolsWas,
                                  value: ch.before.isEmpty
                                      ? l10n.toolsNotStated
                                      : ch.before,
                                  fg: c.textSecondary,
                                  bg: c.surfaceVariant,
                                ),
                                Icon(
                                  AppIcons.arrowForward,
                                  size: AppIconSize.inline,
                                  color: c.textTertiary,
                                ),
                                _DiffPill(
                                  label: l10n.toolsNow,
                                  value: ch.after.isEmpty
                                      ? l10n.toolsNotStated
                                      : ch.after,
                                  fg: c.onPrimaryContainer,
                                  bg: c.primaryContainer,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
      ],
    );
  }
}

class _DiffPill extends StatelessWidget {
  const _DiffPill({
    required this.label,
    required this.value,
    required this.fg,
    required this.bg,
  });

  final String label;
  final String value;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.xsAll),
      child: ProseText(
        '$label: $value',
        style: AppTypography.labelL.copyWith(color: fg),
      ),
    );
  }
}
