import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF5B4BDB);
  static const primaryDark = Color(0xFF3B2FB8);
  static const teal = Color(0xFF1FBFA3);
  static const amber = Color(0xFFFFC94A);
  static const ink = Color(0xFF1E1B3A);
  static const muted = Color(0xFF7A7799);
  static const surface = Colors.white;
  static const background = Color(0xFFF5F4FB);
  static const danger = Color(0xFFE5484D);

  static const brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF6D5DF6), Color(0xFF4A3BD0), Color(0xFF1FBFA3)],
    stops: [0, .55, 1],
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.teal,
    surface: AppColors.surface,
    error: AppColors.danger,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      iconTheme: IconThemeData(color: AppColors.ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: AppColors.primary.withValues(alpha: .35)),
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F0F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: .12),
      elevation: 8,
      shadowColor: Colors.black26,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: Colors.white,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
