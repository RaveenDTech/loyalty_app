import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/qr_generator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/toast.dart';

class QRCodeBottomSheet extends StatelessWidget {
  const QRCodeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      enableDrag: true,
      builder: (context) => const QRCodeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomSheetColor = isDark
        ? const Color(0xFF010C1B) // Dark charcoal
        : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final buttonBgColor = isDark
        ? const Color(0xFF374151) // Darker gray
        : Colors.white;
    final buttonBorderColor = isDark
        ? const Color(0xFF4B5563) // Lighter gray border
        : Colors.grey.shade300;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final supplierId = authProvider.userId;
        final supplierName =
            authProvider.userName.isEmpty ? 'Supplier' : authProvider.userName;

        // Use supplier ID as identifier (similar to OAP14121996 in image)
        final identifier = supplierId.length > 12
            ? supplierId.substring(0, 12).toUpperCase()
            : supplierId.toUpperCase();

        return Container(
          // height: MediaQuery.of(context).size.height * ,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: bottomSheetColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My QR Code',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: textColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // QR Code Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // QR Code with green border
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981), // Bright green
                            width: 10,
                          ),
                        ),
                        child: QRGenerator.createQRWidget(
                          supplierId: supplierId,
                          supplierName: supplierName,
                          size: 180,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Identifier Label (pill-shaped)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Teal/primary-blue
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          identifier,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instructional Text
                      Text(
                        'Show this QR Code to your friends to invite them to play the games together.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.download_rounded,
                        label: 'Save',
                        backgroundColor: buttonBgColor,
                        borderColor: buttonBorderColor,
                        iconColor: textColor,
                        textColor: textColor,
                        onTap: () {
                          Toast.info(context, 'Save functionality coming soon');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        backgroundColor: buttonBgColor,
                        borderColor: buttonBorderColor,
                        iconColor: textColor,
                        textColor: textColor,
                        onTap: () {
                          Toast.info(context, 'Share functionality coming soon');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: 0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
