import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../core/widgets/menu_card.dart';
import '../../../../core/widgets/profile_info_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/toast.dart';
import 'tab_page_wrapper.dart';

/// Tab for Profile: header card, account info, settings, logout.
class SupplierProfileTab extends StatelessWidget {
  const SupplierProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPageWrapper(
      title: 'Profile',
      child: SupplierProfileBody(),
    );
  }
}

class SupplierProfileBody extends StatelessWidget {
  const SupplierProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.userName;
        final userEmail = authProvider.userEmail;
        final userId = authProvider.userId;

        final initials = userName
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Supplier',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SectionHeader(
                    title: 'Account Information',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoCard(
                    icon: Icons.badge_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Supplier ID',
                    value: userId,
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoCard(
                    icon: Icons.email_rounded,
                    iconColor: AppTheme.secondaryColor,
                    title: 'Email',
                    value: userEmail,
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoCard(
                    icon: Icons.store_rounded,
                    iconColor: AppTheme.successColor,
                    title: 'Store Name',
                    value: userName,
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icon: Icons.notifications_outlined,
                    iconColor: AppTheme.warningColor,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      Toast.info(context, 'Notifications settings coming soon');
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icon: Icons.security_rounded,
                    iconColor: AppTheme.infoColor,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                    onTap: () {
                      Toast.info(context, 'Privacy settings coming soon');
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.secondaryColor,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Toast.info(context, 'Help & Support coming soon');
                    },
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      Toast.info(context, 'About coming soon');
                    },
                  ),
                  const SizedBox(height: 32),
                  LogoutButton(
                    onTap: () async {
                      final confirmed = await ConfirmationDialog.show(
                        context: context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        icon: Icons.logout_rounded,
                        iconColor: AppTheme.errorColor,
                        confirmText: 'Logout',
                        confirmColor: AppTheme.errorColor,
                        onConfirm: () => Navigator.pop(context, true),
                        onCancel: () => Navigator.pop(context, false),
                      );
                      if (confirmed == true && context.mounted) {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
