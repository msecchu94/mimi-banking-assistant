import 'package:flutter/widgets.dart';

import '../../../domain/models/chat_ui.dart';
import 'transfer_completed_view.dart';
import 'transfer_failed_view.dart';

/// TRANSFER_SUMMARY: the final result of an executed transfer.
///
/// The backend's [TransferStatus] alone decides which result is shown; each
/// result is its own widget. Nothing here can retry or change the transfer.
class TransferSummaryView extends StatelessWidget {
  const TransferSummaryView({super.key, required this.ui});

  final TransferSummaryUi ui;

  @override
  Widget build(BuildContext context) => switch (ui.status) {
    TransferStatus.completed => TransferCompletedView(transfer: ui),
    TransferStatus.failed => TransferFailedView(transfer: ui),
  };
}
