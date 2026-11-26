import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_icons.dart';
import '../tools/dial_template.dart' show toAsciiDigits;

/// A private note for one date, opened by searching it and pressing Enter.
/// It is the one popup that does not follow the app's design on purpose.
abstract final class LoveNote {
  /// True for 18/09/2026, however it is typed (Arabic digits, - or .,
  /// with or without leading zeros).
  static bool matches(String query) {
    final q = toAsciiDigits(query).trim();
    final m = RegExp(r'^(\d{1,2})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{4})$')
        .firstMatch(q);
    if (m == null) return false;
    return int.parse(m[1]!) == 18 &&
        int.parse(m[2]!) == 9 &&
        int.parse(m[3]!) == 2026;
  }

  static Future<void> show(BuildContext context) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).closeButtonLabel,
      barrierColor: const Color(0xCC2A0710),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, _, _) => const _LoveNote(),
      transitionBuilder: (context, a, _, child) {
        final fade = CurvedAnimation(parent: a, curve: Curves.easeOut);
        final rise = CurvedAnimation(parent: a, curve: Curves.elasticOut);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1).animate(rise),
            child: child,
          ),
        );
      },
    );
  }
}

class _LoveNote extends StatefulWidget {
  const _LoveNote();

  @override
  State<_LoveNote> createState() => _LoveNoteState();
}

class _LoveNoteState extends State<_LoveNote> with TickerProviderStateMixin {
  static const red = Color(0xFFE0123C);

  /// Hearts floating up once.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  /// Three heartbeats, then rest.
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _float.dispose();
    _beat.dispose();
    super.dispose();
  }

  /// Scale of the heart: lub-dub three times.
  double _pulse(double t) {
    final phase = (t * 3) % 1;
    double bump(double c, double w) =>
        math.max(0, 1 - ((phase - c) / w).abs()) * 1.0;
    if (t >= 1) return 1;
    return 1 + 0.22 * bump(0.12, 0.1) + 0.14 * bump(0.32, 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, _) =>
                      CustomPaint(painter: _HeartsPainter(_float.value)),
                ),
              ),
            ),
            Center(
              child: Container(
                key: const ValueKey('love-note'),
                margin: const EdgeInsets.all(28),
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF1F4), Color(0xFFFFD9E2)],
                  ),
                  border: Border.all(color: const Color(0xFFFFB3C4), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88E0123C),
                      blurRadius: 60,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _beat,
                      builder: (context, child) => Transform.scale(
                        scale: _pulse(_beat.value),
                        child: child,
                      ),
                      child: const Icon(
                        AppIcons.toolFavorite,
                        color: red,
                        size: 84,
                        shadows: [
                          Shadow(color: Color(0x66E0123C), blurRadius: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text(
                              'بحبك يا نوئتي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: red,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: _beat,
                            builder: (context, child) => Transform.scale(
                              scale: _pulse(_beat.value),
                              child: child,
                            ),
                            child: const Icon(
                              AppIcons.toolFavorite,
                              color: red,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '18 / 9 / 2026',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Color(0xFFB0475E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small hearts rising from the bottom and fading, once.
class _HeartsPainter extends CustomPainter {
  _HeartsPainter(this.t);

  final double t;

  static final List<(double, double, double, double)> _hearts = () {
    final r = math.Random(1809);
    return [
      for (var i = 0; i < 22; i++)
        (
          r.nextDouble(),
          r.nextDouble() * 0.35,
          10 + r.nextDouble() * 18,
          r.nextDouble() * 2 - 1,
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    for (final (x, delay, s, sway) in _hearts) {
      final k = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final y = size.height * (1.05 - k * 1.1);
      final dx = x * size.width + math.sin(k * math.pi * 2) * 18 * sway;
      final alpha = (k < 0.2 ? k / 0.2 : 1 - (k - 0.2) / 0.8).clamp(0.0, 1.0);
      _heart(
        canvas,
        Offset(dx, y),
        s,
        Paint()
          ..color = const Color(0xFFFF4D6D).withValues(alpha: alpha * 0.85),
      );
    }
  }

  static void _heart(Canvas c, Offset o, double s, Paint p) {
    final path = Path()
      ..moveTo(o.dx, o.dy + s * 0.35)
      ..cubicTo(
        o.dx - s,
        o.dy - s * 0.25,
        o.dx - s * 0.45,
        o.dy - s,
        o.dx,
        o.dy - s * 0.45,
      )
      ..cubicTo(
        o.dx + s * 0.45,
        o.dy - s,
        o.dx + s,
        o.dy - s * 0.25,
        o.dx,
        o.dy + s * 0.35,
      )
      ..close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_HeartsPainter old) => old.t != t;
}
