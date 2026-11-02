import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';
import '../home_mock_data.dart';

/// The savings account the Home summarises, on a solid banking surface.
class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key, required this.account});

  /// Provisional (DESIGN_SYSTEM.md §14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final HomeAccountSummary account;

  @override
  Widget build(BuildContext context) {
    return MimiCard(
      variant: MimiCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Provisional: a 40 px (spaceXl4) leading container, inset on
              // `surface` below the elevated card; DS-03 List Item allows a
              // leading container but does not size it.
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: MimiColors.surface,
                  borderRadius: BorderRadius.all(
                    Radius.circular(MimiRadius.md),
                  ),
                ),
                child: SizedBox.square(
                  dimension: MimiSpacing.xl4,
                  child: Icon(
                    Icons.account_balance_outlined,
                    size: _iconSize,
                    color: MimiColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: MimiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.title,
                      style: MimiTypography.titleMedium.copyWith(
                        color: MimiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: MimiSpacing.xs),
                    Text(
                      account.status,
                      style: MimiTypography.labelMedium.copyWith(
                        color: MimiColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MimiSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alias de tu cuenta',
                      style: MimiTypography.caption.copyWith(
                        color: MimiColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: MimiSpacing.xs),
                    Text(
                      account.alias,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MimiTypography.bodyMedium.copyWith(
                        color: MimiColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Account details are outside FL-06.
              MimiButton(
                label: 'Ver datos',
                variant: MimiButtonVariant.text,
                trailingIcon: Icons.chevron_right,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
