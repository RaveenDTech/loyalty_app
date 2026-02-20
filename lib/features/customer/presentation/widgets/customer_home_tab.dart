import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/wave_painter.dart';
import '../../../../core/widgets/floating_particles.dart';
import '../../../supplier/presentation/widgets/supplier_info_card.dart';
import '../../../supplier/presentation/widgets/supplier_quick_action_button.dart';
import 'promotion_carousel.dart';

/// Home tab body for customer dashboard (welcome, stats, quick actions, requests, transactions).
class CustomerHomeTab extends StatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoyaltyProvider, AuthProvider>(
      builder: (context, loyaltyProvider, authProvider, _) {
        final customerId = authProvider.userId;
        loyaltyProvider.setCustomerTenure(
          customerId,
          authProvider.employmentTenureYears,
        );

        final allRequests = [
          ...loyaltyProvider.pendingRequests
              .where((r) => r.customerId == customerId),
          ...loyaltyProvider.approvedRequests
              .where((r) => r.customerId == customerId),
        ];

        final transactions = loyaltyProvider
            .getCustomerTransactions(customerId)
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

        final totalDiscountReceived = transactions.fold<double>(
          0,
          (sum, t) => sum + t.discountAmount,
        );

        final customerName = authProvider.userName.isEmpty
            ? 'Customer'
            : authProvider.userName;
        final initials = customerName
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        if (useNavigationRail(context)) {
          return _CustomerDesktopDashboard(
            customerName: customerName,
            initials: initials,
            totalDiscountReceived: totalDiscountReceived,
            transactionCount: transactions.length,
            allRequests: allRequests,
            transactions: transactions,
          );
        }

        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppTheme.primaryDark,
              elevation: 0,
              pinned: true,
              expandedHeight: 225 + kToolbarHeight,
              collapsedHeight: 58,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.backgroundColor,
                            AppTheme.primaryDark,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: CustomPaint(
                            painter: WavePainter(
                              waveValue: _waveAnimation.value,
                              primaryColor: AppTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, child) {
                        return FloatingParticles(
                          animationValue: _particleController.value,
                        );
                      },
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SafeArea(
                            right: false,
                            left: false,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.push('/customer/profile'),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppTheme.primaryColor,
                                                AppTheme.primaryColor.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initials,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        customerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Consumer<NotificationProvider>(
                                  builder: (context, notificationProvider, _) {
                                    final unreadCount = notificationProvider.unreadCount;
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => context.push('/notifications'),
                                            borderRadius: BorderRadius.circular(24),
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.12),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                ),
                                                borderRadius: BorderRadius.circular(22),
                                              ),
                                              child: const Icon(
                                                Icons.notifications_none_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade400,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            height: 3,
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  Colors.white.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: SupplierInfoCard(
                                  title: 'Discounts',
                                  subtitle: 'Total received',
                                  value: NumberFormat.compactCurrency(
                                    symbol: 'LKR ',
                                    decimalDigits: 0,
                                  ).format(totalDiscountReceived),
                                  icon: Icons.discount_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SupplierInfoCard(
                                  title: 'Transactions',
                                  subtitle: 'Total completed',
                                  value: transactions.length.toString(),
                                  icon: Icons.receipt_long_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(25),
                child: Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promotions',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PromotionCarousel(
                      items: PromotionCarousel.defaultPromotions,
                      height: 180,
                      autoPlayDuration: const Duration(seconds: 5),
                      enableAutoPlay: true,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SupplierQuickActionButton(
                          label: 'Scan QR',
                          icon: Icons.qr_code_scanner_rounded,
                          color: AppTheme.primaryColor,
                          onTap: () => context.push('/customer/scan'),
                        ),
                        SupplierQuickActionButton(
                          label: 'Buy Voucher',
                          icon: Icons.card_giftcard_rounded,
                          color: AppTheme.accentColor,
                          onTap: () => context.push('/customer/vendor-selection'),
                        ),
                        SupplierQuickActionButton(
                          label: 'Transactions',
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.successColor,
                          onTap: () => context.push('/customer/transactions'),
                        ),
                        SupplierQuickActionButton(
                          label: 'Vouchers',
                          icon: Icons.history_rounded,
                          color: AppTheme.warningColor,
                          onTap: () => context.push('/customer/voucher-history'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (allRequests.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'My Requests',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/customer/requests'),
                            child: Text(
                              'View all',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...allRequests.take(3).map(
                            (request) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CustomerRequestCard(request: request),
                            ),
                          ).toList(),
                      const SizedBox(height: 20),
                    ] else
                      const EmptyStateCard(
                        icon: Icons.request_quote_outlined,
                        title: 'No requests yet',
                        subtitle: 'Scan a QR code to request a discount',
                      ),
                    Row(
                      children: [
                        Text(
                          'Recent Transactions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/customer/transactions'),
                          child: Text(
                            'View all',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (transactions.isEmpty)
                      const EmptyStateCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        subtitle: 'Completed transactions will appear here',
                      )
                    else
                      Column(
                        children: transactions.take(5).map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CustomerTransactionCard(
                              transaction: transaction,
                            ),
                          ),
                        ).toList(),
                      ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Desktop/PC dashboard: compact header, stat cards row, quick actions grid, two-column requests + transactions.
class _CustomerDesktopDashboard extends StatelessWidget {
  const _CustomerDesktopDashboard({
    required this.customerName,
    required this.initials,
    required this.totalDiscountReceived,
    required this.transactionCount,
    required this.allRequests,
    required this.transactions,
  });

  final String customerName;
  final String initials;
  final double totalDiscountReceived;
  final int transactionCount;
  final List<dynamic> allRequests;
  final List<dynamic> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DesktopHeader(customerName: customerName, initials: initials),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _DesktopStatCard(
                    title: 'Total discounts',
                    value: NumberFormat.compactCurrency(
                      symbol: 'LKR ',
                      decimalDigits: 0,
                    ).format(totalDiscountReceived),
                    icon: Icons.discount_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DesktopStatCard(
                    title: 'Transactions',
                    value: transactionCount.toString(),
                    icon: Icons.receipt_long_rounded,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Promotions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            PromotionCarousel(
              items: PromotionCarousel.defaultPromotions,
              height: 200,
              autoPlayDuration: const Duration(seconds: 5),
              enableAutoPlay: true,
            ),
            const SizedBox(height: 28),
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _DesktopQuickAction(
                      label: 'Scan QR',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppTheme.primaryColor,
                      onTap: () => context.push('/customer/scan'),
                    ),
                    _DesktopQuickAction(
                      label: 'Buy Voucher',
                      icon: Icons.card_giftcard_rounded,
                      color: AppTheme.accentColor,
                      onTap: () => context.push('/customer/vendor-selection'),
                    ),
                    _DesktopQuickAction(
                      label: 'Transactions',
                      icon: Icons.receipt_long_rounded,
                      color: AppTheme.successColor,
                      onTap: () => context.push('/customer/transactions'),
                    ),
                    _DesktopQuickAction(
                      label: 'Vouchers',
                      icon: Icons.history_rounded,
                      color: AppTheme.warningColor,
                      onTap: () => context.push('/customer/voucher-history'),
                    ),
                  ],
                ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _DesktopSectionCard(
                    title: 'My Requests',
                    viewAllTap: () => context.push('/customer/requests'),
                    child: allRequests.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: EmptyStateCard(
                              icon: Icons.request_quote_outlined,
                              title: 'No requests yet',
                              subtitle: 'Scan a QR code to request a discount',
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allRequests.length > 5 ? 5 : allRequests.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _CustomerRequestCard(
                              request: allRequests[i],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _DesktopSectionCard(
                    title: 'Recent Transactions',
                    viewAllTap: () => context.push('/customer/transactions'),
                    child: transactions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: EmptyStateCard(
                              icon: Icons.receipt_long_outlined,
                              title: 'No transactions yet',
                              subtitle: 'Completed transactions will appear here',
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length > 5 ? 5 : transactions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _CustomerTransactionCard(
                              transaction: transactions[i],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.customerName,
    required this.initials,
  });

  final String customerName;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/customer/profile'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/customer/profile'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final unreadCount = notificationProvider.unreadCount;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/notifications'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DesktopStatCard extends StatelessWidget {
  const _DesktopStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopQuickAction extends StatelessWidget {
  const _DesktopQuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSectionCard extends StatelessWidget {
  const _DesktopSectionCard({
    required this.title,
    required this.viewAllTap,
    required this.child,
  });

  final String title;
  final VoidCallback viewAllTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: viewAllTap,
                  child: Text(
                    'View all',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CustomerRequestCard extends StatelessWidget {
  final dynamic request;

  const _CustomerRequestCard({required this.request});

  String _age(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status.toString().contains('pending');
    final isApproved = request.status.toString().contains('approved');
    final color = isPending
        ? AppTheme.warningColor
        : isApproved
            ? AppTheme.successColor
            : AppTheme.primaryColor;
    final date = request.createdAt ?? DateTime.now();

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isPending
                    ? Icons.pending_actions_rounded
                    : isApproved
                        ? Icons.check_circle_rounded
                        : Icons.store_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.supplierName?.toString() ?? 'Supplier',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPending
                              ? 'Pending'
                              : isApproved
                                  ? 'Approved'
                                  : 'Processing',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _age(date),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerTransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _CustomerTransactionCard({required this.transaction});

  String _money(double amount) {
    return CurrencyFormat.lkr(amount, decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    return InkWell(
      onTap: () => context.push('/customer/transactions'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor.withOpacity(0.15),
                    AppTheme.successColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.receipt_rounded,
                color: AppTheme.successColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.supplierName?.toString() ?? 'Supplier',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateFormat.format(transaction.completedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(transaction.finalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Disc: ${_money(transaction.discountAmount)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
