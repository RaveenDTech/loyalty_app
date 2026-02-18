import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/toast.dart';
import '../widgets/supplier_info_card.dart';
import '../widgets/supplier_quick_action_button.dart';
import '../widgets/task_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/qr_code_bottom_sheet.dart';
import 'pending_requests_page.dart';
import 'supplier_transactions_page.dart';
import 'supplier_profile_page.dart';

class SupplierHomePage extends StatefulWidget {
  const SupplierHomePage({super.key});

  @override
  State<SupplierHomePage> createState() => _SupplierHomePageState();
}

class _SupplierHomePageState extends State<SupplierHomePage> {
  static const Color _bgTop = Color(0xFF080E27);
  static const Color _bgTop2 = Color(0xFF0F2B66);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _bgTop,
      extendBody: true,
      bottomNavigationBar: GlassmorphismBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // QR Code button - show bottom sheet
            QRCodeBottomSheet.show(context);
            return;
          }
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
            // Index 1: Pending Requests
            _buildPendingRequestsPage(),
            // Index 2: QR Code (handled by bottom sheet, but keep placeholder)
            _buildHomePage(),
            // Index 3: Transactions
            _buildTransactionsPage(),
            // Index 4: Profile
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
                    // stretchModes: const [
                    //   StretchMode.zoomBackground,
                    //   StretchMode.blurBackground,
                    // ],
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
                                // bottom: false,
                                right: false,
                                left: false,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
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
                                            supplierName,
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
                                      title: 'Pending requests',
                                      subtitle: 'Awaiting approval',
                                      value: pending.length.toString(),
                                      icon: Icons.pending_actions_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SupplierInfoCard(
                                      title: 'Today\'s total',
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
                              onTap: () => context.push(
                                '/supplier/pending-requests',
                              ),
                            ),
                            SupplierQuickActionButton(
                              label: 'Transactions',
                              icon: Icons.receipt_long_rounded,
                              color: AppTheme.successColor,
                              onTap: () => context.push(
                                '/supplier/transactions',
                              ),
                            ),
                            SupplierQuickActionButton(
                              label: 'Reports',
                              icon: Icons.bar_chart_rounded,
                              color: AppTheme.secondaryColor,
                              onTap: () {
                                // Placeholder for future reports page
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (pending.isNotEmpty || approved.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'Active Tasks',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    context.push('/supplier/pending-requests'),
                                icon:  Text('View all', style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor
                                ),),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (pending.isNotEmpty)
                            ...pending
                                .take(3)
                                .map(
                                  (request) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TaskCard(
                                      type: TaskType.pending,
                                      request: request,
                                      onTap: () => context
                                          .push('/supplier/pending-requests'),
                                    ),
                                  ),
                                )
                                .toList(),
                          if (approved.isNotEmpty)
                            ...approved
                                .take(3)
                                .map(
                                  (request) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TaskCard(
                                      type: TaskType.billUpload,
                                      request: request,
                                      onTap: () => context.push(
                                          '/supplier/bill-upload?requestId=${request.id}'),
                                    ),
                                  ),
                                )
                                .toList(),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  context.push('/supplier/transactions'),
                              child:  Text('View all', style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor
                              ),),
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
                                    child: TransactionCard(
                                      transaction: transaction,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                        const SizedBox(height: 200,),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
      );
  }

  Widget _buildPendingRequestsPage() {
    return _PageWrapper(
      title: 'Pending Requests',
      child: _PendingRequestsBody(),
    );
  }

  Widget _buildTransactionsPage() {
    return _PageWrapper(
      title: 'All Transactions',
      child: _TransactionsBody(),
    );
  }

  Widget _buildProfilePage() {
    return _PageWrapper(
      title: 'Profile',
      child: _ProfileBody(),
    );
  }
}

// Wrapper widget to provide consistent AppBar for embedded pages
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
        leading: const SizedBox.shrink(), // No back button in bottom nav mode
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

// Body content extracted from PendingRequestsPage
class _PendingRequestsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, loyaltyProvider, _) {
        final requests = loyaltyProvider.pendingRequests;

        if (requests.isEmpty) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: const EmptyStateCard(
              icon: Icons.pending_actions_outlined,
              title: 'No pending requests',
              subtitle: 'New discount requests from customers will appear here',
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
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
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

// Embedded version of RequestCard - full content from pending_requests_page
class _EmbeddedRequestCard extends StatefulWidget {
  final dynamic request;

  const _EmbeddedRequestCard({required this.request});

  @override
  State<_EmbeddedRequestCard> createState() => _EmbeddedRequestCardState();
}

class _EmbeddedRequestCardState extends State<_EmbeddedRequestCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _actionType;

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final customerName = widget.request.customerName.toString();
    final initials = customerName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.08),
                    AppTheme.primaryColor.withOpacity(0.03),
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
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
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
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
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
                              Icons.person_outline_rounded,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'ID: ${widget.request.customerId.substring(0, 10)}...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.warningColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Pending',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
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

          // Expandable Content Section with slide transition
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
                          // Request info row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.discount_rounded,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Discount Request',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Customer requesting discount',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Date and time info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateFormat.format(widget.request.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timeFormat.format(widget.request.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getTimeAgo(widget.request.createdAt),
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _RequestActionButton(
                                  icon: Icons.close_rounded,
                                  label: 'Reject',
                                  color: AppTheme.errorColor,
                                  isOutlined: true,
                                  isLoading: _isLoading && _actionType == 'reject',
                                  onTap: _isLoading
                                      ? null
                                      : () => _rejectRequest(context, widget.request.id),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _RequestActionButton(
                                  icon: Icons.check_circle_rounded,
                                  label: 'Approve Request',
                                  color: AppTheme.successColor,
                                  isOutlined: false,
                                  isLoading: _isLoading && _actionType == 'approve',
                                  onTap: _isLoading
                                      ? null
                                      : () => _approveRequest(context, widget.request),
                                ),
                              ),
                            ],
                          ),
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

  Future<void> _approveRequest(BuildContext context, dynamic request) async {
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: ConfirmationDialog(
            title: 'Approve Request',
            message: 'Approve discount request from ${request.customerName}?',
            icon: Icons.check_circle_rounded,
            iconColor: AppTheme.successColor,
            confirmText: 'Approve',
            confirmColor: AppTheme.successColor,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isLoading = true;
        _actionType = 'approve';
      });

      try {
        final success = await loyaltyProvider.approveRequest(request.id);

        if (success && context.mounted) {
          await notificationProvider.showLocalNotification(
            title: 'Request Approved',
            body: 'Discount request from ${request.customerName} has been approved',
          );

          if (context.mounted) {
            context.push('/supplier/bill-upload?requestId=${request.id}');
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _actionType = null;
          });
        }
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, String requestId) async {
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: ConfirmationDialog(
            title: 'Reject Request',
            message: 'Are you sure you want to reject this request?',
            icon: Icons.close_rounded,
            iconColor: AppTheme.errorColor,
            confirmText: 'Reject',
            confirmColor: AppTheme.errorColor,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isLoading = true;
        _actionType = 'reject';
      });

      try {
        final success = await loyaltyProvider.rejectRequest(requestId);

        if (success && context.mounted) {
          Toast.error(context, 'Request rejected');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _actionType = null;
          });
        }
      }
    }
  }
}

// Request action button widget
class _RequestActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final bool isLoading;
  final VoidCallback? onTap;

  const _RequestActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isOutlined,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;

    if (isOutlined) {
      return InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled ? color.withOpacity(0.5) : color,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(icon, size: 16, color: isDisabled ? color.withOpacity(0.5) : color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDisabled ? color.withOpacity(0.5) : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDisabled ? color.withOpacity(0.6) : color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Request confirm dialog widget

// Body content extracted from SupplierTransactionsPage
class _TransactionsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LoyaltyProvider, AuthProvider>(
      builder: (context, loyaltyProvider, authProvider, _) {
        final transactions =
            loyaltyProvider.getSupplierTransactions(authProvider.userId)
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _TransactionSummaryRow(
                      label: 'Total Bill Amount',
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
                      label: 'Total Discount Given',
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
                      label: 'Total Final Amount',
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

// Embedded transaction card - full content from supplier_transactions_page
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
    final customerName = widget.transaction.customerName.toString();
    final initials = customerName
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
                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
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
                        'Disc: ${_money(widget.transaction.discountAmount)}',
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
                                const Divider(
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
                                const Divider(
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
                              const Icon(
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
                              const Icon(
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
                                          return const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: AppTheme.textSecondary,
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
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

// Body content extracted from SupplierProfilePage
class _ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.userName;
        final userEmail = authProvider.userEmail;
        final userId = authProvider.userId;

        // Get initials for avatar
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

                const SizedBox(height: 24),

                // Account Information Section
                const _ProfileSectionHeader(
                  title: 'Account Information',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  icon: Icons.badge_rounded,
                  iconColor: AppTheme.primaryColor,
                  title: 'Supplier ID',
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
                  icon: Icons.store_rounded,
                  iconColor: AppTheme.successColor,
                  title: 'Store Name',
                  value: userName,
                ),

                const SizedBox(height: 32),

                // Settings Section
                const _ProfileSectionHeader(
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

// Profile section header widget
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
            borderRadius: BorderRadius.circular(8),
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

// Profile info card widget
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
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

// Profile menu card widget
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
                borderRadius: BorderRadius.circular(10),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Profile logout button widget
class _ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileLogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            const Icon(
              Icons.logout_rounded,
              color: AppTheme.errorColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
