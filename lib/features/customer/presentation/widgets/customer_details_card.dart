import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/detail_row_with_icon.dart';

/// Card showing customer ID, email, and name with dividers.
class CustomerDetailsCard extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String userName;

  const CustomerDetailsCard({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.12),
                  AppTheme.primaryColor.withOpacity(0.06),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Customer details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          DetailRowWithIcon(
            icon: Icons.badge_rounded,
            iconColor: AppTheme.primaryColor,
            label: 'Customer ID',
            value: userId,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 20,
            color: AppTheme.dividerColor,
          ),
          DetailRowWithIcon(
            icon: Icons.email_rounded,
            iconColor: AppTheme.secondaryColor,
            label: 'Email',
            value: userEmail,
          ),
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 20,
            color: AppTheme.dividerColor,
          ),
          DetailRowWithIcon(
            icon: Icons.person_rounded,
            iconColor: AppTheme.successColor,
            label: 'Name',
            value: userName,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
