import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/customer/presentation/pages/customer_home_page.dart';
import '../../features/customer/presentation/pages/qr_scan_page.dart';
import '../../features/customer/presentation/pages/customer_transactions_page.dart';
import '../../features/customer/presentation/pages/customer_requests_page.dart';
import '../../features/supplier/presentation/pages/supplier_home_page.dart';
import '../../features/supplier/presentation/pages/pending_requests_page.dart';
import '../../features/supplier/presentation/pages/bill_upload_page.dart';
import '../../features/supplier/presentation/pages/supplier_transactions_page.dart';
import '../../features/supplier/presentation/pages/supplier_qr_code_page.dart';
import '../../features/supplier/presentation/pages/supplier_profile_page.dart';
import '../../features/customer/presentation/pages/customer_profile_page.dart';
import '../../features/customer/presentation/pages/dsi_loyalty_page.dart';
import '../../features/customer/presentation/pages/vendor_selection_page.dart';
import '../../features/customer/presentation/pages/voucher_purchase_page.dart';
import '../../features/customer/presentation/pages/voucher_success_page.dart';
import '../../features/customer/presentation/pages/voucher_history_page.dart';
import '../../features/customer/presentation/pages/voucher_details_page.dart';
import '../../features/shared/presentation/pages/notifications_page.dart';
import '../../core/providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Customer Routes
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: '/customer/scan',
        builder: (context, state) => const QRScanPage(),
      ),
      GoRoute(
        path: '/customer/transactions',
        builder: (context, state) => const CustomerTransactionsPage(),
      ),
      GoRoute(
        path: '/customer/requests',
        builder: (context, state) => const CustomerRequestsPage(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const CustomerProfilePage(),
      ),
      GoRoute(
        path: '/customer/dsi-loyalty',
        builder: (context, state) => const DsiLoyaltyPage(),
      ),
      GoRoute(
        path: '/customer/vendor-selection',
        builder: (context, state) => const VendorSelectionPage(),
      ),
      GoRoute(
        path: '/customer/voucher-purchase',
        builder: (context, state) {
          final vendorId = state.uri.queryParameters['vendorId'] ?? '';
          return VoucherPurchasePage(vendorId: vendorId);
        },
      ),
      GoRoute(
        path: '/customer/voucher-success',
        builder: (context, state) {
          final voucherId = state.uri.queryParameters['voucherId'] ?? '';
          return VoucherSuccessPage(voucherId: voucherId);
        },
      ),
      GoRoute(
        path: '/customer/voucher-history',
        builder: (context, state) => const VoucherHistoryPage(),
      ),
      GoRoute(
        path: '/customer/voucher-details',
        builder: (context, state) {
          final voucherId = state.uri.queryParameters['voucherId'] ?? '';
          final isShared = state.uri.queryParameters['shared'] == 'true';
          return VoucherDetailsPage(voucherId: voucherId, isShared: isShared);
        },
      ),
      // Supplier Routes
      GoRoute(
        path: '/supplier/home',
        builder: (context, state) => const SupplierHomePage(),
      ),
      GoRoute(
        path: '/supplier/pending-requests',
        builder: (context, state) => const PendingRequestsPage(),
      ),
      GoRoute(
        path: '/supplier/bill-upload',
        builder: (context, state) {
          final requestId = state.uri.queryParameters['requestId'] ?? '';
          return BillUploadPage(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/supplier/transactions',
        builder: (context, state) => const SupplierTransactionsPage(),
      ),
      GoRoute(
        path: '/supplier/qr-code',
        builder: (context, state) => const SupplierQRCodePage(),
      ),
      GoRoute(
        path: '/supplier/profile',
        builder: (context, state) => const SupplierProfilePage(),
      ),
      // Shared Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
