import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// EXPENSE_SUMMARY: backend-calculated expenses for one period, one block per
/// currency. Nothing is computed here.
class ExpenseSummaryView extends StatelessWidget {
  const ExpenseSummaryView({super.key, required this.ui});

  final ExpenseSummaryUi ui;

  @override
  Widget build(BuildContext context) {
    final amountStyle = MimiTypography.labelLarge.copyWith(
      color: MimiColors.textPrimary,
      fontFeatures: MimiTypography.tabularFigures,
    );

    return MimiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos · ${periodLabel(ui.period)}',
            style: MimiTypography.labelMedium.copyWith(
              color: MimiColors.textSecondary,
            ),
          ),
          if (ui.currencies.isEmpty) ...[
            const SizedBox(height: MimiSpacing.sm),
            Text(
              'No registramos gastos en este período.',
              style: MimiTypography.bodyMedium.copyWith(
                color: MimiColors.textPrimary,
              ),
            ),
          ],
          for (final expenses in ui.currencies) ...[
            const SizedBox(height: MimiSpacing.sm),
            Text(
              formatMoney(expenses.total),
              style: MimiTypography.displayLarge.copyWith(
                color: MimiColors.textPrimary,
                fontFeatures: MimiTypography.tabularFigures,
              ),
            ),
            for (final category in expenses.categories) ...[
              const SizedBox(height: MimiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      categoryLabel(category.category),
                      style: MimiTypography.bodyMedium.copyWith(
                        color: MimiColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: MimiSpacing.md),
                  Text(formatMoney(category.amount), style: amountStyle),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
