import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/models/employee_details.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bg_animation.dart';
import '../../../../../core/widgets/onboarding/onboarding_main_button.dart';
import '../../../../../core/widgets/toast.dart';

/// Step 3/3: OTP verification (same design as Care System OtpView).
class OtpPage extends StatefulWidget {
  final EmployeeDetails? employeeDetails;

  const OtpPage({super.key, this.employeeDetails});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  int _seconds = 60;
  Timer? _timer;
  String _enteredOtp = '';
  bool _isVerifying = false;

  void _startTimer() {
    setState(() => _seconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resendOtp() {
    if (_seconds > 0) return;
    FocusManager.instance.primaryFocus?.unfocus();
    // TODO: Call resend OTP API
    _startTimer();
    Toast.success(context, 'OTP sent again');
  }

  void _verifyOtp() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_enteredOtp.length != 6) return;
    setState(() => _isVerifying = true);
    // TODO: Call verify OTP API
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      Toast.success(context, 'Verified successfully');
      context.go('/onboarding/create-user', extra: widget.employeeDetails);
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 26,
        color: AppTheme.primaryColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppTheme.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppTheme.primaryColor, width: 1.5),
      ),
    );

    final mobile = widget.employeeDetails?.mobileNo ?? '';
    final maskedMobile = mobile.length > 1 ? '+94 7***${mobile.substring(mobile.length - 3)}' : '';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        extendBody: true,
        resizeToAvoidBottomInset: false,
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
              child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kLeftRightMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.paddingOf(context).top),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 7.h),
                              Icon(
                                Icons.sms_outlined,
                                size: 80,
                                color: AppTheme.primaryColor.withOpacity(0.8),
                              ),
                              SizedBox(height: 3.h),
                              Center(
                                child: Text(
                                  'OTP Verification',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Text(
                                    mobile.isNotEmpty
                                        ? 'We have sent a verification code to\n$maskedMobile'
                                        : 'Enter the 6-digit code sent to you.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Pinput(
                                    length: 6,
                                    controller: _pinController,
                                    focusNode: _focusNode,
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    submittedPinTheme: submittedPinTheme,
                                    separatorBuilder: (int index) => const SizedBox(width: 8),
                                    onChanged: (value) => setState(() => _enteredOtp = value),
                                    onCompleted: (pin) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      setState(() => _enteredOtp = pin);
                                      _verifyOtp();
                                    },
                                    cursor: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 9),
                                          width: 20,
                                          height: 2,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                _seconds <= 0
                                    ? GestureDetector(
                                        onTap: _resendOtp,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'Resend code',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        child: Text(
                                          'Resend in $_seconds s',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            OnboardingMainButton(
                              title: _isVerifying ? 'Verifying...' : 'Verify now',
                              isEnable: !_isVerifying && _enteredOtp.length == 6,
                              onTap: _isVerifying ? null : _verifyOtp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 2.w,
                  top: 2.5.h,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor.withOpacity(0.7),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
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
