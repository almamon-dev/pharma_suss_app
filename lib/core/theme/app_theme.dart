import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConfig.brandPrimary,
      brightness: Brightness.light,
      primary: AppConfig.brandPrimary,
      onPrimary: Colors.white,
      surface: AppConfig.cardLight,
      onSurface: AppConfig.inkPrimaryLight,
      onSurfaceVariant: AppConfig.inkSecondaryLight,
      outline: AppConfig.slateBorderLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConfig.canvasLight,
      hoverColor: AppConfig.brandPrimary.withValues(alpha: 0.04),
      focusColor: AppConfig.brandPrimary.withValues(alpha: 0.06),
      highlightColor: AppConfig.brandPrimary.withValues(alpha: 0.05),
      splashColor: AppConfig.brandPrimary.withValues(alpha: 0.08),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.cardLight,
        foregroundColor: AppConfig.inkPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppConfig.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppConfig.inkSecondaryLight,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.slateBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.slateBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppConfig.brandPrimary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.rose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.rose, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppConfig.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.inkPrimaryLight,
          minimumSize: const Size.fromHeight(46),
          side: const BorderSide(color: AppConfig.slateBorderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppConfig.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConfig.cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 66,
        indicatorColor: AppConfig.brandSoftLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppConfig.brandPrimary
                : AppConfig.inkSecondaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? AppConfig.brandPrimary
                : AppConfig.inkSecondaryLight,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConfig.slateBorderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConfig.brandPrimary,
      brightness: Brightness.dark,
      primary: AppConfig.brandPrimaryBright,
      onPrimary: Colors.white,
      surface: AppConfig.cardDark,
      onSurface: AppConfig.inkPrimaryDark,
      onSurfaceVariant: AppConfig.inkSecondaryDark,
      outline: AppConfig.slateBorderDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConfig.canvasDark,
      hoverColor: AppConfig.brandPrimaryBright.withValues(alpha: 0.07),
      focusColor: AppConfig.brandPrimaryBright.withValues(alpha: 0.09),
      highlightColor: AppConfig.brandPrimaryBright.withValues(alpha: 0.08),
      splashColor: AppConfig.brandPrimaryBright.withValues(alpha: 0.12),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.cardDark,
        foregroundColor: AppConfig.inkPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppConfig.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.elevatedDark,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppConfig.inkSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.slateBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.slateBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppConfig.brandPrimaryBright,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.rose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppConfig.rose, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppConfig.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.inkPrimaryDark,
          minimumSize: const Size.fromHeight(46),
          side: const BorderSide(color: AppConfig.slateBorderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppConfig.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConfig.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 66,
        indicatorColor: AppConfig.brandSoftDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppConfig.brandPrimaryBright
                : AppConfig.inkSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? AppConfig.brandPrimaryBright
                : AppConfig.inkSecondaryDark,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConfig.slateBorderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
