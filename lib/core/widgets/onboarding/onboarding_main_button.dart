import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';

/// Primary or negative action button for onboarding (same design as Care System AppMainButton).
class OnboardingMainButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isEnable;
  final bool isNegative;

  const OnboardingMainButton({
    super.key,
    required this.title,
    this.onTap,
    this.isEnable = true,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnable ? onTap : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 1.7.h, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          backgroundColor: isNegative
              ? AppTheme.textSecondary.withOpacity(0.3)
              : (isEnable ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.3)),
          foregroundColor: isNegative ? AppTheme.textPrimary : (isEnable ? Colors.white : AppTheme.textSecondary.withOpacity(0.5)),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
