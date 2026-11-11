import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../../chat/domain/models/chat_ui.dart';
import '../../chat/presentation/chat_controller.dart';
import '../../chat/presentation/chat_state.dart';
import '../home_providers.dart';
import 'home_view_data.dart';

part 'home_controller.g.dart';

/// Home content loaded through [GetHomeSummary], or the failure that
/// prevented it. Failures are values, never thrown; invalidate to retry.
///
/// Reloads itself when Mimi reports a completed transfer, so Home shows the
/// backend's updated balance and transactions without waiting for the sheet
/// to close. Nothing is derived from the reply; it only signals that the
/// backend's data changed.
@riverpod
Future<Either<Failure, HomeViewData>> homeContent(Ref ref) async {
  ref.listen(chatControllerProvider, (previous, next) {
    if (_addsCompletedTransfer(previous, next)) ref.invalidateSelf();
  });

  final result = await ref.watch(getHomeSummaryProvider)();
  return result.map(
    (summary) => homeViewDataFrom(summary, now: DateTime.now()),
  );
}

/// Whether [next] adds a new assistant reply reporting a transfer the
/// backend completed, which it only reports once the transfer is persisted.
///
/// Only a newly added reply counts, so state changes that keep the latest
/// reply (a request starting, a failure, reopening Mimi) never refresh.
bool _addsCompletedTransfer(ChatState? previous, ChatState next) {
  if (next is! ChatActive) return false;
  final reply = next.latestReply;
  if (reply == null) return false;
  final previousReply = switch (previous) {
    ChatActive() => previous.latestReply,
    _ => null,
  };
  if (identical(reply, previousReply)) return false;
  return switch (reply.ui) {
    TransferSummaryUi(status: TransferStatus.completed) => true,
    _ => false,
  };
}
