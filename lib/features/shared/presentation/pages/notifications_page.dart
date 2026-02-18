import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/toast.dart';
import '../../../supplier/presentation/widgets/empty_state_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unreadCount = notificationProvider.unreadCount;
              if (unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  notificationProvider.markAllAsRead();
                  Toast.success(context, 'All notifications marked as read');
                },
                child: Text(
                  'Mark all read',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: const EmptyStateCard(
                icon: Icons.notifications_none_outlined,
                title: 'No notifications',
                subtitle: 'You\'re all caught up! New notifications will appear here',
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(notification: notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic notification;

  const _NotificationCard({required this.notification});

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat('MMM dd').format(date);
  }

  IconData _getNotificationIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('request') || lowerTitle.contains('approve')) {
      return Icons.request_quote_rounded;
    } else if (lowerTitle.contains('transaction') || lowerTitle.contains('completed')) {
      return Icons.receipt_long_rounded;
    } else if (lowerTitle.contains('reject') || lowerTitle.contains('denied')) {
      return Icons.cancel_rounded;
    } else if (lowerTitle.contains('discount')) {
      return Icons.discount_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getNotificationColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('request') || lowerTitle.contains('approve')) {
      return AppTheme.successColor;
    } else if (lowerTitle.contains('transaction') || lowerTitle.contains('completed')) {
      return AppTheme.primaryColor;
    } else if (lowerTitle.contains('reject') || lowerTitle.contains('denied')) {
      return AppTheme.errorColor;
    } else if (lowerTitle.contains('discount')) {
      return AppTheme.warningColor;
    }
    return AppTheme.secondaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isRead = notification.isRead;
    final icon = _getNotificationIcon(notification.title);
    final iconColor = _getNotificationColor(notification.title);

    return InkWell(
      onTap: () {
        if (!isRead) {
          Provider.of<NotificationProvider>(context, listen: false)
              .markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? AppTheme.surfaceColor
              : AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? AppTheme.borderColor.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.3),
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor,
                    iconColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                            fontSize: 15,
                            color: isRead
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(notification.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(notification.timestamp)} • ${timeFormat.format(notification.timestamp)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          fontSize: 11,
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
    );
  }
}
