import 'package:flutter_test/flutter_test.dart';
import 'package:rofin/core/utils/currency.dart';
import 'package:rofin/core/utils/date_utils.dart';
import 'package:rofin/core/utils/money.dart';

void main() {
  group('parseMoneyToMinor', () {
    test('parses western digits and separators', () {
      expect(parseMoneyToMinor('1,234.50', 'EGP'), 123450);
      expect(parseMoneyToMinor(' 42 ', 'EGP'), 4200);
    });

    test('parses Arabic-Indic digits and decimal separator', () {
      expect(parseMoneyToMinor('١٢٣٤٫٥٠', 'EGP'), 123450);
      expect(parseMoneyToMinor('۹۹', 'EGP'), 9900);
    });

    test('handles three-decimal currencies', () {
      expect(parseMoneyToMinor('12.5', 'KWD'), 12500);
      expect(parseMoneyToMinor('1.234', 'KWD'), 1234);
    });

    test('handles negative amounts', () {
      expect(parseMoneyToMinor('-10', 'EGP'), -1000);
      expect(parseMoneyToMinor('−10.25', 'EGP'), -1025);
    });

    test('rejects invalid input', () {
      expect(parseMoneyToMinor('', 'EGP'), isNull);
      expect(parseMoneyToMinor('abc', 'EGP'), isNull);
      expect(parseMoneyToMinor('1.2.3', 'EGP'), isNull);
      expect(parseMoneyToMinor('-', 'EGP'), isNull);
    });
  });

  group('formatMoney', () {
    test('formats minor units with the currency symbol', () {
      final text = formatMoney(123450, 'EGP');
      expect(text, contains('1,234.50'));
      expect(text, contains(currencySymbol('EGP')));
    });

    test('respects currency decimals', () {
      expect(formatMoney(1234, 'KWD', withSymbol: false), '1.234');
    });

    test('can omit the symbol', () {
      expect(formatMoney(100000, 'EGP', withSymbol: false), '1,000.00');
    });
  });

  group('date utils', () {
    test('dateKey pads values', () {
      expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(monthKey(DateTime(2026, 11, 25)), '2026-11');
    });

    test('parseDateKey round-trips', () {
      expect(parseDateKey('2026-02-28'), DateTime(2026, 2, 28));
      expect(parseMonthKey('2026-02'), DateTime(2026, 2));
    });

    test('start and end of month', () {
      final date = DateTime(2026, 2, 14);
      expect(startOfMonth(date), DateTime(2026, 2));
      expect(endOfMonth(date), DateTime(2026, 2, 28));
      expect(endOfMonth(DateTime(2028, 2, 3)), DateTime(2028, 2, 29));
    });

    test('addMonthsClamped keeps the day inside the target month', () {
      expect(
        addMonthsClamped(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2, 28),
      );
      expect(
        addMonthsClamped(DateTime(2026, 1, 31), 2),
        DateTime(2026, 3, 31),
      );
      expect(
        addMonthsClamped(DateTime(2026, 5, 31), 1, preferredDay: 15),
        DateTime(2026, 6, 15),
      );
    });
  });
}
