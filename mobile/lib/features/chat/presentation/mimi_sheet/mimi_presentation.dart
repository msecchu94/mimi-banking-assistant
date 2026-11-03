import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';

/// Mimi's introduction at the top of the sheet, over a static nebula.
class MimiPresentation extends StatelessWidget {
  const MimiPresentation({super.key});

  /// Provisional: a quiet 1 px `primary` outline (~40%) around the ✦ mark,
  /// instead of a glow (DESIGN_SYSTEM.md §8 reserves glow for emphasis).
  static const _markOutline = BorderSide(color: Color(0x6619C6B3));
  static const _markSize = MimiSpacing.xl5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: IgnorePointer(child: _StaticNebula())),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MimiSpacing.screenInset,
            0,
            MimiSpacing.screenInset,
            MimiSpacing.xl2,
          ),
          child: Column(
            children: [
              DecoratedBox(
                decoration: const ShapeDecoration(
                  color: MimiColors.surfaceElevated,
                  shape: CircleBorder(side: _markOutline),
                ),
                child: SizedBox.square(
                  dimension: _markSize,
                  child: Center(
                    child: Text(
                      '✦',
                      style: MimiTypography.titleLarge.copyWith(
                        color: MimiColors.primaryBright,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MimiSpacing.sm),
              Text(
                'Mimi',
                style: MimiTypography.headlineMedium.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
              const SizedBox(height: MimiSpacing.xs),
              Text(
                '¿En qué puedo ayudarte hoy?',
                textAlign: TextAlign.center,
                style: MimiTypography.titleMedium.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
              const SizedBox(height: MimiSpacing.sm),
              Text(
                'Consultá tus cuentas, movimientos, gastos y tarjetas, '
                'o hacé transferencias.',
                textAlign: TextAlign.center,
                style: MimiTypography.bodyMedium.copyWith(
                  color: MimiColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Mimi Dynamic Nebula's static specimen (DESIGN_SYSTEM.md §9, §14.5):
/// three heavily blurred masses, dominant cyan, secondary violet and a
/// limited pink accent. Motion is deferred.
class _StaticNebula extends StatelessWidget {
  const _StaticNebula();

  /// Provisional (§14.5): ~72 px blur and mass opacities of ~24% / 18% / 12%.
  static const _blurSigma = 36.0;
  static const _cyan = Color(0x3D22D3C5);
  static const _violet = Color(0x2E7B67EE);
  static const _pink = Color(0x1FD65B9E);

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
      child: const Stack(
        children: [
          Align(
            alignment: Alignment(-0.9, -0.2),
            child: _Mass(color: _cyan, size: 160),
          ),
          Align(
            alignment: Alignment(0.9, -0.3),
            child: _Mass(color: _violet, size: 140),
          ),
          Align(
            alignment: Alignment(0.5, 0.6),
            child: _Mass(color: _pink, size: 90),
          ),
        ],
      ),
    );
  }
}

class _Mass extends StatelessWidget {
  const _Mass({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: size),
    );
  }
}
