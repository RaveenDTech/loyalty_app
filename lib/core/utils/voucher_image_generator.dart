import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/voucher.dart';
import '../theme/app_theme.dart';
import 'currency_format.dart';

/// Base URL for the web voucher viewer. Voucher data is appended as ?data=<base64-json>.
const String voucherViewerBaseUrl =
    'https://raveendtech.github.io/loyalty_app/index.html?data=';

/// Google Apps Script Web app URL for voucher status (sheet backend).
/// Set this to your deployed script URL (no callback param = returns JSON for mobile).
/// Must match SHEET_SCRIPT_URL in voucher_viewer/index.html.
const String voucherSheetScriptUrl =
    'https://script.google.com/macros/s/AKfycbzbyyoFevfZWVg5oanTZCGlRNKs2XsyuLxahINE7jVnqIkCN2T4dE7oUhre7ueaL47kZg/exec';

class VoucherImageGenerator {
  /// Result of a status fetch: status string and optional redeemed date from sheet.
  static const String kStatusKey = 'status';
  static const String kRedeemedAtKey = 'redeemedAt';

  /// Fetches current voucher status (and redeemed date when redeemed) from the Google Sheet backend.
  /// Returns a map with 'status' (String) and optionally 'redeemedAt' (String, ISO 8601), or null on failure.
  static Future<Map<String, dynamic>?> fetchStatusFromSheet(String voucherCode) async {
    if (voucherSheetScriptUrl.isEmpty || voucherCode.isEmpty) {
      debugPrint('[VoucherSheet] Status fetch skipped: ${voucherSheetScriptUrl.isEmpty ? "URL not set" : "no voucher code"}');
      return null;
    }
    debugPrint('[VoucherSheet] Establishing connection – fetching status for code: $voucherCode');
    try {
      final uri = Uri.parse(voucherSheetScriptUrl).replace(
        queryParameters: {'action': 'status', 'code': voucherCode},
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 28),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode != 200) {
        debugPrint('[VoucherSheet] Connection failed – HTTP ${response.statusCode}');
        return null;
      }
      final body = response.body.trim();
      Map<String, dynamic>? map;
      try {
        map = jsonDecode(body) as Map<String, dynamic>?;
      } catch (_) {
        map = _parseJsonpResponse(body);
      }
      if (map == null) {
        debugPrint('[VoucherSheet] Connection failed – invalid response body');
        return null;
      }
      final status = map['status']?.toString().trim().toLowerCase();
      if (status?.isNotEmpty != true) {
        debugPrint('[VoucherSheet] Connection OK – no status in response, using active');
        return { kStatusKey: 'active' };
      }
      debugPrint('[VoucherSheet] Connection OK – status: $status');
      final result = <String, dynamic>{ kStatusKey: status! };
      final redeemedAt = map['redeemedAt']?.toString().trim();
      if (redeemedAt != null && redeemedAt.isNotEmpty) {
        result[kRedeemedAtKey] = redeemedAt;
      }
      return result;
    } catch (e) {
      debugPrint('[VoucherSheet] Connection failed – $e');
      return null;
    }
  }

  /// Parses a JSONP response like callback({"status":"active"}); into a map.
  static Map<String, dynamic>? _parseJsonpResponse(String body) {
    final start = body.indexOf('(');
    final end = body.lastIndexOf(')');
    if (start >= 0 && end > start) {
      try {
        final jsonStr = body.substring(start + 1, end);
        return jsonDecode(jsonStr) as Map<String, dynamic>?;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Calls the Google Sheet backend to mark the voucher as redeemed.
  /// Returns the redeemed-at ISO string from the sheet on success, null on failure.
  static Future<String?> redeemOnSheet(String voucherCode) async {
    if (voucherSheetScriptUrl.isEmpty || voucherCode.isEmpty) {
      debugPrint('[VoucherSheet] Redeem skipped: no URL or code');
      return null;
    }
    debugPrint('[VoucherSheet] Redeem request for code: $voucherCode');
    try {
      final uri = Uri.parse(voucherSheetScriptUrl).replace(
        queryParameters: {'action': 'redeem', 'code': voucherCode},
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 28),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode != 200) {
        debugPrint('[VoucherSheet] Redeem failed – HTTP ${response.statusCode}');
        return null;
      }
      final body = response.body.trim();
      Map<String, dynamic>? map;
      try {
        map = jsonDecode(body) as Map<String, dynamic>?;
      } catch (_) {
        map = _parseJsonpResponse(body);
      }
      final ok = map?['ok'] == true && map?['status'] == 'redeemed';
      if (ok) {
        debugPrint('[VoucherSheet] Redeem OK for code: $voucherCode');
      } else {
        debugPrint('[VoucherSheet] Redeem failed – $map');
      }
      if (ok && map != null) {
        return (map['redeemedAt']?.toString().trim()) ?? '';
      }
      return null;
    } catch (e) {
      debugPrint('[VoucherSheet] Redeem failed – $e');
      return null;
    }
  }

  /// Generate voucher image widget — premium gift voucher design
  static Widget generateVoucherImage(Voucher voucher) {
    return RepaintBoundary(
      child: Container(
        width: 400,
        height: 600,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.35),
              blurRadius: 32,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base gradient (teal → dark teal, aligned with app theme)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDark,
                      const Color(0xFF0A3D2E),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Soft decorative shapes
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              // Top brand strip
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo + brand
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'GIFT VOUCHER',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DSI Group',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Amount — hero
                    Text(
                      CurrencyFormat.rs(voucher.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
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
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Code block — glass style
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'VOUCHER CODE',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            voucher.voucherCode,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (voucher.expiresAt != null)
                      Text(
                        'Valid until ${_formatDate(voucher.expiresAt!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      )
                    else
                      const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
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
*Amount:* ${CurrencyFormat.rs(voucher.amount)}
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
