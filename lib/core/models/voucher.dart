class Voucher {
  final String id;
  final String customerId;
  final String customerName;
  final String vendorId;
  final String vendorName;
  final double amount;
  final String voucherCode;
  final VoucherStatus status;
  final DateTime purchasedAt;
  final DateTime? redeemedAt;
  final DateTime? expiresAt;
  final String? recipientName;
  final String? recipientEmail;
  final String? recipientPhone;

  Voucher({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    required this.amount,
    required this.voucherCode,
    required this.status,
    required this.purchasedAt,
    this.redeemedAt,
    this.expiresAt,
    this.recipientName,
    this.recipientEmail,
    this.recipientPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'amount': amount,
      'voucherCode': voucherCode,
      'status': status.toString().split('.').last,
      'purchasedAt': purchasedAt.toIso8601String(),
      'redeemedAt': redeemedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'recipientPhone': recipientPhone,
    };
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      vendorId: json['vendorId'],
      vendorName: json['vendorName'],
      amount: (json['amount'] as num).toDouble(),
      voucherCode: json['voucherCode'],
      status: VoucherStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => VoucherStatus.active,
      ),
      purchasedAt: DateTime.parse(json['purchasedAt']),
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      recipientName: json['recipientName'],
      recipientEmail: json['recipientEmail'],
      recipientPhone: json['recipientPhone'],
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isRedeemed => status == VoucherStatus.redeemed;
  bool get isActive => status == VoucherStatus.active && !isExpired;
}

enum VoucherStatus {
  active,
  redeemed,
  expired,
  cancelled,
}
