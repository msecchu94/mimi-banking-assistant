import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// CARD_LIST: the customer's cards, display only.
///
/// Cards sit in a horizontal row that scrolls when they exceed the available
/// width. Selecting a card is CARD_SELECTOR's responsibility, not this one's.
class CardListView extends StatelessWidget {
  const CardListView({super.key, required this.ui});

  /// Provisional: a card takes ~72% of the conversation width, so the next
  /// one peeks in to show the row scrolls; capped so wide screens keep it
  /// compact.
  static const _widthFactor = 0.72;
  static const _maxCardWidth = 260.0;

  final CardListUi ui;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(
          constraints.maxWidth * _widthFactor,
          _maxCardWidth,
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, card) in ui.cards.indexed) ...[
                  if (index > 0) const SizedBox(width: MimiSpacing.md),
                  SizedBox(
                    width: width,
                    child: _CardTile(card: card),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  /// Provisional: a quiet 1 px `primary` outline (~24%) for the subtle teal
  /// treatment, without glow.
  static const _outline = Color(0x3D19C6B3);

  final BankCard card;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: DecoratedBox(
        // Home's elevated card tone; `surface` reads almost black on the sheet.
        decoration: BoxDecoration(
          color: MimiColors.surfaceElevated,
          border: Border.all(color: _outline),
          borderRadius: BorderRadius.circular(MimiRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MimiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cardBrandLabel(card.brand),
                style: MimiTypography.titleMedium.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
              const SizedBox(height: MimiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _TypeChip(cardTypeLabel(card.type)),
                    ),
                  ),
                  const SizedBox(width: MimiSpacing.sm),
                  Text(
                    '•••• ${card.lastFour}',
                    style: MimiTypography.labelLarge.copyWith(
                      color: MimiColors.textPrimary,
                      fontFeatures: MimiTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MimiSpacing.md),
              _Status(card.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: MimiColors.surfaceGlassStrong,
        shape: StadiumBorder(side: BorderSide(color: MimiCard.outlineColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MimiSpacing.md,
          vertical: MimiSpacing.xs,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: MimiTypography.labelMedium.copyWith(
            color: MimiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// The status always reads as text; the dot or lock only reinforces it.
class _Status extends StatelessWidget {
  const _Status(this.status);

  /// Provisional (§14.6): small status marks beside a label.
  static const _dotSize = 8.0;
  static const _iconSize = 16.0;

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CardStatus.active => MimiColors.success,
      CardStatus.frozen => MimiColors.primarySoft,
    };
    final mark = switch (status) {
      CardStatus.active => const DecoratedBox(
        decoration: BoxDecoration(
          color: MimiColors.success,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(dimension: _dotSize),
      ),
      CardStatus.frozen => Icon(
        Icons.lock_outline,
        size: _iconSize,
        color: color,
      ),
    };

    return Row(
      children: [
        ExcludeSemantics(child: mark),
        const SizedBox(width: MimiSpacing.sm),
        Flexible(
          child: Text(
            cardStatusLabel(status),
            style: MimiTypography.labelMedium.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
