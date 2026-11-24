const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
const String _persianDigits = '۰۱۲۳۴۵۶۷۸۹';

/// Converts Arabic-Indic and Persian digits to Western digits.
///
/// Rofin keeps Western digits across both languages so amounts are easy to
/// scan and to enter on any keyboard.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final arabicIndex = _arabicIndicDigits.indexOf(char);
    final persianIndex = _persianDigits.indexOf(char);
    if (arabicIndex >= 0) {
      buffer.write(arabicIndex);
    } else if (persianIndex >= 0) {
      buffer.write(persianIndex);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}
