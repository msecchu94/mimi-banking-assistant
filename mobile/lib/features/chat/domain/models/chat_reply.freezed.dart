// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatReply {

 String get conversationId;/// The text to show.
 String get message; ChatIntent get intent; ConversationState get conversationState; ChatUi get ui;
/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatReplyCopyWith<ChatReply> get copyWith => _$ChatReplyCopyWithImpl<ChatReply>(this as ChatReply, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatReply;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatReply&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&(identical(other.conversationState, _this.conversationState) || other.conversationState == _this.conversationState)&&(identical(other.ui, _this.ui) || other.ui == _this.ui));
}


@override
int get hashCode {
  final _this = this as ChatReply;
  return Object.hash(runtimeType,_this.conversationId,_this.message,_this.intent,_this.conversationState,_this.ui);
}

@override
String toString() {
  final _this = this as ChatReply;
  return 'ChatReply(conversationId: ${_this.conversationId}, message: ${_this.message}, intent: ${_this.intent}, conversationState: ${_this.conversationState}, ui: ${_this.ui})';
}


}

/// @nodoc
abstract mixin class $ChatReplyCopyWith<$Res>  {
  factory $ChatReplyCopyWith(ChatReply value, $Res Function(ChatReply) _then) = _$ChatReplyCopyWithImpl;
@useResult
$Res call({
 String conversationId, String message, ChatIntent intent, ConversationState conversationState, ChatUi ui
});


$ChatUiCopyWith<$Res> get ui;

}
/// @nodoc
class _$ChatReplyCopyWithImpl<$Res>
    implements $ChatReplyCopyWith<$Res> {
  _$ChatReplyCopyWithImpl(this._self, this._then);

  final ChatReply _self;
  final $Res Function(ChatReply) _then;

/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? message = null,Object? intent = null,Object? conversationState = null,Object? ui = null,}) {
  return _then(ChatReply(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as ChatIntent,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as ConversationState,ui: null == ui ? _self.ui : ui // ignore: cast_nullable_to_non_nullable
as ChatUi,
  ));
}
/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatUiCopyWith<$Res> get ui {
  
  return $ChatUiCopyWith<$Res>(_self.ui, (value) {
    return _then(_self.copyWith(ui: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatReply].
extension ChatReplyPatterns on ChatReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatReply value)  $default,){
final _that = this;
switch (_that) {
case _ChatReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatReply value)?  $default,){
final _that = this;
switch (_that) {
case _ChatReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String message,  ChatIntent intent,  ConversationState conversationState,  ChatUi ui)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatReply() when $default != null:
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String message,  ChatIntent intent,  ConversationState conversationState,  ChatUi ui)  $default,) {final _that = this;
switch (_that) {
case _ChatReply():
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String message,  ChatIntent intent,  ConversationState conversationState,  ChatUi ui)?  $default,) {final _that = this;
switch (_that) {
case _ChatReply() when $default != null:
return $default(_that.conversationId,_that.message,_that.intent,_that.conversationState,_that.ui);case _:
  return null;

}
}

}

/// @nodoc


class _ChatReply implements ChatReply {
  const _ChatReply({required this.conversationId, required this.message, required this.intent, required this.conversationState, required this.ui});
  

@override final  String conversationId;
/// The text to show.
@override final  String message;
@override final  ChatIntent intent;
@override final  ConversationState conversationState;
@override final  ChatUi ui;

/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatReplyCopyWith<_ChatReply> get copyWith => __$ChatReplyCopyWithImpl<_ChatReply>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatReply&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.message, message) || other.message == message)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.conversationState, conversationState) || other.conversationState == conversationState)&&(identical(other.ui, ui) || other.ui == ui));
}


@override
int get hashCode {
    return Object.hash(runtimeType,conversationId,message,intent,conversationState,ui);
}

@override
String toString() {
    return 'ChatReply(conversationId: $conversationId, message: $message, intent: $intent, conversationState: $conversationState, ui: $ui)';
}


}

/// @nodoc
abstract mixin class _$ChatReplyCopyWith<$Res> implements $ChatReplyCopyWith<$Res> {
  factory _$ChatReplyCopyWith(_ChatReply value, $Res Function(_ChatReply) _then) = __$ChatReplyCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String message, ChatIntent intent, ConversationState conversationState, ChatUi ui
});


@override $ChatUiCopyWith<$Res> get ui;

}
/// @nodoc
class __$ChatReplyCopyWithImpl<$Res>
    implements _$ChatReplyCopyWith<$Res> {
  __$ChatReplyCopyWithImpl(this._self, this._then);

  final _ChatReply _self;
  final $Res Function(_ChatReply) _then;

/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? message = null,Object? intent = null,Object? conversationState = null,Object? ui = null,}) {
  return _then(_ChatReply(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as ChatIntent,conversationState: null == conversationState ? _self.conversationState : conversationState // ignore: cast_nullable_to_non_nullable
as ConversationState,ui: null == ui ? _self.ui : ui // ignore: cast_nullable_to_non_nullable
as ChatUi,
  ));
}

/// Create a copy of ChatReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatUiCopyWith<$Res> get ui {
  
  return $ChatUiCopyWith<$Res>(_self.ui, (value) {
    return _then(_self.copyWith(ui: value));
  });
}
}

// dart format on
