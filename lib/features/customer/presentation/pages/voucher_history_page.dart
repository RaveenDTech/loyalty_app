import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/voucher_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/voucher.dart';
import '../../../../core/models/shared_voucher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/glass_app_bar.dart';

class VoucherHistoryPage extends StatefulWidget {
  const VoucherHistoryPage({super.key});

  @override
  State<VoucherHistoryPage> createState() => _VoucherHistoryPageState();
}

class _VoucherHistoryPageState extends State<VoucherHistoryPage> {
  String _filterStatus = 'All'; // All, Active, Redeemed, Expired
  bool _showSharedWithMe = false; // Tab: My Vouchers vs Shared with me
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _refreshStatusFromSheetOnLoad());
  }

  Future<void> _refreshStatusFromSheetOnLoad() async {
    if (!mounted) return;
    final voucherProvider = context.read<VoucherProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = _resolveCustomerId(authProvider);
    final customerVouchers = voucherProvider.getCustomerVouchers(userId);
    final sharedList = voucherProvider.getSharedVouchersForUser(userId);
    final sharedVouchers = sharedList.map((e) => e.voucher).toList();
    final allVouchers = [...customerVouchers, ...sharedVouchers];
    if (allVouchers.isEmpty) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }
    await voucherProvider.refreshAllVouchersStatusFromSheet(allVouchers);
    if (mounted) setState(() => _isLoadingHistory = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true ,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voucher History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/customer/vendor-selection'),
            tooltip: 'Buy Voucher',
          ),
        ],
      ),
      body: _isLoadingHistory
          ? SafeArea(
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2.5,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading voucher history…',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          )
          : Consumer2<VoucherProvider, AuthProvider>(
        builder: (context, voucherProvider, authProvider, _) {
          // customer@demo.com (demo customer) always uses customer_001 for Shared with me & vouchers
          final userId = _resolveCustomerId(authProvider);

          if (_showSharedWithMe) {
            final sharedList = voucherProvider.getSharedVouchersForUser(userId);
            return SafeArea(
              child: Column(
                children: [
                  _buildSegmentBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (sharedList.isEmpty) return;
                        await voucherProvider.refreshAllVouchersStatusFromSheet(
                          sharedList.map((e) => e.voucher).toList(),
                        );
                      },
                      child: sharedList.isEmpty
                          ? _buildEmptyShared()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: sharedList.length,
                              itemBuilder: (context, index) {
                                final item = sharedList[index];
                                return _SharedVoucherCard(
                                  item: item,
                                  onTap: () {
                                    context.push(
                                      '/customer/voucher-details?voucherId=${item.voucher.id}&shared=true',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          }

          var vouchers = voucherProvider.getCustomerVouchers(userId);

          // Apply filter
          if (_filterStatus != 'All') {
            vouchers = vouchers.where((v) {
              switch (_filterStatus) {
                case 'Active':
                  return v.isActive;
                case 'Redeemed':
                  return v.isRedeemed;
                case 'Expired':
                  return v.isExpired && !v.isRedeemed;
                default:
                  return true;
              }
            }).toList();
          }

          return SafeArea(
            child: Column(
              children: [
                _buildSegmentBar(),
                // Filter Chips (only for My Vouchers)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: ['All', 'Active', 'Redeemed', 'Expired'].length,
                    itemBuilder: (context, index) {
                      final status = ['All', 'Active', 'Redeemed', 'Expired'][index];
                      final isSelected = _filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filterStatus = status;
                            });
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Voucher List (pull to refresh syncs status from Google Sheet)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final all = voucherProvider.getCustomerVouchers(userId);
                      await voucherProvider.refreshAllVouchersStatusFromSheet(all);
                    },
                    child: vouchers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 400,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.card_giftcard_outlined,
                                        size: 80,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'No vouchers found',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Purchase a gift voucher to get started',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: () =>
                                            context.push('/customer/vendor-selection'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          backgroundColor: AppTheme.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Buy Voucher',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vouchers.length,
                            itemBuilder: (context, index) {
                              final voucher = vouchers[index];
                              return _VoucherCard(
                                voucher: voucher,
                                onTap: () {
                                  context.push(
                                    '/customer/voucher-details?voucherId=${voucher.id}',
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Resolves customer ID for voucher/shared lists. Ensures customer@demo.com gets customer_001.
  String _resolveCustomerId(AuthProvider authProvider) {
    if (authProvider.userEmail.toLowerCase() == 'customer@demo.com') {
      return 'customer_001';
    }
    return authProvider.userId.isEmpty ? 'customer_001' : authProvider.userId;
  }

  Widget _buildSegmentBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: _showSharedWithMe ? AppTheme.surfaceColor : AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _showSharedWithMe = false),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'My Vouchers',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _showSharedWithMe ? AppTheme.textSecondary : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: _showSharedWithMe ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _showSharedWithMe = true),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'Shared with me',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _showSharedWithMe ? AppTheme.primaryColor : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShared() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'No shared vouchers',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vouchers shared with you will appear here.\nYou can check status (Valid/Expired) and redeem if valid.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedVoucherCard extends StatelessWidget {
  final SharedVoucherWithVoucher item;
  final VoidCallback onTap;

  const _SharedVoucherCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final voucher = item.voucher;
    final isAvailable = item.isAvailable;
    final statusText = item.statusDisplay;
    final statusColor = statusText == 'Valid'
        ? AppTheme.successColor
        : statusText == 'Redeemed'
            ? AppTheme.textSecondary
            : AppTheme.errorColor;
    final statusIcon = statusText == 'Valid' || statusText == 'Redeemed'
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor.withOpacity(0.08),
            AppTheme.surfaceColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.accentColor.withOpacity(0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.vendorName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Shared by ${item.sharedVoucher.ownerName}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormat.rs(voucher.amount),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Shared on',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(item.sharedVoucher.sharedAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onTap;

  const _VoucherCard({
    required this.voucher,
    required this.onTap,
  });

  Color _getStatusColor() {
    if (voucher.isRedeemed) return AppTheme.textSecondary;
    if (voucher.isExpired) return AppTheme.errorColor;
    return AppTheme.successColor;
  }

  String _getStatusText() {
    if (voucher.isRedeemed) return 'Redeemed';
    if (voucher.isExpired) return 'Expired';
    return 'Active';
  }

  IconData _getStatusIcon() {
    if (voucher.isRedeemed) return Icons.check_circle_rounded;
    if (voucher.isExpired) return Icons.cancel_rounded;
    return Icons.card_giftcard_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vendor Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vendor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.vendorName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            voucher.voucherCode,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormat.rs(voucher.amount),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Purchased',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(voucher.purchasedAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (voucher.expiresAt != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires: ${dateFormat.format(voucher.expiresAt!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
