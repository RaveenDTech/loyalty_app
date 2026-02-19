import 'voucher.dart';

/// Represents a voucher shared with a specific user.
/// When any recipient redeems the voucher, it expires for everyone.
class SharedVoucher {
  final String id;
  final String voucherId;
  final String ownerId;
  final String ownerName;
  final String recipientUserId;
  final DateTime sharedAt;

  SharedVoucher({
    required this.id,
    required this.voucherId,
    required this.ownerId,
    required this.ownerName,
    required this.recipientUserId,
    required this.sharedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucherId': voucherId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'recipientUserId': recipientUserId,
      'sharedAt': sharedAt.toIso8601String(),
    };
  }

  factory SharedVoucher.fromJson(Map<String, dynamic> json) {
    return SharedVoucher(
      id: json['id'],
      voucherId: json['voucherId'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      recipientUserId: json['recipientUserId'],
      sharedAt: DateTime.parse(json['sharedAt']),
    );
  }
}

/// View model: shared voucher + the actual voucher for UI (status comes from voucher).
class SharedVoucherWithVoucher {
  final SharedVoucher sharedVoucher;
  final Voucher voucher;

  SharedVoucherWithVoucher({
    required this.sharedVoucher,
    required this.voucher,
  });

  /// Valid = active and not expired; Expired = past expiry only; Redeemed = used.
  bool get isAvailable => voucher.isActive;
  bool get isExpired => voucher.isExpired;
  bool get isRedeemed => voucher.isRedeemed;
  String get statusDisplay =>
      voucher.isRedeemed ? 'Redeemed' : (voucher.isExpired ? 'Expired' : 'Valid');
}
