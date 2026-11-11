import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../chat/domain/models/chat_ui.dart';
import 'account.dart';

part 'home_summary.freezed.dart';

/// What Home shows: the ARS account and its newest transactions.
@freezed
abstract class HomeSummary with _$HomeSummary {
  const factory HomeSummary({
    required Account account,

    /// Newest first.
    required List<Transaction> recentTransactions,
  }) = _HomeSummary;
}

/// The customer has no ARS account for Home to show.
final class NoArsAccountFailure extends Failure {
  const NoArsAccountFailure();

  @override
  bool operator ==(Object other) => other is NoArsAccountFailure;

  @override
  int get hashCode => (NoArsAccountFailure).hashCode;

  @override
  String toString() => 'NoArsAccountFailure()';
}
