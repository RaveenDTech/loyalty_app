import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../widgets/customer_bottom_navigation_bar.dart';
import '../widgets/customer_home_tab.dart';
import '../widgets/customer_requests_tab.dart';
import '../widgets/customer_transactions_tab.dart';
import '../widgets/customer_profile_tab.dart';

/// Customer home shell: bottom nav on mobile, navigation rail + max-width content on web/desktop.
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  static const Color _bgTop = Color(0xFF080E27);
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
    _NavItem(icon: Icons.request_quote_rounded, label: 'Requests'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Transactions'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final useRail = useNavigationRail(context);

    if (useRail) {
      return Scaffold(
        backgroundColor: _bgTop,
        body: Row(
          children: [
            _CustomerNavRail(
              navItems: _navItems,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              onScanTap: () => context.push('/customer/scan'),
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
                      CustomerHomeTab(),
                      CustomerRequestsTab(),
                      CustomerTransactionsTab(),
                      CustomerProfileTab(),
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
      bottomNavigationBar: CustomerBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            CustomerHomeTab(),
            CustomerRequestsTab(),
            CustomerTransactionsTab(),
            CustomerProfileTab(),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _CustomerNavRail extends StatelessWidget {
  const _CustomerNavRail({
    required this.navItems,
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  });

  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;

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
              final selected = currentIndex == i;
              return _RailTile(
                icon: item.icon,
                label: item.label,
                selected: selected,
                onTap: () => onTap(i),
              );
            }),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onScanTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
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
