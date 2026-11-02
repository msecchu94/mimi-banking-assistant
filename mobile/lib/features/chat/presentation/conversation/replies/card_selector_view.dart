import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/components/mimi_list_item.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// CARD_SELECTOR: the cards the pending operation may use.
///
/// Rows are selectable only while [actionable]; otherwise they are history.
class CardSelectorView extends StatelessWidget {
  const CardSelectorView({
    super.key,
    required this.ui,
    required this.actionable,
    required this.onSelect,
  });

  final CardSelectorUi ui;
  final bool actionable;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return MimiCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, card) in ui.cards.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: MimiSpacing.lg,
                endIndent: MimiSpacing.lg,
                color: MimiCard.outlineColor,
              ),
            _CardRow(
              card: card,
              onTap: actionable ? () => onSelect(card.id) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.onTap});

  final BankCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final row = MimiListItem(
      title: cardLabel(card),
      description: cardStatusLabel(card.status),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: MimiColors.primary),
    );
    if (onTap == null) return row;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MimiRadius.lg),
        child: row,
      ),
    );
  }
}
