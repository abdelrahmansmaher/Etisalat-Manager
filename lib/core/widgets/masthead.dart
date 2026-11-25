import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Navy band at the top of every tab: one title line and the search pill.
/// It stays put while the page scrolls, so search is always one tap away.
class Masthead extends StatelessWidget {
  const Masthead({super.key, this.top, required this.field});

  /// Title line.
  final Widget? top;

  /// Search pill (tabs) or search field (search screen).
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.masthead,
          border: c.isDark
              ? Border(bottom: BorderSide(color: c.hairline))
              : null,
        ),
        child: SafeArea(
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
                    constraints: const BoxConstraints(minHeight: 36),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      heightFactor: 1,
                      child: top,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                field,
              ],
            ),
          ),
        ),
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
      style: AppTypography.titleL.copyWith(
        color: context.colors.onMasthead,
        fontWeight: FontWeight.w700,
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
      child: Material(
        key: const ValueKey('search-pill'),
        color: c.mastheadField,
        shape: const StadiumBorder(),
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
                    color: c.isDark ? c.onMasthead : c.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.homeSearchHint,
                      style: AppTypography.bodyL.copyWith(
                        color: c.isDark ? c.onMastheadMuted : c.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tab: fixed [Masthead] over a scrolling body.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    super.key,
    required this.top,
    this.children = const [],
    this.slivers,
    this.scrollKey,
    this.controller,
  });

  final Widget top;
  final List<Widget> children;
  final List<Widget>? slivers;
  final Key? scrollKey;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.screenPaddingFor(MediaQuery.sizeOf(context).width);
    final bottom = AppSpacing.md + MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Column(
        children: [
          Masthead(top: top, field: const SearchPill()),
          Expanded(
            child: CustomScrollView(
              key: scrollKey,
              controller: controller,
              slivers: [
                if (slivers != null)
                  ...slivers!
                else
                  SliverPadding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: pad),
                    sliver: SliverList.list(children: children),
                  ),
                SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
