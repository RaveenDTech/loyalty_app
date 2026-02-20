import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/qr_code_bottom_sheet.dart';
import '../widgets/supplier_home_tab.dart';
import '../widgets/supplier_pending_requests_tab.dart';
import '../widgets/supplier_transactions_tab.dart';
import '../widgets/supplier_profile_tab.dart';

/// Supplier home shell: bottom nav on mobile, navigation rail + max-width content on web/desktop.
class SupplierHomePage extends StatefulWidget {
  const SupplierHomePage({super.key});

  @override
  State<SupplierHomePage> createState() => _SupplierHomePageState();
}

class _SupplierHomePageState extends State<SupplierHomePage> {
  static const Color _bgTop =AppTheme.backgroundColor;
  int _currentIndex = 0;

  static const List<_SupplierNavItem> _navItems = [
    _SupplierNavItem(icon: Icons.dashboard_rounded, label: 'Home'),
    _SupplierNavItem(icon: Icons.assignment_rounded, label: 'Requests'),
    _SupplierNavItem(icon: Icons.qr_code_rounded, label: 'QR', isQr: true),
    _SupplierNavItem(icon: Icons.receipt_long_rounded, label: 'Transactions'),
    _SupplierNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) {
      QRCodeBottomSheet.show(context);
      return;
    }
    final railIndex = index > 2 ? index - 1 : index; // QR not a tab: 0 Home, 1 Requests, 2 Transactions, 3 Profile
    setState(() => _currentIndex = railIndex);
  }

  @override
  Widget build(BuildContext context) {
    final useRail = useNavigationRail(context);

    if (useRail) {
      return Scaffold(
        backgroundColor: _bgTop,
        body: Row(
          children: [
            _SupplierNavRail(
              navItems: _navItems,
              currentTabIndex: _currentIndex,
              onTap: (index) => _onNavTap(context, index),
            ),
            Expanded(
              child: SafeArea(
                left: false,
                child: ResponsiveMaxWidth(
                  maxWidth: kMaxContentWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: const [
                      SupplierHomeTab(),
                      SupplierPendingRequestsTab(),
                      SupplierTransactionsTab(),
                      SupplierProfileTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgTop,
      extendBody: true,
      bottomNavigationBar: GlassmorphismBottomNavBar(
        currentIndex: _currentIndex < 2 ? _currentIndex : _currentIndex + 1, // 0,1,QR,3,4 -> bar index
        onTap: (index) => _onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            SupplierHomeTab(),
            SupplierPendingRequestsTab(),
            SupplierTransactionsTab(),
            SupplierProfileTab(),
          ],
        ),
      ),
    );
  }
}

class _SupplierNavItem {
  const _SupplierNavItem({
    required this.icon,
    required this.label,
    this.isQr = false,
  });
  final IconData icon;
  final String label;
  final bool isQr;
}

class _SupplierNavRail extends StatelessWidget {
  const _SupplierNavRail({
    required this.navItems,
    required this.currentTabIndex,
    required this.onTap,
  });

  final List<_SupplierNavItem> navItems;
  final int currentTabIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.6),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...navItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              if (item.isQr) {
                return _SupplierRailQRButton(onTap: () => onTap(2));
              }
              final tabIndex = i > 2 ? i - 1 : i;
              final selected = currentTabIndex == tabIndex;
              return _SupplierRailTile(
                icon: item.icon,
                label: item.label,
                selected: selected,
                onTap: () => onTap(i),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SupplierRailTile extends StatelessWidget {
  const _SupplierRailTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupplierRailQRButton extends StatelessWidget {
  const _SupplierRailQRButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Tooltip(
        message: 'Show QR Code',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
