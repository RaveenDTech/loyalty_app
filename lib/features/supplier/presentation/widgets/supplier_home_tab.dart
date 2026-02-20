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
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/wave_painter.dart';
import '../../../../core/widgets/floating_particles.dart';
import 'supplier_info_card.dart';
import 'supplier_quick_action_button.dart';
import 'task_card.dart';
import 'transaction_card.dart';

/// Home tab body for supplier dashboard (welcome, stats, quick actions, tasks, transactions).
class SupplierHomeTab extends StatefulWidget {
  const SupplierHomeTab({super.key});

  @override
  State<SupplierHomeTab> createState() => _SupplierHomeTabState();
}

class _SupplierHomeTabState extends State<SupplierHomeTab>
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
        final supplierId = authProvider.userId;

        final pending = loyaltyProvider.pendingRequests
            .where((r) => r.supplierId == supplierId)
            .toList();
        final approved = loyaltyProvider.approvedRequests
            .where((r) => r.supplierId == supplierId)
            .toList();
        final transactions = loyaltyProvider
            .getSupplierTransactions(supplierId)
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayTransactions = transactions
            .where((t) => t.completedAt.isAfter(today))
            .toList();

        final todayBillTotal = todayTransactions.fold<double>(
          0,
          (sum, t) => sum + t.billAmount,
        );
        final discountGiven = transactions.fold<double>(
          0,
          (sum, t) => sum + t.discountAmount,
        );

        final supplierName = authProvider.userName.isEmpty
            ? 'Supplier'
            : authProvider.userName;
        final initials = supplierName
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        if (useNavigationRail(context)) {
          return _SupplierDesktopDashboard(
            supplierName: supplierName,
            initials: initials,
            pendingCount: pending.length,
            todayBillTotal: todayBillTotal,
            discountGiven: discountGiven,
            pending: pending,
            approved: approved,
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
              collapsedHeight: 60,
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
                            AppTheme.primaryColor.withOpacity(0.2),
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
                                Container(
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
                                        supplierName,
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
                                  title: 'Pending requests',
                                  subtitle: 'Awaiting approval',
                                  value: pending.length.toString(),
                                  icon: Icons.pending_actions_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SupplierInfoCard(
                                  title: "Today's total",
                                  subtitle: 'Bills processed',
                                  value: NumberFormat.compactCurrency(
                                    symbol: 'LKR ',
                                    decimalDigits: 0,
                                  ).format(todayBillTotal),
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
                  height: 25,
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
                          label: 'Upload bill',
                          icon: Icons.upload_file_rounded,
                          color: AppTheme.primaryColor,
                          onTap: () {
                            if (approved.isNotEmpty) {
                              final first = approved.first;
                              context.push(
                                '/supplier/bill-upload?requestId=${first.id}',
                              );
                            } else {
                              context.push('/supplier/pending-requests');
                            }
                          },
                        ),
                        SupplierQuickActionButton(
                          label: 'Requests',
                          icon: Icons.assignment_rounded,
                          color: AppTheme.warningColor,
                          onTap: () => context.push('/supplier/pending-requests'),
                        ),
                        SupplierQuickActionButton(
                          label: 'Transactions',
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.successColor,
                          onTap: () => context.push('/supplier/transactions'),
                        ),
                        SupplierQuickActionButton(
                          label: 'Reports',
                          icon: Icons.bar_chart_rounded,
                          color: AppTheme.secondaryColor,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (pending.isNotEmpty || approved.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'Active Tasks',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                context.push('/supplier/pending-requests'),
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
                      if (pending.isNotEmpty)
                        ...pending.take(3).map(
                              (request) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TaskCard(
                                  type: TaskType.pending,
                                  request: request,
                                  onTap: () =>
                                      context.push('/supplier/pending-requests'),
                                ),
                              ),
                            ).toList(),
                      if (approved.isNotEmpty)
                        ...approved.take(3).map(
                              (request) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TaskCard(
                                  type: TaskType.billUpload,
                                  request: request,
                                  onTap: () => context.push(
                                    '/supplier/bill-upload?requestId=${request.id}',
                                  ),
                                ),
                              ),
                            ).toList(),
                      const SizedBox(height: 20),
                    ] else
                      const EmptyStateCard(
                        icon: Icons.check_circle_outline,
                        title: 'All caught up!',
                        subtitle: 'No pending tasks at the moment',
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
                          onPressed: () =>
                              context.push('/supplier/transactions'),
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
                            child: TransactionCard(
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

/// Desktop/PC dashboard: compact header, stat cards, quick actions, two-column tasks + transactions.
class _SupplierDesktopDashboard extends StatelessWidget {
  const _SupplierDesktopDashboard({
    required this.supplierName,
    required this.initials,
    required this.pendingCount,
    required this.todayBillTotal,
    required this.discountGiven,
    required this.pending,
    required this.approved,
    required this.transactions,
  });

  final String supplierName;
  final String initials;
  final int pendingCount;
  final double todayBillTotal;
  final double discountGiven;
  final List<dynamic> pending;
  final List<dynamic> approved;
  final List<dynamic> transactions;

  @override
  Widget build(BuildContext context) {
    final allTasks = [
      ...pending.take(5).map((r) => _TaskItem(type: TaskType.pending, request: r)),
      ...approved.take(5).map((r) => _TaskItem(type: TaskType.billUpload, request: r)),
    ];

    return Container(
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SupplierDesktopHeader(supplierName: supplierName, initials: initials),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _SupplierDesktopStatCard(
                    title: 'Pending requests',
                    value: pendingCount.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SupplierDesktopStatCard(
                    title: "Today's total",
                    value: NumberFormat.compactCurrency(
                      symbol: 'LKR ',
                      decimalDigits: 0,
                    ).format(todayBillTotal),
                    icon: Icons.receipt_long_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SupplierDesktopStatCard(
                    title: 'Discount given',
                    value: NumberFormat.compactCurrency(
                      symbol: 'LKR ',
                      decimalDigits: 0,
                    ).format(discountGiven),
                    icon: Icons.discount_rounded,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
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
                _SupplierDesktopQuickAction(
                  label: 'Upload bill',
                  icon: Icons.upload_file_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    if (approved.isNotEmpty) {
                      context.push('/supplier/bill-upload?requestId=${approved.first.id}');
                    } else {
                      context.push('/supplier/pending-requests');
                    }
                  },
                ),
                _SupplierDesktopQuickAction(
                  label: 'Requests',
                  icon: Icons.assignment_rounded,
                  color: AppTheme.warningColor,
                  onTap: () => context.push('/supplier/pending-requests'),
                ),
                _SupplierDesktopQuickAction(
                  label: 'Transactions',
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.successColor,
                  onTap: () => context.push('/supplier/transactions'),
                ),
                _SupplierDesktopQuickAction(
                  label: 'Reports',
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.secondaryColor,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _SupplierDesktopSectionCard(
                    title: 'Active Tasks',
                    viewAllTap: () => context.push('/supplier/pending-requests'),
                    child: allTasks.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: EmptyStateCard(
                              icon: Icons.check_circle_outline,
                              title: 'All caught up!',
                              subtitle: 'No pending tasks at the moment',
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allTasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final item = allTasks[i];
                              return TaskCard(
                                type: item.type,
                                request: item.request,
                                onTap: () {
                                  if (item.type == TaskType.billUpload) {
                                    context.push('/supplier/bill-upload?requestId=${item.request.id}');
                                  } else {
                                    context.push('/supplier/pending-requests');
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _SupplierDesktopSectionCard(
                    title: 'Recent Transactions',
                    viewAllTap: () => context.push('/supplier/transactions'),
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
                            itemBuilder: (_, i) => TransactionCard(
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

class _TaskItem {
  _TaskItem({required this.type, required this.request});
  final TaskType type;
  final dynamic request;
}

class _SupplierDesktopHeader extends StatelessWidget {
  const _SupplierDesktopHeader({
    required this.supplierName,
    required this.initials,
  });

  final String supplierName;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/supplier/profile'),
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
                supplierName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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

class _SupplierDesktopStatCard extends StatelessWidget {
  const _SupplierDesktopStatCard({
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
                    fontSize: 16,
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

class _SupplierDesktopQuickAction extends StatelessWidget {
  const _SupplierDesktopQuickAction({
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

class _SupplierDesktopSectionCard extends StatelessWidget {
  const _SupplierDesktopSectionCard({
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
