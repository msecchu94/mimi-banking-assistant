import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';
import '../home_mock_data.dart';

/// DS-04 recent transactions, reproduced as approved (refinement is DS-05).
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key, required this.transactions});

  final List<HomeTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Movimientos',
                style: MimiTypography.titleMedium.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
            ),
            // The full transaction list is outside FL-06.
            MimiButton(
              label: 'Ver todos',
              variant: MimiButtonVariant.text,
              trailingIcon: Icons.chevron_right,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: MimiSpacing.xs),
        // One solid banking surface; rows are separated by quiet dividers.
        MimiCard(
          variant: MimiCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, transaction) in transactions.indexed) ...[
                if (index > 0) const _RowDivider(),
                _TransactionRow(transaction: transaction),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// DS-03 Divider construction: 1 px (provisional, DESIGN_SYSTEM.md §14.1),
/// spanning the card, in the same quiet tone as the card outline.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: MimiCard.outlineColor);
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  static const _iconSize = 22.0;
  static const _iconSlot = 24.0;

  final HomeTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final icon = switch (transaction.category) {
      HomeTransactionCategory.groceries => Icons.shopping_cart_outlined,
      HomeTransactionCategory.transfer => Icons.swap_horiz,
      HomeTransactionCategory.services => Icons.receipt_long_outlined,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: MimiSpacing.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MimiSpacing.lg,
          vertical: MimiSpacing.sm + 2,
        ),
        child: Row(
          children: [
            // The icon restates the category; title and detail carry it.
            ExcludeSemantics(
              child: SizedBox(
                width: _iconSlot,
                child: Icon(
                  icon,
                  size: _iconSize,
                  color: isCredit ? MimiColors.success : MimiColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: MimiSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MimiTypography.labelLarge.copyWith(
                      color: MimiColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MimiTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w400,
                      color: MimiColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MimiSpacing.md),
            Text(
              // Direction is stated by the sign, never by color alone.
              '${isCredit ? '+' : '−'} ${transaction.amount}',
              style: MimiTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isCredit ? MimiColors.success : MimiColors.textPrimary,
                fontFeatures: MimiTypography.tabularFigures,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
