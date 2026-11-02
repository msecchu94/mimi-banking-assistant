import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/mimi_tokens.dart';

/// Transferir / Pagar / Tarjetas. Their flows are outside FL-06.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MimiButton(
            label: 'Transferir',
            icon: Icons.swap_horiz,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: MimiSpacing.sm),
        Expanded(
          child: MimiButton(
            label: 'Pagar',
            icon: Icons.qr_code_scanner,
            variant: MimiButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: MimiSpacing.sm),
        Expanded(
          child: MimiButton(
            label: 'Tarjetas',
            icon: Icons.credit_card_outlined,
            variant: MimiButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
