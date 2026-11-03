import 'package:flutter/material.dart';

import '../../shared/design_system/mimi_tokens.dart';
import '../../shared/design_system/mimi_typography.dart';

/// Material defaults derived from the Mimi Design System (dark only).
///
/// Widgets use [MimiColors] and [MimiTypography] directly; this theme only
/// keeps Material's built-in widgets consistent with them.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: MimiColors.primary,
    onPrimary: MimiColors.background,
    secondary: MimiColors.primarySoft,
    onSecondary: MimiColors.background,
    error: MimiColors.error,
    onError: MimiColors.background,
    surface: MimiColors.surface,
    onSurface: MimiColors.textPrimary,
    onSurfaceVariant: MimiColors.textSecondary,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: MimiColors.background,
    fontFamily: MimiTypography.fontFamily,
    textTheme:
        const TextTheme(
          displayLarge: MimiTypography.displayLarge,
          headlineLarge: MimiTypography.headlineLarge,
          headlineMedium: MimiTypography.headlineMedium,
          titleLarge: MimiTypography.titleLarge,
          titleMedium: MimiTypography.titleMedium,
          bodyLarge: MimiTypography.bodyLarge,
          bodyMedium: MimiTypography.bodyMedium,
          labelLarge: MimiTypography.labelLarge,
          labelMedium: MimiTypography.labelMedium,
        ).apply(
          bodyColor: MimiColors.textPrimary,
          displayColor: MimiColors.textPrimary,
        ),
  );
}
