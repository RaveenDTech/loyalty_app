import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/dsi_loyalty_tier.dart';

class DsiLoyaltyPage extends StatelessWidget {
  const DsiLoyaltyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color bgTop = Color(0xFF080E27);

    return Scaffold(
      backgroundColor: bgTop,
      body: Consumer2<AuthProvider, LoyaltyProvider>(
        builder: (context, authProvider, loyaltyProvider, _) {
          final customerId = authProvider.userId;
          loyaltyProvider.setCustomerTenure(
            customerId,
            authProvider.employmentTenureYears,
          );
          final tenureYears = loyaltyProvider.getTenureYearsForCustomer(customerId);
          final currentTier = loyaltyProvider.getTierForCustomer(customerId);
          final discountPercent = currentTier.discountPercent;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'DSI Loyalty',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(
                        context,
                        theme,
                        currentTier,
                        tenureYears,
                        discountPercent,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle(theme, 'How it works'),
                      const SizedBox(height: 12),
                      _buildHowItWorksCard(theme),
                      const SizedBox(height: 28),
                      _buildSectionTitle(theme, 'All tiers'),
                      const SizedBox(height: 12),
                      ...DsiLoyaltyTierHelper.allTiers.map(
                        (tier) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TierRow(
                            tier: tier,
                            isCurrent: tier == currentTier,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    ThemeData theme,
    DsiTenureTier currentTier,
    double tenureYears,
    int discountPercent,
  ) {
    final colors = currentTier.gradientColors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0],
            colors[1],
            colors[1].withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  currentTier.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your tier',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTier.tierName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentTier.label}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount on every bill',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$discountPercent%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (tenureYears > 0) ...[
            const SizedBox(height: 12),
            Text(
              '${tenureYears.toStringAsFixed(1)} years at DSI Group',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildHowItWorksCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HowItWorksRow(
            icon: Icons.work_outline_rounded,
            title: 'Employment at DSI Group',
            subtitle: 'Your tenure at DSI group companies determines your tier.',
          ),
          SizedBox(height: 16),
          _HowItWorksRow(
            icon: Icons.discount_rounded,
            title: 'Discount on every bill',
            subtitle: 'Suppliers apply your tier discount to the bill total.',
          ),
          SizedBox(height: 16),
          _HowItWorksRow(
            icon: Icons.receipt_long_rounded,
            title: 'Automatic at checkout',
            subtitle: 'Scan QR, get approved, and your discount is applied.',
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final DsiTenureTier tier;
  final bool isCurrent;

  const _TierRow({required this.tier, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tier.gradientColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? colors[0].withOpacity(0.6) : AppTheme.borderColor,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.map((c) => c.withOpacity(0.9)).toList(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tier.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.tierName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'You',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tier.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${tier.discountPercent}%',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors[0],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HowItWorksRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
