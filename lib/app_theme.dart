import 'package:flutter/material.dart';

class AppTheme {
  static const violet = Color(0xFF6337D9);
  static const coral = Color(0xFFFF8066);
  static const ink = Color(0xFF291447);
  static const cream = Color(0xFFFFF8F4);

  static Color income(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color expense(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFAB96)
      : const Color(0xFFAD3E2C);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: violet,
          brightness: brightness,
          surface: dark ? const Color(0xFF1C142A) : cream,
        ).copyWith(
          primary: dark ? const Color(0xFFCDBAFF) : violet,
          onPrimary: dark ? ink : Colors.white,
          secondary: dark ? const Color(0xFFFFAB96) : const Color(0xFFAD3E2C),
          secondaryContainer: dark
              ? const Color(0xFF63382F)
              : const Color(0xFFFFDED4),
          onSecondaryContainer: dark ? cream : ink,
          onSurface: dark ? const Color(0xFFF5ECFF) : ink,
        );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF2C203E) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded.copyWith(
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: rounded,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 54),
          elevation: 0,
          shape: rounded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: rounded,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF302442) : const Color(0xFFF2ECFF),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF2C203E) : Colors.white,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: coral,
        foregroundColor: ink,
        elevation: 2,
        shape: rounded,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      chipTheme: ChipThemeData(
        shape: rounded,
        side: BorderSide.none,
        selectedColor: scheme.primaryContainer,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.primary.withValues(alpha: 0.12),
      ),
    );
  }
}
