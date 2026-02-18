import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Utility class for generating QR codes for suppliers
class QRGenerator {
  /// Generates QR code data string for a supplier
  /// Format: supplierId|supplierName
  static String generateQRData(String supplierId, String supplierName) {
    return '$supplierId|$supplierName';
  }

  /// Parses QR code data string
  /// Returns a map with supplierId and supplierName
  static Map<String, String>? parseQRData(String qrData) {
    final parts = qrData.split('|');
    if (parts.length < 2) {
      return null;
    }
    return {
      'supplierId': parts[0],
      'supplierName': parts.sublist(1).join('|'), // In case name contains |
    };
  }

  /// Creates a QR code widget for display
  static Widget createQRWidget({
    required String supplierId,
    required String supplierName,
    double size = 200,
  }) {
    final qrData = generateQRData(supplierId, supplierName);
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      padding:  EdgeInsets.zero,
    );
  }
}
