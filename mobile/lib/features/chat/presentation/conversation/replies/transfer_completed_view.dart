import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../shared/design_system/components/mimi_button.dart';
import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../domain/models/chat_ui.dart';
import '../../formatting/chat_formatting.dart';
import 'transfer_result_parts.dart';

/// A transfer the backend reports as COMPLETED.
///
/// `Compartir` opens the system share sheet with the transfer's data; it is
/// local to the device and never reaches Mimi or the backend.
class TransferCompletedView extends StatelessWidget {
  const TransferCompletedView({super.key, required this.transfer});

  final TransferSummaryUi transfer;

  @override
  Widget build(BuildContext context) {
    return TransferResultFrame(
      accent: MimiColors.success,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransferResultHeading(
            icon: Icons.check_circle_outline,
            accent: MimiColors.success,
            title: 'Transferencia realizada',
            amount: transfer.amount,
          ),
          const SizedBox(height: MimiSpacing.lg),
          TransferDetails(transfer: transfer),
          const SizedBox(height: MimiSpacing.lg),
          // A quiet `primary` outline sets the local share action apart
          // from the elevated surface it sits on.
          DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(color: MimiColors.primary),
              borderRadius: BorderRadius.circular(MimiRadius.md),
            ),
            child: Builder(
              builder: (context) => MimiButton(
                label: 'Compartir',
                variant: MimiButtonVariant.secondary,
                trailingIcon: Icons.ios_share,
                onPressed: () => _share(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    // iPad presents the sheet as a popover anchored to the button.
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: transferShareText(transfer),
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
