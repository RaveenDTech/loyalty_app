import 'package:flutter/foundation.dart';
import '../models/loyalty_request.dart';
import '../models/transaction.dart';
import '../models/dsi_loyalty_tier.dart';

class LoyaltyProvider extends ChangeNotifier {
  List<LoyaltyRequest> _pendingRequests = [];
  List<LoyaltyRequest> _approvedRequests = [];
  List<Transaction> _transactions = [];
  /// Customer ID -> years of employment at DSI group (for supplier bill discount lookup).
  final Map<String, double> _customerTenureYears = {};

  List<LoyaltyRequest> get pendingRequests => _pendingRequests;
  List<LoyaltyRequest> get approvedRequests => _approvedRequests;
  List<Transaction> get transactions => _transactions;

  LoyaltyProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // DSI Loyalty: employment tenure at DSI group (years) for discount tier
    _customerTenureYears['customer_001'] = 3.0;  // 1–5 years → 10%
    _customerTenureYears['customer_002'] = 7.0;   // 5–10 years → 15%
    _customerTenureYears['customer_003'] = 12.0; // 10+ years → 20%
    // Initialize with mock data for demo
    _pendingRequests = [
      LoyaltyRequest(
        id: 'req_001',
        customerId: 'customer_001',
        customerName: 'John Customer',
        supplierId: 'supplier_001',
        supplierName: 'ABC Store',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LoyaltyRequest(
        id: 'req_002',
        customerId: 'customer_002',
        customerName: 'Jane Doe',
        supplierId: 'supplier_001',
        supplierName: 'ABC Store',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _approvedRequests = [
      LoyaltyRequest(
        id: 'req_003',
        customerId: 'customer_003',
        customerName: 'Bob Smith',
        supplierId: 'supplier_001',
        supplierName: 'ABC Store',
        status: RequestStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        approvedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    _transactions = [
      Transaction(
        id: 'trans_001',
        requestId: 'req_004',
        customerId: 'customer_001',
        customerName: 'John Customer',
        supplierId: 'supplier_001',
        supplierName: 'ABC Store',
        billAmount: 5000.0,
        discountAmount: 500.0,
        finalAmount: 4500.0,
        billImagePath: '',
        status: TransactionStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 'trans_002',
        requestId: 'req_005',
        customerId: 'customer_001',
        customerName: 'John Customer',
        supplierId: 'supplier_001',
        supplierName: 'ABC Store',
        billAmount: 3000.0,
        discountAmount: 300.0,
        finalAmount: 2700.0,
        billImagePath: '',
        status: TransactionStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Customer methods
  Future<bool> sendDiscountRequest(String supplierId, String supplierName) async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));
      
      final request = LoyaltyRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'customer_001', // Mock customer ID
        customerName: 'John Customer', // Mock customer name
        supplierId: supplierId,
        supplierName: supplierName,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );
      
      _pendingRequests.add(request);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error sending discount request: $e');
      return false;
    }
  }

  // Supplier methods
  Future<bool> approveRequest(String requestId) async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _pendingRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final request = _pendingRequests[index];
        request.status = RequestStatus.approved;
        request.approvedAt = DateTime.now();
        _approvedRequests.add(request);
        _pendingRequests.removeAt(index);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _pendingRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _pendingRequests[index].status = RequestStatus.rejected;
        _pendingRequests[index].rejectedAt = DateTime.now();
        _pendingRequests.removeAt(index);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  Future<bool> completeTransaction({
    required String requestId,
    required double billAmount,
    required double discountAmount,
    required String billImagePath,
  }) async {
    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));
      
      final request = _approvedRequests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => _pendingRequests.firstWhere((r) => r.id == requestId),
      );
      
      final transaction = Transaction(
        id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
        requestId: requestId,
        customerId: request.customerId,
        customerName: request.customerName,
        supplierId: request.supplierId,
        supplierName: request.supplierName,
        billAmount: billAmount,
        discountAmount: discountAmount,
        finalAmount: billAmount - discountAmount,
        billImagePath: billImagePath,
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );
      
      _transactions.add(transaction);
      
      // Remove from approved requests
      _approvedRequests.removeWhere((r) => r.id == requestId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing transaction: $e');
      return false;
    }
  }

  List<Transaction> getCustomerTransactions(String customerId) {
    return _transactions.where((t) => t.customerId == customerId).toList();
  }

  List<Transaction> getSupplierTransactions(String supplierId) {
    return _transactions.where((t) => t.supplierId == supplierId).toList();
  }

  // --- DSI Loyalty (employment tenure based discount) ---

  /// Sets tenure for a customer (e.g. after login sync from auth).
  void setCustomerTenure(String customerId, double years) {
    _customerTenureYears[customerId] = years;
    notifyListeners();
  }

  /// Returns tenure in years for a customer, or 0 if unknown.
  double getTenureYearsForCustomer(String customerId) {
    return _customerTenureYears[customerId] ?? 0;
  }

  /// Returns the DSI loyalty tier for a customer.
  DsiTenureTier getTierForCustomer(String customerId) {
    final years = _customerTenureYears[customerId] ?? 0;
    return DsiLoyaltyTierHelper.tierFromYears(years);
  }

  /// Returns discount percentage for a customer (0–100).
  int getDiscountPercentForCustomer(String customerId) {
    return getTierForCustomer(customerId).discountPercent;
  }

  /// Returns suggested discount amount for a bill total based on customer's tier.
  double getSuggestedDiscountForCustomer(String customerId, double billTotal) {
    final tier = getTierForCustomer(customerId);
    return DsiLoyaltyTierHelper.discountAmount(billTotal, tier);
  }
}
