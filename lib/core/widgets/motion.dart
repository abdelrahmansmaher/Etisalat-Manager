import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Marks when a page appeared, so its rows can rise into place once (and
/// not again when a lazy list rebuilds them on scroll).
class EntranceScope extends StatefulWidget {
  const EntranceScope({super.key, required this.child});

  final Widget child;

  /// Time since the page appeared, or `null` outside a scope.
  static Duration? elapsedOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_EntranceClock>()
      ?.stopwatch
      .elapsed;

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope> {
  final Stopwatch _stopwatch = Stopwatch()..start();

  @override
  Widget build(BuildContext context) =>
      _EntranceClock(stopwatch: _stopwatch, child: widget.child);
}

class _EntranceClock extends InheritedWidget {
  const _EntranceClock({required this.stopwatch, required super.child});

  final Stopwatch stopwatch;

  @override
  bool updateShouldNotify(_EntranceClock old) => old.stopwatch != stopwatch;
}

/// Fades a row in and lifts it 16dp into place, [index] steps after the
/// first one. Only while the page is appearing; afterwards it rests.
///
/// The widget tree never changes shape (the row's own state, like typed
/// text, is kept): whether to animate is decided once, when it is built.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Rows after this one appear together with it.
  static const int maxStagger = 8;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _v;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final elapsed = EntranceScope.elapsedOf(context);
    final delay =
        AppMotion.stagger * widget.index.clamp(0, Entrance.maxStagger);
    final total = delay + AppMotion.entrance;
    final animate =
        elapsed != null && !AppMotion.reduced(context) && elapsed < total;
    _c = AnimationController(
      vsync: this,
      duration: total,
      value: animate ? 0 : 1,
    );
    _v = CurvedAnimation(
      parent: _c!,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.smooth,
      ),
    );
    if (animate) _c!.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _v!,
    builder: (context, child) => Opacity(
      opacity: _v!.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _v!.value) * 16),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

/// Plays a small spring "pop" every time [trigger] changes (a selected tab
/// icon, a copied tick, a new badge). Nothing plays on the first build.
class SpringPop extends StatefulWidget {
  const SpringPop({
    super.key,
    required this.trigger,
    required this.child,
    this.from = 0.78,
  });

  final Object? trigger;
  final Widget child;

  /// Scale it starts from.
  final double from;

  @override
  State<SpringPop> createState() => _SpringPopState();
}

class _SpringPopState extends State<SpringPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.spring,
    value: 1,
  );

  @override
  void didUpdateWidget(SpringPop old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !AppMotion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) => Transform.scale(
      scale:
          widget.from +
          (1 - widget.from) * AppMotion.springy.transform(_c.value),
      child: child,
    ),
    child: widget.child,
  );
}
