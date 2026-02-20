import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable wave background painter for splash, login, and home screens.
class WavePainter extends CustomPainter {
  final double waveValue;
  final Color primaryColor;

  WavePainter({
    required this.waveValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 40.0;
    final waveLength = size.width / 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * 0.7 + i * 30);

      for (double x = 0; x <= size.width; x++) {
        final y = waveHeight *
                math.sin((x / waveLength * 2 * math.pi) + (waveValue + i * 0.5)) +
            size.height * 0.7 +
            i * 30;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveValue != waveValue;
  }
}
