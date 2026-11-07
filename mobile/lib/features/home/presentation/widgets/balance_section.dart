import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';

class BalanceSection extends StatelessWidget {
  const BalanceSection({
    super.key,
    required this.currency,
    required this.balance,
    required this.isHidden,
    required this.onToggleVisibility,
  });

  static const hiddenBalance = r'$ ••••••';

  final String currency;
  final String balance;
  final bool isHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final amountStyle = MimiTypography.displayLarge.copyWith(
      color: MimiColors.textPrimary,
      fontFeatures: MimiTypography.tabularFigures,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The visibility control sits next to the label it acts on.
        Row(
          children: [
            Flexible(
              child: Text(
                'Saldo disponible · $currency',
                style: MimiTypography.bodyMedium.copyWith(
                  color: MimiColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: MimiSpacing.xs),
            _VisibilityToggle(
              isHidden: isHidden,
              onPressed: onToggleVisibility,
            ),
          ],
        ),
        // The balance keeps displayLarge on common widths. It only scales
        // down when it cannot fit on one line (very narrow widths or large
        // text scales), so digits are never wrapped or truncated.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: isHidden
              ? Semantics(
                  label: 'Saldo oculto',
                  excludeSemantics: true,
                  child: Text(hiddenBalance, style: amountStyle),
                )
              : Text(balance, style: amountStyle),
        ),
      ],
    );
  }
}

/// A compact pill that stays secondary to the balance, while its
/// interactive area keeps the 48 px minimum touch target.
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.isHidden, required this.onPressed});

  static const _pillSize = Size(40, 30);
  static const _iconSize = 18.0;

  final bool isHidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isHidden ? 'Mostrar saldo' : 'Ocultar saldo',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: MimiSpacing.minTouchTarget,
          child: Center(
            child: Material(
              color: MimiColors.surfaceElevated,
              shape: const StadiumBorder(
                side: BorderSide(color: MimiCard.outlineColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox.fromSize(
                  size: _pillSize,
                  child: Icon(
                    isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: _iconSize,
                    color: MimiColors.textSecondary,
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
