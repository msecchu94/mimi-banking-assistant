// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_ui.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatUi {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatUi);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatUi()';
}


}

/// @nodoc
class $ChatUiCopyWith<$Res>  {
$ChatUiCopyWith(ChatUi _, $Res Function(ChatUi) __);
}


/// Adds pattern-matching-related methods to [ChatUi].
extension ChatUiPatterns on ChatUi {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextUi value)?  text,TResult Function( CardListUi value)?  cardList,TResult Function( CardSelectorUi value)?  cardSelector,TResult Function( BeneficiaryListUi value)?  beneficiaryList,TResult Function( ConfirmationUi value)?  confirmation,TResult Function( ExpenseSummaryUi value)?  expenseSummary,TResult Function( ExpenseComparisonUi value)?  expenseComparison,TResult Function( TransactionListUi value)?  transactionList,TResult Function( TransferSummaryUi value)?  transferSummary,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextUi() when text != null:
return text(_that);case CardListUi() when cardList != null:
return cardList(_that);case CardSelectorUi() when cardSelector != null:
return cardSelector(_that);case BeneficiaryListUi() when beneficiaryList != null:
return beneficiaryList(_that);case ConfirmationUi() when confirmation != null:
return confirmation(_that);case ExpenseSummaryUi() when expenseSummary != null:
return expenseSummary(_that);case ExpenseComparisonUi() when expenseComparison != null:
return expenseComparison(_that);case TransactionListUi() when transactionList != null:
return transactionList(_that);case TransferSummaryUi() when transferSummary != null:
return transferSummary(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextUi value)  text,required TResult Function( CardListUi value)  cardList,required TResult Function( CardSelectorUi value)  cardSelector,required TResult Function( BeneficiaryListUi value)  beneficiaryList,required TResult Function( ConfirmationUi value)  confirmation,required TResult Function( ExpenseSummaryUi value)  expenseSummary,required TResult Function( ExpenseComparisonUi value)  expenseComparison,required TResult Function( TransactionListUi value)  transactionList,required TResult Function( TransferSummaryUi value)  transferSummary,}){
final _that = this;
switch (_that) {
case TextUi():
return text(_that);case CardListUi():
return cardList(_that);case CardSelectorUi():
return cardSelector(_that);case BeneficiaryListUi():
return beneficiaryList(_that);case ConfirmationUi():
return confirmation(_that);case ExpenseSummaryUi():
return expenseSummary(_that);case ExpenseComparisonUi():
return expenseComparison(_that);case TransactionListUi():
return transactionList(_that);case TransferSummaryUi():
return transferSummary(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextUi value)?  text,TResult? Function( CardListUi value)?  cardList,TResult? Function( CardSelectorUi value)?  cardSelector,TResult? Function( BeneficiaryListUi value)?  beneficiaryList,TResult? Function( ConfirmationUi value)?  confirmation,TResult? Function( ExpenseSummaryUi value)?  expenseSummary,TResult? Function( ExpenseComparisonUi value)?  expenseComparison,TResult? Function( TransactionListUi value)?  transactionList,TResult? Function( TransferSummaryUi value)?  transferSummary,}){
final _that = this;
switch (_that) {
case TextUi() when text != null:
return text(_that);case CardListUi() when cardList != null:
return cardList(_that);case CardSelectorUi() when cardSelector != null:
return cardSelector(_that);case BeneficiaryListUi() when beneficiaryList != null:
return beneficiaryList(_that);case ConfirmationUi() when confirmation != null:
return confirmation(_that);case ExpenseSummaryUi() when expenseSummary != null:
return expenseSummary(_that);case ExpenseComparisonUi() when expenseComparison != null:
return expenseComparison(_that);case TransactionListUi() when transactionList != null:
return transactionList(_that);case TransferSummaryUi() when transferSummary != null:
return transferSummary(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  text,TResult Function( List<BankCard> cards)?  cardList,TResult Function( List<BankCard> cards)?  cardSelector,TResult Function( List<Beneficiary> beneficiaries)?  beneficiaryList,TResult Function( String operationId,  String title,  ConfirmationSummary summary,  List<ConfirmationAction> actions)?  confirmation,TResult Function( ExpensePeriod period,  List<CurrencyExpenses> currencies)?  expenseSummary,TResult Function( ExpensePeriod currentPeriod,  ExpensePeriod previousPeriod,  List<CurrencyComparison> currencies)?  expenseComparison,TResult Function( List<Transaction> transactions)?  transactionList,TResult Function( String transferId,  String beneficiary,  Money amount,  TransferStatus status,  DateTime executedAt)?  transferSummary,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextUi() when text != null:
return text();case CardListUi() when cardList != null:
return cardList(_that.cards);case CardSelectorUi() when cardSelector != null:
return cardSelector(_that.cards);case BeneficiaryListUi() when beneficiaryList != null:
return beneficiaryList(_that.beneficiaries);case ConfirmationUi() when confirmation != null:
return confirmation(_that.operationId,_that.title,_that.summary,_that.actions);case ExpenseSummaryUi() when expenseSummary != null:
return expenseSummary(_that.period,_that.currencies);case ExpenseComparisonUi() when expenseComparison != null:
return expenseComparison(_that.currentPeriod,_that.previousPeriod,_that.currencies);case TransactionListUi() when transactionList != null:
return transactionList(_that.transactions);case TransferSummaryUi() when transferSummary != null:
return transferSummary(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  text,required TResult Function( List<BankCard> cards)  cardList,required TResult Function( List<BankCard> cards)  cardSelector,required TResult Function( List<Beneficiary> beneficiaries)  beneficiaryList,required TResult Function( String operationId,  String title,  ConfirmationSummary summary,  List<ConfirmationAction> actions)  confirmation,required TResult Function( ExpensePeriod period,  List<CurrencyExpenses> currencies)  expenseSummary,required TResult Function( ExpensePeriod currentPeriod,  ExpensePeriod previousPeriod,  List<CurrencyComparison> currencies)  expenseComparison,required TResult Function( List<Transaction> transactions)  transactionList,required TResult Function( String transferId,  String beneficiary,  Money amount,  TransferStatus status,  DateTime executedAt)  transferSummary,}) {final _that = this;
switch (_that) {
case TextUi():
return text();case CardListUi():
return cardList(_that.cards);case CardSelectorUi():
return cardSelector(_that.cards);case BeneficiaryListUi():
return beneficiaryList(_that.beneficiaries);case ConfirmationUi():
return confirmation(_that.operationId,_that.title,_that.summary,_that.actions);case ExpenseSummaryUi():
return expenseSummary(_that.period,_that.currencies);case ExpenseComparisonUi():
return expenseComparison(_that.currentPeriod,_that.previousPeriod,_that.currencies);case TransactionListUi():
return transactionList(_that.transactions);case TransferSummaryUi():
return transferSummary(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  text,TResult? Function( List<BankCard> cards)?  cardList,TResult? Function( List<BankCard> cards)?  cardSelector,TResult? Function( List<Beneficiary> beneficiaries)?  beneficiaryList,TResult? Function( String operationId,  String title,  ConfirmationSummary summary,  List<ConfirmationAction> actions)?  confirmation,TResult? Function( ExpensePeriod period,  List<CurrencyExpenses> currencies)?  expenseSummary,TResult? Function( ExpensePeriod currentPeriod,  ExpensePeriod previousPeriod,  List<CurrencyComparison> currencies)?  expenseComparison,TResult? Function( List<Transaction> transactions)?  transactionList,TResult? Function( String transferId,  String beneficiary,  Money amount,  TransferStatus status,  DateTime executedAt)?  transferSummary,}) {final _that = this;
switch (_that) {
case TextUi() when text != null:
return text();case CardListUi() when cardList != null:
return cardList(_that.cards);case CardSelectorUi() when cardSelector != null:
return cardSelector(_that.cards);case BeneficiaryListUi() when beneficiaryList != null:
return beneficiaryList(_that.beneficiaries);case ConfirmationUi() when confirmation != null:
return confirmation(_that.operationId,_that.title,_that.summary,_that.actions);case ExpenseSummaryUi() when expenseSummary != null:
return expenseSummary(_that.period,_that.currencies);case ExpenseComparisonUi() when expenseComparison != null:
return expenseComparison(_that.currentPeriod,_that.previousPeriod,_that.currencies);case TransactionListUi() when transactionList != null:
return transactionList(_that.transactions);case TransferSummaryUi() when transferSummary != null:
return transferSummary(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);case _:
  return null;

}
}

}

/// @nodoc


class TextUi implements ChatUi {
  const TextUi();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextUi);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatUi.text()';
}


}




/// @nodoc


class CardListUi implements ChatUi {
  const CardListUi({required  List<BankCard> cards}): _cards = cards;
  

 final  List<BankCard> _cards;
 List<BankCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardListUiCopyWith<CardListUi> get copyWith => _$CardListUiCopyWithImpl<CardListUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardListUi&&const DeepCollectionEquality().equals(other.cards, _cards));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards));
}

@override
String toString() {
    return 'ChatUi.cardList(cards: $cards)';
}


}

/// @nodoc
abstract mixin class $CardListUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $CardListUiCopyWith(CardListUi value, $Res Function(CardListUi) _then) = _$CardListUiCopyWithImpl;
@useResult
$Res call({
 List<BankCard> cards
});




}
/// @nodoc
class _$CardListUiCopyWithImpl<$Res>
    implements $CardListUiCopyWith<$Res> {
  _$CardListUiCopyWithImpl(this._self, this._then);

  final CardListUi _self;
  final $Res Function(CardListUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cards = null,}) {
  return _then(CardListUi(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<BankCard>,
  ));
}


}

/// @nodoc


class CardSelectorUi implements ChatUi {
  const CardSelectorUi({required  List<BankCard> cards}): _cards = cards;
  

 final  List<BankCard> _cards;
 List<BankCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSelectorUiCopyWith<CardSelectorUi> get copyWith => _$CardSelectorUiCopyWithImpl<CardSelectorUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSelectorUi&&const DeepCollectionEquality().equals(other.cards, _cards));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards));
}

@override
String toString() {
    return 'ChatUi.cardSelector(cards: $cards)';
}


}

/// @nodoc
abstract mixin class $CardSelectorUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $CardSelectorUiCopyWith(CardSelectorUi value, $Res Function(CardSelectorUi) _then) = _$CardSelectorUiCopyWithImpl;
@useResult
$Res call({
 List<BankCard> cards
});




}
/// @nodoc
class _$CardSelectorUiCopyWithImpl<$Res>
    implements $CardSelectorUiCopyWith<$Res> {
  _$CardSelectorUiCopyWithImpl(this._self, this._then);

  final CardSelectorUi _self;
  final $Res Function(CardSelectorUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cards = null,}) {
  return _then(CardSelectorUi(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<BankCard>,
  ));
}


}

/// @nodoc


class BeneficiaryListUi implements ChatUi {
  const BeneficiaryListUi({required  List<Beneficiary> beneficiaries}): _beneficiaries = beneficiaries;
  

 final  List<Beneficiary> _beneficiaries;
 List<Beneficiary> get beneficiaries {
  if (_beneficiaries is EqualUnmodifiableListView) return _beneficiaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beneficiaries);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeneficiaryListUiCopyWith<BeneficiaryListUi> get copyWith => _$BeneficiaryListUiCopyWithImpl<BeneficiaryListUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeneficiaryListUi&&const DeepCollectionEquality().equals(other.beneficiaries, _beneficiaries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_beneficiaries));
}

@override
String toString() {
    return 'ChatUi.beneficiaryList(beneficiaries: $beneficiaries)';
}


}

/// @nodoc
abstract mixin class $BeneficiaryListUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $BeneficiaryListUiCopyWith(BeneficiaryListUi value, $Res Function(BeneficiaryListUi) _then) = _$BeneficiaryListUiCopyWithImpl;
@useResult
$Res call({
 List<Beneficiary> beneficiaries
});




}
/// @nodoc
class _$BeneficiaryListUiCopyWithImpl<$Res>
    implements $BeneficiaryListUiCopyWith<$Res> {
  _$BeneficiaryListUiCopyWithImpl(this._self, this._then);

  final BeneficiaryListUi _self;
  final $Res Function(BeneficiaryListUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? beneficiaries = null,}) {
  return _then(BeneficiaryListUi(
beneficiaries: null == beneficiaries ? _self._beneficiaries : beneficiaries // ignore: cast_nullable_to_non_nullable
as List<Beneficiary>,
  ));
}


}

/// @nodoc


class ConfirmationUi implements ChatUi {
  const ConfirmationUi({required this.operationId, required this.title, required this.summary, required  List<ConfirmationAction> actions}): _actions = actions;
  

 final  String operationId;
 final  String title;
 final  ConfirmationSummary summary;
 final  List<ConfirmationAction> _actions;
 List<ConfirmationAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationUiCopyWith<ConfirmationUi> get copyWith => _$ConfirmationUiCopyWithImpl<ConfirmationUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationUi&&(identical(other.operationId, operationId) || other.operationId == operationId)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.actions, _actions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,operationId,title,summary,const DeepCollectionEquality().hash(_actions));
}

@override
String toString() {
    return 'ChatUi.confirmation(operationId: $operationId, title: $title, summary: $summary, actions: $actions)';
}


}

/// @nodoc
abstract mixin class $ConfirmationUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $ConfirmationUiCopyWith(ConfirmationUi value, $Res Function(ConfirmationUi) _then) = _$ConfirmationUiCopyWithImpl;
@useResult
$Res call({
 String operationId, String title, ConfirmationSummary summary, List<ConfirmationAction> actions
});


$ConfirmationSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$ConfirmationUiCopyWithImpl<$Res>
    implements $ConfirmationUiCopyWith<$Res> {
  _$ConfirmationUiCopyWithImpl(this._self, this._then);

  final ConfirmationUi _self;
  final $Res Function(ConfirmationUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operationId = null,Object? title = null,Object? summary = null,Object? actions = null,}) {
  return _then(ConfirmationUi(
operationId: null == operationId ? _self.operationId : operationId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ConfirmationSummary,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<ConfirmationAction>,
  ));
}

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfirmationSummaryCopyWith<$Res> get summary {
  
  return $ConfirmationSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc


class ExpenseSummaryUi implements ChatUi {
  const ExpenseSummaryUi({required this.period, required  List<CurrencyExpenses> currencies}): _currencies = currencies;
  

 final  ExpensePeriod period;
 final  List<CurrencyExpenses> _currencies;
 List<CurrencyExpenses> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSummaryUiCopyWith<ExpenseSummaryUi> get copyWith => _$ExpenseSummaryUiCopyWithImpl<ExpenseSummaryUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSummaryUi&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.currencies, _currencies));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,const DeepCollectionEquality().hash(_currencies));
}

@override
String toString() {
    return 'ChatUi.expenseSummary(period: $period, currencies: $currencies)';
}


}

/// @nodoc
abstract mixin class $ExpenseSummaryUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $ExpenseSummaryUiCopyWith(ExpenseSummaryUi value, $Res Function(ExpenseSummaryUi) _then) = _$ExpenseSummaryUiCopyWithImpl;
@useResult
$Res call({
 ExpensePeriod period, List<CurrencyExpenses> currencies
});


$ExpensePeriodCopyWith<$Res> get period;

}
/// @nodoc
class _$ExpenseSummaryUiCopyWithImpl<$Res>
    implements $ExpenseSummaryUiCopyWith<$Res> {
  _$ExpenseSummaryUiCopyWithImpl(this._self, this._then);

  final ExpenseSummaryUi _self;
  final $Res Function(ExpenseSummaryUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? period = null,Object? currencies = null,}) {
  return _then(ExpenseSummaryUi(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ExpensePeriod,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyExpenses>,
  ));
}

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodCopyWith<$Res> get period {
  
  return $ExpensePeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}

/// @nodoc


class ExpenseComparisonUi implements ChatUi {
  const ExpenseComparisonUi({required this.currentPeriod, required this.previousPeriod, required  List<CurrencyComparison> currencies}): _currencies = currencies;
  

 final  ExpensePeriod currentPeriod;
 final  ExpensePeriod previousPeriod;
 final  List<CurrencyComparison> _currencies;
 List<CurrencyComparison> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseComparisonUiCopyWith<ExpenseComparisonUi> get copyWith => _$ExpenseComparisonUiCopyWithImpl<ExpenseComparisonUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseComparisonUi&&(identical(other.currentPeriod, currentPeriod) || other.currentPeriod == currentPeriod)&&(identical(other.previousPeriod, previousPeriod) || other.previousPeriod == previousPeriod)&&const DeepCollectionEquality().equals(other.currencies, _currencies));
}


@override
int get hashCode {
    return Object.hash(runtimeType,currentPeriod,previousPeriod,const DeepCollectionEquality().hash(_currencies));
}

@override
String toString() {
    return 'ChatUi.expenseComparison(currentPeriod: $currentPeriod, previousPeriod: $previousPeriod, currencies: $currencies)';
}


}

/// @nodoc
abstract mixin class $ExpenseComparisonUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $ExpenseComparisonUiCopyWith(ExpenseComparisonUi value, $Res Function(ExpenseComparisonUi) _then) = _$ExpenseComparisonUiCopyWithImpl;
@useResult
$Res call({
 ExpensePeriod currentPeriod, ExpensePeriod previousPeriod, List<CurrencyComparison> currencies
});


$ExpensePeriodCopyWith<$Res> get currentPeriod;$ExpensePeriodCopyWith<$Res> get previousPeriod;

}
/// @nodoc
class _$ExpenseComparisonUiCopyWithImpl<$Res>
    implements $ExpenseComparisonUiCopyWith<$Res> {
  _$ExpenseComparisonUiCopyWithImpl(this._self, this._then);

  final ExpenseComparisonUi _self;
  final $Res Function(ExpenseComparisonUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentPeriod = null,Object? previousPeriod = null,Object? currencies = null,}) {
  return _then(ExpenseComparisonUi(
currentPeriod: null == currentPeriod ? _self.currentPeriod : currentPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriod,previousPeriod: null == previousPeriod ? _self.previousPeriod : previousPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriod,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyComparison>,
  ));
}

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodCopyWith<$Res> get currentPeriod {
  
  return $ExpensePeriodCopyWith<$Res>(_self.currentPeriod, (value) {
    return _then(_self.copyWith(currentPeriod: value));
  });
}/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodCopyWith<$Res> get previousPeriod {
  
  return $ExpensePeriodCopyWith<$Res>(_self.previousPeriod, (value) {
    return _then(_self.copyWith(previousPeriod: value));
  });
}
}

/// @nodoc


class TransactionListUi implements ChatUi {
  const TransactionListUi({required  List<Transaction> transactions}): _transactions = transactions;
  

 final  List<Transaction> _transactions;
 List<Transaction> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionListUiCopyWith<TransactionListUi> get copyWith => _$TransactionListUiCopyWithImpl<TransactionListUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionListUi&&const DeepCollectionEquality().equals(other.transactions, _transactions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_transactions));
}

@override
String toString() {
    return 'ChatUi.transactionList(transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $TransactionListUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $TransactionListUiCopyWith(TransactionListUi value, $Res Function(TransactionListUi) _then) = _$TransactionListUiCopyWithImpl;
@useResult
$Res call({
 List<Transaction> transactions
});




}
/// @nodoc
class _$TransactionListUiCopyWithImpl<$Res>
    implements $TransactionListUiCopyWith<$Res> {
  _$TransactionListUiCopyWithImpl(this._self, this._then);

  final TransactionListUi _self;
  final $Res Function(TransactionListUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transactions = null,}) {
  return _then(TransactionListUi(
transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}


}

/// @nodoc


class TransferSummaryUi implements ChatUi {
  const TransferSummaryUi({required this.transferId, required this.beneficiary, required this.amount, required this.status, required this.executedAt});
  

 final  String transferId;
 final  String beneficiary;
 final  Money amount;
 final  TransferStatus status;
 final  DateTime executedAt;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferSummaryUiCopyWith<TransferSummaryUi> get copyWith => _$TransferSummaryUiCopyWithImpl<TransferSummaryUi>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferSummaryUi&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.beneficiary, beneficiary) || other.beneficiary == beneficiary)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,transferId,beneficiary,amount,status,executedAt);
}

@override
String toString() {
    return 'ChatUi.transferSummary(transferId: $transferId, beneficiary: $beneficiary, amount: $amount, status: $status, executedAt: $executedAt)';
}


}

/// @nodoc
abstract mixin class $TransferSummaryUiCopyWith<$Res> implements $ChatUiCopyWith<$Res> {
  factory $TransferSummaryUiCopyWith(TransferSummaryUi value, $Res Function(TransferSummaryUi) _then) = _$TransferSummaryUiCopyWithImpl;
@useResult
$Res call({
 String transferId, String beneficiary, Money amount, TransferStatus status, DateTime executedAt
});




}
/// @nodoc
class _$TransferSummaryUiCopyWithImpl<$Res>
    implements $TransferSummaryUiCopyWith<$Res> {
  _$TransferSummaryUiCopyWithImpl(this._self, this._then);

  final TransferSummaryUi _self;
  final $Res Function(TransferSummaryUi) _then;

/// Create a copy of ChatUi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transferId = null,Object? beneficiary = null,Object? amount = null,Object? status = null,Object? executedAt = null,}) {
  return _then(TransferSummaryUi(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,beneficiary: null == beneficiary ? _self.beneficiary : beneficiary // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$BankCard {

 String get id; CardBrand get brand; CardType get type; String get lastFour; CardStatus get status;
/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankCardCopyWith<BankCard> get copyWith => _$BankCardCopyWithImpl<BankCard>(this as BankCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BankCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.lastFour, _this.lastFour) || other.lastFour == _this.lastFour)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as BankCard;
  return Object.hash(runtimeType,_this.id,_this.brand,_this.type,_this.lastFour,_this.status);
}

@override
String toString() {
  final _this = this as BankCard;
  return 'BankCard(id: ${_this.id}, brand: ${_this.brand}, type: ${_this.type}, lastFour: ${_this.lastFour}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BankCardCopyWith<$Res>  {
  factory $BankCardCopyWith(BankCard value, $Res Function(BankCard) _then) = _$BankCardCopyWithImpl;
@useResult
$Res call({
 String id, CardBrand brand, CardType type, String lastFour, CardStatus status
});




}
/// @nodoc
class _$BankCardCopyWithImpl<$Res>
    implements $BankCardCopyWith<$Res> {
  _$BankCardCopyWithImpl(this._self, this._then);

  final BankCard _self;
  final $Res Function(BankCard) _then;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? brand = null,Object? type = null,Object? lastFour = null,Object? status = null,}) {
  return _then(BankCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CardBrand,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CardType,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [BankCard].
extension BankCardPatterns on BankCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankCard value)  $default,){
final _that = this;
switch (_that) {
case _BankCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankCard value)?  $default,){
final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CardBrand brand,  CardType type,  String lastFour,  CardStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that.id,_that.brand,_that.type,_that.lastFour,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CardBrand brand,  CardType type,  String lastFour,  CardStatus status)  $default,) {final _that = this;
switch (_that) {
case _BankCard():
return $default(_that.id,_that.brand,_that.type,_that.lastFour,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CardBrand brand,  CardType type,  String lastFour,  CardStatus status)?  $default,) {final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that.id,_that.brand,_that.type,_that.lastFour,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _BankCard implements BankCard {
  const _BankCard({required this.id, required this.brand, required this.type, required this.lastFour, required this.status});
  

@override final  String id;
@override final  CardBrand brand;
@override final  CardType type;
@override final  String lastFour;
@override final  CardStatus status;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankCardCopyWith<_BankCard> get copyWith => __$BankCardCopyWithImpl<_BankCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankCard&&(identical(other.id, id) || other.id == id)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastFour, lastFour) || other.lastFour == lastFour)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,brand,type,lastFour,status);
}

@override
String toString() {
    return 'BankCard(id: $id, brand: $brand, type: $type, lastFour: $lastFour, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BankCardCopyWith<$Res> implements $BankCardCopyWith<$Res> {
  factory _$BankCardCopyWith(_BankCard value, $Res Function(_BankCard) _then) = __$BankCardCopyWithImpl;
@override @useResult
$Res call({
 String id, CardBrand brand, CardType type, String lastFour, CardStatus status
});




}
/// @nodoc
class __$BankCardCopyWithImpl<$Res>
    implements _$BankCardCopyWith<$Res> {
  __$BankCardCopyWithImpl(this._self, this._then);

  final _BankCard _self;
  final $Res Function(_BankCard) _then;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brand = null,Object? type = null,Object? lastFour = null,Object? status = null,}) {
  return _then(_BankCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CardBrand,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CardType,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,
  ));
}


}

/// @nodoc
mixin _$Beneficiary {

 String get id; String get name;/// A masked reference, e.g. `****4582`.
 String get accountReference; String? get bankName;
/// Create a copy of Beneficiary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeneficiaryCopyWith<Beneficiary> get copyWith => _$BeneficiaryCopyWithImpl<Beneficiary>(this as Beneficiary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Beneficiary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Beneficiary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.accountReference, _this.accountReference) || other.accountReference == _this.accountReference)&&(identical(other.bankName, _this.bankName) || other.bankName == _this.bankName));
}


@override
int get hashCode {
  final _this = this as Beneficiary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.accountReference,_this.bankName);
}

@override
String toString() {
  final _this = this as Beneficiary;
  return 'Beneficiary(id: ${_this.id}, name: ${_this.name}, accountReference: ${_this.accountReference}, bankName: ${_this.bankName})';
}


}

/// @nodoc
abstract mixin class $BeneficiaryCopyWith<$Res>  {
  factory $BeneficiaryCopyWith(Beneficiary value, $Res Function(Beneficiary) _then) = _$BeneficiaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String accountReference, String? bankName
});




}
/// @nodoc
class _$BeneficiaryCopyWithImpl<$Res>
    implements $BeneficiaryCopyWith<$Res> {
  _$BeneficiaryCopyWithImpl(this._self, this._then);

  final Beneficiary _self;
  final $Res Function(Beneficiary) _then;

/// Create a copy of Beneficiary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? accountReference = null,Object? bankName = freezed,}) {
  return _then(Beneficiary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountReference: null == accountReference ? _self.accountReference : accountReference // ignore: cast_nullable_to_non_nullable
as String,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Beneficiary].
extension BeneficiaryPatterns on Beneficiary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Beneficiary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Beneficiary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Beneficiary value)  $default,){
final _that = this;
switch (_that) {
case _Beneficiary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Beneficiary value)?  $default,){
final _that = this;
switch (_that) {
case _Beneficiary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String accountReference,  String? bankName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Beneficiary() when $default != null:
return $default(_that.id,_that.name,_that.accountReference,_that.bankName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String accountReference,  String? bankName)  $default,) {final _that = this;
switch (_that) {
case _Beneficiary():
return $default(_that.id,_that.name,_that.accountReference,_that.bankName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String accountReference,  String? bankName)?  $default,) {final _that = this;
switch (_that) {
case _Beneficiary() when $default != null:
return $default(_that.id,_that.name,_that.accountReference,_that.bankName);case _:
  return null;

}
}

}

/// @nodoc


class _Beneficiary implements Beneficiary {
  const _Beneficiary({required this.id, required this.name, required this.accountReference, required this.bankName});
  

@override final  String id;
@override final  String name;
/// A masked reference, e.g. `****4582`.
@override final  String accountReference;
@override final  String? bankName;

/// Create a copy of Beneficiary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BeneficiaryCopyWith<_Beneficiary> get copyWith => __$BeneficiaryCopyWithImpl<_Beneficiary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Beneficiary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accountReference, accountReference) || other.accountReference == accountReference)&&(identical(other.bankName, bankName) || other.bankName == bankName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,accountReference,bankName);
}

@override
String toString() {
    return 'Beneficiary(id: $id, name: $name, accountReference: $accountReference, bankName: $bankName)';
}


}

/// @nodoc
abstract mixin class _$BeneficiaryCopyWith<$Res> implements $BeneficiaryCopyWith<$Res> {
  factory _$BeneficiaryCopyWith(_Beneficiary value, $Res Function(_Beneficiary) _then) = __$BeneficiaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String accountReference, String? bankName
});




}
/// @nodoc
class __$BeneficiaryCopyWithImpl<$Res>
    implements _$BeneficiaryCopyWith<$Res> {
  __$BeneficiaryCopyWithImpl(this._self, this._then);

  final _Beneficiary _self;
  final $Res Function(_Beneficiary) _then;

/// Create a copy of Beneficiary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? accountReference = null,Object? bankName = freezed,}) {
  return _then(_Beneficiary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountReference: null == accountReference ? _self.accountReference : accountReference // ignore: cast_nullable_to_non_nullable
as String,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Transaction {

 String get id; String get description; Money get amount;/// The direction; never inferred from the amount's sign.
 TransactionType get type; TransactionCategory get category; DateTime get occurredAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt));
}


@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hash(runtimeType,_this.id,_this.description,_this.amount,_this.type,_this.category,_this.occurredAt);
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(id: ${_this.id}, description: ${_this.description}, amount: ${_this.amount}, type: ${_this.type}, category: ${_this.category}, occurredAt: ${_this.occurredAt})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, String description, Money amount, TransactionType type, TransactionCategory category, DateTime occurredAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? amount = null,Object? type = null,Object? category = null,Object? occurredAt = null,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  Money amount,  TransactionType type,  TransactionCategory category,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.description,_that.amount,_that.type,_that.category,_that.occurredAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  Money amount,  TransactionType type,  TransactionCategory category,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.description,_that.amount,_that.type,_that.category,_that.occurredAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  Money amount,  TransactionType type,  TransactionCategory category,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.description,_that.amount,_that.type,_that.category,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc


class _Transaction implements Transaction {
  const _Transaction({required this.id, required this.description, required this.amount, required this.type, required this.category, required this.occurredAt});
  

@override final  String id;
@override final  String description;
@override final  Money amount;
/// The direction; never inferred from the amount's sign.
@override final  TransactionType type;
@override final  TransactionCategory category;
@override final  DateTime occurredAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,description,amount,type,category,occurredAt);
}

@override
String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, type: $type, category: $category, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, Money amount, TransactionType type, TransactionCategory category, DateTime occurredAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? amount = null,Object? type = null,Object? category = null,Object? occurredAt = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ExpensePeriod {

 DateTime get from; DateTime get to;
/// Create a copy of ExpensePeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensePeriodCopyWith<ExpensePeriod> get copyWith => _$ExpensePeriodCopyWithImpl<ExpensePeriod>(this as ExpensePeriod, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExpensePeriod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensePeriod&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to));
}


@override
int get hashCode {
  final _this = this as ExpensePeriod;
  return Object.hash(runtimeType,_this.from,_this.to);
}

@override
String toString() {
  final _this = this as ExpensePeriod;
  return 'ExpensePeriod(from: ${_this.from}, to: ${_this.to})';
}


}

/// @nodoc
abstract mixin class $ExpensePeriodCopyWith<$Res>  {
  factory $ExpensePeriodCopyWith(ExpensePeriod value, $Res Function(ExpensePeriod) _then) = _$ExpensePeriodCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to
});




}
/// @nodoc
class _$ExpensePeriodCopyWithImpl<$Res>
    implements $ExpensePeriodCopyWith<$Res> {
  _$ExpensePeriodCopyWithImpl(this._self, this._then);

  final ExpensePeriod _self;
  final $Res Function(ExpensePeriod) _then;

/// Create a copy of ExpensePeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,}) {
  return _then(ExpensePeriod(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensePeriod].
extension ExpensePeriodPatterns on ExpensePeriod {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpensePeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpensePeriod() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpensePeriod value)  $default,){
final _that = this;
switch (_that) {
case _ExpensePeriod():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpensePeriod value)?  $default,){
final _that = this;
switch (_that) {
case _ExpensePeriod() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpensePeriod() when $default != null:
return $default(_that.from,_that.to);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to)  $default,) {final _that = this;
switch (_that) {
case _ExpensePeriod():
return $default(_that.from,_that.to);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to)?  $default,) {final _that = this;
switch (_that) {
case _ExpensePeriod() when $default != null:
return $default(_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _ExpensePeriod implements ExpensePeriod {
  const _ExpensePeriod({required this.from, required this.to});
  

@override final  DateTime from;
@override final  DateTime to;

/// Create a copy of ExpensePeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpensePeriodCopyWith<_ExpensePeriod> get copyWith => __$ExpensePeriodCopyWithImpl<_ExpensePeriod>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpensePeriod&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode {
    return Object.hash(runtimeType,from,to);
}

@override
String toString() {
    return 'ExpensePeriod(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$ExpensePeriodCopyWith<$Res> implements $ExpensePeriodCopyWith<$Res> {
  factory _$ExpensePeriodCopyWith(_ExpensePeriod value, $Res Function(_ExpensePeriod) _then) = __$ExpensePeriodCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to
});




}
/// @nodoc
class __$ExpensePeriodCopyWithImpl<$Res>
    implements _$ExpensePeriodCopyWith<$Res> {
  __$ExpensePeriodCopyWithImpl(this._self, this._then);

  final _ExpensePeriod _self;
  final $Res Function(_ExpensePeriod) _then;

/// Create a copy of ExpensePeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(_ExpensePeriod(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CurrencyExpenses {

 Money get total; List<CategoryExpense> get categories;
/// Create a copy of CurrencyExpenses
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyExpensesCopyWith<CurrencyExpenses> get copyWith => _$CurrencyExpensesCopyWithImpl<CurrencyExpenses>(this as CurrencyExpenses, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CurrencyExpenses;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencyExpenses&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}


@override
int get hashCode {
  final _this = this as CurrencyExpenses;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as CurrencyExpenses;
  return 'CurrencyExpenses(total: ${_this.total}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $CurrencyExpensesCopyWith<$Res>  {
  factory $CurrencyExpensesCopyWith(CurrencyExpenses value, $Res Function(CurrencyExpenses) _then) = _$CurrencyExpensesCopyWithImpl;
@useResult
$Res call({
 Money total, List<CategoryExpense> categories
});




}
/// @nodoc
class _$CurrencyExpensesCopyWithImpl<$Res>
    implements $CurrencyExpensesCopyWith<$Res> {
  _$CurrencyExpensesCopyWithImpl(this._self, this._then);

  final CurrencyExpenses _self;
  final $Res Function(CurrencyExpenses) _then;

/// Create a copy of CurrencyExpenses
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? categories = null,}) {
  return _then(CurrencyExpenses(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpense>,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrencyExpenses].
extension CurrencyExpensesPatterns on CurrencyExpenses {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencyExpenses value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencyExpenses() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencyExpenses value)  $default,){
final _that = this;
switch (_that) {
case _CurrencyExpenses():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencyExpenses value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencyExpenses() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money total,  List<CategoryExpense> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencyExpenses() when $default != null:
return $default(_that.total,_that.categories);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money total,  List<CategoryExpense> categories)  $default,) {final _that = this;
switch (_that) {
case _CurrencyExpenses():
return $default(_that.total,_that.categories);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money total,  List<CategoryExpense> categories)?  $default,) {final _that = this;
switch (_that) {
case _CurrencyExpenses() when $default != null:
return $default(_that.total,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _CurrencyExpenses implements CurrencyExpenses {
  const _CurrencyExpenses({required this.total, required  List<CategoryExpense> categories}): _categories = categories;
  

@override final  Money total;
 final  List<CategoryExpense> _categories;
@override List<CategoryExpense> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of CurrencyExpenses
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyExpensesCopyWith<_CurrencyExpenses> get copyWith => __$CurrencyExpensesCopyWithImpl<_CurrencyExpenses>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencyExpenses&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.categories, _categories));
}


@override
int get hashCode {
    return Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'CurrencyExpenses(total: $total, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$CurrencyExpensesCopyWith<$Res> implements $CurrencyExpensesCopyWith<$Res> {
  factory _$CurrencyExpensesCopyWith(_CurrencyExpenses value, $Res Function(_CurrencyExpenses) _then) = __$CurrencyExpensesCopyWithImpl;
@override @useResult
$Res call({
 Money total, List<CategoryExpense> categories
});




}
/// @nodoc
class __$CurrencyExpensesCopyWithImpl<$Res>
    implements _$CurrencyExpensesCopyWith<$Res> {
  __$CurrencyExpensesCopyWithImpl(this._self, this._then);

  final _CurrencyExpenses _self;
  final $Res Function(_CurrencyExpenses) _then;

/// Create a copy of CurrencyExpenses
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? categories = null,}) {
  return _then(_CurrencyExpenses(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpense>,
  ));
}


}

/// @nodoc
mixin _$CategoryExpense {

 TransactionCategory get category; Money get amount;
/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryExpenseCopyWith<CategoryExpense> get copyWith => _$CategoryExpenseCopyWithImpl<CategoryExpense>(this as CategoryExpense, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryExpense;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryExpense&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}


@override
int get hashCode {
  final _this = this as CategoryExpense;
  return Object.hash(runtimeType,_this.category,_this.amount);
}

@override
String toString() {
  final _this = this as CategoryExpense;
  return 'CategoryExpense(category: ${_this.category}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $CategoryExpenseCopyWith<$Res>  {
  factory $CategoryExpenseCopyWith(CategoryExpense value, $Res Function(CategoryExpense) _then) = _$CategoryExpenseCopyWithImpl;
@useResult
$Res call({
 TransactionCategory category, Money amount
});




}
/// @nodoc
class _$CategoryExpenseCopyWithImpl<$Res>
    implements $CategoryExpenseCopyWith<$Res> {
  _$CategoryExpenseCopyWithImpl(this._self, this._then);

  final CategoryExpense _self;
  final $Res Function(CategoryExpense) _then;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? amount = null,}) {
  return _then(CategoryExpense(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryExpense].
extension CategoryExpensePatterns on CategoryExpense {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryExpense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryExpense value)  $default,){
final _that = this;
switch (_that) {
case _CategoryExpense():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryExpense value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionCategory category,  Money amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that.category,_that.amount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionCategory category,  Money amount)  $default,) {final _that = this;
switch (_that) {
case _CategoryExpense():
return $default(_that.category,_that.amount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionCategory category,  Money amount)?  $default,) {final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that.category,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryExpense implements CategoryExpense {
  const _CategoryExpense({required this.category, required this.amount});
  

@override final  TransactionCategory category;
@override final  Money amount;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryExpenseCopyWith<_CategoryExpense> get copyWith => __$CategoryExpenseCopyWithImpl<_CategoryExpense>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryExpense&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category,amount);
}

@override
String toString() {
    return 'CategoryExpense(category: $category, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$CategoryExpenseCopyWith<$Res> implements $CategoryExpenseCopyWith<$Res> {
  factory _$CategoryExpenseCopyWith(_CategoryExpense value, $Res Function(_CategoryExpense) _then) = __$CategoryExpenseCopyWithImpl;
@override @useResult
$Res call({
 TransactionCategory category, Money amount
});




}
/// @nodoc
class __$CategoryExpenseCopyWithImpl<$Res>
    implements _$CategoryExpenseCopyWith<$Res> {
  __$CategoryExpenseCopyWithImpl(this._self, this._then);

  final _CategoryExpense _self;
  final $Res Function(_CategoryExpense) _then;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? amount = null,}) {
  return _then(_CategoryExpense(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$CurrencyComparison {

 Money get currentTotal; Money get previousTotal; Money get difference; ExpenseChange get change;
/// Create a copy of CurrencyComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyComparisonCopyWith<CurrencyComparison> get copyWith => _$CurrencyComparisonCopyWithImpl<CurrencyComparison>(this as CurrencyComparison, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CurrencyComparison;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencyComparison&&(identical(other.currentTotal, _this.currentTotal) || other.currentTotal == _this.currentTotal)&&(identical(other.previousTotal, _this.previousTotal) || other.previousTotal == _this.previousTotal)&&(identical(other.difference, _this.difference) || other.difference == _this.difference)&&(identical(other.change, _this.change) || other.change == _this.change));
}


@override
int get hashCode {
  final _this = this as CurrencyComparison;
  return Object.hash(runtimeType,_this.currentTotal,_this.previousTotal,_this.difference,_this.change);
}

@override
String toString() {
  final _this = this as CurrencyComparison;
  return 'CurrencyComparison(currentTotal: ${_this.currentTotal}, previousTotal: ${_this.previousTotal}, difference: ${_this.difference}, change: ${_this.change})';
}


}

/// @nodoc
abstract mixin class $CurrencyComparisonCopyWith<$Res>  {
  factory $CurrencyComparisonCopyWith(CurrencyComparison value, $Res Function(CurrencyComparison) _then) = _$CurrencyComparisonCopyWithImpl;
@useResult
$Res call({
 Money currentTotal, Money previousTotal, Money difference, ExpenseChange change
});




}
/// @nodoc
class _$CurrencyComparisonCopyWithImpl<$Res>
    implements $CurrencyComparisonCopyWith<$Res> {
  _$CurrencyComparisonCopyWithImpl(this._self, this._then);

  final CurrencyComparison _self;
  final $Res Function(CurrencyComparison) _then;

/// Create a copy of CurrencyComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? difference = null,Object? change = null,}) {
  return _then(CurrencyComparison(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as Money,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as Money,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as Money,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as ExpenseChange,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrencyComparison].
extension CurrencyComparisonPatterns on CurrencyComparison {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencyComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencyComparison() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencyComparison value)  $default,){
final _that = this;
switch (_that) {
case _CurrencyComparison():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencyComparison value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencyComparison() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money currentTotal,  Money previousTotal,  Money difference,  ExpenseChange change)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencyComparison() when $default != null:
return $default(_that.currentTotal,_that.previousTotal,_that.difference,_that.change);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money currentTotal,  Money previousTotal,  Money difference,  ExpenseChange change)  $default,) {final _that = this;
switch (_that) {
case _CurrencyComparison():
return $default(_that.currentTotal,_that.previousTotal,_that.difference,_that.change);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money currentTotal,  Money previousTotal,  Money difference,  ExpenseChange change)?  $default,) {final _that = this;
switch (_that) {
case _CurrencyComparison() when $default != null:
return $default(_that.currentTotal,_that.previousTotal,_that.difference,_that.change);case _:
  return null;

}
}

}

/// @nodoc


class _CurrencyComparison implements CurrencyComparison {
  const _CurrencyComparison({required this.currentTotal, required this.previousTotal, required this.difference, required this.change});
  

@override final  Money currentTotal;
@override final  Money previousTotal;
@override final  Money difference;
@override final  ExpenseChange change;

/// Create a copy of CurrencyComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyComparisonCopyWith<_CurrencyComparison> get copyWith => __$CurrencyComparisonCopyWithImpl<_CurrencyComparison>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencyComparison&&(identical(other.currentTotal, currentTotal) || other.currentTotal == currentTotal)&&(identical(other.previousTotal, previousTotal) || other.previousTotal == previousTotal)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.change, change) || other.change == change));
}


@override
int get hashCode {
    return Object.hash(runtimeType,currentTotal,previousTotal,difference,change);
}

@override
String toString() {
    return 'CurrencyComparison(currentTotal: $currentTotal, previousTotal: $previousTotal, difference: $difference, change: $change)';
}


}

/// @nodoc
abstract mixin class _$CurrencyComparisonCopyWith<$Res> implements $CurrencyComparisonCopyWith<$Res> {
  factory _$CurrencyComparisonCopyWith(_CurrencyComparison value, $Res Function(_CurrencyComparison) _then) = __$CurrencyComparisonCopyWithImpl;
@override @useResult
$Res call({
 Money currentTotal, Money previousTotal, Money difference, ExpenseChange change
});




}
/// @nodoc
class __$CurrencyComparisonCopyWithImpl<$Res>
    implements _$CurrencyComparisonCopyWith<$Res> {
  __$CurrencyComparisonCopyWithImpl(this._self, this._then);

  final _CurrencyComparison _self;
  final $Res Function(_CurrencyComparison) _then;

/// Create a copy of CurrencyComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? difference = null,Object? change = null,}) {
  return _then(_CurrencyComparison(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as Money,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as Money,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as Money,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as ExpenseChange,
  ));
}


}

/// @nodoc
mixin _$ConfirmationSummary {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationSummary);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfirmationSummary()';
}


}

/// @nodoc
class $ConfirmationSummaryCopyWith<$Res>  {
$ConfirmationSummaryCopyWith(ConfirmationSummary _, $Res Function(ConfirmationSummary) __);
}


/// Adds pattern-matching-related methods to [ConfirmationSummary].
extension ConfirmationSummaryPatterns on ConfirmationSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransferConfirmationSummary value)?  transfer,TResult Function( CardConfirmationSummary value)?  card,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransferConfirmationSummary() when transfer != null:
return transfer(_that);case CardConfirmationSummary() when card != null:
return card(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransferConfirmationSummary value)  transfer,required TResult Function( CardConfirmationSummary value)  card,}){
final _that = this;
switch (_that) {
case TransferConfirmationSummary():
return transfer(_that);case CardConfirmationSummary():
return card(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransferConfirmationSummary value)?  transfer,TResult? Function( CardConfirmationSummary value)?  card,}){
final _that = this;
switch (_that) {
case TransferConfirmationSummary() when transfer != null:
return transfer(_that);case CardConfirmationSummary() when card != null:
return card(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Money amount,  String beneficiary)?  transfer,TResult Function( BankCard card)?  card,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransferConfirmationSummary() when transfer != null:
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummary() when card != null:
return card(_that.card);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Money amount,  String beneficiary)  transfer,required TResult Function( BankCard card)  card,}) {final _that = this;
switch (_that) {
case TransferConfirmationSummary():
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummary():
return card(_that.card);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Money amount,  String beneficiary)?  transfer,TResult? Function( BankCard card)?  card,}) {final _that = this;
switch (_that) {
case TransferConfirmationSummary() when transfer != null:
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummary() when card != null:
return card(_that.card);case _:
  return null;

}
}

}

/// @nodoc


class TransferConfirmationSummary implements ConfirmationSummary {
  const TransferConfirmationSummary({required this.amount, required this.beneficiary});
  

 final  Money amount;
 final  String beneficiary;

/// Create a copy of ConfirmationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferConfirmationSummaryCopyWith<TransferConfirmationSummary> get copyWith => _$TransferConfirmationSummaryCopyWithImpl<TransferConfirmationSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferConfirmationSummary&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.beneficiary, beneficiary) || other.beneficiary == beneficiary));
}


@override
int get hashCode {
    return Object.hash(runtimeType,amount,beneficiary);
}

@override
String toString() {
    return 'ConfirmationSummary.transfer(amount: $amount, beneficiary: $beneficiary)';
}


}

/// @nodoc
abstract mixin class $TransferConfirmationSummaryCopyWith<$Res> implements $ConfirmationSummaryCopyWith<$Res> {
  factory $TransferConfirmationSummaryCopyWith(TransferConfirmationSummary value, $Res Function(TransferConfirmationSummary) _then) = _$TransferConfirmationSummaryCopyWithImpl;
@useResult
$Res call({
 Money amount, String beneficiary
});




}
/// @nodoc
class _$TransferConfirmationSummaryCopyWithImpl<$Res>
    implements $TransferConfirmationSummaryCopyWith<$Res> {
  _$TransferConfirmationSummaryCopyWithImpl(this._self, this._then);

  final TransferConfirmationSummary _self;
  final $Res Function(TransferConfirmationSummary) _then;

/// Create a copy of ConfirmationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? beneficiary = null,}) {
  return _then(TransferConfirmationSummary(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,beneficiary: null == beneficiary ? _self.beneficiary : beneficiary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CardConfirmationSummary implements ConfirmationSummary {
  const CardConfirmationSummary({required this.card});
  

 final  BankCard card;

/// Create a copy of ConfirmationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardConfirmationSummaryCopyWith<CardConfirmationSummary> get copyWith => _$CardConfirmationSummaryCopyWithImpl<CardConfirmationSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardConfirmationSummary&&(identical(other.card, card) || other.card == card));
}


@override
int get hashCode {
    return Object.hash(runtimeType,card);
}

@override
String toString() {
    return 'ConfirmationSummary.card(card: $card)';
}


}

/// @nodoc
abstract mixin class $CardConfirmationSummaryCopyWith<$Res> implements $ConfirmationSummaryCopyWith<$Res> {
  factory $CardConfirmationSummaryCopyWith(CardConfirmationSummary value, $Res Function(CardConfirmationSummary) _then) = _$CardConfirmationSummaryCopyWithImpl;
@useResult
$Res call({
 BankCard card
});


$BankCardCopyWith<$Res> get card;

}
/// @nodoc
class _$CardConfirmationSummaryCopyWithImpl<$Res>
    implements $CardConfirmationSummaryCopyWith<$Res> {
  _$CardConfirmationSummaryCopyWithImpl(this._self, this._then);

  final CardConfirmationSummary _self;
  final $Res Function(CardConfirmationSummary) _then;

/// Create a copy of ConfirmationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,}) {
  return _then(CardConfirmationSummary(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as BankCard,
  ));
}

/// Create a copy of ConfirmationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCardCopyWith<$Res> get card {
  
  return $BankCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

/// @nodoc
mixin _$ConfirmationAction {

 ConfirmationActionType get type; String get label;
/// Create a copy of ConfirmationAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationActionCopyWith<ConfirmationAction> get copyWith => _$ConfirmationActionCopyWithImpl<ConfirmationAction>(this as ConfirmationAction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConfirmationAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationAction&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as ConfirmationAction;
  return Object.hash(runtimeType,_this.type,_this.label);
}

@override
String toString() {
  final _this = this as ConfirmationAction;
  return 'ConfirmationAction(type: ${_this.type}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $ConfirmationActionCopyWith<$Res>  {
  factory $ConfirmationActionCopyWith(ConfirmationAction value, $Res Function(ConfirmationAction) _then) = _$ConfirmationActionCopyWithImpl;
@useResult
$Res call({
 ConfirmationActionType type, String label
});




}
/// @nodoc
class _$ConfirmationActionCopyWithImpl<$Res>
    implements $ConfirmationActionCopyWith<$Res> {
  _$ConfirmationActionCopyWithImpl(this._self, this._then);

  final ConfirmationAction _self;
  final $Res Function(ConfirmationAction) _then;

/// Create a copy of ConfirmationAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? label = null,}) {
  return _then(ConfirmationAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationActionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmationAction].
extension ConfirmationActionPatterns on ConfirmationAction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmationAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmationAction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmationAction value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmationAction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmationAction value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmationAction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConfirmationActionType type,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmationAction() when $default != null:
return $default(_that.type,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConfirmationActionType type,  String label)  $default,) {final _that = this;
switch (_that) {
case _ConfirmationAction():
return $default(_that.type,_that.label);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConfirmationActionType type,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmationAction() when $default != null:
return $default(_that.type,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ConfirmationAction implements ConfirmationAction {
  const _ConfirmationAction({required this.type, required this.label});
  

@override final  ConfirmationActionType type;
@override final  String label;

/// Create a copy of ConfirmationAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmationActionCopyWith<_ConfirmationAction> get copyWith => __$ConfirmationActionCopyWithImpl<_ConfirmationAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmationAction&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,label);
}

@override
String toString() {
    return 'ConfirmationAction(type: $type, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ConfirmationActionCopyWith<$Res> implements $ConfirmationActionCopyWith<$Res> {
  factory _$ConfirmationActionCopyWith(_ConfirmationAction value, $Res Function(_ConfirmationAction) _then) = __$ConfirmationActionCopyWithImpl;
@override @useResult
$Res call({
 ConfirmationActionType type, String label
});




}
/// @nodoc
class __$ConfirmationActionCopyWithImpl<$Res>
    implements _$ConfirmationActionCopyWith<$Res> {
  __$ConfirmationActionCopyWithImpl(this._self, this._then);

  final _ConfirmationAction _self;
  final $Res Function(_ConfirmationAction) _then;

/// Create a copy of ConfirmationAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? label = null,}) {
  return _then(_ConfirmationAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationActionType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
