import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../mimi_tokens.dart';
import '../mimi_typography.dart';

/// DS-03 Mimi FAB: the labelled "✦ Mimi" entry point into Mimi.
///
/// Uses the Ambient Glass material (`surfaceGlass`) so content scrolling
/// beneath it stays perceptible, plus the restrained Mimi glow.
class MimiFab extends StatelessWidget {
  const MimiFab({super.key, required this.onPressed});

  /// Provisional glow (DESIGN_SYSTEM.md §14.4): `primary` at ~30%, 24 px
  /// blur, no offset or spread. Scoped to this component; not a global token.
  static const _glow = BoxShadow(color: Color(0x4D19C6B3), blurRadius: 24);

  /// Provisional glass recipe (DESIGN_SYSTEM.md §14.1, §14.3): ~24 px
  /// background blur and a 1 px `mimiCyan` border at ~40%, the subtle cyan
  /// edge that marks Mimi's entry point.
  static const _blurSigma = 12.0;
  static const _border = BorderSide(color: Color(0x6622D3C5));

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const shape = StadiumBorder(side: _border);

    return DecoratedBox(
      decoration: const ShapeDecoration(shape: shape, shadows: [_glow]),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: Material(
            color: MimiColors.surfaceGlass,
            shape: shape,
            child: InkWell(
              onTap: onPressed,
              customBorder: shape,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: MimiSpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MimiSpacing.xl,
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      '✦ Mimi',
                      style: MimiTypography.titleMedium.copyWith(
                        color: MimiColors.primaryBright,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
