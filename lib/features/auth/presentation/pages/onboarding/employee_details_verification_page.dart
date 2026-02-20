import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/models/employee_details.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bg_animation.dart';
import '../../../../../core/widgets/onboarding/onboarding_app_bar.dart';
import '../../../../../core/widgets/onboarding/onboarding_form_field.dart';
import '../../../../../core/widgets/onboarding/onboarding_main_button.dart';

/// Step 2/3: Verify employee details (read-only + editable email/mobile). Same design as Care System EmpDetailsVerificationView.
class EmployeeDetailsVerificationPage extends StatefulWidget {
  final EmployeeDetails? employeeDetails;

  const EmployeeDetailsVerificationPage({super.key, this.employeeDetails});

  @override
  State<EmployeeDetailsVerificationPage> createState() =>
      _EmployeeDetailsVerificationPageState();
}

class _EmployeeDetailsVerificationPageState
    extends State<EmployeeDetailsVerificationPage> {
  late EmployeeDetails _details;
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  late final List<TextEditingController> _readOnlyControllers;
  final _emailFormKey = GlobalKey<FormState>();
  final _mobileFormKey = GlobalKey<FormState>();

  bool _isEmailValid = true;
  bool _isMobileValid = true;

  static bool _validateEmail(String? v) {
    if (v == null || v.isEmpty) return false;
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(v);
  }

  static bool _validateMobile(String? v) {
    if (v == null || v.isEmpty) return false;
    return RegExp(r'^0[0-9]{9}$').hasMatch(v.replaceAll(' ', ''));
  }

  @override
  void initState() {
    super.initState();
    _details = widget.employeeDetails ?? EmployeeDetails();
    _emailController.text = _details.email ?? '';
    _mobileController.text = _details.mobileNo ?? '';
    final dobStr = _details.dob != null
        ? DateFormat('yyyy-MM-dd').format(_details.dob!)
        : '';
    _readOnlyControllers = [
      TextEditingController(text: _details.policyType ?? ''),
      TextEditingController(text: (_details.nic ?? '').toUpperCase()),
      TextEditingController(text: _details.titleDescription ?? ''),
      TextEditingController(text: _details.initials ?? ''),
      TextEditingController(text: _details.firstName ?? ''),
      TextEditingController(text: _details.lastName ?? ''),
      TextEditingController(text: dobStr),
      TextEditingController(text: '${_details.age ?? ''}'),
      TextEditingController(text: _details.gender ?? ''),
      TextEditingController(text: _details.houseNo ?? ''),
      TextEditingController(text: _details.street1 ?? ''),
      TextEditingController(text: _details.street2 ?? ''),
      TextEditingController(text: _details.city ?? ''),
      TextEditingController(text: _details.companyName ?? ''),
      TextEditingController(text: _details.epfNo ?? ''),
      TextEditingController(text: _details.staffCategory ?? ''),
      TextEditingController(text: _details.staffType ?? ''),
      TextEditingController(text: _details.permanentDate ?? ''),
      TextEditingController(text: _details.designation ?? ''),
    ];
  }

  @override
  void dispose() {
    for (final c in _readOnlyControllers) {
      c.dispose();
    }
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _reject() {
    context.go('/login');
  }

  void _verify() {
    if (!_isEmailValid || !_isMobileValid) return;
    setState(() {
      _details = _details.copyWith(
        email: _emailController.text.trim(),
        mobileNo: _mobileController.text.trim(),
      );
    });
    context.push('/onboarding/otp', extra: _details);
  }

  @override
  Widget build(BuildContext context) {
    final c = _readOnlyControllers;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: OnboardingAppBar(
          title: 'Sign up'.toUpperCase(),
          currentStep: 2,
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
                              'Verify your information',
                              style: GoogleFonts.poppins(
                                fontSize: 35.px,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Review your personal details and confirm.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Personal details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [

                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[1],
                                    label: 'NIC Number',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[2],
                                    label: 'Title',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[3],
                                    label: 'Initials',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            OnboardingFormField(
                              controller: c[4],
                              label: 'First name',
                              isReadOnly: true,
                            ),
                            SizedBox(height: 2.5.h),
                            OnboardingFormField(
                              controller: c[5],
                              label: 'Last name',
                              isReadOnly: true,
                            ),
                            SizedBox(height: 2.5.h),
                            Form(
                              key: _emailFormKey,
                              child: OnboardingFormField(
                                controller: _emailController,
                                label: 'Email address',
                                isForEdit: true,
                                textInputType: TextInputType.emailAddress,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@_.]')),
                                ],
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    if (_validateEmail(v)) {
                                      setState(() => _isEmailValid = true);
                                      return null;
                                    }
                                    setState(() => _isEmailValid = false);
                                    return 'Enter a valid email';
                                  }
                                  setState(() => _isEmailValid = false);
                                  return 'Email cannot be empty';
                                },
                                onChanged: (_) => _emailFormKey.currentState?.validate(),
                              ),
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Form(
                                    key: _mobileFormKey,
                                    child: OnboardingFormField(
                                      controller: _mobileController,
                                      label: 'Mobile number',
                                      isForEdit: true,
                                      maxLength: 10,
                                      counterText: '',
                                      textInputType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      ],
                                      validator: (v) {
                                        if (v != null && v.isNotEmpty) {
                                          if (_validateMobile(v)) {
                                            setState(() => _isMobileValid = true);
                                            return null;
                                          }
                                          setState(() => _isMobileValid = false);
                                          return 'Enter a valid mobile number';
                                        }
                                        setState(() => _isMobileValid = false);
                                        return 'Mobile cannot be empty';
                                      },
                                      onChanged: (_) => _mobileFormKey.currentState?.validate(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[6],
                                    label: 'Date of birth',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[7],
                                    label: 'Age',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[8],
                                    label: 'Gender',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Residential details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[9],
                                    label: 'House number',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[10],
                                    label: 'Street 1',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[11],
                                    label: 'Street 2',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[12],
                                    label: 'City',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Company details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            OnboardingFormField(
                              controller: c[13],
                              label: 'Company name',
                              isReadOnly: true,
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[14],
                                    label: 'EPF Number',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[15],
                                    label: 'Staff category',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[16],
                                    label: 'Staff type',
                                    isReadOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OnboardingFormField(
                                    controller: c[17],
                                    label: 'Permanent date',
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                            OnboardingFormField(
                              controller: c[18],
                              label: 'Designation',
                              isReadOnly: true,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: OnboardingMainButton(
                          title: 'Reject',
                          isNegative: true,
                          onTap: _reject,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OnboardingMainButton(
                          title: 'Verify',
                          isEnable: _isEmailValid && _isMobileValid,
                          onTap: _verify,
                        ),
                      ),
                    ],
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
