import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const String _arabicFont = 'IBMPlexSansArabic';
  static const String _latinFont = 'IBMPlexSans';

  static ThemeData light(String locale) => _build(Brightness.light, locale);

  static ThemeData dark(String locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, String locale) {
    final isDark = brightness == Brightness.dark;
    final isArabic = locale == 'ar';
    final fontFamily = isArabic ? _arabicFont : _latinFont;
    final fallback = isArabic ? _latinFont : _arabicFont;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppColors.tealLight : AppColors.teal,
      onPrimary: isDark ? AppColors.night : Colors.white,
      primaryContainer: isDark
          ? AppColors.tealDeep
          : const Color(0xFFCDEAE5),
      onPrimaryContainer: isDark ? AppColors.nightText : AppColors.tealDeep,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      secondaryContainer: isDark
          ? const Color(0xFF3B3320)
          : const Color(0xFFF1E6C8),
      onSecondaryContainer: isDark ? const Color(0xFFF4E5B8) : AppColors.ink,
      surface: isDark ? AppColors.night : AppColors.sand,
      onSurface: isDark ? AppColors.nightText : AppColors.ink,
      surfaceContainerLowest: isDark ? AppColors.night : Colors.white,
      surfaceContainerLow: isDark
          ? AppColors.nightSurface
          : const Color(0xFFFBF8F1),
      surfaceContainer: isDark ? AppColors.nightCard : Colors.white,
      surfaceContainerHigh: isDark
          ? const Color(0xFF1E2C2A)
          : const Color(0xFFF3ECDF),
      surfaceContainerHighest: isDark
          ? const Color(0xFF263633)
          : AppColors.sandDeep,
      onSurfaceVariant: isDark ? AppColors.nightMuted : AppColors.inkSoft,
      outline: isDark ? const Color(0xFF4C5F5B) : const Color(0xFFCBBFA9),
      outlineVariant: isDark
          ? const Color(0xFF2C3D3A)
          : const Color(0xFFE2D7C5),
      error: isDark ? const Color(0xFFFCA5A5) : AppColors.danger,
      onError: isDark ? AppColors.night : Colors.white,
    );

    final baseText = (isDark ? Typography.material2021().white : Typography.material2021().black)
        .apply(
          fontFamily: fontFamily,
          fontFamilyFallback: <String>[fallback],
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: isArabic ? 0 : -0.5,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: isArabic ? 0 : -0.4,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: isArabic ? 0 : -0.2,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.45),
    );

    final roundedCard = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      fontFamilyFallback: <String>[fallback],
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.night : AppColors.sand,
      canvasColor: isDark ? AppColors.night : AppColors.sand,
      cardColor: scheme.surfaceContainer,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: roundedCard.copyWith(
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? AppColors.nightSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark
            ? AppColors.tealDeep
            : const Color(0xFFD8EEE9),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected
                ? (isDark ? AppColors.tealLight : AppColors.tealDeep)
                : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? (isDark ? AppColors.tealLight : AppColors.tealDeep)
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? AppColors.tealLight : AppColors.teal,
        foregroundColor: isDark ? AppColors.night : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.nightSurface
            : const Color(0xFFFBF8F1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF2A3B38)
            : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: roundedCard,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.nightSurface
            : const Color(0xFFF3ECDF),
        selectedColor: isDark ? AppColors.tealDeep : const Color(0xFFD8EEE9),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.22),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}
