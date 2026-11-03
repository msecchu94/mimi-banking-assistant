import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/mimi_card.dart';
import '../../../../../shared/design_system/components/mimi_list_item.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../../../shared/design_system/mimi_typography.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';

/// BENEFICIARY_LIST: the saved beneficiaries the backend returned, in its
/// order.
///
/// One solid surface with quiet dividers, like TRANSACTION_LIST. Display
/// only: choosing a beneficiary belongs to an explicit transfer flow.
class BeneficiaryListView extends StatelessWidget {
  const BeneficiaryListView({super.key, required this.ui});

  final BeneficiaryListUi ui;

  @override
  Widget build(BuildContext context) {
    const divider = Divider(
      height: 1,
      thickness: 1,
      indent: MimiSpacing.lg,
      endIndent: MimiSpacing.lg,
      color: MimiCard.outlineColor,
    );

    return MimiCard(
      variant: MimiCardVariant.elevated,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // An empty list is the header alone; the backend message explains it.
          _Header(count: ui.beneficiaries.length),
          for (final beneficiary in ui.beneficiaries) ...[
            divider,
            _BeneficiaryRow(beneficiary: beneficiary),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  /// Provisional (§14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final int count;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(MimiSpacing.lg),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.groups_outlined,
                size: _iconSize,
                color: MimiColors.primary,
              ),
            ),
            const SizedBox(width: MimiSpacing.sm),
            Expanded(
              child: Text(
                'Destinatarios',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MimiTypography.titleMedium.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: MimiSpacing.sm),
            DecoratedBox(
              decoration: const ShapeDecoration(
                color: MimiColors.surfaceGlassStrong,
                shape: StadiumBorder(
                  side: BorderSide(color: MimiCard.outlineColor),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MimiSpacing.md,
                  vertical: MimiSpacing.xs,
                ),
                child: Text(
                  '$count',
                  style: MimiTypography.labelMedium.copyWith(
                    color: MimiColors.textSecondary,
                    fontFeatures: MimiTypography.tabularFigures,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeneficiaryRow extends StatelessWidget {
  const _BeneficiaryRow({required this.beneficiary});

  final Beneficiary beneficiary;

  @override
  Widget build(BuildContext context) {
    final account = accountReferenceLabel(beneficiary.accountReference);
    final bankName = beneficiary.bankName;

    return MergeSemantics(
      child: MimiListItem(
        leading: _Initials(beneficiaryInitials(beneficiary.name)),
        title: beneficiary.name,
        // No bank reads as the account alone, never as a placeholder.
        description: bankName == null ? account : '$bankName · $account',
      ),
    );
  }
}

/// The beneficiary's initials; they restate the name and nothing more.
class _Initials extends StatelessWidget {
  const _Initials(this.initials);

  static const _tileSize = MimiSpacing.xl4;

  final String initials;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      // The same glass tile as TRANSACTION_LIST's category icons.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MimiColors.surfaceGlassStrong,
          border: Border.all(color: MimiCard.outlineColor),
          borderRadius: BorderRadius.circular(MimiRadius.md),
        ),
        child: SizedBox.square(
          dimension: _tileSize,
          child: Center(
            child: Text(
              initials,
              maxLines: 1,
              style: MimiTypography.labelLarge.copyWith(
                color: MimiColors.primarySoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
