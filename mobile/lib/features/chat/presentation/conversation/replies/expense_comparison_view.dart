import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../../domain/models/money.dart';
import '../../formatting/chat_formatting.dart';

/// EXPENSE_COMPARISON: backend-calculated totals of two periods, one block
/// per currency. The direction is the backend's `change`; nothing is
/// compared, converted or calculated here.
class ExpenseComparisonView extends StatelessWidget {
  const ExpenseComparisonView({super.key, required this.ui});

  final ExpenseComparisonUi ui;

  @override
  Widget build(BuildContext context) {
    final category = ui.category;
    final (currentLabel, previousLabel) = comparisonPeriodLabels(
      ui.currentPeriod,
      ui.previousPeriod,
    );

    return MimiCard(
      variant: MimiCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            category == null
                ? 'Comparación de gastos'
                : 'Gastos en ${categoryLabel(category)}',
            style: MimiTypography.labelMedium.copyWith(
              color: MimiColors.textSecondary,
            ),
          ),
          if (ui.currencies.isEmpty) ...[
            const SizedBox(height: MimiSpacing.sm),
            Text(
              'No registramos gastos en estos períodos.',
              style: MimiTypography.bodyMedium.copyWith(
                color: MimiColors.textPrimary,
              ),
            ),
          ],
          for (final (index, comparison) in ui.currencies.indexed) ...[
            if (index > 0) ...[
              const SizedBox(height: MimiSpacing.lg),
              const Divider(
                height: 1,
                thickness: 1,
                color: MimiCard.outlineColor,
              ),
            ],
            const SizedBox(height: MimiSpacing.md),
            _CurrencyComparison(
              comparison: comparison,
              currentLabel: currentLabel,
              previousLabel: previousLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrencyComparison extends StatelessWidget {
  const _CurrencyComparison({
    required this.comparison,
    required this.currentLabel,
    required this.previousLabel,
  });

  final CurrencyComparison comparison;
  final String currentLabel;
  final String previousLabel;

  @override
  Widget build(BuildContext context) {
    final current = _cents(comparison.currentTotal);
    final previous = _cents(comparison.previousTotal);
    // Bars only restate the two totals, scaled to the larger one.
    final scale = current > previous ? current : previous;
    double share(int total) => scale == 0 ? 0 : total / scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodTotal(
          label: currentLabel,
          total: comparison.currentTotal,
          share: share(current),
          barColor: MimiColors.primary,
        ),
        const SizedBox(height: MimiSpacing.md),
        _PeriodTotal(
          label: previousLabel,
          total: comparison.previousTotal,
          share: share(previous),
          barColor: MimiColors.textMuted,
        ),
        const SizedBox(height: MimiSpacing.md),
        _Change(comparison: comparison),
      ],
    );
  }

  /// The backend's two-decimal amount in cents, for the bar lengths only.
  static int _cents(Money money) {
    final cents = int.parse(money.amount.replaceFirst('.', ''));
    return cents < 0 ? 0 : cents;
  }
}

class _PeriodTotal extends StatelessWidget {
  const _PeriodTotal({
    required this.label,
    required this.total,
    required this.share,
    required this.barColor,
  });

  /// Provisional (§14.6): a thin bar, quiet beside the amounts.
  static const _barHeight = 6.0;

  final String label;
  final Money total;
  final double share;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: MimiTypography.bodyMedium.copyWith(
                    color: MimiColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: MimiSpacing.md),
              Text(
                formatMoney(total),
                style: MimiTypography.labelLarge.copyWith(
                  color: MimiColors.textPrimary,
                  fontFeatures: MimiTypography.tabularFigures,
                ),
              ),
            ],
          ),
          const SizedBox(height: MimiSpacing.xs),
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MimiRadius.full),
              child: SizedBox(
                height: _barHeight,
                child: ColoredBox(
                  color: MimiCard.outlineColor,
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: share.clamp(0, 1),
                    child: ColoredBox(color: barColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The backend's direction, always in words; the arrow only reinforces it.
class _Change extends StatelessWidget {
  const _Change({required this.comparison});

  /// Provisional (§14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final CurrencyComparison comparison;

  @override
  Widget build(BuildContext context) {
    final difference = formatMoney(comparison.difference);
    // Fewer expenses are good news; more call for attention, not alarm.
    final (icon, text, color) = switch (comparison.change) {
      ExpenseChange.decrease => (
        Icons.arrow_downward,
        '$difference menos',
        MimiColors.success,
      ),
      ExpenseChange.increase => (
        Icons.arrow_upward,
        '$difference más',
        MimiColors.warning,
      ),
      ExpenseChange.unchanged => (
        Icons.horizontal_rule,
        'Sin cambios',
        MimiColors.textSecondary,
      ),
    };

    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: _iconSize, color: color),
        ),
        const SizedBox(width: MimiSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: MimiTypography.titleMedium.copyWith(
              color: color,
              fontFeatures: MimiTypography.tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}
