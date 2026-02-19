import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _signUpPressed = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _waveAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

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

    // Start logo animation
    _logoController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _waveController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Toast.warning(context, 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ok = await authProvider.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!ok) {
      Toast.error(context, 'Invalid credentials');
      return;
    }

    // Route based on role stored in AuthProvider.
    final role = authProvider.userRole;
    if (role == 'supplier') {
      context.go('/supplier/home');
    } else {
      context.go('/customer/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF2A69DF),
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light, systemNavigationBarContrastEnforced: false,),
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundColor,
                AppTheme.primaryDark,
                AppTheme.primaryColor.withOpacity(0.8),
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
                      painter: _LoginWavePainter(
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
                  return _LoginFloatingParticles(
                    animationValue: _particleController.value,
                  );
                },
              ),

              /// ===== CONTENT =====
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),

                              /// LOGO + TITLE
                              AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScaleAnimation.value,
                                    child: Opacity(
                                      opacity: _logoFadeAnimation.value,
                                      child: Column(
                                        children: [
                                          // Geometric Logo
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor
                                                      .withOpacity(0.4),
                                                  blurRadius: 30,
                                                  spreadRadius: 5,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppTheme.primaryColor,
                                                      AppTheme.primaryColor
                                                          .withOpacity(0.7),
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.star_rounded,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // App Name
                                          Text(
                                            'DSI',
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
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
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              letterSpacing: 4,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            height: 3,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor,
                                                  Colors.white.withOpacity(0.5),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          Text(
                                            'Welcome Back',
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Sign in to continue',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 40),

                              /// SOCIAL LOGIN
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    _glassSocialButton(
                                      icon: Brands.google,
                                      text: 'Google',
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    _glassSocialButton(
                                      icon: Brands.apple_logo,
                                      text: 'Apple',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                      thickness: 1,
                                      color: Colors.grey.withOpacity(0.2),
                                    )),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Or',
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Divider(
                                      thickness: 1,
                                      color: Colors.grey.withOpacity(0.2),
                                    )),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// INPUTS
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    _glassInput(
                                      hint: 'Email address',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 18),
                                    _glassInput(
                                      hint: 'Password',
                                      controller: _passwordController,
                                      obscure: _obscurePassword,
                                      onSubmit: (_) {
                                        _handleLogin();
                                      },
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// FORGOT PASSWORD
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 28, top: 14, bottom: 24),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.blue.shade200,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                              /// LOGIN BUTTON
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: _glassLoginButton(
                                  onTap: _handleLogin,
                                  isLoading: _isLoading,
                                ),
                              ),

                              // Spacer to push sign up to bottom
                              const Spacer(),

                              /// SIGN UP - Always at bottom
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Don\'t have an account? ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                    AnimatedScale(
                                      duration:
                                          const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                      scale: _signUpPressed ? 0.98 : 1,
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        opacity: _signUpPressed ? 0.85 : 1,
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: navigate to sign up page
                                            },
                                            onHighlightChanged:
                                                (isHighlighted) {
                                              if (!mounted) return;
                                              setState(() {
                                                _signUpPressed = isHighlighted;
                                              });
                                            },
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            splashColor:
                                                Colors.white.withOpacity(0.10),
                                            highlightColor:
                                                Colors.white.withOpacity(0.06),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              child: Text(
                                                'SIGN UP',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // GLASS INPUT FIELD
  // =========================
  Widget _glassInput({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    Function(String)? onSubmit,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(30));

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, height: 1),
        cursorColor: Colors.white,
        onSubmitted: onSubmit,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: AppTheme.primaryLight,
              width: 1.2,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.10),
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
          floatingLabelStyle: const TextStyle(color: AppTheme.primaryLight),
          suffixIcon: suffix,
          border: const OutlineInputBorder(borderRadius: borderRadius),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ),
    );
  }

  // =========================
  // GLASS SOCIAL BUTTON
  // =========================
  Widget _glassSocialButton({
    required String icon,
    required String text,
    VoidCallback? onTap,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(30));
    // ignore: prefer_final_locals
    bool pressed = false;

    return Expanded(
      child: StatefulBuilder(
        builder: (context, setLocalState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: onTap == null
                ? null
                : (_) => setLocalState(() {
                      pressed = true;
                    }),
            onTapCancel: onTap == null
                ? null
                : () => setLocalState(() {
                      pressed = false;
                    }),
            onTapUp: onTap == null
                ? null
                : (_) => setLocalState(() {
                      pressed = false;
                    }),
            onTap: onTap,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              scale: pressed ? 0.98 : 1,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: pressed ? 0.92 : 1,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: borderRadius,
                        splashColor: Colors.white.withOpacity(0.08),
                        highlightColor: Colors.white.withOpacity(0.06),
                        child: Container(
                          height: 53,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Brand(
                                  icon,
                                  size: 25,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // GLASS LOGIN BUTTON
  // =========================
  Widget _glassLoginButton({
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          splashColor: Colors.white.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.08),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primaryColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for wave effect in login
class _LoginWavePainter extends CustomPainter {
  final double waveValue;
  final Color primaryColor;

  _LoginWavePainter({
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

    // Draw multiple waves
    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * 0.7 + i * 30);

      for (double x = 0; x <= size.width; x++) {
        final y = waveHeight *
                math.sin(
                    (x / waveLength * 2 * math.pi) + (waveValue + i * 0.5)) +
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
  bool shouldRepaint(_LoginWavePainter oldDelegate) {
    return oldDelegate.waveValue != waveValue;
  }
}

// Floating particles widget for login
class _LoginFloatingParticles extends StatelessWidget {
  final double animationValue;

  const _LoginFloatingParticles({required this.animationValue});

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
