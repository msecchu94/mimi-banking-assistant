// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiErrorResponseDto _$ApiErrorResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ApiErrorResponseDto', json, ($checkedConvert) {
      final val = _ApiErrorResponseDto(
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        requestId: $checkedConvert('request_id', (v) => v as String),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'requestId': 'request_id'});

Map<String, dynamic> _$ApiErrorResponseDtoToJson(
  _ApiErrorResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'request_id': instance.requestId,
  'timestamp': instance.timestamp.toIso8601String(),
};
