import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section header with icon used in profile and settings.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
