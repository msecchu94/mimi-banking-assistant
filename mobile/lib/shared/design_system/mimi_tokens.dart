import 'package:flutter/painting.dart';

/// DS-02 Foundations: approved colors (docs/design/DESIGN_SYSTEM.md §2).
abstract final class MimiColors {
  // Core / structure / identity / text.
  static const background = Color(0xFF071A1F);
  static const surface = Color(0xFF0C252A);
  static const surfaceElevated = Color(0xFF123238);

  /// #16383D at 70%.
  static const surfaceGlass = Color(0xB316383D);

  /// #16383D at 85%.
  static const surfaceGlassStrong = Color(0xD916383D);
  static const primary = Color(0xFF19C6B3);
  static const primaryBright = Color(0xFF25E3D2);
  static const primarySoft = Color(0xFF8EF1E7);
  static const textPrimary = Color(0xFFF4F8F8);
  static const textSecondary = Color(0xFFA6BBBC);

  /// Tertiary and supporting text only; never critical financial information.
  static const textMuted = Color(0xFF7D9A9C);

  // Semantic / financial states. Never communicate state through color alone.
  static const success = Color(0xFF35D07F);
  static const warning = Color(0xFFF3B84B);
  static const error = Color(0xFFF05B68);

  // Mimi ambient colors. Not action or financial-state colors.
  static const mimiCyan = Color(0xFF22D3C5);
  static const mimiPurple = Color(0xFF7B67EE);
  static const mimiPink = Color(0xFFD65B9E);
}

/// DS-02 Foundations: 4 px spacing grid (DESIGN_SYSTEM.md §4).
abstract final class MimiSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xl2 = 24.0;
  static const xl3 = 32.0;
  static const xl4 = 40.0;
  static const xl5 = 48.0;

  /// Default horizontal screen inset (spaceXl).
  static const screenInset = xl;

  /// Minimum height of important interactive targets.
  static const minTouchTarget = 48.0;
}

/// DS-02 Foundations: approved corner radii (DESIGN_SYSTEM.md §5).
abstract final class MimiRadius {
  static const xs = 6.0;
  static const sm = 10.0;

  /// Buttons and standard inputs.
  static const md = 14.0;

  /// Standard banking cards.
  static const lg = 20.0;

  /// Mimi sheets / exposed panel corners.
  static const xl = 28.0;

  /// Pills, avatars and Mimi FAB.
  static const full = 999.0;
}
