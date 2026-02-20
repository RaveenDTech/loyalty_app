import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable floating particles overlay for splash, login, and home screens.
class FloatingParticles extends StatelessWidget {
  final double animationValue;

  const FloatingParticles({super.key, required this.animationValue});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: List.generate(8, (index) {
        final delay = index * 0.2;
        final offset = (animationValue + delay) % 1.0;
        final size = 4.0 + (index % 3) * 2.0;
        final left = (index * 12.5) / 100.0 * screenSize.width;
        final top = 20.0 + (offset * 60.0);

        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: 0.3 + (math.sin(offset * math.pi) * 0.3),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
