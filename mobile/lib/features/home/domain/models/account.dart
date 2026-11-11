import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../chat/domain/models/money.dart';

part 'account.freezed.dart';

/// A customer account with its persisted balance, as supplied by the
/// backend.
@freezed
abstract class Account with _$Account {
  const Account._();

  const factory Account({
    required String id,
    required String name,
    required Money balance,
    required AccountStatus status,
  }) = _Account;

  bool get isArs => balance.currency == Currency.ars;
}

enum AccountStatus { active, inactive }
