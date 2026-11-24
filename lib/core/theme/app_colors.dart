import 'package:material_ui/material_ui.dart';

/// The Rofin palette: deep teal for trust, warm sand for calm, gold for the
/// business side of life, and clear green / terracotta for money direction.
abstract final class AppColors {
  static const Color teal = Color(0xFF0F766E);
  static const Color tealDeep = Color(0xFF115E59);
  static const Color tealLight = Color(0xFF5EEAD4);
  static const Color gold = Color(0xFFC8A24A);
  static const Color sand = Color(0xFFF7F2E8);
  static const Color sandDeep = Color(0xFFEFE6D6);
  static const Color ink = Color(0xFF13201E);
  static const Color inkSoft = Color(0xFF42524F);
  static const Color night = Color(0xFF0B1413);
  static const Color nightSurface = Color(0xFF121D1C);
  static const Color nightCard = Color(0xFF182524);
  static const Color nightText = Color(0xFFE8F0EE);
  static const Color nightMuted = Color(0xFF9FB0AC);

  static const Color income = Color(0xFF15803D);
  static const Color incomeDark = Color(0xFF4ADE80);
  static const Color expense = Color(0xFFC2410C);
  static const Color expenseDark = Color(0xFFFB923C);
  static const Color transfer = Color(0xFF2563EB);
  static const Color transferDark = Color(0xFF60A5FA);
  static const Color danger = Color(0xFFB91C1C);

  static const Color personal = teal;
  static const Color business = gold;

  static Color incomeFor(Brightness brightness) =>
      brightness == Brightness.dark ? incomeDark : income;

  static Color expenseFor(Brightness brightness) =>
      brightness == Brightness.dark ? expenseDark : expense;

  static Color transferFor(Brightness brightness) =>
      brightness == Brightness.dark ? transferDark : transfer;

  static Color mutedFor(Brightness brightness) =>
      brightness == Brightness.dark ? nightMuted : inkSoft;
}
