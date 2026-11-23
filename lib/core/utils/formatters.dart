class Formatters {
  const Formatters._();

  /// Formats an amount with grouping commas and optional decimals.
  static String currency(
    num value, {
    String symbol = '৳',
    int decimals = 0,
  }) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final isNegative = intPart.startsWith('-');
    final digits = isNegative ? intPart.substring(1) : intPart;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && (remaining - 1) % 3 == 0) {
        buffer.write(',');
      }
    }

    final sign = isNegative ? '-' : '';
    final decPart = decimals > 0 ? '.${parts[1]}' : '';
    return '$sign$symbol ${buffer.toString()}$decPart';
  }

  /// Formats large currency amounts compactly for KPI tiles.
  static String compactCurrency(num value, {String symbol = '৳'}) {
    if (value >= 1000000) {
      return '$symbol ${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 10000) {
      return '$symbol ${(value / 1000).toStringAsFixed(1)}K';
    }
    return currency(value, symbol: symbol, decimals: 0);
  }

  static String initials(String fullName) {
    final tokens = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      return 'PC';
    }
    if (tokens.length == 1) {
      return tokens.first.substring(0, tokens.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${tokens.first[0]}${tokens.last[0]}'.toUpperCase();
  }
}

