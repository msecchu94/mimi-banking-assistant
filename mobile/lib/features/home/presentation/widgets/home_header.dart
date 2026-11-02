import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_icon_button.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    required this.accountDescription,
  });

  final String firstName;
  final String accountDescription;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $firstName',
                style: MimiTypography.titleLarge.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
              const SizedBox(height: MimiSpacing.xs),
              Text(
                accountDescription,
                style: MimiTypography.labelMedium.copyWith(
                  color: MimiColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: MimiSpacing.md),
        // The profile destination is outside FL-06.
        MimiIconButton(
          icon: Icons.person_outline,
          semanticLabel: 'Perfil',
          onPressed: () {},
        ),
      ],
    );
  }
}
