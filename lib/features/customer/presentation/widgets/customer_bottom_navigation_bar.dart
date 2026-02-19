import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CustomerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Navigation bar container
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.surfaceColor.withOpacity(0.5),
                        AppTheme.surfaceColor.withOpacity(0.0),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomerNavBarItem(
                                icon: Icons.dashboard_rounded,
                                label: 'Home',
                                isSelected: currentIndex == 0,
                                onTap: () => onTap(0),
                              ),
                            ),
                            Expanded(
                              child: CustomerNavBarItem(
                                icon: Icons.request_quote_rounded,
                                label: 'Requests',
                                isSelected: currentIndex == 1,
                                onTap: () => onTap(1),
                              ),
                            ),
                            // Spacer for center button
                            const SizedBox(width: 45),
                              Expanded(
                                child: CustomerNavBarItem(
                                  icon: Icons.receipt_long_rounded,
                                  label: 'Transactions',
                                  isSelected: currentIndex == 2,
                                  onTap: () => onTap(2),
                                ),
                              ),
                              Expanded(
                                child: CustomerNavBarItem(
                                  icon: Icons.person_rounded,
                                  label: 'Profile',
                                  isSelected: currentIndex == 3,
                                  onTap: () => onTap(3),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating QR Code Button - positioned outside the bar
          Positioned(
            bottom: 55,
            child: CustomerCenterQRButton(
              onTap: () {
                // Navigate to separate QR scan page
                context.push('/customer/scan');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomerNavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    // Return filled icon when selected, outlined when not
    switch (icon) {
      case Icons.dashboard_rounded:
        return isSelected
            ? Icons.dashboard_rounded
            : Icons.dashboard_outlined;
      case Icons.request_quote_rounded:
        return isSelected
            ? Icons.request_quote_rounded
            : Icons.request_quote_outlined;
      case Icons.receipt_long_rounded:
        return isSelected
            ? Icons.receipt_long_rounded
            : Icons.receipt_long_outlined;
      case Icons.person_rounded:
        return isSelected
            ? Icons.person_rounded
            : Icons.person_outline_rounded;
      default:
        return icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 4 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                size: isSelected ? 24 : 24,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 10 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                height: 1.1,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerCenterQRButton extends StatefulWidget {
  final VoidCallback onTap;

  const CustomerCenterQRButton({
    super.key,
    required this.onTap,
  });

  @override
  State<CustomerCenterQRButton> createState() => _CustomerCenterQRButtonState();
}

class _CustomerCenterQRButtonState extends State<CustomerCenterQRButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_glowController.value * 0.3);
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.85),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(glowIntensity * 0.8),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 4,
                ),
                // Middle glow
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(glowIntensity * 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
                // Inner glow
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(glowIntensity * 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
                // Deep shadow for floating effect
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}
