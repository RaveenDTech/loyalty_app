import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Same animated orb background as Care System (WeCare) onboarding:
/// three circles moving along the screen perimeter with scale/opacity animation.
class BGAnimation extends StatefulWidget {
  final bool isLogged;

  const BGAnimation({super.key, this.isLogged = false});

  @override
  State<BGAnimation> createState() => _BGAnimationState();
}

class _BGAnimationState extends State<BGAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;
  late Animation<double> _scaleAnimation3;
  late Animation<double> _opacityAnimation1;
  late Animation<double> _opacityAnimation2;
  late Animation<double> _opacityAnimation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.isLogged ? 100 : 24),
    )..repeat();

    _scaleAnimation1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 80.0, end: 100.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 100.0, end: 80.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));

    _opacityAnimation1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));

    _scaleAnimation2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 100.0, end: 120.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 120.0, end: 100.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));

    _opacityAnimation2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.7), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));

    _scaleAnimation3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 70.0, end: 90.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 90.0, end: 70.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));

    _opacityAnimation3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.8), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    children: [
                      _buildAnimatedCircle(
                        _controller.value,
                        _scaleAnimation1.value,
                        _opacityAnimation1.value,
                        AppTheme.primaryColor,
                        constraints,
                      ),
                      _buildAnimatedCircle(
                        (_controller.value + 1 / 3) % 1.0,
                        _scaleAnimation2.value,
                        _opacityAnimation2.value,
                        AppTheme.accentColor,
                        constraints,
                      ),
                      _buildAnimatedCircle(
                        (_controller.value + 2 / 3) % 1.0,
                        _scaleAnimation3.value,
                        _opacityAnimation3.value,
                        AppTheme.infoColor,
                        constraints,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(
    double position,
    double size,
    double opacity,
    Color color,
    BoxConstraints constraints,
  ) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final adjustedWidth = screenWidth - size;
    final adjustedHeight = screenHeight - size;
    final perimeter = 2 * (adjustedWidth + adjustedHeight);
    final totalDistance = perimeter * position;

    Offset circlePosition;
    if (totalDistance < adjustedWidth) {
      circlePosition = Offset(size / 2 + totalDistance, size / 2);
    } else if (totalDistance < adjustedWidth + adjustedHeight) {
      circlePosition = Offset(
        screenWidth - size / 2,
        size / 2 + (totalDistance - adjustedWidth),
      );
    } else if (totalDistance < 2 * adjustedWidth + adjustedHeight) {
      circlePosition = Offset(
        screenWidth -
            size / 2 -
            (totalDistance - adjustedWidth - adjustedHeight),
        screenHeight - size / 2,
      );
    } else {
      circlePosition = Offset(
        size / 2,
        screenHeight -
            size / 2 -
            (totalDistance - 2 * adjustedWidth - adjustedHeight),
      );
    }

    return Positioned(
      left: circlePosition.dx - size / 2,
      top: circlePosition.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: size * 0.5,
                spreadRadius: size * 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
