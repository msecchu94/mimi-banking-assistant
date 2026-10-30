// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatState()';
}


}

/// @nodoc
class $ChatStateCopyWith<$Res>  {
$ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatInitial value)?  initial,TResult Function( ChatStarting value)?  starting,TResult Function( ChatStartFailed value)?  startFailed,TResult Function( ChatActive value)?  active,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatStarting() when starting != null:
return starting(_that);case ChatStartFailed() when startFailed != null:
return startFailed(_that);case ChatActive() when active != null:
return active(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatInitial value)  initial,required TResult Function( ChatStarting value)  starting,required TResult Function( ChatStartFailed value)  startFailed,required TResult Function( ChatActive value)  active,}){
final _that = this;
switch (_that) {
case ChatInitial():
return initial(_that);case ChatStarting():
return starting(_that);case ChatStartFailed():
return startFailed(_that);case ChatActive():
return active(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatInitial value)?  initial,TResult? Function( ChatStarting value)?  starting,TResult? Function( ChatStartFailed value)?  startFailed,TResult? Function( ChatActive value)?  active,}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatStarting() when starting != null:
return starting(_that);case ChatStartFailed() when startFailed != null:
return startFailed(_that);case ChatActive() when active != null:
return active(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  starting,TResult Function( Failure failure)?  startFailed,TResult Function( Conversation conversation,  List<ChatEntry> transcript,  ChatAction? pendingAction,  ChatActionFailure? lastFailure)?  active,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatStarting() when starting != null:
return starting();case ChatStartFailed() when startFailed != null:
return startFailed(_that.failure);case ChatActive() when active != null:
return active(_that.conversation,_that.transcript,_that.pendingAction,_that.lastFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  starting,required TResult Function( Failure failure)  startFailed,required TResult Function( Conversation conversation,  List<ChatEntry> transcript,  ChatAction? pendingAction,  ChatActionFailure? lastFailure)  active,}) {final _that = this;
switch (_that) {
case ChatInitial():
return initial();case ChatStarting():
return starting();case ChatStartFailed():
return startFailed(_that.failure);case ChatActive():
return active(_that.conversation,_that.transcript,_that.pendingAction,_that.lastFailure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  starting,TResult? Function( Failure failure)?  startFailed,TResult? Function( Conversation conversation,  List<ChatEntry> transcript,  ChatAction? pendingAction,  ChatActionFailure? lastFailure)?  active,}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatStarting() when starting != null:
return starting();case ChatStartFailed() when startFailed != null:
return startFailed(_that.failure);case ChatActive() when active != null:
return active(_that.conversation,_that.transcript,_that.pendingAction,_that.lastFailure);case _:
  return null;

}
}

}

/// @nodoc


class ChatInitial implements ChatState {
  const ChatInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatState.initial()';
}


}




/// @nodoc


class ChatStarting implements ChatState {
  const ChatStarting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStarting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatState.starting()';
}


}




/// @nodoc


class ChatStartFailed implements ChatState {
  const ChatStartFailed(this.failure);
  

 final  Failure failure;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStartFailedCopyWith<ChatStartFailed> get copyWith => _$ChatStartFailedCopyWithImpl<ChatStartFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStartFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'ChatState.startFailed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ChatStartFailedCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatStartFailedCopyWith(ChatStartFailed value, $Res Function(ChatStartFailed) _then) = _$ChatStartFailedCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$ChatStartFailedCopyWithImpl<$Res>
    implements $ChatStartFailedCopyWith<$Res> {
  _$ChatStartFailedCopyWithImpl(this._self, this._then);

  final ChatStartFailed _self;
  final $Res Function(ChatStartFailed) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ChatStartFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc


class ChatActive implements ChatState {
  const ChatActive({required this.conversation, required  List<ChatEntry> transcript, this.pendingAction, this.lastFailure}): _transcript = transcript;
  

 final  Conversation conversation;
 final  List<ChatEntry> _transcript;
 List<ChatEntry> get transcript {
  if (_transcript is EqualUnmodifiableListView) return _transcript;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transcript);
}

 final  ChatAction? pendingAction;
 final  ChatActionFailure? lastFailure;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatActiveCopyWith<ChatActive> get copyWith => _$ChatActiveCopyWithImpl<ChatActive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatActive&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other.transcript, _transcript)&&(identical(other.pendingAction, pendingAction) || other.pendingAction == pendingAction)&&(identical(other.lastFailure, lastFailure) || other.lastFailure == lastFailure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(_transcript),pendingAction,lastFailure);
}

@override
String toString() {
    return 'ChatState.active(conversation: $conversation, transcript: $transcript, pendingAction: $pendingAction, lastFailure: $lastFailure)';
}


}

/// @nodoc
abstract mixin class $ChatActiveCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatActiveCopyWith(ChatActive value, $Res Function(ChatActive) _then) = _$ChatActiveCopyWithImpl;
@useResult
$Res call({
 Conversation conversation, List<ChatEntry> transcript, ChatAction? pendingAction, ChatActionFailure? lastFailure
});


$ConversationCopyWith<$Res> get conversation;$ChatActionCopyWith<$Res>? get pendingAction;$ChatActionFailureCopyWith<$Res>? get lastFailure;

}
/// @nodoc
class _$ChatActiveCopyWithImpl<$Res>
    implements $ChatActiveCopyWith<$Res> {
  _$ChatActiveCopyWithImpl(this._self, this._then);

  final ChatActive _self;
  final $Res Function(ChatActive) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversation = null,Object? transcript = null,Object? pendingAction = freezed,Object? lastFailure = freezed,}) {
  return _then(ChatActive(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as Conversation,transcript: null == transcript ? _self._transcript : transcript // ignore: cast_nullable_to_non_nullable
as List<ChatEntry>,pendingAction: freezed == pendingAction ? _self.pendingAction : pendingAction // ignore: cast_nullable_to_non_nullable
as ChatAction?,lastFailure: freezed == lastFailure ? _self.lastFailure : lastFailure // ignore: cast_nullable_to_non_nullable
as ChatActionFailure?,
  ));
}

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res> get conversation {
  
  return $ConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatActionCopyWith<$Res>? get pendingAction {
    if (_self.pendingAction == null) {
    return null;
  }

  return $ChatActionCopyWith<$Res>(_self.pendingAction!, (value) {
    return _then(_self.copyWith(pendingAction: value));
  });
}/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatActionFailureCopyWith<$Res>? get lastFailure {
    if (_self.lastFailure == null) {
    return null;
  }

  return $ChatActionFailureCopyWith<$Res>(_self.lastFailure!, (value) {
    return _then(_self.copyWith(lastFailure: value));
  });
}
}

/// @nodoc
mixin _$ChatEntry {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEntry);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatEntry()';
}


}

/// @nodoc
class $ChatEntryCopyWith<$Res>  {
$ChatEntryCopyWith(ChatEntry _, $Res Function(ChatEntry) __);
}


/// Adds pattern-matching-related methods to [ChatEntry].
extension ChatEntryPatterns on ChatEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UserMessage value)?  userMessage,TResult Function( AssistantReply value)?  assistantReply,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UserMessage() when userMessage != null:
return userMessage(_that);case AssistantReply() when assistantReply != null:
return assistantReply(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UserMessage value)  userMessage,required TResult Function( AssistantReply value)  assistantReply,}){
final _that = this;
switch (_that) {
case UserMessage():
return userMessage(_that);case AssistantReply():
return assistantReply(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UserMessage value)?  userMessage,TResult? Function( AssistantReply value)?  assistantReply,}){
final _that = this;
switch (_that) {
case UserMessage() when userMessage != null:
return userMessage(_that);case AssistantReply() when assistantReply != null:
return assistantReply(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  userMessage,TResult Function( ChatReply reply)?  assistantReply,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UserMessage() when userMessage != null:
return userMessage(_that.text);case AssistantReply() when assistantReply != null:
return assistantReply(_that.reply);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  userMessage,required TResult Function( ChatReply reply)  assistantReply,}) {final _that = this;
switch (_that) {
case UserMessage():
return userMessage(_that.text);case AssistantReply():
return assistantReply(_that.reply);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  userMessage,TResult? Function( ChatReply reply)?  assistantReply,}) {final _that = this;
switch (_that) {
case UserMessage() when userMessage != null:
return userMessage(_that.text);case AssistantReply() when assistantReply != null:
return assistantReply(_that.reply);case _:
  return null;

}
}

}

/// @nodoc


class UserMessage implements ChatEntry {
  const UserMessage(this.text);
  

 final  String text;

/// Create a copy of ChatEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserMessageCopyWith<UserMessage> get copyWith => _$UserMessageCopyWithImpl<UserMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UserMessage&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'ChatEntry.userMessage(text: $text)';
}


}

/// @nodoc
abstract mixin class $UserMessageCopyWith<$Res> implements $ChatEntryCopyWith<$Res> {
  factory $UserMessageCopyWith(UserMessage value, $Res Function(UserMessage) _then) = _$UserMessageCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$UserMessageCopyWithImpl<$Res>
    implements $UserMessageCopyWith<$Res> {
  _$UserMessageCopyWithImpl(this._self, this._then);

  final UserMessage _self;
  final $Res Function(UserMessage) _then;

/// Create a copy of ChatEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(UserMessage(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AssistantReply implements ChatEntry {
  const AssistantReply(this.reply);
  

 final  ChatReply reply;

/// Create a copy of ChatEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantReplyCopyWith<AssistantReply> get copyWith => _$AssistantReplyCopyWithImpl<AssistantReply>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantReply&&(identical(other.reply, reply) || other.reply == reply));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reply);
}

@override
String toString() {
    return 'ChatEntry.assistantReply(reply: $reply)';
}


}

/// @nodoc
abstract mixin class $AssistantReplyCopyWith<$Res> implements $ChatEntryCopyWith<$Res> {
  factory $AssistantReplyCopyWith(AssistantReply value, $Res Function(AssistantReply) _then) = _$AssistantReplyCopyWithImpl;
@useResult
$Res call({
 ChatReply reply
});


$ChatReplyCopyWith<$Res> get reply;

}
/// @nodoc
class _$AssistantReplyCopyWithImpl<$Res>
    implements $AssistantReplyCopyWith<$Res> {
  _$AssistantReplyCopyWithImpl(this._self, this._then);

  final AssistantReply _self;
  final $Res Function(AssistantReply) _then;

/// Create a copy of ChatEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reply = null,}) {
  return _then(AssistantReply(
null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as ChatReply,
  ));
}

/// Create a copy of ChatEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatReplyCopyWith<$Res> get reply {
  
  return $ChatReplyCopyWith<$Res>(_self.reply, (value) {
    return _then(_self.copyWith(reply: value));
  });
}
}

/// @nodoc
mixin _$ChatAction {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatAction);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatAction()';
}


}

/// @nodoc
class $ChatActionCopyWith<$Res>  {
$ChatActionCopyWith(ChatAction _, $Res Function(ChatAction) __);
}


/// Adds pattern-matching-related methods to [ChatAction].
extension ChatActionPatterns on ChatAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SendMessageAction value)?  sendMessage,TResult Function( ConfirmAction value)?  confirm,TResult Function( CancelAction value)?  cancel,TResult Function( SelectCardAction value)?  selectCard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SendMessageAction() when sendMessage != null:
return sendMessage(_that);case ConfirmAction() when confirm != null:
return confirm(_that);case CancelAction() when cancel != null:
return cancel(_that);case SelectCardAction() when selectCard != null:
return selectCard(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SendMessageAction value)  sendMessage,required TResult Function( ConfirmAction value)  confirm,required TResult Function( CancelAction value)  cancel,required TResult Function( SelectCardAction value)  selectCard,}){
final _that = this;
switch (_that) {
case SendMessageAction():
return sendMessage(_that);case ConfirmAction():
return confirm(_that);case CancelAction():
return cancel(_that);case SelectCardAction():
return selectCard(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SendMessageAction value)?  sendMessage,TResult? Function( ConfirmAction value)?  confirm,TResult? Function( CancelAction value)?  cancel,TResult? Function( SelectCardAction value)?  selectCard,}){
final _that = this;
switch (_that) {
case SendMessageAction() when sendMessage != null:
return sendMessage(_that);case ConfirmAction() when confirm != null:
return confirm(_that);case CancelAction() when cancel != null:
return cancel(_that);case SelectCardAction() when selectCard != null:
return selectCard(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  sendMessage,TResult Function( String operationId)?  confirm,TResult Function()?  cancel,TResult Function( String cardId)?  selectCard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SendMessageAction() when sendMessage != null:
return sendMessage(_that.message);case ConfirmAction() when confirm != null:
return confirm(_that.operationId);case CancelAction() when cancel != null:
return cancel();case SelectCardAction() when selectCard != null:
return selectCard(_that.cardId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  sendMessage,required TResult Function( String operationId)  confirm,required TResult Function()  cancel,required TResult Function( String cardId)  selectCard,}) {final _that = this;
switch (_that) {
case SendMessageAction():
return sendMessage(_that.message);case ConfirmAction():
return confirm(_that.operationId);case CancelAction():
return cancel();case SelectCardAction():
return selectCard(_that.cardId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  sendMessage,TResult? Function( String operationId)?  confirm,TResult? Function()?  cancel,TResult? Function( String cardId)?  selectCard,}) {final _that = this;
switch (_that) {
case SendMessageAction() when sendMessage != null:
return sendMessage(_that.message);case ConfirmAction() when confirm != null:
return confirm(_that.operationId);case CancelAction() when cancel != null:
return cancel();case SelectCardAction() when selectCard != null:
return selectCard(_that.cardId);case _:
  return null;

}
}

}

/// @nodoc


class SendMessageAction implements ChatAction {
  const SendMessageAction(this.message);
  

 final  String message;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendMessageActionCopyWith<SendMessageAction> get copyWith => _$SendMessageActionCopyWithImpl<SendMessageAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SendMessageAction&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ChatAction.sendMessage(message: $message)';
}


}

/// @nodoc
abstract mixin class $SendMessageActionCopyWith<$Res> implements $ChatActionCopyWith<$Res> {
  factory $SendMessageActionCopyWith(SendMessageAction value, $Res Function(SendMessageAction) _then) = _$SendMessageActionCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SendMessageActionCopyWithImpl<$Res>
    implements $SendMessageActionCopyWith<$Res> {
  _$SendMessageActionCopyWithImpl(this._self, this._then);

  final SendMessageAction _self;
  final $Res Function(SendMessageAction) _then;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SendMessageAction(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConfirmAction implements ChatAction {
  const ConfirmAction(this.operationId);
  

 final  String operationId;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmActionCopyWith<ConfirmAction> get copyWith => _$ConfirmActionCopyWithImpl<ConfirmAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmAction&&(identical(other.operationId, operationId) || other.operationId == operationId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,operationId);
}

@override
String toString() {
    return 'ChatAction.confirm(operationId: $operationId)';
}


}

/// @nodoc
abstract mixin class $ConfirmActionCopyWith<$Res> implements $ChatActionCopyWith<$Res> {
  factory $ConfirmActionCopyWith(ConfirmAction value, $Res Function(ConfirmAction) _then) = _$ConfirmActionCopyWithImpl;
@useResult
$Res call({
 String operationId
});




}
/// @nodoc
class _$ConfirmActionCopyWithImpl<$Res>
    implements $ConfirmActionCopyWith<$Res> {
  _$ConfirmActionCopyWithImpl(this._self, this._then);

  final ConfirmAction _self;
  final $Res Function(ConfirmAction) _then;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operationId = null,}) {
  return _then(ConfirmAction(
null == operationId ? _self.operationId : operationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CancelAction implements ChatAction {
  const CancelAction();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAction);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatAction.cancel()';
}


}




/// @nodoc


class SelectCardAction implements ChatAction {
  const SelectCardAction(this.cardId);
  

 final  String cardId;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectCardActionCopyWith<SelectCardAction> get copyWith => _$SelectCardActionCopyWithImpl<SelectCardAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectCardAction&&(identical(other.cardId, cardId) || other.cardId == cardId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cardId);
}

@override
String toString() {
    return 'ChatAction.selectCard(cardId: $cardId)';
}


}

/// @nodoc
abstract mixin class $SelectCardActionCopyWith<$Res> implements $ChatActionCopyWith<$Res> {
  factory $SelectCardActionCopyWith(SelectCardAction value, $Res Function(SelectCardAction) _then) = _$SelectCardActionCopyWithImpl;
@useResult
$Res call({
 String cardId
});




}
/// @nodoc
class _$SelectCardActionCopyWithImpl<$Res>
    implements $SelectCardActionCopyWith<$Res> {
  _$SelectCardActionCopyWithImpl(this._self, this._then);

  final SelectCardAction _self;
  final $Res Function(SelectCardAction) _then;

/// Create a copy of ChatAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cardId = null,}) {
  return _then(SelectCardAction(
null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChatActionFailure {

 ChatAction get action; Failure get failure;
/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatActionFailureCopyWith<ChatActionFailure> get copyWith => _$ChatActionFailureCopyWithImpl<ChatActionFailure>(this as ChatActionFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatActionFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatActionFailure&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as ChatActionFailure;
  return Object.hash(runtimeType,_this.action,_this.failure);
}

@override
String toString() {
  final _this = this as ChatActionFailure;
  return 'ChatActionFailure(action: ${_this.action}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $ChatActionFailureCopyWith<$Res>  {
  factory $ChatActionFailureCopyWith(ChatActionFailure value, $Res Function(ChatActionFailure) _then) = _$ChatActionFailureCopyWithImpl;
@useResult
$Res call({
 ChatAction action, Failure failure
});


$ChatActionCopyWith<$Res> get action;

}
/// @nodoc
class _$ChatActionFailureCopyWithImpl<$Res>
    implements $ChatActionFailureCopyWith<$Res> {
  _$ChatActionFailureCopyWithImpl(this._self, this._then);

  final ChatActionFailure _self;
  final $Res Function(ChatActionFailure) _then;

/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? failure = null,}) {
  return _then(ChatActionFailure(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ChatAction,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}
/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatActionCopyWith<$Res> get action {
  
  return $ChatActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatActionFailure].
extension ChatActionFailurePatterns on ChatActionFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatActionFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatActionFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatActionFailure value)  $default,){
final _that = this;
switch (_that) {
case _ChatActionFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatActionFailure value)?  $default,){
final _that = this;
switch (_that) {
case _ChatActionFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatAction action,  Failure failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatActionFailure() when $default != null:
return $default(_that.action,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatAction action,  Failure failure)  $default,) {final _that = this;
switch (_that) {
case _ChatActionFailure():
return $default(_that.action,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatAction action,  Failure failure)?  $default,) {final _that = this;
switch (_that) {
case _ChatActionFailure() when $default != null:
return $default(_that.action,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _ChatActionFailure implements ChatActionFailure {
  const _ChatActionFailure({required this.action, required this.failure});
  

@override final  ChatAction action;
@override final  Failure failure;

/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatActionFailureCopyWith<_ChatActionFailure> get copyWith => __$ChatActionFailureCopyWithImpl<_ChatActionFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatActionFailure&&(identical(other.action, action) || other.action == action)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,action,failure);
}

@override
String toString() {
    return 'ChatActionFailure(action: $action, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ChatActionFailureCopyWith<$Res> implements $ChatActionFailureCopyWith<$Res> {
  factory _$ChatActionFailureCopyWith(_ChatActionFailure value, $Res Function(_ChatActionFailure) _then) = __$ChatActionFailureCopyWithImpl;
@override @useResult
$Res call({
 ChatAction action, Failure failure
});


@override $ChatActionCopyWith<$Res> get action;

}
/// @nodoc
class __$ChatActionFailureCopyWithImpl<$Res>
    implements _$ChatActionFailureCopyWith<$Res> {
  __$ChatActionFailureCopyWithImpl(this._self, this._then);

  final _ChatActionFailure _self;
  final $Res Function(_ChatActionFailure) _then;

/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? failure = null,}) {
  return _then(_ChatActionFailure(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ChatAction,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of ChatActionFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatActionCopyWith<$Res> get action {
  
  return $ChatActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

// dart format on
