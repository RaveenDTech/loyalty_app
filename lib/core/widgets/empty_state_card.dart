import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared empty state used across customer, supplier, and shared features.
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppTheme.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
