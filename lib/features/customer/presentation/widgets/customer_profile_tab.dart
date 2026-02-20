import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../core/widgets/menu_card.dart';
import '../../../../core/widgets/profile_info_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/toast.dart';
import 'expandable_loyalty_section.dart';
import 'tab_page_wrapper.dart';

/// Tab wrapper for Profile: header card, loyalty section, account info, settings, logout.
class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPageWrapper(
      title: 'Profile',
      child: CustomerProfileBody(),
    );
  }
}

class CustomerProfileBody extends StatelessWidget {
  const CustomerProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthProvider, LoyaltyProvider>(
      builder: (context, authProvider, loyaltyProvider, _) {
        final userName = authProvider.userName;
        final userEmail = authProvider.userEmail;
        final userId = authProvider.userId;
        loyaltyProvider.setCustomerTenure(userId, authProvider.employmentTenureYears);
        final tier = loyaltyProvider.getTierForCustomer(userId);
        final tenureYears = loyaltyProvider.getTenureYearsForCustomer(userId);

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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card — modern gradient with depth
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDark,
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.15),
                                blurRadius: 0,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 2.5,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.08),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 34,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                userEmail,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Customer',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DSI Loyalty Section (expandable)
                  ExpandableLoyaltySection(
                    tier: tier,
                    tenureYears: tenureYears,
                  ),
                  const SizedBox(height: 60),

                  // Account Information Section
                  const SectionHeader(
                    title: 'Account Information',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoCard(
                    icon: Icons.badge_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Customer ID',
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
                    icon: Icons.person_rounded,
                    iconColor: AppTheme.successColor,
                    title: 'Name',
                    value: userName,
                  ),

                  const SizedBox(height: 32),

                  // Settings Section
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

                  // Logout Button
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
