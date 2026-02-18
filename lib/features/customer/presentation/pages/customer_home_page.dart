import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/toast.dart';
import '../../../supplier/presentation/widgets/empty_state_card.dart';
import '../../../supplier/presentation/widgets/supplier_info_card.dart';
import '../../../supplier/presentation/widgets/supplier_quick_action_button.dart';
import '../widgets/customer_bottom_navigation_bar.dart';
import 'qr_scan_page.dart';
import 'customer_transactions_page.dart';
import 'customer_profile_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  static const Color _bgTop = Color(0xFF080E27);
  static const Color _bgTop2 = Color(0xFF0F2B66);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _bgTop,
      extendBody: true,
      bottomNavigationBar: CustomerBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Index 0: Home
            _buildHomePage(),
            // Index 1: Requests
            _buildRequestsPage(),
            // Index 2: Transactions (shifted since scan is now separate page)
            _buildTransactionsPage(),
            // Index 3: Profile
            _buildProfilePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final theme = Theme.of(context);
    return Consumer2<LoyaltyProvider, AuthProvider>(
          builder: (context, loyaltyProvider, authProvider, _) {
            final customerId = authProvider.userId;

            // Get customer's requests (both pending and approved)
            final allRequests = [
              ...loyaltyProvider.pendingRequests
                  .where((r) => r.customerId == customerId),
              ...loyaltyProvider.approvedRequests
                  .where((r) => r.customerId == customerId),
            ];

            // Get customer's transactions
            final transactions = loyaltyProvider
                .getCustomerTransactions(customerId)
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

            // Calculate stats
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final todayTransactions = transactions
                .where((t) => t.completedAt.isAfter(today))
                .toList();

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
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor,
                                _bgTop2,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SafeArea(
                                right: false,
                                left: false,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => context.push('/customer/profile'),
                                      borderRadius: BorderRadius.circular(24),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome back',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            customerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Consumer<NotificationProvider>(
                                      builder:
                                          (context, notificationProvider, _) {
                                        final unreadCount =
                                            notificationProvider.unreadCount;
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                context.push('/notifications');
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .notifications_none_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (unreadCount > 0)
                                              Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade400,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 18,
                                                    minHeight: 18,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      unreadCount > 9
                                                          ? '9+'
                                                          : '$unreadCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                              const SizedBox(height: 24),
                              Text(
                                'Dashboard',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
                              onTap: () {
                                context.push('/customer/voucher-history');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (allRequests.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'My Requests',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  context.push('/customer/requests');
                                },
                                child: Text(
                                  'View all',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...allRequests
                              .take(3)
                              .map(
                                (request) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _CustomerRequestCard(
                                    request: request,
                                  ),
                                ),
                              )
                              .toList(),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  context.push('/customer/transactions'),
                              child: Text(
                                'View all',
                                style: theme.textTheme.titleSmall?.copyWith(
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
                            children: transactions
                                .take(5)
                                .map(
                                  (transaction) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _CustomerTransactionCard(
                                      transaction: transaction,
                                    ),
                                  ),
                                )
                                .toList(),
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

  Widget _buildRequestsPage() {
    return const _PageWrapper(
      title: 'My Requests',
      child: _RequestsBody(),
    );
  }

  Widget _buildTransactionsPage() {
    return const _PageWrapper(
      title: 'Transactions',
      child: _TransactionsBody(),
    );
  }

  Widget _buildProfilePage() {
    return const _PageWrapper(
      title: 'Profile',
      child: _ProfileBody(),
    );
  }
}

// Page wrapper for embedded pages
class _PageWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _PageWrapper({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color _bgTop = Color(0xFF080E27);

    return Scaffold(
      backgroundColor: _bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: child,
    );
  }
}

// Requests body (embedded from CustomerRequestsPage)
class _RequestsBody extends StatelessWidget {
  const _RequestsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoyaltyProvider, AuthProvider>(
      builder: (context, loyaltyProvider, authProvider, _) {
        final customerId = authProvider.userId;

        // Get all customer requests (pending, approved, rejected)
        final allRequests = [
          ...loyaltyProvider.pendingRequests
              .where((r) => r.customerId == customerId),
          ...loyaltyProvider.approvedRequests
              .where((r) => r.customerId == customerId),
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (allRequests.isEmpty) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: const EmptyStateCard(
              icon: Icons.request_quote_outlined,
              title: 'No requests yet',
              subtitle: 'Scan a QR code to request a discount from suppliers',
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
            itemCount: allRequests.length,
            itemBuilder: (context, index) {
              final request = allRequests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _EmbeddedRequestCard(request: request),
              );
            },
          ),
        );
      },
    );
  }
}

// Embedded request card (from CustomerRequestsPage)
class _EmbeddedRequestCard extends StatefulWidget {
  final dynamic request;

  const _EmbeddedRequestCard({required this.request});

  @override
  State<_EmbeddedRequestCard> createState() => _EmbeddedRequestCardState();
}

class _EmbeddedRequestCardState extends State<_EmbeddedRequestCard> {
  bool _isExpanded = false;

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _getStatusColor() {
    final status = widget.request.status.toString().toLowerCase();
    if (status.contains('pending')) {
      return AppTheme.warningColor;
    } else if (status.contains('approved')) {
      return AppTheme.successColor;
    } else if (status.contains('rejected')) {
      return AppTheme.errorColor;
    }
    return AppTheme.primaryColor;
  }

  String _getStatusText() {
    final status = widget.request.status.toString().toLowerCase();
    if (status.contains('pending')) {
      return 'Pending';
    } else if (status.contains('approved')) {
      return 'Approved';
    } else if (status.contains('rejected')) {
      return 'Rejected';
    }
    return 'Unknown';
  }

  IconData _getStatusIcon() {
    final status = widget.request.status.toString().toLowerCase();
    if (status.contains('pending')) {
      return Icons.pending_actions_rounded;
    } else if (status.contains('approved')) {
      return Icons.check_circle_rounded;
    } else if (status.contains('rejected')) {
      return Icons.cancel_rounded;
    }
    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final supplierName = widget.request.supplierName?.toString() ?? 'Supplier';
    final initials = supplierName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section - always visible (collapsed state)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withOpacity(0.08),
                    statusColor.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusColor,
                          statusColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Supplier Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplierName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 12,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(widget.request.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _isExpanded
                  ? Padding(
                      key: const ValueKey('expanded'),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Request Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _RequestDetailRow(
                                  label: 'Request ID',
                                  value: widget.request.id,
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: AppTheme.borderColor,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                _RequestDetailRow(
                                  label: 'Supplier',
                                  value: supplierName,
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: AppTheme.borderColor,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                _RequestDetailRow(
                                  label: 'Status',
                                  value: statusText,
                                  valueColor: statusColor,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Date and Time
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateFormat.format(widget.request.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeFormat.format(widget.request.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (widget.request.approvedAt != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Approved on: ${dateFormat.format(widget.request.approvedAt!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (widget.request.rejectedAt != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  size: 14,
                                  color: AppTheme.errorColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rejected on: ${dateFormat.format(widget.request.rejectedAt!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('collapsed')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _RequestDetailRow({
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
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Transactions body (embedded from CustomerTransactionsPage)
class _TransactionsBody extends StatelessWidget {
  const _TransactionsBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<LoyaltyProvider, AuthProvider>(
      builder: (context, loyaltyProvider, authProvider, _) {
        final transactions = loyaltyProvider
            .getCustomerTransactions(authProvider.userId)
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

        if (transactions.isEmpty) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: const EmptyStateCard(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              subtitle: 'Completed transactions will appear here',
            ),
          );
        }

        // Calculate summary
        double totalBillAmount = 0;
        double totalDiscount = 0;
        double totalFinalAmount = 0;

        for (var transaction in transactions) {
          totalBillAmount += transaction.billAmount;
          totalDiscount += transaction.discountAmount;
          totalFinalAmount += transaction.finalAmount;
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Total Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _TransactionSummaryRow(
                      label: 'Total Spent',
                      value: NumberFormat.currency(
                        symbol: 'LKR ',
                        decimalDigits: 0,
                      ).format(totalBillAmount),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    _TransactionSummaryRow(
                      label: 'Total Saved',
                      value: NumberFormat.currency(
                        symbol: 'LKR ',
                        decimalDigits: 0,
                      ).format(totalDiscount),
                      valueColor: AppTheme.successColor,
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    _TransactionSummaryRow(
                      label: 'Total Paid',
                      value: NumberFormat.currency(
                        symbol: 'LKR ',
                        decimalDigits: 0,
                      ).format(totalFinalAmount),
                      isBold: true,
                    ),
                  ],
                ),
              ),

              // Transactions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _EmbeddedTransactionCard(transaction: transaction),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Transaction summary row
class _TransactionSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _TransactionSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Embedded transaction card (from CustomerTransactionsPage)
class _EmbeddedTransactionCard extends StatefulWidget {
  final dynamic transaction;

  const _EmbeddedTransactionCard({required this.transaction});

  @override
  State<_EmbeddedTransactionCard> createState() => _EmbeddedTransactionCardState();
}

class _EmbeddedTransactionCardState extends State<_EmbeddedTransactionCard> {
  bool _isExpanded = false;

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(date);
  }

  String _money(double amount) {
    final fmt = NumberFormat.currency(symbol: 'LKR ', decimalDigits: 0);
    return fmt.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final supplierName = widget.transaction.supplierName?.toString() ?? 'Supplier';
    final initials = supplierName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.successColor.withOpacity(0.08),
                    AppTheme.successColor.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.successColor,
                          AppTheme.successColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.successColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Supplier Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplierName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(widget.transaction.completedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(widget.transaction.finalAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saved: ${_money(widget.transaction.discountAmount)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _isExpanded
                  ? Padding(
                      key: const ValueKey('expanded'),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _TransactionDetailRow(
                                  label: 'Bill Amount',
                                  value: _money(widget.transaction.billAmount),
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: AppTheme.borderColor,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                _TransactionDetailRow(
                                  label: 'Discount',
                                  value: _money(widget.transaction.discountAmount),
                                  valueColor: AppTheme.successColor,
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: AppTheme.borderColor,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                _TransactionDetailRow(
                                  label: 'Final Amount',
                                  value: _money(widget.transaction.finalAmount),
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Date and Time
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateFormat.format(widget.transaction.completedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeFormat.format(widget.transaction.completedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (widget.transaction.billImagePath.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: widget.transaction.billImagePath.startsWith('http')
                                    ? Image.network(
                                        widget.transaction.billImagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: AppTheme.textSecondary,
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.receipt_long,
                                          size: 48,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('collapsed')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _TransactionDetailRow({
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

// Profile body (embedded from CustomerProfilePage)
class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
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
                      // Avatar
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
                          'Customer',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account Information Section
                _ProfileSectionHeader(
                  title: 'Account Information',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.badge_rounded,
                  iconColor: AppTheme.primaryColor,
                  title: 'Customer ID',
                  value: userId,
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.email_rounded,
                  iconColor: AppTheme.secondaryColor,
                  title: 'Email',
                  value: userEmail,
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.person_rounded,
                  iconColor: AppTheme.successColor,
                  title: 'Name',
                  value: userName,
                ),

                const SizedBox(height: 32),

                // Settings Section
                _ProfileSectionHeader(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                ),
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.warningColor,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    Toast.info(context, 'Notifications settings coming soon');
                  },
                ),
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.security_rounded,
                  iconColor: AppTheme.infoColor,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    Toast.info(context, 'Privacy settings coming soon');
                  },
                ),
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppTheme.secondaryColor,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    Toast.info(context, 'Help & Support coming soon');
                  },
                ),
                const SizedBox(height: 12),
                _ProfileMenuCard(
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
                _ProfileLogoutButton(
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
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
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
        );
      },
    );
  }
}

// Profile helper widgets
class _ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ProfileSectionHeader({
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

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileLogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.errorColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppTheme.errorColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


// Customer request card widget
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
      onTap: () {
        // TODO: Navigate to request details
      },
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

// Customer transaction card widget (adapted from TransactionCard)
class _CustomerTransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _CustomerTransactionCard({required this.transaction});

  String _money(double amount) {
    final fmt = NumberFormat.currency(symbol: 'LKR ', decimalDigits: 0);
    return fmt.format(amount);
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