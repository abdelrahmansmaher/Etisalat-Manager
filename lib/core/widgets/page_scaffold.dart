import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

/// Standard scrolling page: large title + optional subtitle, then content.
/// Bottom padding clears the floating nav bar (Scaffold.extendBody).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final pad = AppSpacing.screenPaddingFor(width);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            pad,
            AppSpacing.xl,
            pad,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.displayMedium),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Calm "coming soon" panel: tinted icon, title, one line of body. No large
/// illustrations (doc 04 §5 shared states).
class PlaceholderPanel extends StatelessWidget {
  const PlaceholderPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Column(
        children: [
          TintedIcon(icon, size: 56),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
