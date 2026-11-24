import 'package:intl/intl.dart';

import 'digits.dart';

String dateKey(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String monthKey(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    return DateTime.now();
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return DateTime.now();
  }
  return DateTime(year, month, day);
}

DateTime parseMonthKey(String key) {
  final parts = key.split('-');
  if (parts.length < 2) {
    return DateTime.now();
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) {
    return DateTime.now();
  }
  return DateTime(year, month);
}

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

DateTime addMonthsClamped(DateTime date, int months, {int? preferredDay}) {
  final targetMonth = DateTime(date.year, date.month + months);
  final day = preferredDay ?? date.day;
  final maxDay = daysInMonth(targetMonth.year, targetMonth.month);
  return DateTime(
    targetMonth.year,
    targetMonth.month,
    day.clamp(1, maxDay),
  );
}

DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

String formatDateKey(String key, String locale) {
  final date = parseDateKey(key);
  return normalizeDigits(DateFormat.yMMMd(locale).format(date));
}

String formatMonthKey(String key, String locale) {
  final date = parseMonthKey(key);
  return normalizeDigits(DateFormat.yMMMM(locale).format(date));
}

String formatShortMonthKey(String key, String locale) {
  final date = parseMonthKey(key);
  return normalizeDigits(DateFormat.MMM(locale).format(date));
}

String formatWeekdayKey(String key, String locale) {
  final date = parseDateKey(key);
  return normalizeDigits(DateFormat.EEEE(locale).format(date));
}

List<String> lastMonthKeys(String endMonth, int count) {
  final end = parseMonthKey(endMonth);
  return List<String>.generate(count, (index) {
    final date = DateTime(end.year, end.month - (count - 1 - index));
    return monthKey(date);
  });
}

String shiftMonthKey(String key, int offset) {
  final date = parseMonthKey(key);
  return monthKey(DateTime(date.year, date.month + offset));
}

bool isDateKeyInRange(String key, String startKey, String endKey) {
  return key.compareTo(startKey) >= 0 && key.compareTo(endKey) <= 0;
}
