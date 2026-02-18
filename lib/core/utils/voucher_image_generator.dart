import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/voucher.dart';
import '../theme/app_theme.dart';

/// Base URL for the web voucher viewer. Voucher data is appended as ?data=<base64-json>.
const String voucherViewerBaseUrl =
    'https://raveendtech.github.io/loyalty_app/index.html?data=';

class VoucherImageGenerator {
  /// Generate voucher image widget
  static Widget generateVoucherImage(Voucher voucher) {
    return RepaintBoundary(
      child: Container(
        width: 400,
        height: 600,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.accentColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'Gift Voucher',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DSI Group',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  // Voucher Code
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Voucher Code',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          voucher.voucherCode,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amount
                  Text(
                    'Rs. ${voucher.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valid at ${voucher.vendorName}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(),
                  // Expiry Date
                  if (voucher.expiresAt != null)
                    Text(
                      'Valid until ${_formatDate(voucher.expiresAt!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate voucher message text (no link).
  static String generateVoucherMessage(Voucher voucher) {
    final expiryDate =
        voucher.expiresAt != null ? _formatDate(voucher.expiresAt!) : 'N/A';

    return '''
🎁 *Gift Voucher from DSI Group*

*Voucher Code:* ${voucher.voucherCode}
*Amount:* Rs. ${voucher.amount.toStringAsFixed(2)}
*Vendor:* ${voucher.vendorName}
*Valid Until:* $expiryDate

This voucher can be redeemed at ${voucher.vendorName}. Present this voucher code at the time of purchase.

Thank you for choosing DSI Group!
    ''';
  }

  /// Build the full web viewer URL for this voucher (base URL + base64 data).
  static String buildVoucherViewerUrl(Voucher voucher) {
    final payload = _viewerPayload(voucher);
    final json = jsonEncode(payload);
    final base64 = base64Encode(utf8.encode(json));
    return '$voucherViewerBaseUrl$base64';
  }

  /// Share message including the online verification link (for WhatsApp, Email, etc.).
  /// Use [generateVoucherShareMessageWithShortUrl] to include a short URL in shares.
  static String generateVoucherShareMessage(Voucher voucher, {String? shortUrl}) {
    final message = generateVoucherMessage(voucher);
    final url = shortUrl ?? buildVoucherViewerUrl(voucher);
    return '$message\n\n📎 View voucher status online: $url';
  }

  /// Shorten the voucher viewer URL via is.gd (no API key). Returns full URL on failure.
  static Future<String> getShortVoucherViewerUrl(Voucher voucher) async {
    final fullUrl = buildVoucherViewerUrl(voucher);
    try {
      final uri = Uri.parse(
        'https://is.gd/create.php?format=simple&url=${Uri.encodeComponent(fullUrl)}',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode == 200) {
        final short = response.body.trim();
        if (short.startsWith('http')) return short;
      }
    } catch (_) {
      // fallback to full URL
    }
    return fullUrl;
  }

  /// Share message with short URL. Call this before sharing; use result in Share.share.
  static Future<String> generateVoucherShareMessageWithShortUrl(Voucher voucher) async {
    final shortUrl = await getShortVoucherViewerUrl(voucher);
    return generateVoucherShareMessage(voucher, shortUrl: shortUrl);
  }

  /// Payload for web viewer (same shape as index.html expects).
  static Map<String, dynamic> _viewerPayload(Voucher voucher) {
    return {
      'voucherCode': voucher.voucherCode,
      'vendorName': voucher.vendorName,
      'amount': voucher.amount,
      'status': voucher.status.toString().split('.').last,
      'purchasedAt': voucher.purchasedAt.toIso8601String(),
      if (voucher.expiresAt != null) 'expiresAt': voucher.expiresAt!.toIso8601String(),
      if (voucher.redeemedAt != null) 'redeemedAt': voucher.redeemedAt!.toIso8601String(),
    };
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
