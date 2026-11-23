import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// One-shot entrance: fade + 8px rise, delayed by [index] × [step].
///
/// Budget (doc 04 §2.8, ≤ 300ms total): with the defaults, 5 items finish
/// within 4 × 25 + 180 = 280ms. Small widgets only (cards) — never animate
/// opacity on large layers. Disabled entirely (renders final state, no
/// controller) when the OS asks to remove animations.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 25),
    this.duration = const Duration(milliseconds: 180),
    this.maxItems = 5,
  });

  final int index;
  final Widget child;
  final Duration step;
  final Duration duration;

  /// Items beyond this start together, keeping the total bounded.
  final int maxItems;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _curve;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) return;
    final slot = widget.index.clamp(0, widget.maxItems - 1);
    final delay = widget.step * slot;
    final total = delay + widget.duration;
    assert(total <= AppMotion.max, 'Stagger exceeds the 300ms motion budget');
    final start = delay.inMicroseconds / total.inMicroseconds;
    final controller = AnimationController(vsync: this, duration: total);
    _controller = controller;
    _curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1, curve: AppMotion.enter),
    );
    controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = _curve;
    if (curve == null) return widget.child;
    return FadeTransition(
      opacity: curve,
      child: AnimatedBuilder(
        animation: curve,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - curve.value)),
          child: child,
        ),
      ),
    );
  }
}
