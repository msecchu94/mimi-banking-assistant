// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeSummary {

 Account get account;/// Newest first.
 List<Transaction> get recentTransactions;
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSummaryCopyWith<HomeSummary> get copyWith => _$HomeSummaryCopyWithImpl<HomeSummary>(this as HomeSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSummary&&(identical(other.account, _this.account) || other.account == _this.account)&&const DeepCollectionEquality().equals(other.recentTransactions, _this.recentTransactions));
}


@override
int get hashCode {
  final _this = this as HomeSummary;
  return Object.hash(runtimeType,_this.account,const DeepCollectionEquality().hash(_this.recentTransactions));
}

@override
String toString() {
  final _this = this as HomeSummary;
  return 'HomeSummary(account: ${_this.account}, recentTransactions: ${_this.recentTransactions})';
}


}

/// @nodoc
abstract mixin class $HomeSummaryCopyWith<$Res>  {
  factory $HomeSummaryCopyWith(HomeSummary value, $Res Function(HomeSummary) _then) = _$HomeSummaryCopyWithImpl;
@useResult
$Res call({
 Account account, List<Transaction> recentTransactions
});


$AccountCopyWith<$Res> get account;

}
/// @nodoc
class _$HomeSummaryCopyWithImpl<$Res>
    implements $HomeSummaryCopyWith<$Res> {
  _$HomeSummaryCopyWithImpl(this._self, this._then);

  final HomeSummary _self;
  final $Res Function(HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? recentTransactions = null,}) {
  return _then(HomeSummary(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,recentTransactions: null == recentTransactions ? _self.recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeSummary].
extension HomeSummaryPatterns on HomeSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSummary value)  $default,){
final _that = this;
switch (_that) {
case _HomeSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Account account,  List<Transaction> recentTransactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.account,_that.recentTransactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Account account,  List<Transaction> recentTransactions)  $default,) {final _that = this;
switch (_that) {
case _HomeSummary():
return $default(_that.account,_that.recentTransactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Account account,  List<Transaction> recentTransactions)?  $default,) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.account,_that.recentTransactions);case _:
  return null;

}
}

}

/// @nodoc


class _HomeSummary implements HomeSummary {
  const _HomeSummary({required this.account, required  List<Transaction> recentTransactions}): _recentTransactions = recentTransactions;
  

@override final  Account account;
/// Newest first.
 final  List<Transaction> _recentTransactions;
/// Newest first.
@override List<Transaction> get recentTransactions {
  if (_recentTransactions is EqualUnmodifiableListView) return _recentTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTransactions);
}


/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSummaryCopyWith<_HomeSummary> get copyWith => __$HomeSummaryCopyWithImpl<_HomeSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSummary&&(identical(other.account, account) || other.account == account)&&const DeepCollectionEquality().equals(other.recentTransactions, _recentTransactions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,account,const DeepCollectionEquality().hash(_recentTransactions));
}

@override
String toString() {
    return 'HomeSummary(account: $account, recentTransactions: $recentTransactions)';
}


}

/// @nodoc
abstract mixin class _$HomeSummaryCopyWith<$Res> implements $HomeSummaryCopyWith<$Res> {
  factory _$HomeSummaryCopyWith(_HomeSummary value, $Res Function(_HomeSummary) _then) = __$HomeSummaryCopyWithImpl;
@override @useResult
$Res call({
 Account account, List<Transaction> recentTransactions
});


@override $AccountCopyWith<$Res> get account;

}
/// @nodoc
class __$HomeSummaryCopyWithImpl<$Res>
    implements _$HomeSummaryCopyWith<$Res> {
  __$HomeSummaryCopyWithImpl(this._self, this._then);

  final _HomeSummary _self;
  final $Res Function(_HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? recentTransactions = null,}) {
  return _then(_HomeSummary(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,recentTransactions: null == recentTransactions ? _self._recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
