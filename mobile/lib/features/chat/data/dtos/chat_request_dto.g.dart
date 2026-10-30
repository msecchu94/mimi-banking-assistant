// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$MessageRequestDtoToJson(MessageRequestDto instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'message': instance.message,
    };

Map<String, dynamic> _$ConfirmRequestDtoToJson(ConfirmRequestDto instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'interaction': instance.interaction,
      'payload': instance.payload.toJson(),
    };

Map<String, dynamic> _$ConfirmPayloadDtoToJson(ConfirmPayloadDto instance) =>
    <String, dynamic>{'operation_id': instance.operationId};

Map<String, dynamic> _$CancelRequestDtoToJson(CancelRequestDto instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'interaction': instance.interaction,
    };

Map<String, dynamic> _$SelectCardRequestDtoToJson(
  SelectCardRequestDto instance,
) => <String, dynamic>{
  'conversation_id': instance.conversationId,
  'interaction': instance.interaction,
  'payload': instance.payload.toJson(),
};

Map<String, dynamic> _$SelectCardPayloadDtoToJson(
  SelectCardPayloadDto instance,
) => <String, dynamic>{'card_id': instance.cardId};
