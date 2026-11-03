import 'package:flutter/material.dart';

import '../mimi_tokens.dart';

/// DS-03 Icon Button: a compact icon action with an accessible label.
class MimiIconButton extends StatelessWidget {
  const MimiIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  /// Provisional (DESIGN_SYSTEM.md §14.6): a 20 px Material icon renders a
  /// glyph close to the 16 px placeholder geometry of DS-03.
  static const _iconSize = 20.0;

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: MimiColors.surface,
        borderRadius: BorderRadius.circular(MimiRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: MimiSpacing.minTouchTarget,
            child: Icon(icon, size: _iconSize, color: MimiColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
