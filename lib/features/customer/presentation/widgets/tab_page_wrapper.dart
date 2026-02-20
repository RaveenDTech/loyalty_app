import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_app_bar.dart';

/// Wraps a tab body with a scaffold and app bar (for Requests, Transactions, Profile tabs).
class TabPageWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const TabPageWrapper({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color bgTop = Color(0xFF080E27);

    return Scaffold(
      backgroundColor: bgTop,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: child,
    );
  }
}
