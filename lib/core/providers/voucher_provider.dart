import 'package:flutter/foundation.dart';
import '../models/vendor.dart';
import '../models/voucher.dart';
import '../models/shared_voucher.dart';
import '../utils/voucher_image_generator.dart';

class VoucherProvider extends ChangeNotifier {
  List<Vendor> _vendors = [];
  List<Voucher> _vouchers = [];
  final List<SharedVoucher> _sharedVouchers = [];

  /// Mock app users for "Share with app users" (recipients).
  static const List<Map<String, String>> mockShareableUsers = [
    {'id': 'customer_001', 'name': 'John Customer'},
    {'id': 'customer_002', 'name': 'Jane Doe'},
    {'id': 'customer_003', 'name': 'Bob Smith'},
  ];

  List<Vendor> get vendors => _vendors;
  List<Voucher> get vouchers => _vouchers;

  VoucherProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with mock DSI vendors
    _vendors = [
      Vendor(
        id: 'vendor_001',
        name: 'DSI Fashion Store',
        description: 'Premium fashion and clothing store',
        category: 'Fashion',
        location: 'Colombo 05',
        rating: 4.5,
        imageUrl: null,
      ),
      Vendor(
        id: 'vendor_002',
        name: 'DSI Electronics',
        description: 'Latest electronics and gadgets',
        category: 'Electronics',
        location: 'Kandy',
        rating: 4.8,
        imageUrl: null,
      ),
      Vendor(
        id: 'vendor_003',
        name: 'DSI Home & Living',
        description: 'Home decor and furniture',
        category: 'Home & Living',
        location: 'Galle',
        rating: 4.3,
        imageUrl: null,
      ),
      Vendor(
        id: 'vendor_004',
        name: 'DSI Sports Hub',
        description: 'Sports equipment and accessories',
        category: 'Sports',
        location: 'Colombo 07',
        rating: 4.6,
        imageUrl: null,
      ),
      Vendor(
        id: 'vendor_005',
        name: 'DSI Beauty & Wellness',
        description: 'Beauty products and spa services',
        category: 'Beauty',
        location: 'Negombo',
        rating: 4.7,
        imageUrl: null,
      ),
      Vendor(
        id: 'vendor_006',
        name: 'DSI Supermarket',
        description: 'Daily groceries and essentials',
        category: 'Supermarket',
        location: 'Colombo 03',
        rating: 4.4,
        imageUrl: null,
      ),
    ];

    // Initialize with mock vouchers
    _vouchers = [
      Voucher(
        id: 'voucher_001',
        customerId: 'customer_001',
        customerName: 'John Customer',
        vendorId: 'vendor_001',
        vendorName: 'DSI Fashion Store',
        amount: 5000.0,
        voucherCode: 'DSI-FASH-2024-001',
        status: VoucherStatus.active,
        purchasedAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 358)),
      ),
      Voucher(
        id: 'voucher_002',
        customerId: 'customer_001',
        customerName: 'John Customer',
        vendorId: 'vendor_002',
        vendorName: 'DSI Electronics',
        amount: 10000.0,
        voucherCode: 'DSI-ELEC-2024-002',
        status: VoucherStatus.redeemed,
        purchasedAt: DateTime.now().subtract(const Duration(days: 10)),
        redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // Extra vouchers for "Shared with me" dummy data (all statuses)
      Voucher(
        id: 'voucher_shared_valid',
        customerId: 'customer_002',
        customerName: 'Jane Doe',
        vendorId: 'vendor_003',
        vendorName: 'DSI Home & Living',
        amount: 2500.0,
        voucherCode: 'DSI-HOME-SHARED-001',
        status: VoucherStatus.active,
        purchasedAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 360)),
      ),
      Voucher(
        id: 'voucher_shared_redeemed',
        customerId: 'customer_003',
        customerName: 'Bob Smith',
        vendorId: 'vendor_004',
        vendorName: 'DSI Sports Hub',
        amount: 7500.0,
        voucherCode: 'DSI-SPORT-SHARED-002',
        status: VoucherStatus.redeemed,
        purchasedAt: DateTime.now().subtract(const Duration(days: 14)),
        redeemedAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 350)),
      ),
      Voucher(
        id: 'voucher_shared_expired',
        customerId: 'customer_002',
        customerName: 'Jane Doe',
        vendorId: 'vendor_005',
        vendorName: 'DSI Beauty & Wellness',
        amount: 3000.0,
        voucherCode: 'DSI-BEAUTY-SHARED-003',
        status: VoucherStatus.expired,
        purchasedAt: DateTime.now().subtract(const Duration(days: 400)),
        expiresAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];

    // Dummy "Shared with me" coupons for customer@demo.com (userId: customer_001) – all statuses
    final now = DateTime.now();
    _sharedVouchers.addAll([
      SharedVoucher(
        id: 'shared_dummy_1',
        voucherId: 'voucher_shared_valid',
        ownerId: 'customer_002',
        ownerName: 'Jane Doe',
        recipientUserId: 'customer_001',
        sharedAt: now.subtract(const Duration(days: 4)),
      ),
      SharedVoucher(
        id: 'shared_dummy_2',
        voucherId: 'voucher_shared_redeemed',
        ownerId: 'customer_003',
        ownerName: 'Bob Smith',
        recipientUserId: 'customer_001',
        sharedAt: now.subtract(const Duration(days: 12)),
      ),
      SharedVoucher(
        id: 'shared_dummy_3',
        voucherId: 'voucher_shared_expired',
        ownerId: 'customer_002',
        ownerName: 'Jane Doe',
        recipientUserId: 'customer_001',
        sharedAt: now.subtract(const Duration(days: 50)),
      ),
    ]);
  }

  // Get all active vendors
  List<Vendor> getActiveVendors() {
    return _vendors.where((v) => v.isActive).toList();
  }

  // Get vendors by category
  List<Vendor> getVendorsByCategory(String category) {
    return _vendors.where((v) => v.category == category && v.isActive).toList();
  }

  // Search vendors
  List<Vendor> searchVendors(String query) {
    if (query.isEmpty) return getActiveVendors();
    final lowerQuery = query.toLowerCase();
    return _vendors.where((v) {
      return v.isActive &&
          (v.name.toLowerCase().contains(lowerQuery) ||
              v.description.toLowerCase().contains(lowerQuery) ||
              v.category.toLowerCase().contains(lowerQuery) ||
              (v.location?.toLowerCase().contains(lowerQuery) ?? false));
    }).toList();
  }

  // Get all categories
  List<String> getCategories() {
    return _vendors
        .where((v) => v.isActive)
        .map((v) => v.category)
        .toSet()
        .toList()
      ..sort();
  }

  // Purchase voucher - Happy path: always succeeds
  Future<Voucher> purchaseVoucher({
    required String customerId,
    required String customerName,
    required String vendorId,
    required String vendorName,
    required double amount,
    String? recipientName,
    String? recipientEmail,
    String? recipientPhone,
  }) async {
    // Simulating API call with success guarantee
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate voucher code - ensure it's always valid
    String vendorCode = 'VEND';
    try {
      final code = vendorName
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => word[0])
          .join()
          .toUpperCase();
      vendorCode = code.length >= 4 
          ? code.substring(0, 4) 
          : code.padRight(4, 'X');
    } catch (e) {
      vendorCode = 'DSI';
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final voucherCode = 'DSI-$vendorCode-$timestamp';

    // Ensure valid customer ID and name
    final validCustomerId = customerId.isEmpty ? 'customer_001' : customerId;
    final validCustomerName = customerName.isEmpty ? 'Customer' : customerName;

    final voucher = Voucher(
      id: 'voucher_$timestamp',
      customerId: validCustomerId,
      customerName: validCustomerName,
      vendorId: vendorId,
      vendorName: vendorName,
      amount: amount,
      voucherCode: voucherCode,
      status: VoucherStatus.active,
      purchasedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 365)), // Valid for 1 year
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      recipientPhone: recipientPhone,
    );

    _vouchers.add(voucher);
    notifyListeners();
    return voucher; // Always return voucher (happy path)
  }

  // Get customer vouchers
  List<Voucher> getCustomerVouchers(String customerId) {
    return _vouchers
        .where((v) => v.customerId == customerId)
        .toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  // Get active vouchers for customer
  List<Voucher> getActiveCustomerVouchers(String customerId) {
    return getCustomerVouchers(customerId)
        .where((v) => v.isActive)
        .toList();
  }

  // Get vendor by ID
  Vendor? getVendorById(String vendorId) {
    try {
      return _vendors.firstWhere((v) => v.id == vendorId);
    } catch (e) {
      return null;
    }
  }

  // Get voucher by ID
  Voucher? getVoucherById(String voucherId) {
    try {
      return _vouchers.firstWhere((v) => v.id == voucherId);
    } catch (e) {
      return null;
    }
  }

  // --- Shared voucher (multi-user coupon) support ---

  /// Share a voucher with multiple users. Each recipient can see status (Valid/Expired).
  /// When any one redeems, the voucher expires for everyone.
  void shareVoucherWithUsers({
    required String voucherId,
    required String ownerId,
    required String ownerName,
    required List<String> recipientUserIds,
  }) {
    final voucher = getVoucherById(voucherId);
    if (voucher == null || !voucher.isActive) return;

    final now = DateTime.now();
    for (final recipientId in recipientUserIds) {
      if (recipientId == ownerId) continue; // don't share with self
      final id = 'shared_${voucherId}_${recipientId}_${now.millisecondsSinceEpoch}';
      if (_sharedVouchers.any((s) => s.voucherId == voucherId && s.recipientUserId == recipientId)) {
        continue; // already shared with this user
      }
      _sharedVouchers.add(SharedVoucher(
        id: id,
        voucherId: voucherId,
        ownerId: ownerId,
        ownerName: ownerName,
        recipientUserId: recipientId,
        sharedAt: now,
      ));
    }
    notifyListeners();
  }

  /// Get all shared vouchers for a user (as recipient), with voucher details and status.
  List<SharedVoucherWithVoucher> getSharedVouchersForUser(String userId) {
    final list = <SharedVoucherWithVoucher>[];
    for (final s in _sharedVouchers) {
      if (s.recipientUserId != userId) continue;
      final voucher = getVoucherById(s.voucherId);
      if (voucher != null) {
        list.add(SharedVoucherWithVoucher(sharedVoucher: s, voucher: voucher));
      }
    }
    list.sort((a, b) => b.sharedVoucher.sharedAt.compareTo(a.sharedVoucher.sharedAt));
    return list;
  }

  /// Redeem a voucher (e.g. by a recipient). Marks voucher as redeemed immediately;
  /// all other users with the same shared coupon will see it as Expired.
  /// [redeemedAt] optional date from sheet; if null uses DateTime.now().
  void redeemVoucher(String voucherId, String redeemedByUserId, [DateTime? redeemedAt]) {
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index < 0) return;
    final v = _vouchers[index];
    if (v.status != VoucherStatus.active) return;

    _vouchers[index] = Voucher(
      id: v.id,
      customerId: v.customerId,
      customerName: v.customerName,
      vendorId: v.vendorId,
      vendorName: v.vendorName,
      amount: v.amount,
      voucherCode: v.voucherCode,
      status: VoucherStatus.redeemed,
      purchasedAt: v.purchasedAt,
      redeemedAt: redeemedAt ?? DateTime.now(),
      expiresAt: v.expiresAt,
      recipientName: v.recipientName,
      recipientEmail: v.recipientEmail,
      recipientPhone: v.recipientPhone,
    );
    notifyListeners();
  }

  /// Check if current user can redeem this voucher (recipient of a valid shared voucher).
  bool canCurrentUserRedeemSharedVoucher(String voucherId, String currentUserId) {
    final voucher = getVoucherById(voucherId);
    if (voucher == null || !voucher.isActive) return false;
    return _sharedVouchers.any((s) =>
        s.voucherId == voucherId && s.recipientUserId == currentUserId);
  }

  /// Refresh a single voucher's status from the Google Sheet backend and update local state.
  Future<void> refreshVoucherStatusFromSheetById(String voucherId) async {
    debugPrint('[VoucherSheet] Refresh by id: $voucherId');
    final voucher = getVoucherById(voucherId);
    if (voucher == null) {
      debugPrint('[VoucherSheet] Voucher not found for id: $voucherId');
      return;
    }
    final data = await VoucherImageGenerator.fetchStatusFromSheet(voucher.voucherCode);
    if (data == null) {
      debugPrint('[VoucherSheet] No status from sheet for code: ${voucher.voucherCode} – keeping current');
      return;
    }
    _applySheetStatusToVoucher(
      voucher.voucherCode,
      data[VoucherImageGenerator.kStatusKey] as String? ?? 'active',
      data[VoucherImageGenerator.kRedeemedAtKey] as String?,
    );
  }

  /// Refresh status from sheet for a voucher code (finds first matching voucher by code).
  Future<void> refreshVoucherStatusFromSheetByCode(String voucherCode) async {
    debugPrint('[VoucherSheet] Refresh by code: $voucherCode');
    final data = await VoucherImageGenerator.fetchStatusFromSheet(voucherCode);
    if (data == null) {
      debugPrint('[VoucherSheet] No status from sheet for code: $voucherCode – keeping current');
      return;
    }
    _applySheetStatusToVoucher(
      voucherCode,
      data[VoucherImageGenerator.kStatusKey] as String? ?? 'active',
      data[VoucherImageGenerator.kRedeemedAtKey] as String?,
    );
  }

  /// Refresh status from sheet for all vouchers in the list (e.g. for pull-to-refresh).
  Future<void> refreshAllVouchersStatusFromSheet(List<Voucher> vouchers) async {
    debugPrint('[VoucherSheet] Refresh all – ${vouchers.length} voucher(s)');
    for (final v in vouchers) {
      final data = await VoucherImageGenerator.fetchStatusFromSheet(v.voucherCode);
      if (data != null) {
        _applySheetStatusToVoucher(
          v.voucherCode,
          data[VoucherImageGenerator.kStatusKey] as String? ?? 'active',
          data[VoucherImageGenerator.kRedeemedAtKey] as String?,
        );
      }
    }
    debugPrint('[VoucherSheet] Refresh all complete');
  }

  void _applySheetStatusToVoucher(String voucherCode, String statusStr, [String? redeemedAtIso]) {
    final index = _vouchers.indexWhere((v) => v.voucherCode == voucherCode);
    if (index < 0) return;
    final v = _vouchers[index];
    final status = _sheetStatusToEnum(statusStr);
    DateTime? newRedeemedAt;
    if (status == VoucherStatus.redeemed) {
      if (redeemedAtIso != null && redeemedAtIso.isNotEmpty) {
        try {
          newRedeemedAt = DateTime.parse(redeemedAtIso);
        } catch (_) {
          newRedeemedAt = v.redeemedAt ?? DateTime.now();
        }
      } else {
        newRedeemedAt = v.redeemedAt ?? DateTime.now();
      }
    } else {
      newRedeemedAt = v.redeemedAt;
    }
    if (status == v.status && newRedeemedAt == v.redeemedAt) {
      debugPrint('[VoucherSheet] Status unchanged for $voucherCode: $statusStr');
      return;
    }
    debugPrint('[VoucherSheet] Updating voucher $voucherCode: ${v.status} -> $status');
    _vouchers[index] = Voucher(
      id: v.id,
      customerId: v.customerId,
      customerName: v.customerName,
      vendorId: v.vendorId,
      vendorName: v.vendorName,
      amount: v.amount,
      voucherCode: v.voucherCode,
      status: status,
      purchasedAt: v.purchasedAt,
      redeemedAt: newRedeemedAt,
      expiresAt: v.expiresAt,
      recipientName: v.recipientName,
      recipientEmail: v.recipientEmail,
      recipientPhone: v.recipientPhone,
    );
    notifyListeners();
  }

  VoucherStatus _sheetStatusToEnum(String s) {
    switch (s) {
      case 'redeemed':
        return VoucherStatus.redeemed;
      case 'expired':
        return VoucherStatus.expired;
      case 'cancelled':
        return VoucherStatus.cancelled;
      default:
        return VoucherStatus.active;
    }
  }
}
