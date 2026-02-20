import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/dsi_loyalty_tier.dart';

/// Expandable DSI loyalty tier card and levels list for customer profile.
class ExpandableLoyaltySection extends StatefulWidget {
  final DsiTenureTier tier;
  final double tenureYears;

  const ExpandableLoyaltySection({
    super.key,
    required this.tier,
    required this.tenureYears,
  });

  @override
  State<ExpandableLoyaltySection> createState() =>
      _ExpandableLoyaltySectionState();
}

class _ExpandableLoyaltySectionState extends State<ExpandableLoyaltySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(22),
            child: _DsiLoyaltyProfileCard(
              tier: widget.tier,
              tenureYears: widget.tenureYears,
              isExpanded: _expanded,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _LoyaltyLevelsList(currentTier: widget.tier),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _DsiLoyaltyProfileCard extends StatelessWidget {
  final DsiTenureTier tier;
  final double tenureYears;
  final bool isExpanded;

  const _DsiLoyaltyProfileCard({
    required this.tier,
    required this.tenureYears,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tier.gradientColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withOpacity(0.35),
            colors[1].withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors[0].withOpacity(0.5),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.5),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tier.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loyalty status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.tierName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tier.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tier.discountPercent}%',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'off every DSI bill',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  tenureYears > 0
                      ? '${tenureYears.toStringAsFixed(1)} years at DSI Group'
                      : 'Linked to your DSI employment record',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.expand_more_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoyaltyLevelsList extends StatelessWidget {
  final DsiTenureTier currentTier;

  const _LoyaltyLevelsList({required this.currentTier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loyalty levels & percentages',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...DsiLoyaltyTierHelper.allTiers.map(
            (tier) {
              final isCurrent = tier == currentTier;
              final colors = tier.gradientColors;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? colors[0].withOpacity(0.18)
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? colors[0].withOpacity(0.6)
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors[0].withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tier.icon,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tier.tierName,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors[0].withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tier.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tier.discountPercent}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors[0],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
