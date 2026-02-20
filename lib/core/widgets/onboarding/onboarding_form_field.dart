import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';

/// Onboarding form field matching Care System ZynoloFormField design.
class OnboardingFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final bool isReadOnly;
  final bool isForEdit;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onCompleted;
  final int? maxLength;
  final String? counterText;
  final bool obscureText;
  final Widget? suffixIcon;

  const OnboardingFormField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.isReadOnly = false,
    this.isForEdit = false,
    this.textInputType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onCompleted,
    this.maxLength,
    this.counterText = '',
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      obscureText: obscureText,
      keyboardType: textInputType ?? TextInputType.text,
      maxLength: maxLength,
      onEditingComplete: onCompleted,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: isReadOnly ? FontWeight.w400 : FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      cursorColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: label,
        counterText: counterText,
        filled: true,
        fillColor: isForEdit
            ? AppTheme.textSecondary.withOpacity(0.15)
            : AppTheme.borderColor.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(vertical: 1.9.h, horizontal: 2.h),
        hintStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
        labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
        floatingLabelStyle: GoogleFonts.poppins(
          color: isForEdit ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.poppins(color: AppTheme.errorColor, fontSize: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isForEdit ? AppTheme.primaryColor.withOpacity(0.5) : AppTheme.borderColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
