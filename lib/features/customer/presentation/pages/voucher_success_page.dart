import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/providers/voucher_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/voucher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/voucher_image_generator.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/toast.dart';

class VoucherSuccessPage extends StatefulWidget {
  final String voucherId;

  const VoucherSuccessPage({
    super.key,
    required this.voucherId,
  });

  @override
  State<VoucherSuccessPage> createState() => _VoucherSuccessPageState();
}

class _VoucherSuccessPageState extends State<VoucherSuccessPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareViaWhatsApp(Voucher voucher) async {
    setState(() {
      _isSharing = true;
    });

    try {
      // Capture the voucher image
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        if (mounted) {
          Toast.error(context, 'Failed to capture voucher image');
        }
        return;
      }

      // Save image to temporary file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/voucher_${voucher.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Generate message with short URL
      final message = await VoucherImageGenerator.generateVoucherShareMessageWithShortUrl(voucher);

      // Share image with text using share_plus
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: message,
        subject: 'Gift Voucher from DSI Group',
      );
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error sharing: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareViaEmail(Voucher voucher) async {
    setState(() {
      _isSharing = true;
    });

    try {
      // Capture the voucher image
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        if (mounted) {
          Toast.error(context, 'Failed to capture voucher image');
        }
        return;
      }

      // Save image to temporary file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/voucher_${voucher.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Generate message with short URL
      final subject = 'Gift Voucher from DSI Group';
      final body = await VoucherImageGenerator.generateVoucherShareMessageWithShortUrl(voucher);

      // Share image with text using share_plus
      // This will open the share sheet where user can choose email app
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: body,
        subject: subject,
      );
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error sharing: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareAsImage(Voucher voucher) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        // Save to temporary file
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/voucher_${voucher.id}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // Share the file with voucher details and short viewer link
        final message = await VoucherImageGenerator.generateVoucherShareMessageWithShortUrl(voucher);
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: message,
          subject: 'Gift Voucher from DSI Group',
        );
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error sharing image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareAsText(Voucher voucher) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final message = await VoucherImageGenerator.generateVoucherShareMessageWithShortUrl(voucher);
      await Share.share(message);
    } catch (e) {
      if (mounted) {
        Toast.error(context, 'Error sharing: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _copyVoucherViewerLink(Voucher voucher) async {
    if (mounted) Toast.info(context, 'Shortening link…');
    final url = await VoucherImageGenerator.getShortVoucherViewerUrl(voucher);
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      Toast.success(context, 'Short link copied. Share it so others can view voucher status online.');
    }
  }

  void _showShareWithAppUsersSheet(
    BuildContext context,
    Voucher voucher,
    AuthProvider authProvider,
    VoucherProvider voucherProvider,
  ) {
    final currentUserId = authProvider.userId.isEmpty ? 'customer_001' : authProvider.userId;
    final recipients = VoucherProvider.mockShareableUsers
        .where((u) => u['id'] != currentUserId)
        .toList();
    if (recipients.isEmpty) {
      Toast.info(context, 'No other users to share with in this demo');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ShareWithAppUsersSheet(
        voucher: voucher,
        ownerId: currentUserId,
        ownerName: authProvider.userName.isEmpty ? 'Customer' : authProvider.userName,
        recipients: recipients,
        voucherProvider: voucherProvider,
        onShared: () {
          Navigator.pop(ctx);
          if (mounted) Toast.success(context, 'Voucher shared. Recipients can see status (Valid/Expired); first to redeem expires it for all.');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true ,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/customer/home'),
        ),
        title: Text(
          'Voucher Purchased',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer2<VoucherProvider, AuthProvider>(
        builder: (context, voucherProvider, authProvider, _) {
          var voucher = voucherProvider.getVoucherById(widget.voucherId);

          // Happy path: if voucher not found, wait a bit and retry (might be still processing)
          if (voucher == null) {
            // Try to find it in customer vouchers as fallback
            final customerVouchers = voucherProvider.getCustomerVouchers(
              authProvider.userId.isEmpty ? 'customer_001' : authProvider.userId,
            );
            if (customerVouchers.isNotEmpty) {
              voucher = customerVouchers.first; // Use most recent voucher
            }
          }

          // If still null, show loading and redirect after delay (happy path)
          if (voucher == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading voucher...',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                children: [
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 60,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Voucher Purchased!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your gift voucher is ready to share',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
              
                  // Voucher Image Preview
                  Screenshot(
                    controller: _screenshotController,
                    child: VoucherImageGenerator.generateVoucherImage(voucher),
                  ),
              
                  const SizedBox(height: 32),
              
                  // Share Options
                  Text(
                    'Share Voucher',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
              
                  // Share Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          icon: Brand(
                            Brands.whatsapp,
                            size: 28,
                          ),
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: _isSharing ? null : () => _shareViaWhatsApp(voucher!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          icon: Brand(
                            Brands.gmail,
                            size: 28,
                          ),
                          label: 'Email',
                          color: AppTheme.primaryColor,
                          onTap: _isSharing ? null : () => _shareViaEmail(voucher!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          icon: const Icon(
                            Icons.image_rounded,
                            size: 28,
                          ),
                          label: 'Share Image',
                          color: AppTheme.accentColor,
                          onTap: _isSharing ? null : () => _shareAsImage(voucher!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          icon: const Icon(
                            Icons.text_fields_rounded,
                            size: 28,
                          ),
                          label: 'Share Text',
                          color: AppTheme.infoColor,
                          onTap: _isSharing ? null : () => _shareAsText(voucher!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Share with app users (multi-user status & single redemption)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSharing
                          ? null
                          : () => _showShareWithAppUsersSheet(context, voucher!, authProvider, voucherProvider),
                      icon: const Icon(Icons.people_rounded, size: 22),
                      label: Text(
                        'Share with app users',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.accentColor),
                        foregroundColor: AppTheme.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // View voucher online – copy short link
                  Text(
                    'View voucher online',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyVoucherViewerLink(voucher!),
                      icon: const Icon(Icons.link_rounded, size: 20),
                      label: Text(
                        'Copy short link',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 32),
              
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/customer/voucher-history'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppTheme.borderColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        'View Voucher History',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/customer/home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final Widget icon; // Can be Brand widget or Icon widget
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareWithAppUsersSheet extends StatefulWidget {
  final Voucher voucher;
  final String ownerId;
  final String ownerName;
  final List<Map<String, String>> recipients;
  final VoucherProvider voucherProvider;
  final VoidCallback onShared;

  const _ShareWithAppUsersSheet({
    required this.voucher,
    required this.ownerId,
    required this.ownerName,
    required this.recipients,
    required this.voucherProvider,
    required this.onShared,
  });

  @override
  State<_ShareWithAppUsersSheet> createState() => _ShareWithAppUsersSheetState();
}

class _ShareWithAppUsersSheetState extends State<_ShareWithAppUsersSheet> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share with app users',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recipients can see coupon status (Valid/Expired). When one redeems, it expires for everyone.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ...widget.recipients.map((u) {
            final id = u['id']!;
            final name = u['name']!;
            final selected = _selectedIds.contains(id);
            return CheckboxListTile(
              value: selected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedIds.add(id);
                  } else {
                    _selectedIds.remove(id);
                  }
                });
              },
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                id,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              activeColor: AppTheme.primaryColor,
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      widget.voucherProvider.shareVoucherWithUsers(
                        voucherId: widget.voucher.id,
                        ownerId: widget.ownerId,
                        ownerName: widget.ownerName,
                        recipientUserIds: _selectedIds.toList(),
                      );
                      widget.onShared();
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Share with ${_selectedIds.length} user(s)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
