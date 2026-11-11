import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/components/mimi_card.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';
import '../../../chat/domain/models/chat_ui.dart';
import '../home_view_data.dart';

/// DS-04 recent transactions, reproduced as approved (refinement is DS-05).
///
/// Rows are identified by transaction id. When [transactions] changes, a row
/// that is new enters, a row that is gone exits, and the rows in between
/// move as the space around them grows and shrinks, together in one
/// [transition]. The list shown is always the one given; rows that are
/// already shown never animate again.
class RecentTransactions extends StatefulWidget {
  const RecentTransactions({super.key, required this.transactions});

  /// How long rows take to enter, exit and move.
  static const transition = Duration(milliseconds: 300);

  final List<HomeTransaction> transactions;

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

/// A shown row. [presence] is 1 while the row is in the list; it runs to 1
/// as the row enters and to 0 as it exits.
class _Row {
  _Row(this.transaction, this.presence);

  HomeTransaction transaction;
  final AnimationController presence;

  bool get isExiting =>
      presence.status == AnimationStatus.reverse ||
      presence.status == AnimationStatus.dismissed;
}

class _RecentTransactionsState extends State<RecentTransactions>
    with TickerProviderStateMixin {
  /// The given transactions in order, plus any rows still exiting.
  late List<_Row> _rows = [
    for (final transaction in widget.transactions)
      _Row(transaction, _presence(value: 1)),
  ];

  AnimationController _presence({required double value}) => AnimationController(
    vsync: this,
    duration: RecentTransactions.transition,
    value: value,
  );

  @override
  void didUpdateWidget(RecentTransactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(widget.transactions, oldWidget.transactions)) return;

    final shown = {for (final row in _rows) row.transaction.id: row};
    final current = [
      for (final transaction in widget.transactions)
        if (shown[transaction.id] case final row?)
          row..transaction = transaction
        else
          _Row(transaction, _presence(value: 0)),
    ];

    // A row that is no longer given exits where it was: after the row it
    // followed.
    final next = [...current];
    for (final (index, row) in _rows.indexed) {
      if (current.contains(row)) continue;
      next.insert(index == 0 ? 0 : next.indexOf(_rows[index - 1]) + 1, row);
      if (!row.isExiting) _exit(row);
    }
    // New rows enter; a row given again while exiting returns.
    for (final row in current) {
      if (row.presence.status != AnimationStatus.completed) {
        row.presence.forward();
      }
    }
    _rows = next;
  }

  void _exit(_Row row) {
    // Completes only if the row is not given again before it is gone.
    row.presence.reverse().then((_) {
      if (!mounted) return;
      setState(() => _rows.remove(row));
      row.presence.dispose();
    });
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.presence.dispose();
    }
    super.dispose();
  }

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
          child: widget.transactions.isEmpty
              ? const _NoTransactions()
              : Column(
                  children: [
                    for (final (index, row) in _rows.indexed)
                      _AnimatedRow(
                        key: ValueKey(row.transaction.id),
                        presence: row.presence,
                        isExiting: row.isExiting,
                        hasDivider: index > 0,
                        child: _TransactionRow(transaction: row.transaction),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A row that takes its space as it enters and gives it up as it exits, so
/// the rows around it move to their new positions. It fades in moving down
/// from slightly above, and fades out moving slightly down.
class _AnimatedRow extends StatelessWidget {
  const _AnimatedRow({
    super.key,
    required this.presence,
    required this.isExiting,
    required this.hasDivider,
    required this.child,
  });

  static const _drift = Offset(0, 0.2);

  final Animation<double> presence;
  final bool isExiting;
  final bool hasDivider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = presence.drive(CurveTween(curve: Curves.easeInOutCubic));
    return ExcludeSemantics(
      excluding: isExiting,
      child: SizeTransition(
        sizeFactor: animation,
        alignment: AlignmentDirectional.topStart,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween(begin: isExiting ? _drift : -_drift, end: Offset.zero),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [if (hasDivider) const _RowDivider(), child],
            ),
          ),
        ),
      ),
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

class _NoTransactions extends StatelessWidget {
  const _NoTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MimiSpacing.lg),
      child: Text(
        'Todavía no tenés movimientos.',
        style: MimiTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: MimiColors.textSecondary,
        ),
      ),
    );
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
      TransactionCategory.groceries => Icons.shopping_cart_outlined,
      TransactionCategory.transfer => Icons.swap_horiz,
      TransactionCategory.utilities ||
      TransactionCategory.subscriptions => Icons.receipt_long_outlined,
      TransactionCategory.dining => Icons.restaurant_outlined,
      TransactionCategory.transport => Icons.directions_bus_outlined,
      TransactionCategory.fuel => Icons.local_gas_station_outlined,
      TransactionCategory.entertainment => Icons.movie_outlined,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.other => Icons.payments_outlined,
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
