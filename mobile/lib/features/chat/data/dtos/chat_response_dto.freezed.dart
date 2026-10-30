// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationResponseDto {

 String get conversationId; String get conversationState; ResponseMetadataDto get metadata;
/// Create a copy of ConversationResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationResponseDtoCopyWith<ConversationResponseDto> get copyWith => _$ConversationResponseDtoCopyWithImpl<ConversationResponseDto>(this as ConversationResponseDto, _$identity);

  /// Serializes this ConversationResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConversationResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationResponseDto&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&(identical(other.conversationState, _this.conversationState) || other.conversationState == _this.conversationState)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConversationResponseDto;
  return Object.hash(runtimeType,_this.conversationId,_this.conversationState,_this.metadata);
}

@override
String toString() {
  final _this = this as ConversationResponseDto;
  return 'ConversationResponseDto(conversationId: ${_this.conversationId}, conversationState: ${_this.conversationState}, metadata: ${_this.metadata})';
}


}

/// @nodoc
abstract mixin class $ConversationResponseDtoCopyWith<$Res>  {
  factory $ConversationResponseDtoCopyWith(ConversationResponseDto value, $Res Function(ConversationResponseDto) _then) = _$ConversationResponseDtoCopyWithImpl;
@useResult
$Res call({
 String conversationId, String conversationState, ResponseMetadataDto metadata
});


$ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class _$ConversationResponseDtoCopyWithImpl<$Res>
    implements $ConversationResponseDtoCopyWith<$Res> {
  _$ConversationResponseDtoCopyWithImpl(this._self, this._then);

  final ConversationResponseDto _self;
  final $Res Function(ConversationResponseDto) _then;

/// Create a copy of ConversationResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? conversationState = null,Object? metadata = null,}) {
  return _then(ConversationResponseDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}
/// Create a copy of ConversationResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationResponseDto].
extension ConversationResponseDtoPatterns on ConversationResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ConversationResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String conversationState,  ResponseMetadataDto metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationResponseDto() when $default != null:
return $default(_that.conversationId,_that.conversationState,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String conversationState,  ResponseMetadataDto metadata)  $default,) {final _that = this;
switch (_that) {
case _ConversationResponseDto():
return $default(_that.conversationId,_that.conversationState,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String conversationState,  ResponseMetadataDto metadata)?  $default,) {final _that = this;
switch (_that) {
case _ConversationResponseDto() when $default != null:
return $default(_that.conversationId,_that.conversationState,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationResponseDto implements ConversationResponseDto {
  const _ConversationResponseDto({required this.conversationId, required this.conversationState, required this.metadata});
  factory _ConversationResponseDto.fromJson(Map<String, dynamic> json) => _$ConversationResponseDtoFromJson(json);

@override final  String conversationId;
@override final  String conversationState;
@override final  ResponseMetadataDto metadata;

/// Create a copy of ConversationResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationResponseDtoCopyWith<_ConversationResponseDto> get copyWith => __$ConversationResponseDtoCopyWithImpl<_ConversationResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationResponseDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.conversationState, conversationState) || other.conversationState == conversationState)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,conversationId,conversationState,metadata);
}

@override
String toString() {
    return 'ConversationResponseDto(conversationId: $conversationId, conversationState: $conversationState, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ConversationResponseDtoCopyWith<$Res> implements $ConversationResponseDtoCopyWith<$Res> {
  factory _$ConversationResponseDtoCopyWith(_ConversationResponseDto value, $Res Function(_ConversationResponseDto) _then) = __$ConversationResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String conversationState, ResponseMetadataDto metadata
});


@override $ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class __$ConversationResponseDtoCopyWithImpl<$Res>
    implements _$ConversationResponseDtoCopyWith<$Res> {
  __$ConversationResponseDtoCopyWithImpl(this._self, this._then);

  final _ConversationResponseDto _self;
  final $Res Function(_ConversationResponseDto) _then;

/// Create a copy of ConversationResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? conversationState = null,Object? metadata = null,}) {
  return _then(_ConversationResponseDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}

/// Create a copy of ConversationResponseDto
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
mixin _$ChatResponseDto {

 String get conversationId; String get message; String get intent; String get conversationState; UiResponseDto get ui; ResponseMetadataDto get metadata;
/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatResponseDtoCopyWith<ChatResponseDto> get copyWith => _$ChatResponseDtoCopyWithImpl<ChatResponseDto>(this as ChatResponseDto, _$identity);

  /// Serializes this ChatResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatResponseDto&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&(identical(other.conversationState, _this.conversationState) || other.conversationState == _this.conversationState)&&(identical(other.ui, _this.ui) || other.ui == _this.ui)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatResponseDto;
  return Object.hash(runtimeType,_this.conversationId,_this.message,_this.intent,_this.conversationState,_this.ui,_this.metadata);
}

@override
String toString() {
  final _this = this as ChatResponseDto;
  return 'ChatResponseDto(conversationId: ${_this.conversationId}, message: ${_this.message}, intent: ${_this.intent}, conversationState: ${_this.conversationState}, ui: ${_this.ui}, metadata: ${_this.metadata})';
}


}

/// @nodoc
abstract mixin class $ChatResponseDtoCopyWith<$Res>  {
  factory $ChatResponseDtoCopyWith(ChatResponseDto value, $Res Function(ChatResponseDto) _then) = _$ChatResponseDtoCopyWithImpl;
@useResult
$Res call({
 String conversationId, String message, String intent, String conversationState, UiResponseDto ui, ResponseMetadataDto metadata
});


$UiResponseDtoCopyWith<$Res> get ui;$ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class _$ChatResponseDtoCopyWithImpl<$Res>
    implements $ChatResponseDtoCopyWith<$Res> {
  _$ChatResponseDtoCopyWithImpl(this._self, this._then);

  final ChatResponseDto _self;
  final $Res Function(ChatResponseDto) _then;

/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? message = null,Object? intent = null,Object? conversationState = null,Object? ui = null,Object? metadata = null,}) {
  return _then(ChatResponseDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as String,ui: null == ui ? _self.ui : ui // ignore: cast_nullable_to_non_nullable
as UiResponseDto,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}
/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UiResponseDtoCopyWith<$Res> get ui {
  
  return $UiResponseDtoCopyWith<$Res>(_self.ui, (value) {
    return _then(_self.copyWith(ui: value));
  });
}/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<$Res> get metadata {
  
  return $ResponseMetadataDtoCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatResponseDto].
extension ChatResponseDtoPatterns on ChatResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String message,  String intent,  String conversationState,  UiResponseDto ui,  ResponseMetadataDto metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatResponseDto() when $default != null:
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String message,  String intent,  String conversationState,  UiResponseDto ui,  ResponseMetadataDto metadata)  $default,) {final _that = this;
switch (_that) {
case _ChatResponseDto():
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String message,  String intent,  String conversationState,  UiResponseDto ui,  ResponseMetadataDto metadata)?  $default,) {final _that = this;
switch (_that) {
case _ChatResponseDto() when $default != null:
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatResponseDto implements ChatResponseDto {
  const _ChatResponseDto({required this.conversationId, required this.message, required this.intent, required this.conversationState, required this.ui, required this.metadata});
  factory _ChatResponseDto.fromJson(Map<String, dynamic> json) => _$ChatResponseDtoFromJson(json);

@override final  String conversationId;
@override final  String message;
@override final  String intent;
@override final  String conversationState;
@override final  UiResponseDto ui;
@override final  ResponseMetadataDto metadata;

/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatResponseDtoCopyWith<_ChatResponseDto> get copyWith => __$ChatResponseDtoCopyWithImpl<_ChatResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatResponseDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.message, message) || other.message == message)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.conversationState, conversationState) || other.conversationState == conversationState)&&(identical(other.ui, ui) || other.ui == ui)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,conversationId,message,intent,conversationState,ui,metadata);
}

@override
String toString() {
    return 'ChatResponseDto(conversationId: $conversationId, message: $message, intent: $intent, conversationState: $conversationState, ui: $ui, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ChatResponseDtoCopyWith<$Res> implements $ChatResponseDtoCopyWith<$Res> {
  factory _$ChatResponseDtoCopyWith(_ChatResponseDto value, $Res Function(_ChatResponseDto) _then) = __$ChatResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String message, String intent, String conversationState, UiResponseDto ui, ResponseMetadataDto metadata
});


@override $UiResponseDtoCopyWith<$Res> get ui;@override $ResponseMetadataDtoCopyWith<$Res> get metadata;

}
/// @nodoc
class __$ChatResponseDtoCopyWithImpl<$Res>
    implements _$ChatResponseDtoCopyWith<$Res> {
  __$ChatResponseDtoCopyWithImpl(this._self, this._then);

  final _ChatResponseDto _self;
  final $Res Function(_ChatResponseDto) _then;

/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? message = null,Object? intent = null,Object? conversationState = null,Object? ui = null,Object? metadata = null,}) {
  return _then(_ChatResponseDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as String,ui: null == ui ? _self.ui : ui // ignore: cast_nullable_to_non_nullable
as UiResponseDto,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as ResponseMetadataDto,
  ));
}

/// Create a copy of ChatResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UiResponseDtoCopyWith<$Res> get ui {
  
  return $UiResponseDtoCopyWith<$Res>(_self.ui, (value) {
    return _then(_self.copyWith(ui: value));
  });
}/// Create a copy of ChatResponseDto
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
mixin _$ResponseMetadataDto {

 String get requestId; DateTime get timestamp;
/// Create a copy of ResponseMetadataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseMetadataDtoCopyWith<ResponseMetadataDto> get copyWith => _$ResponseMetadataDtoCopyWithImpl<ResponseMetadataDto>(this as ResponseMetadataDto, _$identity);

  /// Serializes this ResponseMetadataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResponseMetadataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseMetadataDto&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResponseMetadataDto;
  return Object.hash(runtimeType,_this.requestId,_this.timestamp);
}

@override
String toString() {
  final _this = this as ResponseMetadataDto;
  return 'ResponseMetadataDto(requestId: ${_this.requestId}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $ResponseMetadataDtoCopyWith<$Res>  {
  factory $ResponseMetadataDtoCopyWith(ResponseMetadataDto value, $Res Function(ResponseMetadataDto) _then) = _$ResponseMetadataDtoCopyWithImpl;
@useResult
$Res call({
 String requestId, DateTime timestamp
});




}
/// @nodoc
class _$ResponseMetadataDtoCopyWithImpl<$Res>
    implements $ResponseMetadataDtoCopyWith<$Res> {
  _$ResponseMetadataDtoCopyWithImpl(this._self, this._then);

  final ResponseMetadataDto _self;
  final $Res Function(ResponseMetadataDto) _then;

/// Create a copy of ResponseMetadataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? timestamp = null,}) {
  return _then(ResponseMetadataDto(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ResponseMetadataDto].
extension ResponseMetadataDtoPatterns on ResponseMetadataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseMetadataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseMetadataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseMetadataDto value)  $default,){
final _that = this;
switch (_that) {
case _ResponseMetadataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseMetadataDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseMetadataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestId,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseMetadataDto() when $default != null:
return $default(_that.requestId,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestId,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _ResponseMetadataDto():
return $default(_that.requestId,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestId,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ResponseMetadataDto() when $default != null:
return $default(_that.requestId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResponseMetadataDto implements ResponseMetadataDto {
  const _ResponseMetadataDto({required this.requestId, required this.timestamp});
  factory _ResponseMetadataDto.fromJson(Map<String, dynamic> json) => _$ResponseMetadataDtoFromJson(json);

@override final  String requestId;
@override final  DateTime timestamp;

/// Create a copy of ResponseMetadataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseMetadataDtoCopyWith<_ResponseMetadataDto> get copyWith => __$ResponseMetadataDtoCopyWithImpl<_ResponseMetadataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseMetadataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseMetadataDto&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,requestId,timestamp);
}

@override
String toString() {
    return 'ResponseMetadataDto(requestId: $requestId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ResponseMetadataDtoCopyWith<$Res> implements $ResponseMetadataDtoCopyWith<$Res> {
  factory _$ResponseMetadataDtoCopyWith(_ResponseMetadataDto value, $Res Function(_ResponseMetadataDto) _then) = __$ResponseMetadataDtoCopyWithImpl;
@override @useResult
$Res call({
 String requestId, DateTime timestamp
});




}
/// @nodoc
class __$ResponseMetadataDtoCopyWithImpl<$Res>
    implements _$ResponseMetadataDtoCopyWith<$Res> {
  __$ResponseMetadataDtoCopyWithImpl(this._self, this._then);

  final _ResponseMetadataDto _self;
  final $Res Function(_ResponseMetadataDto) _then;

/// Create a copy of ResponseMetadataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? timestamp = null,}) {
  return _then(_ResponseMetadataDto(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

UiResponseDto _$UiResponseDtoFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'TEXT':
          return TextUiDto.fromJson(
            json
          );
                case 'CARD_LIST':
          return CardListUiDto.fromJson(
            json
          );
                case 'CARD_SELECTOR':
          return CardSelectorUiDto.fromJson(
            json
          );
                case 'BENEFICIARY_LIST':
          return BeneficiaryListUiDto.fromJson(
            json
          );
                case 'CONFIRMATION':
          return ConfirmationUiDto.fromJson(
            json
          );
                case 'EXPENSE_SUMMARY':
          return ExpenseSummaryUiDto.fromJson(
            json
          );
                case 'EXPENSE_COMPARISON':
          return ExpenseComparisonUiDto.fromJson(
            json
          );
                case 'TRANSACTION_LIST':
          return TransactionListUiDto.fromJson(
            json
          );
                case 'TRANSFER_SUMMARY':
          return TransferSummaryUiDto.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'UiResponseDto',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$UiResponseDto {



  /// Serializes this UiResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UiResponseDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UiResponseDto()';
}


}

/// @nodoc
class $UiResponseDtoCopyWith<$Res>  {
$UiResponseDtoCopyWith(UiResponseDto _, $Res Function(UiResponseDto) __);
}


/// Adds pattern-matching-related methods to [UiResponseDto].
extension UiResponseDtoPatterns on UiResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextUiDto value)?  text,TResult Function( CardListUiDto value)?  cardList,TResult Function( CardSelectorUiDto value)?  cardSelector,TResult Function( BeneficiaryListUiDto value)?  beneficiaryList,TResult Function( ConfirmationUiDto value)?  confirmation,TResult Function( ExpenseSummaryUiDto value)?  expenseSummary,TResult Function( ExpenseComparisonUiDto value)?  expenseComparison,TResult Function( TransactionListUiDto value)?  transactionList,TResult Function( TransferSummaryUiDto value)?  transferSummary,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextUiDto() when text != null:
return text(_that);case CardListUiDto() when cardList != null:
return cardList(_that);case CardSelectorUiDto() when cardSelector != null:
return cardSelector(_that);case BeneficiaryListUiDto() when beneficiaryList != null:
return beneficiaryList(_that);case ConfirmationUiDto() when confirmation != null:
return confirmation(_that);case ExpenseSummaryUiDto() when expenseSummary != null:
return expenseSummary(_that);case ExpenseComparisonUiDto() when expenseComparison != null:
return expenseComparison(_that);case TransactionListUiDto() when transactionList != null:
return transactionList(_that);case TransferSummaryUiDto() when transferSummary != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextUiDto value)  text,required TResult Function( CardListUiDto value)  cardList,required TResult Function( CardSelectorUiDto value)  cardSelector,required TResult Function( BeneficiaryListUiDto value)  beneficiaryList,required TResult Function( ConfirmationUiDto value)  confirmation,required TResult Function( ExpenseSummaryUiDto value)  expenseSummary,required TResult Function( ExpenseComparisonUiDto value)  expenseComparison,required TResult Function( TransactionListUiDto value)  transactionList,required TResult Function( TransferSummaryUiDto value)  transferSummary,}){
final _that = this;
switch (_that) {
case TextUiDto():
return text(_that);case CardListUiDto():
return cardList(_that);case CardSelectorUiDto():
return cardSelector(_that);case BeneficiaryListUiDto():
return beneficiaryList(_that);case ConfirmationUiDto():
return confirmation(_that);case ExpenseSummaryUiDto():
return expenseSummary(_that);case ExpenseComparisonUiDto():
return expenseComparison(_that);case TransactionListUiDto():
return transactionList(_that);case TransferSummaryUiDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextUiDto value)?  text,TResult? Function( CardListUiDto value)?  cardList,TResult? Function( CardSelectorUiDto value)?  cardSelector,TResult? Function( BeneficiaryListUiDto value)?  beneficiaryList,TResult? Function( ConfirmationUiDto value)?  confirmation,TResult? Function( ExpenseSummaryUiDto value)?  expenseSummary,TResult? Function( ExpenseComparisonUiDto value)?  expenseComparison,TResult? Function( TransactionListUiDto value)?  transactionList,TResult? Function( TransferSummaryUiDto value)?  transferSummary,}){
final _that = this;
switch (_that) {
case TextUiDto() when text != null:
return text(_that);case CardListUiDto() when cardList != null:
return cardList(_that);case CardSelectorUiDto() when cardSelector != null:
return cardSelector(_that);case BeneficiaryListUiDto() when beneficiaryList != null:
return beneficiaryList(_that);case ConfirmationUiDto() when confirmation != null:
return confirmation(_that);case ExpenseSummaryUiDto() when expenseSummary != null:
return expenseSummary(_that);case ExpenseComparisonUiDto() when expenseComparison != null:
return expenseComparison(_that);case TransactionListUiDto() when transactionList != null:
return transactionList(_that);case TransferSummaryUiDto() when transferSummary != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  text,TResult Function( CardsDataDto data)?  cardList,TResult Function( CardsDataDto data)?  cardSelector,TResult Function( BeneficiaryListDataDto data)?  beneficiaryList,TResult Function( ConfirmationDataDto data)?  confirmation,TResult Function( ExpenseSummaryDataDto data)?  expenseSummary,TResult Function( ExpenseComparisonDataDto data)?  expenseComparison,TResult Function( TransactionListDataDto data)?  transactionList,TResult Function( TransferSummaryDataDto data)?  transferSummary,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextUiDto() when text != null:
return text();case CardListUiDto() when cardList != null:
return cardList(_that.data);case CardSelectorUiDto() when cardSelector != null:
return cardSelector(_that.data);case BeneficiaryListUiDto() when beneficiaryList != null:
return beneficiaryList(_that.data);case ConfirmationUiDto() when confirmation != null:
return confirmation(_that.data);case ExpenseSummaryUiDto() when expenseSummary != null:
return expenseSummary(_that.data);case ExpenseComparisonUiDto() when expenseComparison != null:
return expenseComparison(_that.data);case TransactionListUiDto() when transactionList != null:
return transactionList(_that.data);case TransferSummaryUiDto() when transferSummary != null:
return transferSummary(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  text,required TResult Function( CardsDataDto data)  cardList,required TResult Function( CardsDataDto data)  cardSelector,required TResult Function( BeneficiaryListDataDto data)  beneficiaryList,required TResult Function( ConfirmationDataDto data)  confirmation,required TResult Function( ExpenseSummaryDataDto data)  expenseSummary,required TResult Function( ExpenseComparisonDataDto data)  expenseComparison,required TResult Function( TransactionListDataDto data)  transactionList,required TResult Function( TransferSummaryDataDto data)  transferSummary,}) {final _that = this;
switch (_that) {
case TextUiDto():
return text();case CardListUiDto():
return cardList(_that.data);case CardSelectorUiDto():
return cardSelector(_that.data);case BeneficiaryListUiDto():
return beneficiaryList(_that.data);case ConfirmationUiDto():
return confirmation(_that.data);case ExpenseSummaryUiDto():
return expenseSummary(_that.data);case ExpenseComparisonUiDto():
return expenseComparison(_that.data);case TransactionListUiDto():
return transactionList(_that.data);case TransferSummaryUiDto():
return transferSummary(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  text,TResult? Function( CardsDataDto data)?  cardList,TResult? Function( CardsDataDto data)?  cardSelector,TResult? Function( BeneficiaryListDataDto data)?  beneficiaryList,TResult? Function( ConfirmationDataDto data)?  confirmation,TResult? Function( ExpenseSummaryDataDto data)?  expenseSummary,TResult? Function( ExpenseComparisonDataDto data)?  expenseComparison,TResult? Function( TransactionListDataDto data)?  transactionList,TResult? Function( TransferSummaryDataDto data)?  transferSummary,}) {final _that = this;
switch (_that) {
case TextUiDto() when text != null:
return text();case CardListUiDto() when cardList != null:
return cardList(_that.data);case CardSelectorUiDto() when cardSelector != null:
return cardSelector(_that.data);case BeneficiaryListUiDto() when beneficiaryList != null:
return beneficiaryList(_that.data);case ConfirmationUiDto() when confirmation != null:
return confirmation(_that.data);case ExpenseSummaryUiDto() when expenseSummary != null:
return expenseSummary(_that.data);case ExpenseComparisonUiDto() when expenseComparison != null:
return expenseComparison(_that.data);case TransactionListUiDto() when transactionList != null:
return transactionList(_that.data);case TransferSummaryUiDto() when transferSummary != null:
return transferSummary(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TextUiDto implements UiResponseDto {
  const TextUiDto({ String? $type}): $type = $type ?? 'TEXT';
  factory TextUiDto.fromJson(Map<String, dynamic> json) => _$TextUiDtoFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$TextUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextUiDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UiResponseDto.text()';
}


}




/// @nodoc
@JsonSerializable()

class CardListUiDto implements UiResponseDto {
  const CardListUiDto({required this.data,  String? $type}): $type = $type ?? 'CARD_LIST';
  factory CardListUiDto.fromJson(Map<String, dynamic> json) => _$CardListUiDtoFromJson(json);

 final  CardsDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardListUiDtoCopyWith<CardListUiDto> get copyWith => _$CardListUiDtoCopyWithImpl<CardListUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardListUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardListUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.cardList(data: $data)';
}


}

/// @nodoc
abstract mixin class $CardListUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $CardListUiDtoCopyWith(CardListUiDto value, $Res Function(CardListUiDto) _then) = _$CardListUiDtoCopyWithImpl;
@useResult
$Res call({
 CardsDataDto data
});


$CardsDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$CardListUiDtoCopyWithImpl<$Res>
    implements $CardListUiDtoCopyWith<$Res> {
  _$CardListUiDtoCopyWithImpl(this._self, this._then);

  final CardListUiDto _self;
  final $Res Function(CardListUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(CardListUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CardsDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardsDataDtoCopyWith<$Res> get data {
  
  return $CardsDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class CardSelectorUiDto implements UiResponseDto {
  const CardSelectorUiDto({required this.data,  String? $type}): $type = $type ?? 'CARD_SELECTOR';
  factory CardSelectorUiDto.fromJson(Map<String, dynamic> json) => _$CardSelectorUiDtoFromJson(json);

 final  CardsDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSelectorUiDtoCopyWith<CardSelectorUiDto> get copyWith => _$CardSelectorUiDtoCopyWithImpl<CardSelectorUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardSelectorUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSelectorUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.cardSelector(data: $data)';
}


}

/// @nodoc
abstract mixin class $CardSelectorUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $CardSelectorUiDtoCopyWith(CardSelectorUiDto value, $Res Function(CardSelectorUiDto) _then) = _$CardSelectorUiDtoCopyWithImpl;
@useResult
$Res call({
 CardsDataDto data
});


$CardsDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$CardSelectorUiDtoCopyWithImpl<$Res>
    implements $CardSelectorUiDtoCopyWith<$Res> {
  _$CardSelectorUiDtoCopyWithImpl(this._self, this._then);

  final CardSelectorUiDto _self;
  final $Res Function(CardSelectorUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(CardSelectorUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CardsDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardsDataDtoCopyWith<$Res> get data {
  
  return $CardsDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class BeneficiaryListUiDto implements UiResponseDto {
  const BeneficiaryListUiDto({required this.data,  String? $type}): $type = $type ?? 'BENEFICIARY_LIST';
  factory BeneficiaryListUiDto.fromJson(Map<String, dynamic> json) => _$BeneficiaryListUiDtoFromJson(json);

 final  BeneficiaryListDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeneficiaryListUiDtoCopyWith<BeneficiaryListUiDto> get copyWith => _$BeneficiaryListUiDtoCopyWithImpl<BeneficiaryListUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BeneficiaryListUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeneficiaryListUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.beneficiaryList(data: $data)';
}


}

/// @nodoc
abstract mixin class $BeneficiaryListUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $BeneficiaryListUiDtoCopyWith(BeneficiaryListUiDto value, $Res Function(BeneficiaryListUiDto) _then) = _$BeneficiaryListUiDtoCopyWithImpl;
@useResult
$Res call({
 BeneficiaryListDataDto data
});


$BeneficiaryListDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$BeneficiaryListUiDtoCopyWithImpl<$Res>
    implements $BeneficiaryListUiDtoCopyWith<$Res> {
  _$BeneficiaryListUiDtoCopyWithImpl(this._self, this._then);

  final BeneficiaryListUiDto _self;
  final $Res Function(BeneficiaryListUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(BeneficiaryListUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as BeneficiaryListDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BeneficiaryListDataDtoCopyWith<$Res> get data {
  
  return $BeneficiaryListDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ConfirmationUiDto implements UiResponseDto {
  const ConfirmationUiDto({required this.data,  String? $type}): $type = $type ?? 'CONFIRMATION';
  factory ConfirmationUiDto.fromJson(Map<String, dynamic> json) => _$ConfirmationUiDtoFromJson(json);

 final  ConfirmationDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationUiDtoCopyWith<ConfirmationUiDto> get copyWith => _$ConfirmationUiDtoCopyWithImpl<ConfirmationUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmationUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.confirmation(data: $data)';
}


}

/// @nodoc
abstract mixin class $ConfirmationUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $ConfirmationUiDtoCopyWith(ConfirmationUiDto value, $Res Function(ConfirmationUiDto) _then) = _$ConfirmationUiDtoCopyWithImpl;
@useResult
$Res call({
 ConfirmationDataDto data
});


$ConfirmationDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$ConfirmationUiDtoCopyWithImpl<$Res>
    implements $ConfirmationUiDtoCopyWith<$Res> {
  _$ConfirmationUiDtoCopyWithImpl(this._self, this._then);

  final ConfirmationUiDto _self;
  final $Res Function(ConfirmationUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ConfirmationUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ConfirmationDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfirmationDataDtoCopyWith<$Res> get data {
  
  return $ConfirmationDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ExpenseSummaryUiDto implements UiResponseDto {
  const ExpenseSummaryUiDto({required this.data,  String? $type}): $type = $type ?? 'EXPENSE_SUMMARY';
  factory ExpenseSummaryUiDto.fromJson(Map<String, dynamic> json) => _$ExpenseSummaryUiDtoFromJson(json);

 final  ExpenseSummaryDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSummaryUiDtoCopyWith<ExpenseSummaryUiDto> get copyWith => _$ExpenseSummaryUiDtoCopyWithImpl<ExpenseSummaryUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseSummaryUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSummaryUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.expenseSummary(data: $data)';
}


}

/// @nodoc
abstract mixin class $ExpenseSummaryUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $ExpenseSummaryUiDtoCopyWith(ExpenseSummaryUiDto value, $Res Function(ExpenseSummaryUiDto) _then) = _$ExpenseSummaryUiDtoCopyWithImpl;
@useResult
$Res call({
 ExpenseSummaryDataDto data
});


$ExpenseSummaryDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$ExpenseSummaryUiDtoCopyWithImpl<$Res>
    implements $ExpenseSummaryUiDtoCopyWith<$Res> {
  _$ExpenseSummaryUiDtoCopyWithImpl(this._self, this._then);

  final ExpenseSummaryUiDto _self;
  final $Res Function(ExpenseSummaryUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ExpenseSummaryUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ExpenseSummaryDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpenseSummaryDataDtoCopyWith<$Res> get data {
  
  return $ExpenseSummaryDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ExpenseComparisonUiDto implements UiResponseDto {
  const ExpenseComparisonUiDto({required this.data,  String? $type}): $type = $type ?? 'EXPENSE_COMPARISON';
  factory ExpenseComparisonUiDto.fromJson(Map<String, dynamic> json) => _$ExpenseComparisonUiDtoFromJson(json);

 final  ExpenseComparisonDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseComparisonUiDtoCopyWith<ExpenseComparisonUiDto> get copyWith => _$ExpenseComparisonUiDtoCopyWithImpl<ExpenseComparisonUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseComparisonUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseComparisonUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.expenseComparison(data: $data)';
}


}

/// @nodoc
abstract mixin class $ExpenseComparisonUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $ExpenseComparisonUiDtoCopyWith(ExpenseComparisonUiDto value, $Res Function(ExpenseComparisonUiDto) _then) = _$ExpenseComparisonUiDtoCopyWithImpl;
@useResult
$Res call({
 ExpenseComparisonDataDto data
});


$ExpenseComparisonDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$ExpenseComparisonUiDtoCopyWithImpl<$Res>
    implements $ExpenseComparisonUiDtoCopyWith<$Res> {
  _$ExpenseComparisonUiDtoCopyWithImpl(this._self, this._then);

  final ExpenseComparisonUiDto _self;
  final $Res Function(ExpenseComparisonUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ExpenseComparisonUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ExpenseComparisonDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpenseComparisonDataDtoCopyWith<$Res> get data {
  
  return $ExpenseComparisonDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TransactionListUiDto implements UiResponseDto {
  const TransactionListUiDto({required this.data,  String? $type}): $type = $type ?? 'TRANSACTION_LIST';
  factory TransactionListUiDto.fromJson(Map<String, dynamic> json) => _$TransactionListUiDtoFromJson(json);

 final  TransactionListDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionListUiDtoCopyWith<TransactionListUiDto> get copyWith => _$TransactionListUiDtoCopyWithImpl<TransactionListUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionListUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionListUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.transactionList(data: $data)';
}


}

/// @nodoc
abstract mixin class $TransactionListUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $TransactionListUiDtoCopyWith(TransactionListUiDto value, $Res Function(TransactionListUiDto) _then) = _$TransactionListUiDtoCopyWithImpl;
@useResult
$Res call({
 TransactionListDataDto data
});


$TransactionListDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$TransactionListUiDtoCopyWithImpl<$Res>
    implements $TransactionListUiDtoCopyWith<$Res> {
  _$TransactionListUiDtoCopyWithImpl(this._self, this._then);

  final TransactionListUiDto _self;
  final $Res Function(TransactionListUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(TransactionListUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TransactionListDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionListDataDtoCopyWith<$Res> get data {
  
  return $TransactionListDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TransferSummaryUiDto implements UiResponseDto {
  const TransferSummaryUiDto({required this.data,  String? $type}): $type = $type ?? 'TRANSFER_SUMMARY';
  factory TransferSummaryUiDto.fromJson(Map<String, dynamic> json) => _$TransferSummaryUiDtoFromJson(json);

 final  TransferSummaryDataDto data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferSummaryUiDtoCopyWith<TransferSummaryUiDto> get copyWith => _$TransferSummaryUiDtoCopyWithImpl<TransferSummaryUiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferSummaryUiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferSummaryUiDto&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'UiResponseDto.transferSummary(data: $data)';
}


}

/// @nodoc
abstract mixin class $TransferSummaryUiDtoCopyWith<$Res> implements $UiResponseDtoCopyWith<$Res> {
  factory $TransferSummaryUiDtoCopyWith(TransferSummaryUiDto value, $Res Function(TransferSummaryUiDto) _then) = _$TransferSummaryUiDtoCopyWithImpl;
@useResult
$Res call({
 TransferSummaryDataDto data
});


$TransferSummaryDataDtoCopyWith<$Res> get data;

}
/// @nodoc
class _$TransferSummaryUiDtoCopyWithImpl<$Res>
    implements $TransferSummaryUiDtoCopyWith<$Res> {
  _$TransferSummaryUiDtoCopyWithImpl(this._self, this._then);

  final TransferSummaryUiDto _self;
  final $Res Function(TransferSummaryUiDto) _then;

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(TransferSummaryUiDto(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TransferSummaryDataDto,
  ));
}

/// Create a copy of UiResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferSummaryDataDtoCopyWith<$Res> get data {
  
  return $TransferSummaryDataDtoCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$CardsDataDto {

 List<CardDto> get cards;
/// Create a copy of CardsDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsDataDtoCopyWith<CardsDataDto> get copyWith => _$CardsDataDtoCopyWithImpl<CardsDataDto>(this as CardsDataDto, _$identity);

  /// Serializes this CardsDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardsDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDataDto&&const DeepCollectionEquality().equals(other.cards, _this.cards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardsDataDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.cards));
}

@override
String toString() {
  final _this = this as CardsDataDto;
  return 'CardsDataDto(cards: ${_this.cards})';
}


}

/// @nodoc
abstract mixin class $CardsDataDtoCopyWith<$Res>  {
  factory $CardsDataDtoCopyWith(CardsDataDto value, $Res Function(CardsDataDto) _then) = _$CardsDataDtoCopyWithImpl;
@useResult
$Res call({
 List<CardDto> cards
});




}
/// @nodoc
class _$CardsDataDtoCopyWithImpl<$Res>
    implements $CardsDataDtoCopyWith<$Res> {
  _$CardsDataDtoCopyWithImpl(this._self, this._then);

  final CardsDataDto _self;
  final $Res Function(CardsDataDto) _then;

/// Create a copy of CardsDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cards = null,}) {
  return _then(CardsDataDto(
cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<CardDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [CardsDataDto].
extension CardsDataDtoPatterns on CardsDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardsDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardsDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardsDataDto value)  $default,){
final _that = this;
switch (_that) {
case _CardsDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardsDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardsDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CardDto> cards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardsDataDto() when $default != null:
return $default(_that.cards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CardDto> cards)  $default,) {final _that = this;
switch (_that) {
case _CardsDataDto():
return $default(_that.cards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CardDto> cards)?  $default,) {final _that = this;
switch (_that) {
case _CardsDataDto() when $default != null:
return $default(_that.cards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardsDataDto implements CardsDataDto {
  const _CardsDataDto({required  List<CardDto> cards}): _cards = cards;
  factory _CardsDataDto.fromJson(Map<String, dynamic> json) => _$CardsDataDtoFromJson(json);

 final  List<CardDto> _cards;
@override List<CardDto> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}


/// Create a copy of CardsDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardsDataDtoCopyWith<_CardsDataDto> get copyWith => __$CardsDataDtoCopyWithImpl<_CardsDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardsDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardsDataDto&&const DeepCollectionEquality().equals(other.cards, _cards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards));
}

@override
String toString() {
    return 'CardsDataDto(cards: $cards)';
}


}

/// @nodoc
abstract mixin class _$CardsDataDtoCopyWith<$Res> implements $CardsDataDtoCopyWith<$Res> {
  factory _$CardsDataDtoCopyWith(_CardsDataDto value, $Res Function(_CardsDataDto) _then) = __$CardsDataDtoCopyWithImpl;
@override @useResult
$Res call({
 List<CardDto> cards
});




}
/// @nodoc
class __$CardsDataDtoCopyWithImpl<$Res>
    implements _$CardsDataDtoCopyWith<$Res> {
  __$CardsDataDtoCopyWithImpl(this._self, this._then);

  final _CardsDataDto _self;
  final $Res Function(_CardsDataDto) _then;

/// Create a copy of CardsDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cards = null,}) {
  return _then(_CardsDataDto(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<CardDto>,
  ));
}


}


/// @nodoc
mixin _$BeneficiaryListDataDto {

 List<BeneficiaryDto> get beneficiaries;
/// Create a copy of BeneficiaryListDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeneficiaryListDataDtoCopyWith<BeneficiaryListDataDto> get copyWith => _$BeneficiaryListDataDtoCopyWithImpl<BeneficiaryListDataDto>(this as BeneficiaryListDataDto, _$identity);

  /// Serializes this BeneficiaryListDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BeneficiaryListDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeneficiaryListDataDto&&const DeepCollectionEquality().equals(other.beneficiaries, _this.beneficiaries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BeneficiaryListDataDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.beneficiaries));
}

@override
String toString() {
  final _this = this as BeneficiaryListDataDto;
  return 'BeneficiaryListDataDto(beneficiaries: ${_this.beneficiaries})';
}


}

/// @nodoc
abstract mixin class $BeneficiaryListDataDtoCopyWith<$Res>  {
  factory $BeneficiaryListDataDtoCopyWith(BeneficiaryListDataDto value, $Res Function(BeneficiaryListDataDto) _then) = _$BeneficiaryListDataDtoCopyWithImpl;
@useResult
$Res call({
 List<BeneficiaryDto> beneficiaries
});




}
/// @nodoc
class _$BeneficiaryListDataDtoCopyWithImpl<$Res>
    implements $BeneficiaryListDataDtoCopyWith<$Res> {
  _$BeneficiaryListDataDtoCopyWithImpl(this._self, this._then);

  final BeneficiaryListDataDto _self;
  final $Res Function(BeneficiaryListDataDto) _then;

/// Create a copy of BeneficiaryListDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? beneficiaries = null,}) {
  return _then(BeneficiaryListDataDto(
beneficiaries: null == beneficiaries ? _self.beneficiaries : beneficiaries // ignore: cast_nullable_to_non_nullable
as List<BeneficiaryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [BeneficiaryListDataDto].
extension BeneficiaryListDataDtoPatterns on BeneficiaryListDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BeneficiaryListDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BeneficiaryListDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BeneficiaryListDataDto value)  $default,){
final _that = this;
switch (_that) {
case _BeneficiaryListDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BeneficiaryListDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _BeneficiaryListDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BeneficiaryDto> beneficiaries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BeneficiaryListDataDto() when $default != null:
return $default(_that.beneficiaries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BeneficiaryDto> beneficiaries)  $default,) {final _that = this;
switch (_that) {
case _BeneficiaryListDataDto():
return $default(_that.beneficiaries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BeneficiaryDto> beneficiaries)?  $default,) {final _that = this;
switch (_that) {
case _BeneficiaryListDataDto() when $default != null:
return $default(_that.beneficiaries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BeneficiaryListDataDto implements BeneficiaryListDataDto {
  const _BeneficiaryListDataDto({required  List<BeneficiaryDto> beneficiaries}): _beneficiaries = beneficiaries;
  factory _BeneficiaryListDataDto.fromJson(Map<String, dynamic> json) => _$BeneficiaryListDataDtoFromJson(json);

 final  List<BeneficiaryDto> _beneficiaries;
@override List<BeneficiaryDto> get beneficiaries {
  if (_beneficiaries is EqualUnmodifiableListView) return _beneficiaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beneficiaries);
}


/// Create a copy of BeneficiaryListDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BeneficiaryListDataDtoCopyWith<_BeneficiaryListDataDto> get copyWith => __$BeneficiaryListDataDtoCopyWithImpl<_BeneficiaryListDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BeneficiaryListDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BeneficiaryListDataDto&&const DeepCollectionEquality().equals(other.beneficiaries, _beneficiaries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_beneficiaries));
}

@override
String toString() {
    return 'BeneficiaryListDataDto(beneficiaries: $beneficiaries)';
}


}

/// @nodoc
abstract mixin class _$BeneficiaryListDataDtoCopyWith<$Res> implements $BeneficiaryListDataDtoCopyWith<$Res> {
  factory _$BeneficiaryListDataDtoCopyWith(_BeneficiaryListDataDto value, $Res Function(_BeneficiaryListDataDto) _then) = __$BeneficiaryListDataDtoCopyWithImpl;
@override @useResult
$Res call({
 List<BeneficiaryDto> beneficiaries
});




}
/// @nodoc
class __$BeneficiaryListDataDtoCopyWithImpl<$Res>
    implements _$BeneficiaryListDataDtoCopyWith<$Res> {
  __$BeneficiaryListDataDtoCopyWithImpl(this._self, this._then);

  final _BeneficiaryListDataDto _self;
  final $Res Function(_BeneficiaryListDataDto) _then;

/// Create a copy of BeneficiaryListDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? beneficiaries = null,}) {
  return _then(_BeneficiaryListDataDto(
beneficiaries: null == beneficiaries ? _self._beneficiaries : beneficiaries // ignore: cast_nullable_to_non_nullable
as List<BeneficiaryDto>,
  ));
}


}


/// @nodoc
mixin _$ConfirmationDataDto {

 String get operationId; String get title; ConfirmationSummaryDto get summary; List<ConfirmationActionDto> get actions;
/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationDataDtoCopyWith<ConfirmationDataDto> get copyWith => _$ConfirmationDataDtoCopyWithImpl<ConfirmationDataDto>(this as ConfirmationDataDto, _$identity);

  /// Serializes this ConfirmationDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfirmationDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationDataDto&&(identical(other.operationId, _this.operationId) || other.operationId == _this.operationId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.actions, _this.actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmationDataDto;
  return Object.hash(runtimeType,_this.operationId,_this.title,_this.summary,const DeepCollectionEquality().hash(_this.actions));
}

@override
String toString() {
  final _this = this as ConfirmationDataDto;
  return 'ConfirmationDataDto(operationId: ${_this.operationId}, title: ${_this.title}, summary: ${_this.summary}, actions: ${_this.actions})';
}


}

/// @nodoc
abstract mixin class $ConfirmationDataDtoCopyWith<$Res>  {
  factory $ConfirmationDataDtoCopyWith(ConfirmationDataDto value, $Res Function(ConfirmationDataDto) _then) = _$ConfirmationDataDtoCopyWithImpl;
@useResult
$Res call({
 String operationId, String title, ConfirmationSummaryDto summary, List<ConfirmationActionDto> actions
});


$ConfirmationSummaryDtoCopyWith<$Res> get summary;

}
/// @nodoc
class _$ConfirmationDataDtoCopyWithImpl<$Res>
    implements $ConfirmationDataDtoCopyWith<$Res> {
  _$ConfirmationDataDtoCopyWithImpl(this._self, this._then);

  final ConfirmationDataDto _self;
  final $Res Function(ConfirmationDataDto) _then;

/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? operationId = null,Object? title = null,Object? summary = null,Object? actions = null,}) {
  return _then(ConfirmationDataDto(
operationId: null == operationId ? _self.operationId : operationId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ConfirmationSummaryDto,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<ConfirmationActionDto>,
  ));
}
/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfirmationSummaryDtoCopyWith<$Res> get summary {
  
  return $ConfirmationSummaryDtoCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConfirmationDataDto].
extension ConfirmationDataDtoPatterns on ConfirmationDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmationDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmationDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmationDataDto value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmationDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmationDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmationDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String operationId,  String title,  ConfirmationSummaryDto summary,  List<ConfirmationActionDto> actions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmationDataDto() when $default != null:
return $default(_that.operationId,_that.title,_that.summary,_that.actions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String operationId,  String title,  ConfirmationSummaryDto summary,  List<ConfirmationActionDto> actions)  $default,) {final _that = this;
switch (_that) {
case _ConfirmationDataDto():
return $default(_that.operationId,_that.title,_that.summary,_that.actions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String operationId,  String title,  ConfirmationSummaryDto summary,  List<ConfirmationActionDto> actions)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmationDataDto() when $default != null:
return $default(_that.operationId,_that.title,_that.summary,_that.actions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmationDataDto implements ConfirmationDataDto {
  const _ConfirmationDataDto({required this.operationId, required this.title, required this.summary, required  List<ConfirmationActionDto> actions}): _actions = actions;
  factory _ConfirmationDataDto.fromJson(Map<String, dynamic> json) => _$ConfirmationDataDtoFromJson(json);

@override final  String operationId;
@override final  String title;
@override final  ConfirmationSummaryDto summary;
 final  List<ConfirmationActionDto> _actions;
@override List<ConfirmationActionDto> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmationDataDtoCopyWith<_ConfirmationDataDto> get copyWith => __$ConfirmationDataDtoCopyWithImpl<_ConfirmationDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmationDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmationDataDto&&(identical(other.operationId, operationId) || other.operationId == operationId)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.actions, _actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,operationId,title,summary,const DeepCollectionEquality().hash(_actions));
}

@override
String toString() {
    return 'ConfirmationDataDto(operationId: $operationId, title: $title, summary: $summary, actions: $actions)';
}


}

/// @nodoc
abstract mixin class _$ConfirmationDataDtoCopyWith<$Res> implements $ConfirmationDataDtoCopyWith<$Res> {
  factory _$ConfirmationDataDtoCopyWith(_ConfirmationDataDto value, $Res Function(_ConfirmationDataDto) _then) = __$ConfirmationDataDtoCopyWithImpl;
@override @useResult
$Res call({
 String operationId, String title, ConfirmationSummaryDto summary, List<ConfirmationActionDto> actions
});


@override $ConfirmationSummaryDtoCopyWith<$Res> get summary;

}
/// @nodoc
class __$ConfirmationDataDtoCopyWithImpl<$Res>
    implements _$ConfirmationDataDtoCopyWith<$Res> {
  __$ConfirmationDataDtoCopyWithImpl(this._self, this._then);

  final _ConfirmationDataDto _self;
  final $Res Function(_ConfirmationDataDto) _then;

/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? operationId = null,Object? title = null,Object? summary = null,Object? actions = null,}) {
  return _then(_ConfirmationDataDto(
operationId: null == operationId ? _self.operationId : operationId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ConfirmationSummaryDto,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<ConfirmationActionDto>,
  ));
}

/// Create a copy of ConfirmationDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfirmationSummaryDtoCopyWith<$Res> get summary {
  
  return $ConfirmationSummaryDtoCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$ExpenseSummaryDataDto {

 ExpensePeriodDto get period; List<CurrencyExpensesDto> get currencies;
/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSummaryDataDtoCopyWith<ExpenseSummaryDataDto> get copyWith => _$ExpenseSummaryDataDtoCopyWithImpl<ExpenseSummaryDataDto>(this as ExpenseSummaryDataDto, _$identity);

  /// Serializes this ExpenseSummaryDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpenseSummaryDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSummaryDataDto&&(identical(other.period, _this.period) || other.period == _this.period)&&const DeepCollectionEquality().equals(other.currencies, _this.currencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpenseSummaryDataDto;
  return Object.hash(runtimeType,_this.period,const DeepCollectionEquality().hash(_this.currencies));
}

@override
String toString() {
  final _this = this as ExpenseSummaryDataDto;
  return 'ExpenseSummaryDataDto(period: ${_this.period}, currencies: ${_this.currencies})';
}


}

/// @nodoc
abstract mixin class $ExpenseSummaryDataDtoCopyWith<$Res>  {
  factory $ExpenseSummaryDataDtoCopyWith(ExpenseSummaryDataDto value, $Res Function(ExpenseSummaryDataDto) _then) = _$ExpenseSummaryDataDtoCopyWithImpl;
@useResult
$Res call({
 ExpensePeriodDto period, List<CurrencyExpensesDto> currencies
});


$ExpensePeriodDtoCopyWith<$Res> get period;

}
/// @nodoc
class _$ExpenseSummaryDataDtoCopyWithImpl<$Res>
    implements $ExpenseSummaryDataDtoCopyWith<$Res> {
  _$ExpenseSummaryDataDtoCopyWithImpl(this._self, this._then);

  final ExpenseSummaryDataDto _self;
  final $Res Function(ExpenseSummaryDataDto) _then;

/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? currencies = null,}) {
  return _then(ExpenseSummaryDataDto(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,currencies: null == currencies ? _self.currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyExpensesDto>,
  ));
}
/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get period {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExpenseSummaryDataDto].
extension ExpenseSummaryDataDtoPatterns on ExpenseSummaryDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseSummaryDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseSummaryDataDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseSummaryDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExpensePeriodDto period,  List<CurrencyExpensesDto> currencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto() when $default != null:
return $default(_that.period,_that.currencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExpensePeriodDto period,  List<CurrencyExpensesDto> currencies)  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto():
return $default(_that.period,_that.currencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExpensePeriodDto period,  List<CurrencyExpensesDto> currencies)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummaryDataDto() when $default != null:
return $default(_that.period,_that.currencies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseSummaryDataDto implements ExpenseSummaryDataDto {
  const _ExpenseSummaryDataDto({required this.period, required  List<CurrencyExpensesDto> currencies}): _currencies = currencies;
  factory _ExpenseSummaryDataDto.fromJson(Map<String, dynamic> json) => _$ExpenseSummaryDataDtoFromJson(json);

@override final  ExpensePeriodDto period;
 final  List<CurrencyExpensesDto> _currencies;
@override List<CurrencyExpensesDto> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}


/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseSummaryDataDtoCopyWith<_ExpenseSummaryDataDto> get copyWith => __$ExpenseSummaryDataDtoCopyWithImpl<_ExpenseSummaryDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseSummaryDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseSummaryDataDto&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.currencies, _currencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,period,const DeepCollectionEquality().hash(_currencies));
}

@override
String toString() {
    return 'ExpenseSummaryDataDto(period: $period, currencies: $currencies)';
}


}

/// @nodoc
abstract mixin class _$ExpenseSummaryDataDtoCopyWith<$Res> implements $ExpenseSummaryDataDtoCopyWith<$Res> {
  factory _$ExpenseSummaryDataDtoCopyWith(_ExpenseSummaryDataDto value, $Res Function(_ExpenseSummaryDataDto) _then) = __$ExpenseSummaryDataDtoCopyWithImpl;
@override @useResult
$Res call({
 ExpensePeriodDto period, List<CurrencyExpensesDto> currencies
});


@override $ExpensePeriodDtoCopyWith<$Res> get period;

}
/// @nodoc
class __$ExpenseSummaryDataDtoCopyWithImpl<$Res>
    implements _$ExpenseSummaryDataDtoCopyWith<$Res> {
  __$ExpenseSummaryDataDtoCopyWithImpl(this._self, this._then);

  final _ExpenseSummaryDataDto _self;
  final $Res Function(_ExpenseSummaryDataDto) _then;

/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? currencies = null,}) {
  return _then(_ExpenseSummaryDataDto(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyExpensesDto>,
  ));
}

/// Create a copy of ExpenseSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get period {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// @nodoc
mixin _$ExpenseComparisonDataDto {

 ExpensePeriodDto get currentPeriod; ExpensePeriodDto get previousPeriod; List<CurrencyComparisonDto> get currencies;
/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseComparisonDataDtoCopyWith<ExpenseComparisonDataDto> get copyWith => _$ExpenseComparisonDataDtoCopyWithImpl<ExpenseComparisonDataDto>(this as ExpenseComparisonDataDto, _$identity);

  /// Serializes this ExpenseComparisonDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpenseComparisonDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseComparisonDataDto&&(identical(other.currentPeriod, _this.currentPeriod) || other.currentPeriod == _this.currentPeriod)&&(identical(other.previousPeriod, _this.previousPeriod) || other.previousPeriod == _this.previousPeriod)&&const DeepCollectionEquality().equals(other.currencies, _this.currencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpenseComparisonDataDto;
  return Object.hash(runtimeType,_this.currentPeriod,_this.previousPeriod,const DeepCollectionEquality().hash(_this.currencies));
}

@override
String toString() {
  final _this = this as ExpenseComparisonDataDto;
  return 'ExpenseComparisonDataDto(currentPeriod: ${_this.currentPeriod}, previousPeriod: ${_this.previousPeriod}, currencies: ${_this.currencies})';
}


}

/// @nodoc
abstract mixin class $ExpenseComparisonDataDtoCopyWith<$Res>  {
  factory $ExpenseComparisonDataDtoCopyWith(ExpenseComparisonDataDto value, $Res Function(ExpenseComparisonDataDto) _then) = _$ExpenseComparisonDataDtoCopyWithImpl;
@useResult
$Res call({
 ExpensePeriodDto currentPeriod, ExpensePeriodDto previousPeriod, List<CurrencyComparisonDto> currencies
});


$ExpensePeriodDtoCopyWith<$Res> get currentPeriod;$ExpensePeriodDtoCopyWith<$Res> get previousPeriod;

}
/// @nodoc
class _$ExpenseComparisonDataDtoCopyWithImpl<$Res>
    implements $ExpenseComparisonDataDtoCopyWith<$Res> {
  _$ExpenseComparisonDataDtoCopyWithImpl(this._self, this._then);

  final ExpenseComparisonDataDto _self;
  final $Res Function(ExpenseComparisonDataDto) _then;

/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPeriod = null,Object? previousPeriod = null,Object? currencies = null,}) {
  return _then(ExpenseComparisonDataDto(
currentPeriod: null == currentPeriod ? _self.currentPeriod : currentPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,previousPeriod: null == previousPeriod ? _self.previousPeriod : previousPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,currencies: null == currencies ? _self.currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyComparisonDto>,
  ));
}
/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get currentPeriod {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.currentPeriod, (value) {
    return _then(_self.copyWith(currentPeriod: value));
  });
}/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get previousPeriod {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.previousPeriod, (value) {
    return _then(_self.copyWith(previousPeriod: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExpenseComparisonDataDto].
extension ExpenseComparisonDataDtoPatterns on ExpenseComparisonDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseComparisonDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseComparisonDataDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseComparisonDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExpensePeriodDto currentPeriod,  ExpensePeriodDto previousPeriod,  List<CurrencyComparisonDto> currencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto() when $default != null:
return $default(_that.currentPeriod,_that.previousPeriod,_that.currencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExpensePeriodDto currentPeriod,  ExpensePeriodDto previousPeriod,  List<CurrencyComparisonDto> currencies)  $default,) {final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto():
return $default(_that.currentPeriod,_that.previousPeriod,_that.currencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExpensePeriodDto currentPeriod,  ExpensePeriodDto previousPeriod,  List<CurrencyComparisonDto> currencies)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseComparisonDataDto() when $default != null:
return $default(_that.currentPeriod,_that.previousPeriod,_that.currencies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseComparisonDataDto implements ExpenseComparisonDataDto {
  const _ExpenseComparisonDataDto({required this.currentPeriod, required this.previousPeriod, required  List<CurrencyComparisonDto> currencies}): _currencies = currencies;
  factory _ExpenseComparisonDataDto.fromJson(Map<String, dynamic> json) => _$ExpenseComparisonDataDtoFromJson(json);

@override final  ExpensePeriodDto currentPeriod;
@override final  ExpensePeriodDto previousPeriod;
 final  List<CurrencyComparisonDto> _currencies;
@override List<CurrencyComparisonDto> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}


/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseComparisonDataDtoCopyWith<_ExpenseComparisonDataDto> get copyWith => __$ExpenseComparisonDataDtoCopyWithImpl<_ExpenseComparisonDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseComparisonDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseComparisonDataDto&&(identical(other.currentPeriod, currentPeriod) || other.currentPeriod == currentPeriod)&&(identical(other.previousPeriod, previousPeriod) || other.previousPeriod == previousPeriod)&&const DeepCollectionEquality().equals(other.currencies, _currencies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentPeriod,previousPeriod,const DeepCollectionEquality().hash(_currencies));
}

@override
String toString() {
    return 'ExpenseComparisonDataDto(currentPeriod: $currentPeriod, previousPeriod: $previousPeriod, currencies: $currencies)';
}


}

/// @nodoc
abstract mixin class _$ExpenseComparisonDataDtoCopyWith<$Res> implements $ExpenseComparisonDataDtoCopyWith<$Res> {
  factory _$ExpenseComparisonDataDtoCopyWith(_ExpenseComparisonDataDto value, $Res Function(_ExpenseComparisonDataDto) _then) = __$ExpenseComparisonDataDtoCopyWithImpl;
@override @useResult
$Res call({
 ExpensePeriodDto currentPeriod, ExpensePeriodDto previousPeriod, List<CurrencyComparisonDto> currencies
});


@override $ExpensePeriodDtoCopyWith<$Res> get currentPeriod;@override $ExpensePeriodDtoCopyWith<$Res> get previousPeriod;

}
/// @nodoc
class __$ExpenseComparisonDataDtoCopyWithImpl<$Res>
    implements _$ExpenseComparisonDataDtoCopyWith<$Res> {
  __$ExpenseComparisonDataDtoCopyWithImpl(this._self, this._then);

  final _ExpenseComparisonDataDto _self;
  final $Res Function(_ExpenseComparisonDataDto) _then;

/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPeriod = null,Object? previousPeriod = null,Object? currencies = null,}) {
  return _then(_ExpenseComparisonDataDto(
currentPeriod: null == currentPeriod ? _self.currentPeriod : currentPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,previousPeriod: null == previousPeriod ? _self.previousPeriod : previousPeriod // ignore: cast_nullable_to_non_nullable
as ExpensePeriodDto,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencyComparisonDto>,
  ));
}

/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get currentPeriod {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.currentPeriod, (value) {
    return _then(_self.copyWith(currentPeriod: value));
  });
}/// Create a copy of ExpenseComparisonDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<$Res> get previousPeriod {
  
  return $ExpensePeriodDtoCopyWith<$Res>(_self.previousPeriod, (value) {
    return _then(_self.copyWith(previousPeriod: value));
  });
}
}


/// @nodoc
mixin _$TransactionListDataDto {

 List<TransactionDto> get transactions;
/// Create a copy of TransactionListDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionListDataDtoCopyWith<TransactionListDataDto> get copyWith => _$TransactionListDataDtoCopyWithImpl<TransactionListDataDto>(this as TransactionListDataDto, _$identity);

  /// Serializes this TransactionListDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransactionListDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionListDataDto&&const DeepCollectionEquality().equals(other.transactions, _this.transactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransactionListDataDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.transactions));
}

@override
String toString() {
  final _this = this as TransactionListDataDto;
  return 'TransactionListDataDto(transactions: ${_this.transactions})';
}


}

/// @nodoc
abstract mixin class $TransactionListDataDtoCopyWith<$Res>  {
  factory $TransactionListDataDtoCopyWith(TransactionListDataDto value, $Res Function(TransactionListDataDto) _then) = _$TransactionListDataDtoCopyWithImpl;
@useResult
$Res call({
 List<TransactionDto> transactions
});




}
/// @nodoc
class _$TransactionListDataDtoCopyWithImpl<$Res>
    implements $TransactionListDataDtoCopyWith<$Res> {
  _$TransactionListDataDtoCopyWithImpl(this._self, this._then);

  final TransactionListDataDto _self;
  final $Res Function(TransactionListDataDto) _then;

/// Create a copy of TransactionListDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactions = null,}) {
  return _then(TransactionListDataDto(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionListDataDto].
extension TransactionListDataDtoPatterns on TransactionListDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionListDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionListDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionListDataDto value)  $default,){
final _that = this;
switch (_that) {
case _TransactionListDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionListDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionListDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransactionDto> transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionListDataDto() when $default != null:
return $default(_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransactionDto> transactions)  $default,) {final _that = this;
switch (_that) {
case _TransactionListDataDto():
return $default(_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransactionDto> transactions)?  $default,) {final _that = this;
switch (_that) {
case _TransactionListDataDto() when $default != null:
return $default(_that.transactions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionListDataDto implements TransactionListDataDto {
  const _TransactionListDataDto({required  List<TransactionDto> transactions}): _transactions = transactions;
  factory _TransactionListDataDto.fromJson(Map<String, dynamic> json) => _$TransactionListDataDtoFromJson(json);

 final  List<TransactionDto> _transactions;
@override List<TransactionDto> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of TransactionListDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionListDataDtoCopyWith<_TransactionListDataDto> get copyWith => __$TransactionListDataDtoCopyWithImpl<_TransactionListDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionListDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionListDataDto&&const DeepCollectionEquality().equals(other.transactions, _transactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_transactions));
}

@override
String toString() {
    return 'TransactionListDataDto(transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$TransactionListDataDtoCopyWith<$Res> implements $TransactionListDataDtoCopyWith<$Res> {
  factory _$TransactionListDataDtoCopyWith(_TransactionListDataDto value, $Res Function(_TransactionListDataDto) _then) = __$TransactionListDataDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TransactionDto> transactions
});




}
/// @nodoc
class __$TransactionListDataDtoCopyWithImpl<$Res>
    implements _$TransactionListDataDtoCopyWith<$Res> {
  __$TransactionListDataDtoCopyWithImpl(this._self, this._then);

  final _TransactionListDataDto _self;
  final $Res Function(_TransactionListDataDto) _then;

/// Create a copy of TransactionListDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactions = null,}) {
  return _then(_TransactionListDataDto(
transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionDto>,
  ));
}


}


/// @nodoc
mixin _$TransferSummaryDataDto {

 String get transferId; String get beneficiary; MoneyDto get amount; String get status; DateTime get executedAt;
/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferSummaryDataDtoCopyWith<TransferSummaryDataDto> get copyWith => _$TransferSummaryDataDtoCopyWithImpl<TransferSummaryDataDto>(this as TransferSummaryDataDto, _$identity);

  /// Serializes this TransferSummaryDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransferSummaryDataDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferSummaryDataDto&&(identical(other.transferId, _this.transferId) || other.transferId == _this.transferId)&&(identical(other.beneficiary, _this.beneficiary) || other.beneficiary == _this.beneficiary)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.executedAt, _this.executedAt) || other.executedAt == _this.executedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransferSummaryDataDto;
  return Object.hash(runtimeType,_this.transferId,_this.beneficiary,_this.amount,_this.status,_this.executedAt);
}

@override
String toString() {
  final _this = this as TransferSummaryDataDto;
  return 'TransferSummaryDataDto(transferId: ${_this.transferId}, beneficiary: ${_this.beneficiary}, amount: ${_this.amount}, status: ${_this.status}, executedAt: ${_this.executedAt})';
}


}

/// @nodoc
abstract mixin class $TransferSummaryDataDtoCopyWith<$Res>  {
  factory $TransferSummaryDataDtoCopyWith(TransferSummaryDataDto value, $Res Function(TransferSummaryDataDto) _then) = _$TransferSummaryDataDtoCopyWithImpl;
@useResult
$Res call({
 String transferId, String beneficiary, MoneyDto amount, String status, DateTime executedAt
});


$MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class _$TransferSummaryDataDtoCopyWithImpl<$Res>
    implements $TransferSummaryDataDtoCopyWith<$Res> {
  _$TransferSummaryDataDtoCopyWithImpl(this._self, this._then);

  final TransferSummaryDataDto _self;
  final $Res Function(TransferSummaryDataDto) _then;

/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transferId = null,Object? beneficiary = null,Object? amount = null,Object? status = null,Object? executedAt = null,}) {
  return _then(TransferSummaryDataDto(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,beneficiary: null == beneficiary ? _self.beneficiary : beneficiary // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransferSummaryDataDto].
extension TransferSummaryDataDtoPatterns on TransferSummaryDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferSummaryDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferSummaryDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferSummaryDataDto value)  $default,){
final _that = this;
switch (_that) {
case _TransferSummaryDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferSummaryDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransferSummaryDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transferId,  String beneficiary,  MoneyDto amount,  String status,  DateTime executedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferSummaryDataDto() when $default != null:
return $default(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transferId,  String beneficiary,  MoneyDto amount,  String status,  DateTime executedAt)  $default,) {final _that = this;
switch (_that) {
case _TransferSummaryDataDto():
return $default(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transferId,  String beneficiary,  MoneyDto amount,  String status,  DateTime executedAt)?  $default,) {final _that = this;
switch (_that) {
case _TransferSummaryDataDto() when $default != null:
return $default(_that.transferId,_that.beneficiary,_that.amount,_that.status,_that.executedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferSummaryDataDto implements TransferSummaryDataDto {
  const _TransferSummaryDataDto({required this.transferId, required this.beneficiary, required this.amount, required this.status, required this.executedAt});
  factory _TransferSummaryDataDto.fromJson(Map<String, dynamic> json) => _$TransferSummaryDataDtoFromJson(json);

@override final  String transferId;
@override final  String beneficiary;
@override final  MoneyDto amount;
@override final  String status;
@override final  DateTime executedAt;

/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferSummaryDataDtoCopyWith<_TransferSummaryDataDto> get copyWith => __$TransferSummaryDataDtoCopyWithImpl<_TransferSummaryDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferSummaryDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferSummaryDataDto&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.beneficiary, beneficiary) || other.beneficiary == beneficiary)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transferId,beneficiary,amount,status,executedAt);
}

@override
String toString() {
    return 'TransferSummaryDataDto(transferId: $transferId, beneficiary: $beneficiary, amount: $amount, status: $status, executedAt: $executedAt)';
}


}

/// @nodoc
abstract mixin class _$TransferSummaryDataDtoCopyWith<$Res> implements $TransferSummaryDataDtoCopyWith<$Res> {
  factory _$TransferSummaryDataDtoCopyWith(_TransferSummaryDataDto value, $Res Function(_TransferSummaryDataDto) _then) = __$TransferSummaryDataDtoCopyWithImpl;
@override @useResult
$Res call({
 String transferId, String beneficiary, MoneyDto amount, String status, DateTime executedAt
});


@override $MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class __$TransferSummaryDataDtoCopyWithImpl<$Res>
    implements _$TransferSummaryDataDtoCopyWith<$Res> {
  __$TransferSummaryDataDtoCopyWithImpl(this._self, this._then);

  final _TransferSummaryDataDto _self;
  final $Res Function(_TransferSummaryDataDto) _then;

/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transferId = null,Object? beneficiary = null,Object? amount = null,Object? status = null,Object? executedAt = null,}) {
  return _then(_TransferSummaryDataDto(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,beneficiary: null == beneficiary ? _self.beneficiary : beneficiary // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TransferSummaryDataDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// @nodoc
mixin _$MoneyDto {

 String get amount; String get currency;
/// Create a copy of MoneyDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<MoneyDto> get copyWith => _$MoneyDtoCopyWithImpl<MoneyDto>(this as MoneyDto, _$identity);

  /// Serializes this MoneyDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MoneyDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoneyDto&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MoneyDto;
  return Object.hash(runtimeType,_this.amount,_this.currency);
}

@override
String toString() {
  final _this = this as MoneyDto;
  return 'MoneyDto(amount: ${_this.amount}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $MoneyDtoCopyWith<$Res>  {
  factory $MoneyDtoCopyWith(MoneyDto value, $Res Function(MoneyDto) _then) = _$MoneyDtoCopyWithImpl;
@useResult
$Res call({
 String amount, String currency
});




}
/// @nodoc
class _$MoneyDtoCopyWithImpl<$Res>
    implements $MoneyDtoCopyWith<$Res> {
  _$MoneyDtoCopyWithImpl(this._self, this._then);

  final MoneyDto _self;
  final $Res Function(MoneyDto) _then;

/// Create a copy of MoneyDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,}) {
  return _then(MoneyDto(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoneyDto].
extension MoneyDtoPatterns on MoneyDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoneyDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoneyDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoneyDto value)  $default,){
final _that = this;
switch (_that) {
case _MoneyDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoneyDto value)?  $default,){
final _that = this;
switch (_that) {
case _MoneyDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String amount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoneyDto() when $default != null:
return $default(_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String amount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _MoneyDto():
return $default(_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String amount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _MoneyDto() when $default != null:
return $default(_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoneyDto implements MoneyDto {
  const _MoneyDto({required this.amount, required this.currency});
  factory _MoneyDto.fromJson(Map<String, dynamic> json) => _$MoneyDtoFromJson(json);

@override final  String amount;
@override final  String currency;

/// Create a copy of MoneyDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyDtoCopyWith<_MoneyDto> get copyWith => __$MoneyDtoCopyWithImpl<_MoneyDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoneyDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoneyDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,amount,currency);
}

@override
String toString() {
    return 'MoneyDto(amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$MoneyDtoCopyWith<$Res> implements $MoneyDtoCopyWith<$Res> {
  factory _$MoneyDtoCopyWith(_MoneyDto value, $Res Function(_MoneyDto) _then) = __$MoneyDtoCopyWithImpl;
@override @useResult
$Res call({
 String amount, String currency
});




}
/// @nodoc
class __$MoneyDtoCopyWithImpl<$Res>
    implements _$MoneyDtoCopyWith<$Res> {
  __$MoneyDtoCopyWithImpl(this._self, this._then);

  final _MoneyDto _self;
  final $Res Function(_MoneyDto) _then;

/// Create a copy of MoneyDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,}) {
  return _then(_MoneyDto(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CardDto {

 String get id; String get brand; String get type; String get lastFour; String get status;
/// Create a copy of CardDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDtoCopyWith<CardDto> get copyWith => _$CardDtoCopyWithImpl<CardDto>(this as CardDto, _$identity);

  /// Serializes this CardDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.lastFour, _this.lastFour) || other.lastFour == _this.lastFour)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardDto;
  return Object.hash(runtimeType,_this.id,_this.brand,_this.type,_this.lastFour,_this.status);
}

@override
String toString() {
  final _this = this as CardDto;
  return 'CardDto(id: ${_this.id}, brand: ${_this.brand}, type: ${_this.type}, lastFour: ${_this.lastFour}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $CardDtoCopyWith<$Res>  {
  factory $CardDtoCopyWith(CardDto value, $Res Function(CardDto) _then) = _$CardDtoCopyWithImpl;
@useResult
$Res call({
 String id, String brand, String type, String lastFour, String status
});




}
/// @nodoc
class _$CardDtoCopyWithImpl<$Res>
    implements $CardDtoCopyWith<$Res> {
  _$CardDtoCopyWithImpl(this._self, this._then);

  final CardDto _self;
  final $Res Function(CardDto) _then;

/// Create a copy of CardDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? brand = null,Object? type = null,Object? lastFour = null,Object? status = null,}) {
  return _then(CardDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardDto].
extension CardDtoPatterns on CardDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardDto value)  $default,){
final _that = this;
switch (_that) {
case _CardDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardDto value)?  $default,){
final _that = this;
switch (_that) {
case _CardDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String brand,  String type,  String lastFour,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String brand,  String type,  String lastFour,  String status)  $default,) {final _that = this;
switch (_that) {
case _CardDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String brand,  String type,  String lastFour,  String status)?  $default,) {final _that = this;
switch (_that) {
case _CardDto() when $default != null:
return $default(_that.id,_that.brand,_that.type,_that.lastFour,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardDto implements CardDto {
  const _CardDto({required this.id, required this.brand, required this.type, required this.lastFour, required this.status});
  factory _CardDto.fromJson(Map<String, dynamic> json) => _$CardDtoFromJson(json);

@override final  String id;
@override final  String brand;
@override final  String type;
@override final  String lastFour;
@override final  String status;

/// Create a copy of CardDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardDtoCopyWith<_CardDto> get copyWith => __$CardDtoCopyWithImpl<_CardDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardDto&&(identical(other.id, id) || other.id == id)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastFour, lastFour) || other.lastFour == lastFour)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,brand,type,lastFour,status);
}

@override
String toString() {
    return 'CardDto(id: $id, brand: $brand, type: $type, lastFour: $lastFour, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CardDtoCopyWith<$Res> implements $CardDtoCopyWith<$Res> {
  factory _$CardDtoCopyWith(_CardDto value, $Res Function(_CardDto) _then) = __$CardDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String brand, String type, String lastFour, String status
});




}
/// @nodoc
class __$CardDtoCopyWithImpl<$Res>
    implements _$CardDtoCopyWith<$Res> {
  __$CardDtoCopyWithImpl(this._self, this._then);

  final _CardDto _self;
  final $Res Function(_CardDto) _then;

/// Create a copy of CardDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brand = null,Object? type = null,Object? lastFour = null,Object? status = null,}) {
  return _then(_CardDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BeneficiaryDto {

 String get id; String get name; String get accountReference; String? get bankName;
/// Create a copy of BeneficiaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeneficiaryDtoCopyWith<BeneficiaryDto> get copyWith => _$BeneficiaryDtoCopyWithImpl<BeneficiaryDto>(this as BeneficiaryDto, _$identity);

  /// Serializes this BeneficiaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BeneficiaryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeneficiaryDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.accountReference, _this.accountReference) || other.accountReference == _this.accountReference)&&(identical(other.bankName, _this.bankName) || other.bankName == _this.bankName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BeneficiaryDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.accountReference,_this.bankName);
}

@override
String toString() {
  final _this = this as BeneficiaryDto;
  return 'BeneficiaryDto(id: ${_this.id}, name: ${_this.name}, accountReference: ${_this.accountReference}, bankName: ${_this.bankName})';
}


}

/// @nodoc
abstract mixin class $BeneficiaryDtoCopyWith<$Res>  {
  factory $BeneficiaryDtoCopyWith(BeneficiaryDto value, $Res Function(BeneficiaryDto) _then) = _$BeneficiaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String accountReference, String? bankName
});




}
/// @nodoc
class _$BeneficiaryDtoCopyWithImpl<$Res>
    implements $BeneficiaryDtoCopyWith<$Res> {
  _$BeneficiaryDtoCopyWithImpl(this._self, this._then);

  final BeneficiaryDto _self;
  final $Res Function(BeneficiaryDto) _then;

/// Create a copy of BeneficiaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? accountReference = null,Object? bankName = freezed,}) {
  return _then(BeneficiaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountReference: null == accountReference ? _self.accountReference : accountReference // ignore: cast_nullable_to_non_nullable
as String,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BeneficiaryDto].
extension BeneficiaryDtoPatterns on BeneficiaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BeneficiaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BeneficiaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BeneficiaryDto value)  $default,){
final _that = this;
switch (_that) {
case _BeneficiaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BeneficiaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _BeneficiaryDto() when $default != null:
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
case _BeneficiaryDto() when $default != null:
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
case _BeneficiaryDto():
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
case _BeneficiaryDto() when $default != null:
return $default(_that.id,_that.name,_that.accountReference,_that.bankName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BeneficiaryDto implements BeneficiaryDto {
  const _BeneficiaryDto({required this.id, required this.name, required this.accountReference, required this.bankName});
  factory _BeneficiaryDto.fromJson(Map<String, dynamic> json) => _$BeneficiaryDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String accountReference;
@override final  String? bankName;

/// Create a copy of BeneficiaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BeneficiaryDtoCopyWith<_BeneficiaryDto> get copyWith => __$BeneficiaryDtoCopyWithImpl<_BeneficiaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BeneficiaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BeneficiaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accountReference, accountReference) || other.accountReference == accountReference)&&(identical(other.bankName, bankName) || other.bankName == bankName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,accountReference,bankName);
}

@override
String toString() {
    return 'BeneficiaryDto(id: $id, name: $name, accountReference: $accountReference, bankName: $bankName)';
}


}

/// @nodoc
abstract mixin class _$BeneficiaryDtoCopyWith<$Res> implements $BeneficiaryDtoCopyWith<$Res> {
  factory _$BeneficiaryDtoCopyWith(_BeneficiaryDto value, $Res Function(_BeneficiaryDto) _then) = __$BeneficiaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String accountReference, String? bankName
});




}
/// @nodoc
class __$BeneficiaryDtoCopyWithImpl<$Res>
    implements _$BeneficiaryDtoCopyWith<$Res> {
  __$BeneficiaryDtoCopyWithImpl(this._self, this._then);

  final _BeneficiaryDto _self;
  final $Res Function(_BeneficiaryDto) _then;

/// Create a copy of BeneficiaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? accountReference = null,Object? bankName = freezed,}) {
  return _then(_BeneficiaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountReference: null == accountReference ? _self.accountReference : accountReference // ignore: cast_nullable_to_non_nullable
as String,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TransactionDto {

 String get id; String get description; MoneyDto get amount; String get type; String get category; DateTime get occurredAt;
/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDtoCopyWith<TransactionDto> get copyWith => _$TransactionDtoCopyWithImpl<TransactionDto>(this as TransactionDto, _$identity);

  /// Serializes this TransactionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransactionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransactionDto;
  return Object.hash(runtimeType,_this.id,_this.description,_this.amount,_this.type,_this.category,_this.occurredAt);
}

@override
String toString() {
  final _this = this as TransactionDto;
  return 'TransactionDto(id: ${_this.id}, description: ${_this.description}, amount: ${_this.amount}, type: ${_this.type}, category: ${_this.category}, occurredAt: ${_this.occurredAt})';
}


}

/// @nodoc
abstract mixin class $TransactionDtoCopyWith<$Res>  {
  factory $TransactionDtoCopyWith(TransactionDto value, $Res Function(TransactionDto) _then) = _$TransactionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String description, MoneyDto amount, String type, String category, DateTime occurredAt
});


$MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class _$TransactionDtoCopyWithImpl<$Res>
    implements $TransactionDtoCopyWith<$Res> {
  _$TransactionDtoCopyWithImpl(this._self, this._then);

  final TransactionDto _self;
  final $Res Function(TransactionDto) _then;

/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? amount = null,Object? type = null,Object? category = null,Object? occurredAt = null,}) {
  return _then(TransactionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionDto].
extension TransactionDtoPatterns on TransactionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionDto value)  $default,){
final _that = this;
switch (_that) {
case _TransactionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  MoneyDto amount,  String type,  String category,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  MoneyDto amount,  String type,  String category,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  MoneyDto amount,  String type,  String category,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionDto() when $default != null:
return $default(_that.id,_that.description,_that.amount,_that.type,_that.category,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionDto implements TransactionDto {
  const _TransactionDto({required this.id, required this.description, required this.amount, required this.type, required this.category, required this.occurredAt});
  factory _TransactionDto.fromJson(Map<String, dynamic> json) => _$TransactionDtoFromJson(json);

@override final  String id;
@override final  String description;
@override final  MoneyDto amount;
@override final  String type;
@override final  String category;
@override final  DateTime occurredAt;

/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDtoCopyWith<_TransactionDto> get copyWith => __$TransactionDtoCopyWithImpl<_TransactionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,description,amount,type,category,occurredAt);
}

@override
String toString() {
    return 'TransactionDto(id: $id, description: $description, amount: $amount, type: $type, category: $category, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionDtoCopyWith<$Res> implements $TransactionDtoCopyWith<$Res> {
  factory _$TransactionDtoCopyWith(_TransactionDto value, $Res Function(_TransactionDto) _then) = __$TransactionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, MoneyDto amount, String type, String category, DateTime occurredAt
});


@override $MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class __$TransactionDtoCopyWithImpl<$Res>
    implements _$TransactionDtoCopyWith<$Res> {
  __$TransactionDtoCopyWithImpl(this._self, this._then);

  final _TransactionDto _self;
  final $Res Function(_TransactionDto) _then;

/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? amount = null,Object? type = null,Object? category = null,Object? occurredAt = null,}) {
  return _then(_TransactionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TransactionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// @nodoc
mixin _$ExpensePeriodDto {

 String get from; String get to;
/// Create a copy of ExpensePeriodDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensePeriodDtoCopyWith<ExpensePeriodDto> get copyWith => _$ExpensePeriodDtoCopyWithImpl<ExpensePeriodDto>(this as ExpensePeriodDto, _$identity);

  /// Serializes this ExpensePeriodDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpensePeriodDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensePeriodDto&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpensePeriodDto;
  return Object.hash(runtimeType,_this.from,_this.to);
}

@override
String toString() {
  final _this = this as ExpensePeriodDto;
  return 'ExpensePeriodDto(from: ${_this.from}, to: ${_this.to})';
}


}

/// @nodoc
abstract mixin class $ExpensePeriodDtoCopyWith<$Res>  {
  factory $ExpensePeriodDtoCopyWith(ExpensePeriodDto value, $Res Function(ExpensePeriodDto) _then) = _$ExpensePeriodDtoCopyWithImpl;
@useResult
$Res call({
 String from, String to
});




}
/// @nodoc
class _$ExpensePeriodDtoCopyWithImpl<$Res>
    implements $ExpensePeriodDtoCopyWith<$Res> {
  _$ExpensePeriodDtoCopyWithImpl(this._self, this._then);

  final ExpensePeriodDto _self;
  final $Res Function(ExpensePeriodDto) _then;

/// Create a copy of ExpensePeriodDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,}) {
  return _then(ExpensePeriodDto(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensePeriodDto].
extension ExpensePeriodDtoPatterns on ExpensePeriodDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpensePeriodDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpensePeriodDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpensePeriodDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpensePeriodDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpensePeriodDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpensePeriodDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String from,  String to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpensePeriodDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String from,  String to)  $default,) {final _that = this;
switch (_that) {
case _ExpensePeriodDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String from,  String to)?  $default,) {final _that = this;
switch (_that) {
case _ExpensePeriodDto() when $default != null:
return $default(_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpensePeriodDto implements ExpensePeriodDto {
  const _ExpensePeriodDto({required this.from, required this.to});
  factory _ExpensePeriodDto.fromJson(Map<String, dynamic> json) => _$ExpensePeriodDtoFromJson(json);

@override final  String from;
@override final  String to;

/// Create a copy of ExpensePeriodDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpensePeriodDtoCopyWith<_ExpensePeriodDto> get copyWith => __$ExpensePeriodDtoCopyWithImpl<_ExpensePeriodDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpensePeriodDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpensePeriodDto&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,from,to);
}

@override
String toString() {
    return 'ExpensePeriodDto(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$ExpensePeriodDtoCopyWith<$Res> implements $ExpensePeriodDtoCopyWith<$Res> {
  factory _$ExpensePeriodDtoCopyWith(_ExpensePeriodDto value, $Res Function(_ExpensePeriodDto) _then) = __$ExpensePeriodDtoCopyWithImpl;
@override @useResult
$Res call({
 String from, String to
});




}
/// @nodoc
class __$ExpensePeriodDtoCopyWithImpl<$Res>
    implements _$ExpensePeriodDtoCopyWith<$Res> {
  __$ExpensePeriodDtoCopyWithImpl(this._self, this._then);

  final _ExpensePeriodDto _self;
  final $Res Function(_ExpensePeriodDto) _then;

/// Create a copy of ExpensePeriodDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(_ExpensePeriodDto(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CurrencyExpensesDto {

 MoneyDto get total; List<CategoryExpenseDto> get categories;
/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyExpensesDtoCopyWith<CurrencyExpensesDto> get copyWith => _$CurrencyExpensesDtoCopyWithImpl<CurrencyExpensesDto>(this as CurrencyExpensesDto, _$identity);

  /// Serializes this CurrencyExpensesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrencyExpensesDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencyExpensesDto&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrencyExpensesDto;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as CurrencyExpensesDto;
  return 'CurrencyExpensesDto(total: ${_this.total}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $CurrencyExpensesDtoCopyWith<$Res>  {
  factory $CurrencyExpensesDtoCopyWith(CurrencyExpensesDto value, $Res Function(CurrencyExpensesDto) _then) = _$CurrencyExpensesDtoCopyWithImpl;
@useResult
$Res call({
 MoneyDto total, List<CategoryExpenseDto> categories
});


$MoneyDtoCopyWith<$Res> get total;

}
/// @nodoc
class _$CurrencyExpensesDtoCopyWithImpl<$Res>
    implements $CurrencyExpensesDtoCopyWith<$Res> {
  _$CurrencyExpensesDtoCopyWithImpl(this._self, this._then);

  final CurrencyExpensesDto _self;
  final $Res Function(CurrencyExpensesDto) _then;

/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? categories = null,}) {
  return _then(CurrencyExpensesDto(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as MoneyDto,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpenseDto>,
  ));
}
/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get total {
  
  return $MoneyDtoCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrencyExpensesDto].
extension CurrencyExpensesDtoPatterns on CurrencyExpensesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencyExpensesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencyExpensesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencyExpensesDto value)  $default,){
final _that = this;
switch (_that) {
case _CurrencyExpensesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencyExpensesDto value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencyExpensesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoneyDto total,  List<CategoryExpenseDto> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencyExpensesDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoneyDto total,  List<CategoryExpenseDto> categories)  $default,) {final _that = this;
switch (_that) {
case _CurrencyExpensesDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoneyDto total,  List<CategoryExpenseDto> categories)?  $default,) {final _that = this;
switch (_that) {
case _CurrencyExpensesDto() when $default != null:
return $default(_that.total,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrencyExpensesDto implements CurrencyExpensesDto {
  const _CurrencyExpensesDto({required this.total, required  List<CategoryExpenseDto> categories}): _categories = categories;
  factory _CurrencyExpensesDto.fromJson(Map<String, dynamic> json) => _$CurrencyExpensesDtoFromJson(json);

@override final  MoneyDto total;
 final  List<CategoryExpenseDto> _categories;
@override List<CategoryExpenseDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyExpensesDtoCopyWith<_CurrencyExpensesDto> get copyWith => __$CurrencyExpensesDtoCopyWithImpl<_CurrencyExpensesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrencyExpensesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencyExpensesDto&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'CurrencyExpensesDto(total: $total, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$CurrencyExpensesDtoCopyWith<$Res> implements $CurrencyExpensesDtoCopyWith<$Res> {
  factory _$CurrencyExpensesDtoCopyWith(_CurrencyExpensesDto value, $Res Function(_CurrencyExpensesDto) _then) = __$CurrencyExpensesDtoCopyWithImpl;
@override @useResult
$Res call({
 MoneyDto total, List<CategoryExpenseDto> categories
});


@override $MoneyDtoCopyWith<$Res> get total;

}
/// @nodoc
class __$CurrencyExpensesDtoCopyWithImpl<$Res>
    implements _$CurrencyExpensesDtoCopyWith<$Res> {
  __$CurrencyExpensesDtoCopyWithImpl(this._self, this._then);

  final _CurrencyExpensesDto _self;
  final $Res Function(_CurrencyExpensesDto) _then;

/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? categories = null,}) {
  return _then(_CurrencyExpensesDto(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as MoneyDto,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryExpenseDto>,
  ));
}

/// Create a copy of CurrencyExpensesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get total {
  
  return $MoneyDtoCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// @nodoc
mixin _$CategoryExpenseDto {

 String get category; MoneyDto get amount;
/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryExpenseDtoCopyWith<CategoryExpenseDto> get copyWith => _$CategoryExpenseDtoCopyWithImpl<CategoryExpenseDto>(this as CategoryExpenseDto, _$identity);

  /// Serializes this CategoryExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CategoryExpenseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryExpenseDto&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CategoryExpenseDto;
  return Object.hash(runtimeType,_this.category,_this.amount);
}

@override
String toString() {
  final _this = this as CategoryExpenseDto;
  return 'CategoryExpenseDto(category: ${_this.category}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $CategoryExpenseDtoCopyWith<$Res>  {
  factory $CategoryExpenseDtoCopyWith(CategoryExpenseDto value, $Res Function(CategoryExpenseDto) _then) = _$CategoryExpenseDtoCopyWithImpl;
@useResult
$Res call({
 String category, MoneyDto amount
});


$MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class _$CategoryExpenseDtoCopyWithImpl<$Res>
    implements $CategoryExpenseDtoCopyWith<$Res> {
  _$CategoryExpenseDtoCopyWithImpl(this._self, this._then);

  final CategoryExpenseDto _self;
  final $Res Function(CategoryExpenseDto) _then;

/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? amount = null,}) {
  return _then(CategoryExpenseDto(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,
  ));
}
/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryExpenseDto].
extension CategoryExpenseDtoPatterns on CategoryExpenseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryExpenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryExpenseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryExpenseDto value)  $default,){
final _that = this;
switch (_that) {
case _CategoryExpenseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryExpenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryExpenseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  MoneyDto amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryExpenseDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  MoneyDto amount)  $default,) {final _that = this;
switch (_that) {
case _CategoryExpenseDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  MoneyDto amount)?  $default,) {final _that = this;
switch (_that) {
case _CategoryExpenseDto() when $default != null:
return $default(_that.category,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryExpenseDto implements CategoryExpenseDto {
  const _CategoryExpenseDto({required this.category, required this.amount});
  factory _CategoryExpenseDto.fromJson(Map<String, dynamic> json) => _$CategoryExpenseDtoFromJson(json);

@override final  String category;
@override final  MoneyDto amount;

/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryExpenseDtoCopyWith<_CategoryExpenseDto> get copyWith => __$CategoryExpenseDtoCopyWithImpl<_CategoryExpenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryExpenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryExpenseDto&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,category,amount);
}

@override
String toString() {
    return 'CategoryExpenseDto(category: $category, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$CategoryExpenseDtoCopyWith<$Res> implements $CategoryExpenseDtoCopyWith<$Res> {
  factory _$CategoryExpenseDtoCopyWith(_CategoryExpenseDto value, $Res Function(_CategoryExpenseDto) _then) = __$CategoryExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String category, MoneyDto amount
});


@override $MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class __$CategoryExpenseDtoCopyWithImpl<$Res>
    implements _$CategoryExpenseDtoCopyWith<$Res> {
  __$CategoryExpenseDtoCopyWithImpl(this._self, this._then);

  final _CategoryExpenseDto _self;
  final $Res Function(_CategoryExpenseDto) _then;

/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? amount = null,}) {
  return _then(_CategoryExpenseDto(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,
  ));
}

/// Create a copy of CategoryExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// @nodoc
mixin _$CurrencyComparisonDto {

 MoneyDto get currentTotal; MoneyDto get previousTotal; MoneyDto get difference; String get change;
/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyComparisonDtoCopyWith<CurrencyComparisonDto> get copyWith => _$CurrencyComparisonDtoCopyWithImpl<CurrencyComparisonDto>(this as CurrencyComparisonDto, _$identity);

  /// Serializes this CurrencyComparisonDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrencyComparisonDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencyComparisonDto&&(identical(other.currentTotal, _this.currentTotal) || other.currentTotal == _this.currentTotal)&&(identical(other.previousTotal, _this.previousTotal) || other.previousTotal == _this.previousTotal)&&(identical(other.difference, _this.difference) || other.difference == _this.difference)&&(identical(other.change, _this.change) || other.change == _this.change));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrencyComparisonDto;
  return Object.hash(runtimeType,_this.currentTotal,_this.previousTotal,_this.difference,_this.change);
}

@override
String toString() {
  final _this = this as CurrencyComparisonDto;
  return 'CurrencyComparisonDto(currentTotal: ${_this.currentTotal}, previousTotal: ${_this.previousTotal}, difference: ${_this.difference}, change: ${_this.change})';
}


}

/// @nodoc
abstract mixin class $CurrencyComparisonDtoCopyWith<$Res>  {
  factory $CurrencyComparisonDtoCopyWith(CurrencyComparisonDto value, $Res Function(CurrencyComparisonDto) _then) = _$CurrencyComparisonDtoCopyWithImpl;
@useResult
$Res call({
 MoneyDto currentTotal, MoneyDto previousTotal, MoneyDto difference, String change
});


$MoneyDtoCopyWith<$Res> get currentTotal;$MoneyDtoCopyWith<$Res> get previousTotal;$MoneyDtoCopyWith<$Res> get difference;

}
/// @nodoc
class _$CurrencyComparisonDtoCopyWithImpl<$Res>
    implements $CurrencyComparisonDtoCopyWith<$Res> {
  _$CurrencyComparisonDtoCopyWithImpl(this._self, this._then);

  final CurrencyComparisonDto _self;
  final $Res Function(CurrencyComparisonDto) _then;

/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? difference = null,Object? change = null,}) {
  return _then(CurrencyComparisonDto(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as MoneyDto,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as MoneyDto,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as MoneyDto,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get currentTotal {
  
  return $MoneyDtoCopyWith<$Res>(_self.currentTotal, (value) {
    return _then(_self.copyWith(currentTotal: value));
  });
}/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get previousTotal {
  
  return $MoneyDtoCopyWith<$Res>(_self.previousTotal, (value) {
    return _then(_self.copyWith(previousTotal: value));
  });
}/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get difference {
  
  return $MoneyDtoCopyWith<$Res>(_self.difference, (value) {
    return _then(_self.copyWith(difference: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrencyComparisonDto].
extension CurrencyComparisonDtoPatterns on CurrencyComparisonDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencyComparisonDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencyComparisonDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencyComparisonDto value)  $default,){
final _that = this;
switch (_that) {
case _CurrencyComparisonDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencyComparisonDto value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencyComparisonDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MoneyDto currentTotal,  MoneyDto previousTotal,  MoneyDto difference,  String change)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencyComparisonDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MoneyDto currentTotal,  MoneyDto previousTotal,  MoneyDto difference,  String change)  $default,) {final _that = this;
switch (_that) {
case _CurrencyComparisonDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MoneyDto currentTotal,  MoneyDto previousTotal,  MoneyDto difference,  String change)?  $default,) {final _that = this;
switch (_that) {
case _CurrencyComparisonDto() when $default != null:
return $default(_that.currentTotal,_that.previousTotal,_that.difference,_that.change);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrencyComparisonDto implements CurrencyComparisonDto {
  const _CurrencyComparisonDto({required this.currentTotal, required this.previousTotal, required this.difference, required this.change});
  factory _CurrencyComparisonDto.fromJson(Map<String, dynamic> json) => _$CurrencyComparisonDtoFromJson(json);

@override final  MoneyDto currentTotal;
@override final  MoneyDto previousTotal;
@override final  MoneyDto difference;
@override final  String change;

/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyComparisonDtoCopyWith<_CurrencyComparisonDto> get copyWith => __$CurrencyComparisonDtoCopyWithImpl<_CurrencyComparisonDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrencyComparisonDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencyComparisonDto&&(identical(other.currentTotal, currentTotal) || other.currentTotal == currentTotal)&&(identical(other.previousTotal, previousTotal) || other.previousTotal == previousTotal)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.change, change) || other.change == change));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentTotal,previousTotal,difference,change);
}

@override
String toString() {
    return 'CurrencyComparisonDto(currentTotal: $currentTotal, previousTotal: $previousTotal, difference: $difference, change: $change)';
}


}

/// @nodoc
abstract mixin class _$CurrencyComparisonDtoCopyWith<$Res> implements $CurrencyComparisonDtoCopyWith<$Res> {
  factory _$CurrencyComparisonDtoCopyWith(_CurrencyComparisonDto value, $Res Function(_CurrencyComparisonDto) _then) = __$CurrencyComparisonDtoCopyWithImpl;
@override @useResult
$Res call({
 MoneyDto currentTotal, MoneyDto previousTotal, MoneyDto difference, String change
});


@override $MoneyDtoCopyWith<$Res> get currentTotal;@override $MoneyDtoCopyWith<$Res> get previousTotal;@override $MoneyDtoCopyWith<$Res> get difference;

}
/// @nodoc
class __$CurrencyComparisonDtoCopyWithImpl<$Res>
    implements _$CurrencyComparisonDtoCopyWith<$Res> {
  __$CurrencyComparisonDtoCopyWithImpl(this._self, this._then);

  final _CurrencyComparisonDto _self;
  final $Res Function(_CurrencyComparisonDto) _then;

/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentTotal = null,Object? previousTotal = null,Object? difference = null,Object? change = null,}) {
  return _then(_CurrencyComparisonDto(
currentTotal: null == currentTotal ? _self.currentTotal : currentTotal // ignore: cast_nullable_to_non_nullable
as MoneyDto,previousTotal: null == previousTotal ? _self.previousTotal : previousTotal // ignore: cast_nullable_to_non_nullable
as MoneyDto,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as MoneyDto,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get currentTotal {
  
  return $MoneyDtoCopyWith<$Res>(_self.currentTotal, (value) {
    return _then(_self.copyWith(currentTotal: value));
  });
}/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get previousTotal {
  
  return $MoneyDtoCopyWith<$Res>(_self.previousTotal, (value) {
    return _then(_self.copyWith(previousTotal: value));
  });
}/// Create a copy of CurrencyComparisonDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get difference {
  
  return $MoneyDtoCopyWith<$Res>(_self.difference, (value) {
    return _then(_self.copyWith(difference: value));
  });
}
}

ConfirmationSummaryDto _$ConfirmationSummaryDtoFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'TRANSFER':
          return TransferConfirmationSummaryDto.fromJson(
            json
          );
                case 'CARD':
          return CardConfirmationSummaryDto.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'ConfirmationSummaryDto',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$ConfirmationSummaryDto {



  /// Serializes this ConfirmationSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationSummaryDto);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConfirmationSummaryDto()';
}


}

/// @nodoc
class $ConfirmationSummaryDtoCopyWith<$Res>  {
$ConfirmationSummaryDtoCopyWith(ConfirmationSummaryDto _, $Res Function(ConfirmationSummaryDto) __);
}


/// Adds pattern-matching-related methods to [ConfirmationSummaryDto].
extension ConfirmationSummaryDtoPatterns on ConfirmationSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransferConfirmationSummaryDto value)?  transfer,TResult Function( CardConfirmationSummaryDto value)?  card,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto() when transfer != null:
return transfer(_that);case CardConfirmationSummaryDto() when card != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransferConfirmationSummaryDto value)  transfer,required TResult Function( CardConfirmationSummaryDto value)  card,}){
final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto():
return transfer(_that);case CardConfirmationSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransferConfirmationSummaryDto value)?  transfer,TResult? Function( CardConfirmationSummaryDto value)?  card,}){
final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto() when transfer != null:
return transfer(_that);case CardConfirmationSummaryDto() when card != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MoneyDto amount,  String beneficiary)?  transfer,TResult Function( CardDto card)?  card,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto() when transfer != null:
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummaryDto() when card != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MoneyDto amount,  String beneficiary)  transfer,required TResult Function( CardDto card)  card,}) {final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto():
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummaryDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MoneyDto amount,  String beneficiary)?  transfer,TResult? Function( CardDto card)?  card,}) {final _that = this;
switch (_that) {
case TransferConfirmationSummaryDto() when transfer != null:
return transfer(_that.amount,_that.beneficiary);case CardConfirmationSummaryDto() when card != null:
return card(_that.card);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TransferConfirmationSummaryDto implements ConfirmationSummaryDto {
  const TransferConfirmationSummaryDto({required this.amount, required this.beneficiary,  String? $type}): $type = $type ?? 'TRANSFER';
  factory TransferConfirmationSummaryDto.fromJson(Map<String, dynamic> json) => _$TransferConfirmationSummaryDtoFromJson(json);

 final  MoneyDto amount;
 final  String beneficiary;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferConfirmationSummaryDtoCopyWith<TransferConfirmationSummaryDto> get copyWith => _$TransferConfirmationSummaryDtoCopyWithImpl<TransferConfirmationSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferConfirmationSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferConfirmationSummaryDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.beneficiary, beneficiary) || other.beneficiary == beneficiary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,amount,beneficiary);
}

@override
String toString() {
    return 'ConfirmationSummaryDto.transfer(amount: $amount, beneficiary: $beneficiary)';
}


}

/// @nodoc
abstract mixin class $TransferConfirmationSummaryDtoCopyWith<$Res> implements $ConfirmationSummaryDtoCopyWith<$Res> {
  factory $TransferConfirmationSummaryDtoCopyWith(TransferConfirmationSummaryDto value, $Res Function(TransferConfirmationSummaryDto) _then) = _$TransferConfirmationSummaryDtoCopyWithImpl;
@useResult
$Res call({
 MoneyDto amount, String beneficiary
});


$MoneyDtoCopyWith<$Res> get amount;

}
/// @nodoc
class _$TransferConfirmationSummaryDtoCopyWithImpl<$Res>
    implements $TransferConfirmationSummaryDtoCopyWith<$Res> {
  _$TransferConfirmationSummaryDtoCopyWithImpl(this._self, this._then);

  final TransferConfirmationSummaryDto _self;
  final $Res Function(TransferConfirmationSummaryDto) _then;

/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? beneficiary = null,}) {
  return _then(TransferConfirmationSummaryDto(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as MoneyDto,beneficiary: null == beneficiary ? _self.beneficiary : beneficiary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyDtoCopyWith<$Res> get amount {
  
  return $MoneyDtoCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class CardConfirmationSummaryDto implements ConfirmationSummaryDto {
  const CardConfirmationSummaryDto({required this.card,  String? $type}): $type = $type ?? 'CARD';
  factory CardConfirmationSummaryDto.fromJson(Map<String, dynamic> json) => _$CardConfirmationSummaryDtoFromJson(json);

 final  CardDto card;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardConfirmationSummaryDtoCopyWith<CardConfirmationSummaryDto> get copyWith => _$CardConfirmationSummaryDtoCopyWithImpl<CardConfirmationSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardConfirmationSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardConfirmationSummaryDto&&(identical(other.card, card) || other.card == card));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,card);
}

@override
String toString() {
    return 'ConfirmationSummaryDto.card(card: $card)';
}


}

/// @nodoc
abstract mixin class $CardConfirmationSummaryDtoCopyWith<$Res> implements $ConfirmationSummaryDtoCopyWith<$Res> {
  factory $CardConfirmationSummaryDtoCopyWith(CardConfirmationSummaryDto value, $Res Function(CardConfirmationSummaryDto) _then) = _$CardConfirmationSummaryDtoCopyWithImpl;
@useResult
$Res call({
 CardDto card
});


$CardDtoCopyWith<$Res> get card;

}
/// @nodoc
class _$CardConfirmationSummaryDtoCopyWithImpl<$Res>
    implements $CardConfirmationSummaryDtoCopyWith<$Res> {
  _$CardConfirmationSummaryDtoCopyWithImpl(this._self, this._then);

  final CardConfirmationSummaryDto _self;
  final $Res Function(CardConfirmationSummaryDto) _then;

/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,}) {
  return _then(CardConfirmationSummaryDto(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as CardDto,
  ));
}

/// Create a copy of ConfirmationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDtoCopyWith<$Res> get card {
  
  return $CardDtoCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// @nodoc
mixin _$ConfirmationActionDto {

 String get type; String get label;
/// Create a copy of ConfirmationActionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationActionDtoCopyWith<ConfirmationActionDto> get copyWith => _$ConfirmationActionDtoCopyWithImpl<ConfirmationActionDto>(this as ConfirmationActionDto, _$identity);

  /// Serializes this ConfirmationActionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfirmationActionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmationActionDto&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfirmationActionDto;
  return Object.hash(runtimeType,_this.type,_this.label);
}

@override
String toString() {
  final _this = this as ConfirmationActionDto;
  return 'ConfirmationActionDto(type: ${_this.type}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $ConfirmationActionDtoCopyWith<$Res>  {
  factory $ConfirmationActionDtoCopyWith(ConfirmationActionDto value, $Res Function(ConfirmationActionDto) _then) = _$ConfirmationActionDtoCopyWithImpl;
@useResult
$Res call({
 String type, String label
});




}
/// @nodoc
class _$ConfirmationActionDtoCopyWithImpl<$Res>
    implements $ConfirmationActionDtoCopyWith<$Res> {
  _$ConfirmationActionDtoCopyWithImpl(this._self, this._then);

  final ConfirmationActionDto _self;
  final $Res Function(ConfirmationActionDto) _then;

/// Create a copy of ConfirmationActionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? label = null,}) {
  return _then(ConfirmationActionDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmationActionDto].
extension ConfirmationActionDtoPatterns on ConfirmationActionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmationActionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmationActionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmationActionDto value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmationActionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmationActionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmationActionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmationActionDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String label)  $default,) {final _that = this;
switch (_that) {
case _ConfirmationActionDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmationActionDto() when $default != null:
return $default(_that.type,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmationActionDto implements ConfirmationActionDto {
  const _ConfirmationActionDto({required this.type, required this.label});
  factory _ConfirmationActionDto.fromJson(Map<String, dynamic> json) => _$ConfirmationActionDtoFromJson(json);

@override final  String type;
@override final  String label;

/// Create a copy of ConfirmationActionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmationActionDtoCopyWith<_ConfirmationActionDto> get copyWith => __$ConfirmationActionDtoCopyWithImpl<_ConfirmationActionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmationActionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmationActionDto&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,label);
}

@override
String toString() {
    return 'ConfirmationActionDto(type: $type, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ConfirmationActionDtoCopyWith<$Res> implements $ConfirmationActionDtoCopyWith<$Res> {
  factory _$ConfirmationActionDtoCopyWith(_ConfirmationActionDto value, $Res Function(_ConfirmationActionDto) _then) = __$ConfirmationActionDtoCopyWithImpl;
@override @useResult
$Res call({
 String type, String label
});




}
/// @nodoc
class __$ConfirmationActionDtoCopyWithImpl<$Res>
    implements _$ConfirmationActionDtoCopyWith<$Res> {
  __$ConfirmationActionDtoCopyWithImpl(this._self, this._then);

  final _ConfirmationActionDto _self;
  final $Res Function(_ConfirmationActionDto) _then;

/// Create a copy of ConfirmationActionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? label = null,}) {
  return _then(_ConfirmationActionDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
