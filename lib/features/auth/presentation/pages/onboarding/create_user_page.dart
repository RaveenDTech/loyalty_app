import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/models/employee_details.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bg_animation.dart';
import '../../../../../core/widgets/onboarding/onboarding_app_bar.dart';
import '../../../../../core/widgets/onboarding/onboarding_form_field.dart';
import '../../../../../core/widgets/onboarding/onboarding_main_button.dart';
import '../../../../../core/widgets/toast.dart';

/// Step 3/3: Create account – username, password, confirm password (same design as Care System CreateUserView).
class CreateUserPage extends StatefulWidget {
  final EmployeeDetails? employeeDetails;

  const CreateUserPage({super.key, this.employeeDetails});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static bool _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final u = value.trim();
    if (u.length < 3 || u.length > 30) return false;
    return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(u);
  }

  static bool _validatePassword(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.length >= 6;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_isUsernameValid || !_isPasswordValid || !_isConfirmPasswordValid) {
      _formKey1.currentState?.validate();
      _formKey2.currentState?.validate();
      _formKey3.currentState?.validate();
      return;
    }
    setState(() => _isLoading = true);
    // TODO: Call create user API with widget.employeeDetails, _usernameController.text, _passwordController.text
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Toast.success(context, 'Account created successfully. Please sign in.');
      context.go('/login');
    });
  }

  void _onBack() {
    context.go('/login');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: OnboardingAppBar(
          title: 'Sign up'.toUpperCase(),
          currentStep: 3,
          totalSteps: 3,
          onBack: _onBack,
        ),
        body: Stack(
          children: [
            const BGAnimation(isLogged: false),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1000, sigmaY: 1000),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.8),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kLeftRightMargin,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.6.h * 10),
                            Text(
                              'Set up your\naccount',
                              style: GoogleFonts.poppins(
                                fontSize: 35.px,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Create a username and password to sign in.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Username',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Form(
                              key: _formKey1,
                              child: OnboardingFormField(
                                controller: _usernameController,
                                hintText: 'Create username',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    setState(() => _isUsernameValid = false);
                                    return 'Username cannot be empty';
                                  }
                                  if (!_validateUsername(v)) {
                                    setState(() => _isUsernameValid = false);
                                    return 'Use 3–30 characters, letters, numbers and underscore only';
                                  }
                                  setState(() => _isUsernameValid = true);
                                  return null;
                                },
                                onChanged: (_) =>
                                    _formKey1.currentState?.validate(),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'New password',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Form(
                              key: _formKey2,
                              child: OnboardingFormField(
                                controller: _passwordController,
                                hintText: 'Enter new password',
                                obscureText: _obscurePassword,
                                textInputType: TextInputType.visiblePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    setState(() => _isPasswordValid = false);
                                    return 'Password cannot be empty';
                                  }
                                  if (!_validatePassword(v)) {
                                    setState(() => _isPasswordValid = false);
                                    return 'Password must be at least 6 characters';
                                  }
                                  setState(() => _isPasswordValid = true);
                                  if (_confirmPasswordController.text.isNotEmpty) {
                                    _formKey3.currentState?.validate();
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  _formKey2.currentState?.validate();
                                  _formKey3.currentState?.validate();
                                },
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Confirm password',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Form(
                              key: _formKey3,
                              child: OnboardingFormField(
                                controller: _confirmPasswordController,
                                hintText: 'Re-enter password',
                                obscureText: _obscureConfirm,
                                textInputType: TextInputType.visiblePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    setState(() => _isConfirmPasswordValid = false);
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    setState(() => _isConfirmPasswordValid = false);
                                    return 'Passwords don\'t match';
                                  }
                                  setState(() => _isConfirmPasswordValid = true);
                                  return null;
                                },
                                onChanged: (_) =>
                                    _formKey3.currentState?.validate(),
                              ),
                            ),
                            SizedBox(height: 5.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: kLeftRightMargin,
                    ),
                    child: OnboardingMainButton(
                      title: _isLoading ? 'Creating...' : 'Submit',
                      isEnable: !_isLoading &&
                          _isUsernameValid &&
                          _isPasswordValid &&
                          _isConfirmPasswordValid,
                      onTap: _isLoading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
