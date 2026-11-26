import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'liquid_glass.dart';
import 'motion.dart';

/// Status bar icons that read on the current glass header.
SystemUiOverlayStyle headerOverlayStyle(AppColors c) =>
    (c.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(statusBarColor: Colors.transparent);

/// Header at the top of every tab, iOS style: a large title, the search
/// pill and, optionally, filters. At rest it sits on the page with no frame;
/// once the page scrolls under it, it turns into frosted glass.
class Masthead extends StatelessWidget {
  const Masthead({
    super.key,
    this.top,
    required this.field,
    this.bottom,
    this.scrolled,
  });

  /// Title line.
  final Widget? top;

  /// Search pill (tabs) or search field (search screen).
  final Widget field;

  /// Filters that stay with the header (segments, capsules).
  final Widget? bottom;

  /// True once content is under the header; `null` = always glass.
  final ValueListenable<bool>? scrolled;

  static const BorderRadius radius = BorderRadius.vertical(
    bottom: Radius.circular(AppRadius.l),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    const glass = LiquidGlass(
      tone: GlassTone.chrome,
      blur: true,
      borderRadius: radius,
      child: SizedBox.expand(),
    );
    final listen = scrolled;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: headerOverlayStyle(c),
      child: Stack(
        key: const ValueKey('masthead'),
        children: [
          Positioned.fill(
            child: listen == null
                ? glass
                : ValueListenableBuilder<bool>(
                    valueListenable: listen,
                    builder: (context, on, child) => AnimatedOpacity(
                      opacity: on ? 1 : 0,
                      duration: AppMotion.resolve(context, AppMotion.normal),
                      curve: AppMotion.enter,
                      child: child,
                    ),
                    child: glass,
                  ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                pad,
                AppSpacing.xs,
                pad,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (top != null) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        heightFactor: 1,
                        child: top,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  field,
                  if (bottom != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    bottom!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title text of a [Masthead].
class MastheadTitle extends StatelessWidget {
  const MastheadTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: AppTypography.displayM.copyWith(
        color: context.colors.onHeader,
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
  );
}

/// Opens the full search screen with the keyboard up.
class SearchPill extends StatelessWidget {
  const SearchPill({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      button: true,
      label: l10n.homeSearchHint,
      excludeSemantics: true,
      child: PressableScale(
        pressedScale: 0.98,
        child: Material(
          key: const ValueKey('search-pill'),
          color: c.headerField,
          shape: StadiumBorder(side: BorderSide(color: c.glassEdge)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(AppRoutes.search),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.search,
                      size: AppIconSize.nav,
                      color: c.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.homeSearchHint,
                        style: AppTypography.bodyL.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tab: the [Masthead] pinned over a scrolling body that passes under it.
/// Rows rise into place the first time the tab appears.
class TabScaffold extends StatefulWidget {
  const TabScaffold({
    super.key,
    this.top,
    this.children = const [],
    this.slivers,
    this.scrollKey,
    this.controller,
    this.headerBottom,
  });

  /// Line above the search pill (a greeting); tabs need no title, the dock
  /// already says where you are.
  final Widget? top;
  final List<Widget> children;
  final List<Widget>? slivers;
  final Key? scrollKey;
  final ScrollController? controller;

  /// Filters pinned inside the header, under the search pill.
  final Widget? headerBottom;

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _scrolled.value = n.metrics.pixels > 2;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final bottom = AppSpacing.md + MediaQuery.paddingOf(context).bottom;
    return EntranceScope(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CustomScrollView(
            key: widget.scrollKey,
            controller: widget.controller,
            slivers: [
              PinnedHeaderSliver(
                child: Masthead(
                  top: widget.top,
                  field: const SearchPill(),
                  bottom: widget.headerBottom,
                  scrolled: _scrolled,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
              if (widget.slivers != null)
                ...widget.slivers!
              else
                SliverPadding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: pad),
                  sliver: SliverList.list(
                    children: [
                      for (var i = 0; i < widget.children.length; i++)
                        Entrance(index: i, child: widget.children[i]),
                    ],
                  ),
                ),
              SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
