import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

/// Onboarding app bar with back button, title, and step progress (e.g. 1 of 3).
class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingAppBar({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.3),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BackButton(onPressed: onBack ?? () => Navigator.maybePop(context)),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.px,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kLeftRightMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '$currentStep of $totalSteps',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: currentStep / totalSteps,
                          minHeight: 7,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(200);
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onPressed();
        },
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.surfaceColor.withOpacity(0.8),
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }
}
