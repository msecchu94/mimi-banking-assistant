// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountsResponseDto {

 List<AccountDto> get accounts; ResponseMetadataDto get metadata;
/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountsResponseDtoCopyWith<AccountsResponseDto> get copyWith => _$AccountsResponseDtoCopyWithImpl<AccountsResponseDto>(this as AccountsResponseDto, _$identity);

  /// Serializes this AccountsResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountsResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountsResponseDto&&const DeepCollectionEquality().equals(other.accounts, _this.accounts)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountsResponseDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.accounts),_this.metadata);
}

@override
String toString() {
  final _this = this as AccountsResponseDto;
  return 'AccountsResponseDto(accounts: ${_this.accounts}, metadata: ${_this.metadata})';
}


}

/// @nodoc
abstract mixin class $AccountsResponseDtoCopyWith<$Res>  {
  factory $AccountsResponseDtoCopyWith(AccountsResponseDto value, $Res Function(AccountsResponseDto) _then) = _$AccountsResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<AccountDto> accounts, ResponseMetadataDto metadata
});


$ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class _$AccountsResponseDtoCopyWithImpl<$Res>
    implements $AccountsResponseDtoCopyWith<$Res> {
  _$AccountsResponseDtoCopyWithImpl(this._self, this._then);

  final AccountsResponseDto _self;
  final $Res Function(AccountsResponseDto) _then;

/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accounts = null,Object? metadata = null,}) {
  return _then(AccountsResponseDto(
accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountDto>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}
/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountsResponseDto].
extension AccountsResponseDtoPatterns on AccountsResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountsResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountsResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountsResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AccountsResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountsResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AccountsResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AccountDto> accounts,  ResponseMetadataDto metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountsResponseDto() when $default != null:
return $default(_that.accounts,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AccountDto> accounts,  ResponseMetadataDto metadata)  $default,) {final _that = this;
switch (_that) {
case _AccountsResponseDto():
return $default(_that.accounts,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AccountDto> accounts,  ResponseMetadataDto metadata)?  $default,) {final _that = this;
switch (_that) {
case _AccountsResponseDto() when $default != null:
return $default(_that.accounts,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountsResponseDto implements AccountsResponseDto {
  const _AccountsResponseDto({required  List<AccountDto> accounts, required this.metadata}): _accounts = accounts;
  factory _AccountsResponseDto.fromJson(Map<String, dynamic> json) => _$AccountsResponseDtoFromJson(json);

 final  List<AccountDto> _accounts;
@override List<AccountDto> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

@override final  ResponseMetadataDto metadata;

/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountsResponseDtoCopyWith<_AccountsResponseDto> get copyWith => __$AccountsResponseDtoCopyWithImpl<_AccountsResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountsResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountsResponseDto&&const DeepCollectionEquality().equals(other.accounts, _accounts)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_accounts),metadata);
}

@override
String toString() {
    return 'AccountsResponseDto(accounts: $accounts, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$AccountsResponseDtoCopyWith<$Res> implements $AccountsResponseDtoCopyWith<$Res> {
  factory _$AccountsResponseDtoCopyWith(_AccountsResponseDto value, $Res Function(_AccountsResponseDto) _then) = __$AccountsResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<AccountDto> accounts, ResponseMetadataDto metadata
});


@override $ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class __$AccountsResponseDtoCopyWithImpl<$Res>
    implements _$AccountsResponseDtoCopyWith<$Res> {
  __$AccountsResponseDtoCopyWithImpl(this._self, this._then);

  final _AccountsResponseDto _self;
  final $Res Function(_AccountsResponseDto) _then;

/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accounts = null,Object? metadata = null,}) {
  return _then(_AccountsResponseDto(
accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountDto>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}

/// Create a copy of AccountsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$AccountDto {

 String get id; String get name; MoneyDto get balance; String get status;
/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDtoCopyWith<AccountDto> get copyWith => _$AccountDtoCopyWithImpl<AccountDto>(this as AccountDto, _$identity);

  /// Serializes this AccountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.balance,_this.status);
}

@override
String toString() {
  final _this = this as AccountDto;
  return 'AccountDto(id: ${_this.id}, name: ${_this.name}, balance: ${_this.balance}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $AccountDtoCopyWith<$Res>  {
  factory $AccountDtoCopyWith(AccountDto value, $Res Function(AccountDto) _then) = _$AccountDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, MoneyDto balance, String status
});


$MoneyDtoCopyWith<$Res> get balance;

}
/// @nodoc
class _$AccountDtoCopyWithImpl<$Res>
    implements $AccountDtoCopyWith<$Res> {
  _$AccountDtoCopyWithImpl(this._self, this._then);

  final AccountDto _self;
  final $Res Function(AccountDto) _then;

/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? status = null,}) {
  return _then(AccountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as MoneyDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get balance {
  
  return $MoneyDtoCopyWith<$Res>(_self.balance, (value) {
    return _then(_self.copyWith(balance: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountDto].
extension AccountDtoPatterns on AccountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDto value)  $default,){
final _that = this;
switch (_that) {
case _AccountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDto value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  MoneyDto balance,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDto() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  MoneyDto balance,  String status)  $default,) {final _that = this;
switch (_that) {
case _AccountDto():
return $default(_that.id,_that.name,_that.balance,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  MoneyDto balance,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AccountDto() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDto implements AccountDto {
  const _AccountDto({required this.id, required this.name, required this.balance, required this.status});
  factory _AccountDto.fromJson(Map<String, dynamic> json) => _$AccountDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  MoneyDto balance;
@override final  String status;

/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDtoCopyWith<_AccountDto> get copyWith => __$AccountDtoCopyWithImpl<_AccountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,balance,status);
}

@override
String toString() {
    return 'AccountDto(id: $id, name: $name, balance: $balance, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AccountDtoCopyWith<$Res> implements $AccountDtoCopyWith<$Res> {
  factory _$AccountDtoCopyWith(_AccountDto value, $Res Function(_AccountDto) _then) = __$AccountDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, MoneyDto balance, String status
});


@override $MoneyDtoCopyWith<$Res> get balance;

}
/// @nodoc
class __$AccountDtoCopyWithImpl<$Res>
    implements _$AccountDtoCopyWith<$Res> {
  __$AccountDtoCopyWithImpl(this._self, this._then);

  final _AccountDto _self;
  final $Res Function(_AccountDto) _then;

/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? status = null,}) {
  return _then(_AccountDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as MoneyDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AccountDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get balance {
  
  return $MoneyDtoCopyWith<$Res>(_self.balance, (value) {
    return _then(_self.copyWith(balance: value));
  });
}
}


/// @nodoc
mixin _$TransactionsResponseDto {

 List<TransactionDto> get transactions; ResponseMetadataDto get metadata;
/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionsResponseDtoCopyWith<TransactionsResponseDto> get copyWith => _$TransactionsResponseDtoCopyWithImpl<TransactionsResponseDto>(this as TransactionsResponseDto, _$identity);

  /// Serializes this TransactionsResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransactionsResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionsResponseDto&&const DeepCollectionEquality().equals(other.transactions, _this.transactions)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransactionsResponseDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.transactions),_this.metadata);
}

@override
String toString() {
  final _this = this as TransactionsResponseDto;
  return 'TransactionsResponseDto(transactions: ${_this.transactions}, metadata: ${_this.metadata})';
}


}

/// @nodoc
abstract mixin class $TransactionsResponseDtoCopyWith<$Res>  {
  factory $TransactionsResponseDtoCopyWith(TransactionsResponseDto value, $Res Function(TransactionsResponseDto) _then) = _$TransactionsResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<TransactionDto> transactions, ResponseMetadataDto metadata
});


$ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class _$TransactionsResponseDtoCopyWithImpl<$Res>
    implements $TransactionsResponseDtoCopyWith<$Res> {
  _$TransactionsResponseDtoCopyWithImpl(this._self, this._then);

  final TransactionsResponseDto _self;
  final $Res Function(TransactionsResponseDto) _then;

/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactions = null,Object? metadata = null,}) {
  return _then(TransactionsResponseDto(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionDto>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}
/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionsResponseDto].
extension TransactionsResponseDtoPatterns on TransactionsResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionsResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionsResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionsResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _TransactionsResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionsResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionsResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransactionDto> transactions,  ResponseMetadataDto metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionsResponseDto() when $default != null:
return $default(_that.transactions,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransactionDto> transactions,  ResponseMetadataDto metadata)  $default,) {final _that = this;
switch (_that) {
case _TransactionsResponseDto():
return $default(_that.transactions,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransactionDto> transactions,  ResponseMetadataDto metadata)?  $default,) {final _that = this;
switch (_that) {
case _TransactionsResponseDto() when $default != null:
return $default(_that.transactions,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionsResponseDto implements TransactionsResponseDto {
  const _TransactionsResponseDto({required  List<TransactionDto> transactions, required this.metadata}): _transactions = transactions;
  factory _TransactionsResponseDto.fromJson(Map<String, dynamic> json) => _$TransactionsResponseDtoFromJson(json);

 final  List<TransactionDto> _transactions;
@override List<TransactionDto> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

@override final  ResponseMetadataDto metadata;

/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionsResponseDtoCopyWith<_TransactionsResponseDto> get copyWith => __$TransactionsResponseDtoCopyWithImpl<_TransactionsResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionsResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionsResponseDto&&const DeepCollectionEquality().equals(other.transactions, _transactions)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_transactions),metadata);
}

@override
String toString() {
    return 'TransactionsResponseDto(transactions: $transactions, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TransactionsResponseDtoCopyWith<$Res> implements $TransactionsResponseDtoCopyWith<$Res> {
  factory _$TransactionsResponseDtoCopyWith(_TransactionsResponseDto value, $Res Function(_TransactionsResponseDto) _then) = __$TransactionsResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TransactionDto> transactions, ResponseMetadataDto metadata
});


@override $ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class __$TransactionsResponseDtoCopyWithImpl<$Res>
    implements _$TransactionsResponseDtoCopyWith<$Res> {
  __$TransactionsResponseDtoCopyWithImpl(this._self, this._then);

  final _TransactionsResponseDto _self;
  final $Res Function(_TransactionsResponseDto) _then;

/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactions = null,Object? metadata = null,}) {
  return _then(_TransactionsResponseDto(
transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionDto>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}

/// Create a copy of TransactionsResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
