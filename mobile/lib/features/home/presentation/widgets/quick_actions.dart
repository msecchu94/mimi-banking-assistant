import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';

/// Transferir / Pagar / Tarjetas. Their flows are outside FL-06.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  /// Gap between tiles.
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    // The primary action is slightly wider, as in the approved Home.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: _ActionTile(
              label: 'Transferir',
              icon: Icons.swap_horiz,
              isPrimary: true,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            flex: 10,
            child: _ActionTile(
              label: 'Pagar',
              icon: Icons.qr_code_scanner,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            flex: 10,
            child: _ActionTile(
              label: 'Tarjetas',
              icon: Icons.credit_card_outlined,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  static const _iconSize = 22.0;

  /// Resting primary surface: the same dark teal family as the secondary
  /// tiles, one step brighter, so it leads without reading as selected.
  static const _primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A4349), MimiColors.surfaceElevated],
  );

  /// Restrained teal edge (`primary` at ~35%).
  static const _primaryBorder = BorderSide(color: Color(0x5919C6B3));

  /// Barely-there accent glow (`primary` at ~12%).
  static const _primaryGlow = BoxShadow(
    color: Color(0x1F19C6B3),
    blurRadius: 12,
    offset: Offset(0, 2),
  );

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const foreground = MimiColors.textPrimary;
    // The primary icon carries the accent; labels stay neutral.
    final iconColor = isPrimary ? MimiColors.primaryBright : foreground;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MimiRadius.md),
      side: isPrimary
          ? _primaryBorder
          : const BorderSide(color: MimiCard.outlineColor),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: isPrimary ? null : MimiColors.surfaceElevated,
        gradient: isPrimary ? _primaryGradient : null,
        shadows: isPrimary ? const [_primaryGlow] : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: MimiSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MimiSpacing.sm,
                vertical: MimiSpacing.sm + 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: _iconSize, color: iconColor),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MimiTypography.labelLarge.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
