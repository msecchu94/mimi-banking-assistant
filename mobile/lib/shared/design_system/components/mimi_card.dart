import 'package:flutter/widgets.dart';

import '../mimi_tokens.dart';

/// DS-03 Card variants used so far.
enum MimiCardVariant {
  /// Default structural banking container on `surface`.
  base,

  /// Stronger hierarchy: `surfaceElevated` with a quiet outline.
  elevated,
}

/// DS-03 Card: a solid banking container.
///
/// Its height follows its content.
class MimiCard extends StatelessWidget {
  const MimiCard({
    super.key,
    required this.child,
    this.variant = MimiCardVariant.base,
    this.padding = const EdgeInsets.all(MimiSpacing.lg),
  });

  /// Provisional (DESIGN_SYSTEM.md §14.1): 1 px outline of `textPrimary` at
  /// ~6%, separating the elevated surface from the background.
  static const outlineColor = Color(0x0FF4F8F8);

  final Widget child;
  final MimiCardVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final elevated = variant == MimiCardVariant.elevated;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: elevated ? MimiColors.surfaceElevated : MimiColors.surface,
        border: elevated ? Border.all(color: outlineColor) : null,
        borderRadius: BorderRadius.circular(MimiRadius.lg),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
