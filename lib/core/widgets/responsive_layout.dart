import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Returns true when width is below [kBreakpointMobile] (phone layout).
bool isMobileLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width < kBreakpointMobile;
}

/// Returns true when width is at or above [kBreakpointDesktop] (desktop layout).
bool isDesktopLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kBreakpointDesktop;
}

/// Returns true when width is in tablet range [kBreakpointMobile, kBreakpointDesktop).
bool isTabletLayout(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= kBreakpointMobile && w < kBreakpointDesktop;
}

/// Use bottom nav on mobile; use navigation rail (or drawer) on tablet/desktop.
bool useBottomNav(BuildContext context) {
  return MediaQuery.sizeOf(context).width < kBreakpointMobile;
}

/// Use navigation rail on tablet/desktop.
bool useNavigationRail(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kBreakpointMobile;
}

/// Wraps [child] in a centered box with [maxWidth] on large screens.
/// On narrow screens, child takes full width.
class ResponsiveMaxWidth extends StatelessWidget {
  const ResponsiveMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = kMaxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < kBreakpointMobile) {
      return padding != null ? Padding(padding: padding!, child: child) : child;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Builder that provides [isMobile], [isTablet], [isDesktop] and [width].
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required double width,
  }) builder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < kBreakpointMobile;
    final isTablet = width >= kBreakpointMobile && width < kBreakpointDesktop;
    final isDesktop = width >= kBreakpointDesktop;
    return builder(
      context,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      width: width,
    );
  }
}
