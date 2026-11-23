import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'prose_text.dart';

/// Standard page: compact app bar + a large title that scrolls away; once it
/// is gone the app bar fades in a small title and a hairline (iOS-style
/// collapsing header that stays robust at 2.0× text scale, because nothing
/// is squeezed into a fixed-height sliver).
///
/// Content is given either as [children] (a lazily built list) or as
/// [slivers]. Bottom padding clears the floating nav bar (Scaffold.extendBody
/// adds its height to MediaQuery padding) and the system inset.
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.slivers,
    this.header,
    this.actions,
    this.scrollKey,
    this.titleIsProse = false,
    this.controller,
    this.titleStyle,
    this.appBarTitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Used instead of [children] when given.
  final List<Widget>? slivers;

  /// Extra widget right under the large title (chips, meta line…).
  final Widget? header;
  final List<Widget>? actions;
  final Key? scrollKey;

  /// Render the title with [ProseText] (titles that may contain codes).
  final bool titleIsProse;
  final ScrollController? controller;

  /// Large-title style (default: displayMedium).
  final TextStyle? titleStyle;

  /// Small title shown in the app bar once collapsed (default: [title]).
  final String? appBarTitle;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  final ValueNotifier<bool> _collapsed = ValueNotifier(false);

  /// Scroll offset after which the large title counts as gone.
  static const double _threshold = 44;

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _collapsed.value = n.metrics.pixels > _threshold;
    }
    return false;
  }

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final bottom = AppSpacing.xl + MediaQuery.paddingOf(context).bottom;

    final titleStyle = widget.titleStyle ?? theme.textTheme.displayMedium;
    final largeTitle = Semantics(
      header: true,
      child: widget.titleIsProse
          ? ProseText(widget.title, style: titleStyle)
          : Text(widget.title, style: titleStyle),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: _collapsed,
          builder: (context, collapsed, _) {
            final d = AppMotion.resolve(context, AppMotion.normal);
            return AppBar(
              backgroundColor: collapsed ? c.surface : c.background,
              shape: Border(
                bottom: BorderSide(
                  color: collapsed ? c.hairline : Colors.transparent,
                ),
              ),
              actions: widget.actions,
              title: AnimatedOpacity(
                opacity: collapsed ? 1 : 0,
                duration: d,
                curve: AppMotion.enter,
                child: Text(
                  widget.appBarTitle ?? widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleL.copyWith(color: c.textPrimary),
                ),
              ),
            );
          },
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          key: widget.scrollKey,
          controller: widget.controller,
          slivers: [
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                pad,
                AppSpacing.xxs,
                pad,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    largeTitle,
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ],
                    if (widget.header != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      widget.header!,
                    ],
                  ],
                ),
              ),
            ),
            if (widget.slivers != null)
              ...widget.slivers!
            else
              SliverPadding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: pad),
                sliver: SliverList.list(children: widget.children),
              ),
            SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
          ],
        ),
      ),
    );
  }
}

/// Calm empty / "coming soon" panel: tinted icon, title, one line of body.
class PlaceholderPanel extends StatelessWidget {
  const PlaceholderPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          TintedIcon(icon, size: 60),
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
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Static skeleton rows shown while content loads (no shimmer animation —
/// cheap, and keeps tests' pumpAndSettle deterministic).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget bar(double widthFactor, double h) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: AppRadius.xsAll,
        ),
      ),
    );
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: Column(
        key: const ValueKey('skeleton'),
        children: [
          for (var i = 0; i < count; i++) ...[
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.surfaceVariant,
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(0.6, 14),
                        const SizedBox(height: AppSpacing.xs),
                        bar(0.9, 10),
                        const SizedBox(height: AppSpacing.xs),
                        bar(0.35, 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
      ),
    );
  }
}
