import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'wave_painter.dart';
import 'floating_particles.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  
  late Animation<double> _waveAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation controller (continuous)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Wave animation
    _waveAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.linear,
      ),
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // Text animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutBack,
      ),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    
    // Start progress animation
    _progressController.forward();

    // Wait before transitioning
    await Future.delayed(const Duration(milliseconds: 1500));

    // Navigate to app
    if (mounted) {
      widget.onInitializationComplete();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundColor,
                AppTheme.primaryDark,
                AppTheme.primaryColor.withOpacity(0.2),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated wave background
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: WavePainter(
                        waveValue: _waveAnimation.value,
                        primaryColor: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),

              // Floating particles
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return FloatingParticles(
                    animationValue: _particleController.value,
                  );
                },
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Geometric Logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Opacity(
                              opacity: _logoFadeAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.star_rounded,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // App Name with scale animation
                      ScaleTransition(
                        scale: _textScaleAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'DSI',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'LOYALTY',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 3,
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your Rewards, Simplified',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Progress bar
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _progressAnimation.value,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      minHeight: 4,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Initializing...',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


