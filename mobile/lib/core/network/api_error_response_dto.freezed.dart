// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiErrorResponseDto {

 String get code; String get message; String get requestId; DateTime get timestamp;
/// Create a copy of ApiErrorResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorResponseDtoCopyWith<ApiErrorResponseDto> get copyWith => _$ApiErrorResponseDtoCopyWithImpl<ApiErrorResponseDto>(this as ApiErrorResponseDto, _$identity);

  /// Serializes this ApiErrorResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApiErrorResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorResponseDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiErrorResponseDto;
  return Object.hash(runtimeType,_this.code,_this.message,_this.requestId,_this.timestamp);
}

@override
String toString() {
  final _this = this as ApiErrorResponseDto;
  return 'ApiErrorResponseDto(code: ${_this.code}, message: ${_this.message}, requestId: ${_this.requestId}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $ApiErrorResponseDtoCopyWith<$Res>  {
  factory $ApiErrorResponseDtoCopyWith(ApiErrorResponseDto value, $Res Function(ApiErrorResponseDto) _then) = _$ApiErrorResponseDtoCopyWithImpl;
@useResult
$Res call({
 String code, String message, String requestId, DateTime timestamp
});




}
/// @nodoc
class _$ApiErrorResponseDtoCopyWithImpl<$Res>
    implements $ApiErrorResponseDtoCopyWith<$Res> {
  _$ApiErrorResponseDtoCopyWithImpl(this._self, this._then);

  final ApiErrorResponseDto _self;
  final $Res Function(ApiErrorResponseDto) _then;

/// Create a copy of ApiErrorResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? requestId = null,Object? timestamp = null,}) {
  return _then(ApiErrorResponseDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorResponseDto].
extension ApiErrorResponseDtoPatterns on ApiErrorResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message,  String requestId,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorResponseDto() when $default != null:
return $default(_that.code,_that.message,_that.requestId,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message,  String requestId,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorResponseDto():
return $default(_that.code,_that.message,_that.requestId,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message,  String requestId,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorResponseDto() when $default != null:
return $default(_that.code,_that.message,_that.requestId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorResponseDto implements ApiErrorResponseDto {
  const _ApiErrorResponseDto({required this.code, required this.message, required this.requestId, required this.timestamp});
  factory _ApiErrorResponseDto.fromJson(Map<String, dynamic> json) => _$ApiErrorResponseDtoFromJson(json);

@override final  String code;
@override final  String message;
@override final  String requestId;
@override final  DateTime timestamp;

/// Create a copy of ApiErrorResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorResponseDtoCopyWith<_ApiErrorResponseDto> get copyWith => __$ApiErrorResponseDtoCopyWithImpl<_ApiErrorResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorResponseDto&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message,requestId,timestamp);
}

@override
String toString() {
    return 'ApiErrorResponseDto(code: $code, message: $message, requestId: $requestId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorResponseDtoCopyWith<$Res> implements $ApiErrorResponseDtoCopyWith<$Res> {
  factory _$ApiErrorResponseDtoCopyWith(_ApiErrorResponseDto value, $Res Function(_ApiErrorResponseDto) _then) = __$ApiErrorResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, String requestId, DateTime timestamp
});




}
/// @nodoc
class __$ApiErrorResponseDtoCopyWithImpl<$Res>
    implements _$ApiErrorResponseDtoCopyWith<$Res> {
  __$ApiErrorResponseDtoCopyWithImpl(this._self, this._then);

  final _ApiErrorResponseDto _self;
  final $Res Function(_ApiErrorResponseDto) _then;

/// Create a copy of ApiErrorResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? requestId = null,Object? timestamp = null,}) {
  return _then(_ApiErrorResponseDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
