import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/components/mimi_list_item.dart';
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
        const SizedBox(height: MimiSpacing.sm),
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
/// inset to the row content, in the same quiet tone as the card outline.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: MimiSpacing.lg,
      endIndent: MimiSpacing.lg,
      color: MimiCard.outlineColor,
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final HomeTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return MimiListItem(
      title: transaction.title,
      description: transaction.detail,
      trailing: Text(
        // Direction is stated by the sign, never by color alone.
        '${isCredit ? '+' : '−'} ${transaction.amount}',
        style: MimiTypography.labelLarge.copyWith(
          color: isCredit ? MimiColors.success : MimiColors.textPrimary,
          fontFeatures: MimiTypography.tabularFigures,
        ),
      ),
    );
  }
}
