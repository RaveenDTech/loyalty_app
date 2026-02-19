import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/voucher_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/voucher_image_generator.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/toast.dart';

class VoucherDetailsPage extends StatefulWidget {
  final String voucherId;
  final bool isShared;

  const VoucherDetailsPage({
    super.key,
    required this.voucherId,
    this.isShared = false,
  });

  @override
  State<VoucherDetailsPage> createState() => _VoucherDetailsPageState();
}

class _VoucherDetailsPageState extends State<VoucherDetailsPage> {
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VoucherProvider>().refreshVoucherStatusFromSheetById(widget.voucherId);
    });
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
          'Voucher Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer2<VoucherProvider, AuthProvider>(
        builder: (context, voucherProvider, authProvider, _) {
          final voucher = voucherProvider.getVoucherById(widget.voucherId);
          final userId = authProvider.userId.isEmpty ? 'customer_001' : authProvider.userId;
          final canRedeemShared = widget.isShared &&
              voucher != null &&
              voucherProvider.canCurrentUserRedeemSharedVoucher(widget.voucherId, userId);

          if (voucher == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Voucher not found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          final dateFormat = DateFormat('MMM dd, yyyy');
          final timeFormat = DateFormat('hh:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                children: [
                  // Voucher Image Preview
                  VoucherImageGenerator.generateVoucherImage(voucher),
              
                  const SizedBox(height: 32),
              
                  // Voucher Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voucher Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DetailRow(
                          label: 'Voucher Code',
                          value: voucher.voucherCode,
                          valueStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Vendor',
                          value: voucher.vendorName,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Amount',
                          value: CurrencyFormat.rs(voucher.amount),
                          valueStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Status',
                          value: voucher.isRedeemed
                              ? 'Redeemed'
                              : voucher.isExpired
                                  ? 'Expired'
                                  : 'Active',
                          valueColor: voucher.isRedeemed
                              ? AppTheme.textSecondary
                              : voucher.isExpired
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Purchased Date',
                          value: '${dateFormat.format(voucher.purchasedAt)} at ${timeFormat.format(voucher.purchasedAt)}',
                        ),
                        if (voucher.expiresAt != null) ...[
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Expires On',
                            value: dateFormat.format(voucher.expiresAt!),
                          ),
                        ],
                        if (voucher.redeemedAt != null) ...[
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Redeemed On',
                            value: '${dateFormat.format(voucher.redeemedAt!)} at ${timeFormat.format(voucher.redeemedAt!)}',
                          ),
                        ],
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 24),
              
                  // Redeem button (shared voucher, valid, current user is recipient)
                  if (canRedeemShared)
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRedeeming
                              ? null
                              : () async {
                                  final confirmed = await ConfirmationDialog.show(
                                    context: context,
                                    title: 'Redeem voucher',
                                    message:
                                        'This will use the voucher and it will expire for everyone else who received it. Continue?',
                                    icon: Icons.card_giftcard_rounded,
                                    iconColor: AppTheme.primaryColor,
                                    confirmText: 'Redeem',
                                    confirmColor: AppTheme.successColor,
                                    onConfirm: () => Navigator.pop(context, true),
                                    onCancel: () => Navigator.pop(context, false),
                                  );
                                  if (confirmed != true || !context.mounted) return;
                                  setState(() => _isRedeeming = true);
                                  final redeemedAtIso = await VoucherImageGenerator.redeemOnSheet(voucher.voucherCode);
                                  if (!mounted) return;
                                  setState(() => _isRedeeming = false);
                                  if (redeemedAtIso == null) {
                                    Toast.error(context, 'Could not redeem. Please try again or check your connection.');
                                    return;
                                  }
                                  DateTime? redeemedAt;
                                  try {
                                    redeemedAt = DateTime.parse(redeemedAtIso);
                                  } catch (_) {
                                    redeemedAt = null;
                                  }
                                  voucherProvider.redeemVoucher(voucher.id, userId, redeemedAt);
                                  Toast.success(context, 'Voucher redeemed. It is now expired for all recipients.');
                                  if (mounted) Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.successColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isRedeeming
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Redeem voucher',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  // Share Button (if active and not viewing as shared recipient)
                  if (voucher.isActive && !canRedeemShared)
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/customer/voucher-success?voucherId=${voucher.id}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Share Voucher',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: valueStyle ??
                GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.textPrimary,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
