import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'list_surface.dart';
import 'prose_text.dart';

/// Standard pushed page: back button, title and actions share the first
/// line (no empty band above the title). The full title scrolls away; a
/// small one fades into the pinned bar.
///
/// The back button is always there: with nothing to go back to (deep link)
/// it goes home.
///
/// Content is given either as [children] (a lazily built list) or as
/// [slivers]; with slivers the title line stays fixed above the scroll view,
/// so pinned headers sit right under it. Bottom padding clears the system inset.
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

  /// Extra widget right under the title (chips, meta line…).
  final Widget? header;
  final List<Widget>? actions;
  final Key? scrollKey;

  /// Render the title with [ProseText] (titles that may contain codes).
  final bool titleIsProse;
  final ScrollController? controller;

  /// Title style (default: headlineM).
  final TextStyle? titleStyle;

  /// Small title shown in the bar once scrolled (default: [title]).
  final String? appBarTitle;

  /// Height of the pinned bar (without the system inset).
  static const double barHeight = 52;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  final ValueNotifier<bool> _collapsed = ValueNotifier(false);

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _collapsed.value = n.metrics.pixels > 6;
    }
    return false;
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    } else {
      GoRouter.maybeOf(context)?.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final insets = MediaQuery.paddingOf(context);
    final bottom = AppSpacing.xl + insets.bottom;
    final actions = widget.actions ?? const <Widget>[];

    final style =
        widget.titleStyle ??
        AppTypography.headlineM.copyWith(color: c.textPrimary);
    final title = Semantics(
      header: true,
      child: widget.titleIsProse
          ? ProseText(widget.title, style: style)
          : Text(widget.title, style: style),
    );

    final bar = ValueListenableBuilder<bool>(
      valueListenable: _collapsed,
      builder: (context, collapsed, _) {
        final d = AppMotion.resolve(context, AppMotion.normal);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: collapsed ? c.surface : null,
            border: collapsed
                ? Border(bottom: BorderSide(color: c.border))
                : null,
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: PageScaffold.barHeight,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.xxs),
                  BackButton(onPressed: _back, color: c.textPrimary),
                  Expanded(
                    child: ExcludeSemantics(
                      child: AnimatedOpacity(
                        opacity: collapsed ? 1 : 0,
                        duration: d,
                        curve: AppMotion.enter,
                        child: Text(
                          widget.appBarTitle ?? widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: MediaQuery.textScalerOf(
                            context,
                          ).clamp(maxScaleFactor: 1.5),
                          style: AppTypography.titleM.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...actions,
                  const SizedBox(width: AppSpacing.xxs),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (widget.slivers != null) {
      return Scaffold(
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.xxs),
                  BackButton(onPressed: _back, color: c.textPrimary),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: PageScaffold.barHeight,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        heightFactor: 1,
                        child: title,
                      ),
                    ),
                  ),
                  ...actions,
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                key: widget.scrollKey,
                controller: widget.controller,
                slivers: [
                  if (widget.subtitle != null || widget.header != null)
                    SliverPadding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        pad,
                        0,
                        pad,
                        AppSpacing.xs,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: AppTypography.bodyM.copyWith(
                                  color: c.textTertiary,
                                ),
                              ),
                            ?widget.header,
                          ],
                        ),
                      ),
                    ),
                  ...widget.slivers!,
                  SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              key: widget.scrollKey,
              controller: widget.controller,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: insets.top),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          // Clears the back button and the actions, so the
                          // title sits on their line.
                          padding: EdgeInsetsDirectional.only(
                            start: AppSpacing.minTouchTarget + AppSpacing.xs,
                            end:
                                AppSpacing.xs +
                                (actions.isEmpty
                                    ? AppSpacing.xs
                                    : AppSpacing.minTouchTarget *
                                          actions.length),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: PageScaffold.barHeight,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              heightFactor: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: title,
                              ),
                            ),
                          ),
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: pad,
                            ),
                            child: Text(
                              widget.subtitle!,
                              style: AppTypography.bodyM.copyWith(
                                color: c.textTertiary,
                              ),
                            ),
                          ),
                        if (widget.header != null)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              pad,
                              widget.subtitle == null ? 0 : AppSpacing.xs,
                              pad,
                              0,
                            ),
                            child: widget.header!,
                          ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: pad),
                  sliver: SliverList.list(children: widget.children),
                ),
                SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: bar),
        ],
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
      role: CardRole.flat,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          TintedIcon(icon, tile: IconTile.xl),
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

/// Static skeleton rows shown while content loads (no shimmer animation:
/// cheap, and it keeps tests' pumpAndSettle deterministic).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget bar(double width, double h) => Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: AppRadius.xsAll,
      ),
    );
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ListSurface(
        key: const ValueKey('skeleton'),
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.surfaceVariant,
                      borderRadius: AppRadius.xsAll,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(120, 14),
                      const SizedBox(height: AppSpacing.xs),
                      bar(80, 10),
                    ],
                  ),
                  const Spacer(),
                  bar(48, 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
