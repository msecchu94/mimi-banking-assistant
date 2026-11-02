import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_button.dart';
import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// CONFIRMATION: a pre-validated operation and the backend's actions.
///
/// The actions are rendered only while [actionable]; pressing one sends the
/// structured interaction, it never authorizes anything locally.
class ConfirmationView extends StatelessWidget {
  const ConfirmationView({
    super.key,
    required this.ui,
    required this.actionable,
    required this.onConfirm,
    required this.onCancel,
  });

  final ConfirmationUi ui;
  final bool actionable;
  final ValueChanged<String> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final details = switch (ui.summary) {
      TransferConfirmationSummary(:final amount, :final beneficiary) => [
        ('Monto', formatMoney(amount)),
        ('Destinatario', beneficiary),
      ],
      CardConfirmationSummary(:final card) => [('Tarjeta', cardLabel(card))],
    };

    return MimiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ui.title,
            style: MimiTypography.titleMedium.copyWith(
              color: MimiColors.textPrimary,
            ),
          ),
          for (final (label, value) in details) ...[
            const SizedBox(height: MimiSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: MimiTypography.bodyMedium.copyWith(
                    color: MimiColors.textSecondary,
                  ),
                ),
                const SizedBox(width: MimiSpacing.md),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: MimiTypography.labelLarge.copyWith(
                      color: MimiColors.textPrimary,
                      fontFeatures: MimiTypography.tabularFigures,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (actionable && ui.actions.isNotEmpty) ...[
            const SizedBox(height: MimiSpacing.lg),
            Row(
              children: [
                for (final (index, action) in ui.actions.indexed) ...[
                  if (index > 0) const SizedBox(width: MimiSpacing.sm),
                  Expanded(
                    child: switch (action.type) {
                      ConfirmationActionType.confirm => MimiButton(
                        label: action.label,
                        onPressed: () => onConfirm(ui.operationId),
                      ),
                      ConfirmationActionType.cancel => MimiButton(
                        label: action.label,
                        variant: MimiButtonVariant.secondary,
                        onPressed: onCancel,
                      ),
                    },
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
