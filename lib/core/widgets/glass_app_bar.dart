import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loyalty_app/core/theme/app_theme.dart';

/// A transparent app bar with glassmorphism (blur + semi-transparent gradient).
/// Use as [Scaffold.appBar] for a consistent look across the app.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  @override
  final Size preferredSize;

  static const Color _glassTint = AppTheme.backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor.withOpacity(0.3),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      leading: leading,
      title: title,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _glassTint.withOpacity(0.72),
                  _glassTint.withOpacity(0.45),
                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}
