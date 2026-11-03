import 'package:flutter/material.dart';

import '../../../../../shared/design_system/mimi_tokens.dart';
import '../../../domain/models/chat_ui.dart';
import 'transfer_result_parts.dart';

/// A transfer the backend reports as FAILED.
///
/// It states the result only: the contract carries no reason, and nothing
/// here retries the transfer.
class TransferFailedView extends StatelessWidget {
  const TransferFailedView({super.key, required this.transfer});

  final TransferSummaryUi transfer;

  @override
  Widget build(BuildContext context) {
    return TransferResultFrame(
      accent: MimiColors.error,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransferResultHeading(
            icon: Icons.cancel_outlined,
            accent: MimiColors.error,
            title: 'Transferencia no realizada',
            amount: transfer.amount,
          ),
          const SizedBox(height: MimiSpacing.lg),
          TransferDetails(transfer: transfer),
        ],
      ),
    );
  }
}
