import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../../domain/models/money.dart';
import '../../formatting/chat_formatting.dart';

/// Presentational pieces shared by the transfer results. Each result decides
/// its own content and accent.

/// The result's surface: Home's elevated tone, outlined and lit from the
/// top-left in the result's [accent].
class TransferResultFrame extends StatelessWidget {
  const TransferResultFrame({
    super.key,
    required this.accent,
    required this.child,
  });

  /// Provisional (§14.6): the accent's outline and glow, kept quiet.
  static const _outlineAlpha = 0.8;
  static const _glowAlpha = 0.22;
  static const _outlineWidth = 1.5;

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(MimiRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MimiColors.surfaceElevated,
        border: Border.all(
          color: accent.withValues(alpha: _outlineAlpha),
          width: _outlineWidth,
        ),
        borderRadius: radius,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              accent.withValues(alpha: _glowAlpha),
              accent.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MimiSpacing.xl),
          child: child,
        ),
      ),
    );
  }
}

/// The result's mark, title and amount, centred.
class TransferResultHeading extends StatelessWidget {
  const TransferResultHeading({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.amount,
  });

  /// Provisional (§14.6): the result mark reads at a glance.
  static const _iconSize = 48.0;

  final IconData icon;
  final Color accent;
  final String title;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: _iconSize, color: accent),
        ),
        const SizedBox(height: MimiSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: MimiTypography.titleLarge.copyWith(
            color: MimiColors.textPrimary,
          ),
        ),
        const SizedBox(height: MimiSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatMoney(amount),
            maxLines: 1,
            style: MimiTypography.displayLarge.copyWith(
              color: MimiColors.textPrimary,
              fontFeatures: MimiTypography.tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}

/// Beneficiary, execution time and operation reference, between dividers.
class TransferDetails extends StatelessWidget {
  const TransferDetails({super.key, required this.transfer});

  final TransferSummaryUi transfer;

  @override
  Widget build(BuildContext context) {
    const divider = Divider(
      height: 1,
      thickness: 1,
      color: MimiCard.outlineColor,
    );
    final rows = [
      (Icons.person_outline, 'Destinatario', transfer.beneficiary),
      (
        Icons.calendar_today_outlined,
        'Fecha',
        dateTimeLabel(transfer.executedAt),
      ),
      (
        Icons.confirmation_number_outlined,
        'Operación',
        shortReferenceLabel(transfer.transferId),
      ),
    ];

    return Column(
      children: [
        for (final (icon, label, value) in rows) ...[
          divider,
          _DetailRow(icon: icon, label: label, value: value),
        ],
        divider,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  /// Provisional (§14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MimiSpacing.md),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: _iconSize,
                color: MimiColors.textSecondary,
              ),
            ),
            const SizedBox(width: MimiSpacing.md),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MimiTypography.labelLarge.copyWith(
                  color: MimiColors.textPrimary,
                  fontFeatures: MimiTypography.tabularFigures,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
