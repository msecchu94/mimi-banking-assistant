import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/components/mimi_list_item.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// TRANSACTION_LIST: the transactions the backend selected, in its order.
///
/// One solid surface with quiet dividers, as on Home. Display only; nothing
/// is filtered, sorted or calculated here.
class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key, required this.ui});

  final TransactionListUi ui;

  @override
  Widget build(BuildContext context) {
    return MimiCard(
      variant: MimiCardVariant.elevated,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, transaction) in ui.transactions.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: MimiSpacing.lg,
                endIndent: MimiSpacing.lg,
                color: MimiCard.outlineColor,
              ),
            _TransactionRow(transaction: transaction),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;

    return MergeSemantics(
      child: MimiListItem(
        leading: _CategoryIcon(transaction.category),
        title: transaction.description,
        // Descriptions are long; two lines keep them readable on narrow
        // screens.
        titleMaxLines: 2,
        description: categoryLabel(transaction.category),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              // Direction is stated by the sign, never by color alone.
              transactionAmountLabel(transaction),
              style: MimiTypography.labelLarge.copyWith(
                color: isCredit ? MimiColors.success : MimiColors.textPrimary,
                fontFeatures: MimiTypography.tabularFigures,
              ),
            ),
            const SizedBox(height: MimiSpacing.xs),
            Text(
              shortDateLabel(transaction.occurredAt),
              style: MimiTypography.caption.copyWith(
                color: MimiColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The category's mark; it restates the category label and nothing more.
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon(this.category);

  /// Provisional (§14.6), as in MimiIconButton.
  static const _iconSize = 20.0;
  static const _tileSize = MimiSpacing.xl4;

  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      TransactionCategory.groceries => Icons.shopping_cart_outlined,
      TransactionCategory.dining => Icons.restaurant_outlined,
      TransactionCategory.transport => Icons.directions_bus_outlined,
      TransactionCategory.fuel => Icons.local_gas_station_outlined,
      TransactionCategory.utilities => Icons.receipt_long_outlined,
      TransactionCategory.subscriptions => Icons.autorenew,
      TransactionCategory.entertainment => Icons.movie_outlined,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.transfer => Icons.swap_horiz,
      TransactionCategory.other => Icons.category_outlined,
    };

    return ExcludeSemantics(
      child: DecoratedBox(
        // Mimi's glass tone, a step above the elevated list, so the tile does
        // not read as a dark hole on the sheet.
        decoration: BoxDecoration(
          color: MimiColors.surfaceGlassStrong,
          border: Border.all(color: MimiCard.outlineColor),
          borderRadius: BorderRadius.circular(MimiRadius.md),
        ),
        child: SizedBox.square(
          dimension: _tileSize,
          child: Icon(icon, size: _iconSize, color: MimiColors.primarySoft),
        ),
      ),
    );
  }
}
