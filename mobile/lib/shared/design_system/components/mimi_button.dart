import 'package:flutter/material.dart';

import '../mimi_tokens.dart';
import '../mimi_typography.dart';

/// Button variants used so far (DS-03 Button).
enum MimiButtonVariant {
  /// Filled with `primary`: the main action of a group.
  primary,

  /// Solid `surface` fill: secondary actions next to a primary one.
  secondary,

  /// No fill, `primary` label: low-emphasis inline actions.
  text,
}

/// DS-03 Button: an explicit action with an editable label, an optional
/// [icon] shown above it and an optional [trailingIcon] after it.
///
/// The visible geometry always preserves the 48 px interactive target.
class MimiButton extends StatelessWidget {
  const MimiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MimiButtonVariant.primary,
    this.icon,
    this.trailingIcon,
  });

  /// Provisional (DESIGN_SYSTEM.md §14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  /// Provisional (§14.6): sized to sit on the label's x-height.
  static const _trailingIconSize = 18.0;

  final String label;
  final VoidCallback onPressed;
  final MimiButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final (fill, foreground) = switch (variant) {
      MimiButtonVariant.primary => (MimiColors.primary, MimiColors.background),
      MimiButtonVariant.secondary => (
        MimiColors.surfaceElevated,
        MimiColors.textPrimary,
      ),
      MimiButtonVariant.text => (Colors.transparent, MimiColors.primary),
    };
    // Provisional: DS-03 horizontal padding is not documented. Filled labels
    // are centred, so their inset is only a minimum and stays small enough
    // for three buttons to share a 320 px row. The text variant has no fill;
    // its inset positions the label as in DS-04, tightened when a trailing
    // icon (whose glyph carries its own side bearing) follows the label.
    final horizontalPadding =
        variant == MimiButtonVariant.text && this.trailingIcon == null
        ? MimiSpacing.lg
        : MimiSpacing.sm;
    // Labels keep their approved style; on widths too narrow for them they
    // truncate rather than wrap or shrink.
    final label = Text(
      this.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: MimiTypography.labelLarge.copyWith(color: foreground),
    );
    final trailingIcon = this.trailingIcon;
    final text = trailingIcon == null
        ? label
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: label),
              Icon(trailingIcon, size: _trailingIconSize, color: foreground),
            ],
          );
    final icon = this.icon;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(MimiRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MimiSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: icon == null ? 0 : MimiSpacing.md,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: icon == null
                  ? text
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: _iconSize, color: foreground),
                        const SizedBox(height: MimiSpacing.xs),
                        text,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
