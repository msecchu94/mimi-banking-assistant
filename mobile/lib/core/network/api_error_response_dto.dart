import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error_response_dto.freezed.dart';
part 'api_error_response_dto.g.dart';

/// The contract's `ApiErrorResponse`, shared by every endpoint.
@freezed
abstract class ApiErrorResponseDto with _$ApiErrorResponseDto {
  const factory ApiErrorResponseDto({
    required String code,
    required String message,
    required String requestId,
    required DateTime timestamp,
  }) = _ApiErrorResponseDto;

  factory ApiErrorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseDtoFromJson(json);
}
