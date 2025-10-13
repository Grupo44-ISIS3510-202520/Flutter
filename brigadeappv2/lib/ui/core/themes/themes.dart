import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: AppColors.lightScheme,
  scaffoldBackgroundColor: AppColors.lightScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightScheme.surface,
    foregroundColor: AppColors.lightScheme.onSurface,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightScheme.surface,
    elevation: 1,
    shadowColor: AppColors.lightScheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.lightScheme.outlineVariant),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.blueSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.lightScheme.outline),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightScheme.primary,
      foregroundColor: AppColors.lightScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    BrigadeExtras.light,
  ],
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: AppColors.darkScheme,
  scaffoldBackgroundColor: AppColors.darkScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkScheme.surface,
    foregroundColor: AppColors.darkScheme.onSurface,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkScheme.surface,
    elevation: 1,
    shadowColor: AppColors.darkScheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.darkScheme.outlineVariant),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F2A33),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.darkScheme.outline),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkScheme.primary,
      foregroundColor: AppColors.darkScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    BrigadeExtras.dark,
  ],
);
