import 'package:json_annotation/json_annotation.dart';

part 'chat_request_dto.g.dart';

/// A `POST /chat` request: exactly one free-text message or one structured
/// interaction, whose payload is defined by its type.
sealed class ChatRequestDto {
  const ChatRequestDto();

  Map<String, dynamic> toJson();
}

@JsonSerializable(createFactory: false)
final class MessageRequestDto extends ChatRequestDto {
  const MessageRequestDto({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final String message;

  @override
  Map<String, dynamic> toJson() => _$MessageRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class ConfirmRequestDto extends ChatRequestDto {
  const ConfirmRequestDto({required this.conversationId, required this.payload})
    : interaction = 'CONFIRM';

  final String conversationId;
  final String interaction;
  final ConfirmPayloadDto payload;

  @override
  Map<String, dynamic> toJson() => _$ConfirmRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class ConfirmPayloadDto {
  const ConfirmPayloadDto({required this.operationId});

  final String operationId;

  Map<String, dynamic> toJson() => _$ConfirmPayloadDtoToJson(this);
}

/// Carries no payload: the contract rejects an object payload for `CANCEL`.
@JsonSerializable(createFactory: false)
final class CancelRequestDto extends ChatRequestDto {
  const CancelRequestDto({required this.conversationId})
    : interaction = 'CANCEL';

  final String conversationId;
  final String interaction;

  @override
  Map<String, dynamic> toJson() => _$CancelRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class SelectCardRequestDto extends ChatRequestDto {
  const SelectCardRequestDto({
    required this.conversationId,
    required this.payload,
  }) : interaction = 'SELECT_CARD';

  final String conversationId;
  final String interaction;
  final SelectCardPayloadDto payload;

  @override
  Map<String, dynamic> toJson() => _$SelectCardRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class SelectCardPayloadDto {
  const SelectCardPayloadDto({required this.cardId});

  final String cardId;

  Map<String, dynamic> toJson() => _$SelectCardPayloadDtoToJson(this);
}
