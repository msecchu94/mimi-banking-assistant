import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_icon_button.dart';
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
            const SizedBox(width: MimiSpacing.sm),
            MimiIconButton(
              icon: isHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              semanticLabel: isHidden ? 'Mostrar saldo' : 'Ocultar saldo',
              onPressed: onToggleVisibility,
            ),
          ],
        ),
        const SizedBox(height: MimiSpacing.xs),
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
