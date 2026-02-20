import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Step 1/3: EPF number + NIC verification (same design as Care System EpfVerificationView).
class EpfVerificationPage extends StatefulWidget {
  const EpfVerificationPage({super.key});

  @override
  State<EpfVerificationPage> createState() => _EpfVerificationPageState();
}

class _EpfVerificationPageState extends State<EpfVerificationPage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _epfController = TextEditingController();
  final _nicController = TextEditingController();

  bool _isEpfValidated = false;
  bool _isNicValidated = false;
  bool _isLoading = false;

  static bool _validateNic(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final nic = value.trim();
    // Old: 9 digits + V or 12 digits. New: 12 digits.
    if (RegExp(r'^\d{9}[vVxX]$').hasMatch(nic)) return true;
    if (RegExp(r'^\d{12}$').hasMatch(nic)) return true;
    return false;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_isEpfValidated || !_isNicValidated) return;
    setState(() => _isLoading = true );
    // TODO: Replace with real API (GetSignUpInquiry). For now use mock data.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final details = EmployeeDetails(
        epfNo: _epfController.text.trim(),
        nic: _nicController.text.trim().toUpperCase(),
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        mobileNo: '0771234567',
        dob: DateTime(1990, 5, 15),
        age: 34,
        gender: 'Male',
        initials: 'J',
        titleDescription: 'Mr',
        policyType: 'Standard',
        companyName: 'DSI',
        staffCategory: 'Permanent',
        staffType: 'Full Time',
        permanentDate: '2018-01-15',
        designation: 'Executive',
        houseNo: '10',
        street1: 'Main St',
        city: 'Colombo',
      );
      context.push('/onboarding/employee-details', extra: details);
    });
  }

  @override
  void dispose() {
    _epfController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar:  OnboardingAppBar(
          title: 'Sign up'.toUpperCase(),
          currentStep: 1,
          totalSteps: 3,
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
                      padding: const EdgeInsets.symmetric(horizontal: kLeftRightMargin),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Text(
                              'Enter required details',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 35.px,
                                height: 1.3,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'We need your EPF number and NIC to verify your identity.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'EPF Number',
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
                                controller: _epfController,
                                hintText: 'EPF Number',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    setState(() => _isEpfValidated = false);
                                    return 'EPF number cannot be empty';
                                  }
                                  setState(() => _isEpfValidated = true);
                                  return null;
                                },
                                onChanged: (_) => _formKey1.currentState?.validate(),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'NIC Number',
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
                                controller: _nicController,
                                hintText: 'Your NIC number',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9vVxX]')),
                                ],
                                validator: (v) {
                                  final nic = v?.trim() ?? '';
                                  if (nic.isEmpty) {
                                    setState(() => _isNicValidated = false);
                                    return 'NIC number cannot be empty';
                                  }
                                  if (!_validateNic(v)) {
                                    setState(() => _isNicValidated = false);
                                    return 'Enter a valid NIC number';
                                  }
                                  setState(() => _isNicValidated = true);
                                  return null;
                                },
                                onChanged: (_) => _formKey2.currentState?.validate(),
                                onCompleted: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (_isEpfValidated && _isNicValidated) _submit();
                                },
                              ),
                            ),
                            SizedBox(height: 5.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: kLeftRightMargin),
                  child: OnboardingMainButton(
                    title: _isLoading ? 'Verifying...' : 'Submit',
                    isEnable: !_isLoading && _isEpfValidated && _isNicValidated,
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
