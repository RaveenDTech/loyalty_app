import 'package:intl/intl.dart';

/// Central currency formatting for the app. Uses comma separators (e.g. 5,000.00).
class CurrencyFormat {
  static final NumberFormat _rsWithDecimals = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 2,
    locale: 'en_LK',
  );

  static final NumberFormat _rsNoDecimals = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 0,
    locale: 'en_LK',
  );

  static final NumberFormat _lkrWithDecimals = NumberFormat.currency(
    symbol: 'LKR ',
    decimalDigits: 2,
    locale: 'en_LK',
  );

  static final NumberFormat _lkrNoDecimals = NumberFormat.currency(
    symbol: 'LKR ',
    decimalDigits: 0,
    locale: 'en_LK',
  );

  /// Format amount with Rs. and 2 decimals (e.g. Rs. 5,000.00).
  static String rs(double amount, {int decimalDigits = 2}) {
    if (decimalDigits == 0) return _rsNoDecimals.format(amount);
    return _rsWithDecimals.format(amount);
  }

  /// Format amount with LKR (e.g. LKR 5,000.00 or LKR 5,000).
  static String lkr(double amount, {int decimalDigits = 2}) {
    if (decimalDigits == 0) return _lkrNoDecimals.format(amount);
    return _lkrWithDecimals.format(amount);
  }

  /// Short form for presets (e.g. Rs. 5K or Rs. 1,000).
  static String rsShort(double amount) {
    if (amount >= 1000) {
      final k = amount / 1000;
      return k == k.roundToDouble()
          ? 'Rs. ${k.toInt()}K'
          : 'Rs. ${k.toStringAsFixed(1)}K';
    }
    return _rsNoDecimals.format(amount);
  }
}
