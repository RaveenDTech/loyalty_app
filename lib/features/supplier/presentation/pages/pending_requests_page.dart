import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/widgets/empty_state_card.dart';
import 'bill_upload_page.dart';

class PendingRequestsPage extends StatelessWidget {
  const PendingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color _bgTop = Color(0xFF080E27);

    return Scaffold(
      backgroundColor: _bgTop,
      extendBodyBehindAppBar: true ,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pending Requests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<LoyaltyProvider>(
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
            child: SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RequestCard(request: request),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final dynamic request;

  const _RequestCard({required this.request});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _actionType; // 'approve' or 'reject'

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
      child: SafeArea(
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
                                  child: _ActionButton(
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
                                  flex: 1,
                                  child: _ActionButton(
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
      ),
    );
  }

  Future<void> _approveRequest(BuildContext context, dynamic request) async {
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Approve Request',
      message: 'Approve discount request from ${request.customerName}?',
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.successColor,
      confirmText: 'Approve',
      confirmColor: AppTheme.successColor,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );

    if (confirmed == true && context.mounted) {
      // Set loading state
      setState(() {
        _isLoading = true;
        _actionType = 'approve';
      });

      try {
        final success = await loyaltyProvider.approveRequest(request.id);

        if (success && context.mounted) {
          // Update status immediately - the request will be removed from pending list
          // The provider's notifyListeners() will trigger a rebuild
          
          await notificationProvider.showLocalNotification(
            title: 'Request Approved',
            body: 'Discount request from ${request.customerName} has been approved',
          );

          if (context.mounted) {
            // Navigate to bill upload screen immediately
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

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Reject Request',
      message: 'Are you sure you want to reject this request?',
      icon: Icons.close_rounded,
      iconColor: AppTheme.errorColor,
      confirmText: 'Reject',
      confirmColor: AppTheme.errorColor,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );

    if (confirmed == true && context.mounted) {
      // Set loading state
      setState(() {
        _isLoading = true;
        _actionType = 'reject';
      });

      try {
        final success = await loyaltyProvider.rejectRequest(requestId);

        if (success && context.mounted) {
          // Update status immediately - the request will be removed from pending list
          // The provider's notifyListeners() will trigger a rebuild
          
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


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
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

