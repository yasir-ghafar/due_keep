/// Display helpers for the currencies Due Keep supports in Settings.
abstract final class CurrencyFormat {
  static String symbol(String code) => switch (code) {
        'USD' => r'$',
        'EUR' => '€',
        'GBP' => '£',
        'CAD' => r'CA$',
        'AUD' => r'A$',
        'JPY' => '¥',
        'INR' => '₹',
        'PKR' => 'Rs',
        _ => code,
      };

  /// e.g. `$12.00`, `€9.99`, `¥1200`
  static String money(double amount, String? code, {int? fractionDigits}) {
    final currency = code ?? 'USD';
    final digits = fractionDigits ?? (currency == 'JPY' ? 0 : 2);
    final value = amount.toStringAsFixed(digits);
    final sym = symbol(currency);
    if (sym == currency) return '$value $currency';
    return '$sym$value';
  }

  /// Compact total for hero copy, e.g. `$61`, `€61`
  static String compact(double amount, String? code) {
    final currency = code ?? 'USD';
    final sym = symbol(currency);
    final value = amount.toStringAsFixed(0);
    if (sym == currency) return '$value $currency';
    return '$sym$value';
  }
}
