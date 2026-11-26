import 'package:flutter/material.dart';

/// The app's mark (same as the launcher icon): an N in rounded strokes on a
/// navy squircle, white uprights and a gold diagonal.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 52});

  final double size;

  static const Color navy = Color(0xFF1E2A78);
  static const Color gold = Color(0xFFF2C15A);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.45),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
            spreadRadius: -size * 0.1,
          ),
        ],
      ),
      child: CustomPaint(painter: _NPainter()),
    ),
  );
}

class _NPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final h = s * 0.46, w = h * 0.86;
    final cx = size.width / 2, cy = size.height / 2;
    final l = cx - w / 2, r = cx + w / 2, t = cy - h / 2, b = cy + h / 2;
    Paint p(Color c) => Paint()
      ..color = c
      ..strokeWidth = h * 0.19
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final white = p(Colors.white);
    canvas
      ..drawLine(Offset(l, t), Offset(l, b), white)
      ..drawLine(Offset(r, t), Offset(r, b), white)
      ..drawLine(Offset(l, t), Offset(r, b), p(AppMark.gold));
  }

  @override
  bool shouldRepaint(_NPainter old) => false;
}
