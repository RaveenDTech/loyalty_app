import 'package:flutter/material.dart';

/// DSI Group loyalty tier based on employment experience at DSI group companies.
/// Discount is applied as a percentage of every bill total.
enum DsiTenureTier {
  zeroToOne,   // 0–1 year
  oneToFive,  // 1–5 years
  fiveToTen,  // 5–10 years
  tenPlus,    // 10+ years
}

extension DsiTenureTierExtension on DsiTenureTier {
  /// Display label for the tenure range.
  String get label {
    switch (this) {
      case DsiTenureTier.zeroToOne:
        return '0–1 year';
      case DsiTenureTier.oneToFive:
        return '1–5 years';
      case DsiTenureTier.fiveToTen:
        return '5–10 years';
      case DsiTenureTier.tenPlus:
        return '10+ years';
    }
  }

  /// Discount percentage applied to every bill total.
  int get discountPercent {
    switch (this) {
      case DsiTenureTier.zeroToOne:
        return 5;
      case DsiTenureTier.oneToFive:
        return 10;
      case DsiTenureTier.fiveToTen:
        return 15;
      case DsiTenureTier.tenPlus:
        return 20;
    }
  }

  /// Short tier name for badges and UI.
  String get tierName {
    switch (this) {
      case DsiTenureTier.zeroToOne:
        return 'Starter';
      case DsiTenureTier.oneToFive:
        return 'Rising Star';
      case DsiTenureTier.fiveToTen:
        return 'Loyal';
      case DsiTenureTier.tenPlus:
        return 'Champion';
    }
  }

  /// Gradient colors for tier cards (primary, secondary).
  List<Color> get gradientColors {
    switch (this) {
      case DsiTenureTier.zeroToOne:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case DsiTenureTier.oneToFive:
        return [const Color(0xFF337AFF), const Color(0xFF06B6D4)];
      case DsiTenureTier.fiveToTen:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case DsiTenureTier.tenPlus:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
  }

  /// Icon for the tier.
  IconData get icon {
    switch (this) {
      case DsiTenureTier.zeroToOne:
        return Icons.star_outline_rounded;
      case DsiTenureTier.oneToFive:
        return Icons.star_half_rounded;
      case DsiTenureTier.fiveToTen:
        return Icons.star_rounded;
      case DsiTenureTier.tenPlus:
        return Icons.workspace_premium_rounded;
    }
  }
}

/// Resolves tier from years of employment at DSI group companies.
class DsiLoyaltyTierHelper {
  static const List<DsiTenureTier> allTiers = [
    DsiTenureTier.zeroToOne,
    DsiTenureTier.oneToFive,
    DsiTenureTier.fiveToTen,
    DsiTenureTier.tenPlus,
  ];

  /// Returns the tier for a given tenure in years.
  static DsiTenureTier tierFromYears(double years) {
    if (years < 1) return DsiTenureTier.zeroToOne;
    if (years < 5) return DsiTenureTier.oneToFive;
    if (years < 10) return DsiTenureTier.fiveToTen;
    return DsiTenureTier.tenPlus;
  }

  /// Returns discount amount for a bill total based on tier.
  static double discountAmount(double billTotal, DsiTenureTier tier) {
    return billTotal * (tier.discountPercent / 100);
  }
}
