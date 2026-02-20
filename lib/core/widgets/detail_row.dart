import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simple label-value row for lists and cards (transactions, vouchers, etc.).
/// Use [DetailRowWithIcon] for profile-style rows with an icon.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
