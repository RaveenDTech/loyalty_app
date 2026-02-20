import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/loyalty_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/detail_row.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/summary_row.dart';
import 'tab_page_wrapper.dart';

/// Tab wrapper for Transactions: summary and list or empty state.
class CustomerTransactionsTab extends StatelessWidget {
  const CustomerTransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPageWrapper(
      title: 'Transactions',
      child: CustomerTransactionsBody(),
    );
  }
}

class CustomerTransactionsBody extends StatelessWidget {
  const CustomerTransactionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<LoyaltyProvider, AuthProvider>(
      builder: (context, loyaltyProvider, authProvider, _) {
        final transactions = loyaltyProvider
            .getCustomerTransactions(authProvider.userId)
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

        if (transactions.isEmpty) {
          return SafeArea(
            child: Container(
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
          child: SafeArea(
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SummaryRow(
                        label: 'Total Spent',
                        value: CurrencyFormat.lkr(totalBillAmount, decimalDigits: 0),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withOpacity(0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      SummaryRow(
                        label: 'Total Saved',
                        value: CurrencyFormat.lkr(totalDiscount, decimalDigits: 0),
                        valueColor: AppTheme.successColor,
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withOpacity(0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      SummaryRow(
                        label: 'Total Paid',
                        value: CurrencyFormat.lkr(totalFinalAmount, decimalDigits: 0),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
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
          ),
        );
      },
    );
  }
}

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
    return CurrencyFormat.lkr(amount, decimalDigits: 0);
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
                                DetailRow(
                                  label: 'Bill Amount',
                                  value: _money(widget.transaction.billAmount),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  color: AppTheme.borderColor,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                DetailRow(
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
                                DetailRow(
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
