class Transaction {
  final String id;
  final String requestId;
  final String customerId;
  final String customerName;
  final String supplierId;
  final String supplierName;
  final double billAmount;
  final double discountAmount;
  final double finalAmount;
  final String billImagePath;
  TransactionStatus status;
  final DateTime completedAt;

  Transaction({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.customerName,
    required this.supplierId,
    required this.supplierName,
    required this.billAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.billImagePath,
    required this.status,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'customerId': customerId,
      'customerName': customerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'billAmount': billAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'billImagePath': billImagePath,
      'status': status.toString().split('.').last,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      requestId: json['requestId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      billAmount: (json['billAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      billImagePath: json['billImagePath'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}

enum TransactionStatus {
  pending,
  completed,
  cancelled,
}
