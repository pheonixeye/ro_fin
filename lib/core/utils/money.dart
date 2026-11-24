import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'currency.dart';
import 'digits.dart';

export 'digits.dart' show normalizeDigits;

String formatMoney(
  int amountMinor,
  String currencyCode, {
  bool withSymbol = true,
  String locale = 'en_US',
}) {
  final currency = currencyFor(currencyCode);
  final value = amountMinor / math.pow(10, currency.decimals);
  final format = NumberFormat.currency(
    locale: locale,
    symbol: withSymbol ? currency.symbol : '',
    decimalDigits: currency.decimals,
  );
  return format.format(value).trim();
}

String formatCompactMoney(int amountMinor, String currencyCode) {
  final currency = currencyFor(currencyCode);
  final value = amountMinor / math.pow(10, currency.decimals);
  final format = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: currency.symbol,
    decimalDigits: 0,
  );
  return format.format(value);
}

int? parseMoneyToMinor(String input, String currencyCode) {
  final normalized = normalizeDigits(input)
      .replaceAll('\u200f', '')
      .replaceAll('\u200e', '')
      .replaceAll(' ', '')
      .replaceAll('٬', '')
      .replaceAll(',', '')
      .replaceAll('٫', '.')
      .replaceAll('−', '-')
      .replaceAll('—', '-');
  if (normalized.isEmpty) {
    return null;
  }

  final negative = normalized.startsWith('-');
  final body = negative ? normalized.substring(1) : normalized;
  if (body.isEmpty) {
    return null;
  }

  final parts = body.split('.');
  if (parts.length > 2) {
    return null;
  }

  final whole = int.tryParse(parts[0]);
  if (whole == null) {
    return null;
  }

  final decimals = currencyDecimals(currencyCode);
  final fractionText = parts.length == 2 ? parts[1] : '';
  final padded = fractionText.padRight(decimals, '0');
  final fraction = decimals == 0
      ? 0
      : int.tryParse(padded.substring(0, decimals));
  if (fraction == null) {
    return null;
  }

  final factor = math.pow(10, decimals).toInt();
  final minor = whole * factor + fraction;
  return negative ? -minor : minor;
}

String amountToInput(int amountMinor, String currencyCode) {
  final decimals = currencyDecimals(currencyCode);
  final factor = math.pow(10, decimals).toInt();
  final whole = amountMinor.abs() ~/ factor;
  final fraction = amountMinor.abs() % factor;
  final sign = amountMinor < 0 ? '-' : '';
  if (decimals == 0) {
    return '$sign$whole';
  }
  return '$sign$whole.${fraction.toString().padLeft(decimals, '0')}';
}

String formatNumber(num value, {String locale = 'en_US'}) {
  return NumberFormat.decimalPattern(locale).format(value);
}
