class LoyaltyRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String supplierId;
  final String supplierName;
  RequestStatus status;
  final DateTime createdAt;
  DateTime? approvedAt;
  DateTime? rejectedAt;

  LoyaltyRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
    };
  }

  factory LoyaltyRequest.fromJson(Map<String, dynamic> json) {
    return LoyaltyRequest(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
    );
  }
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  completed,
}
