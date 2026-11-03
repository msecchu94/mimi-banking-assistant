import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/network_exception.dart';
import '../dtos/chat_request_dto.dart';
import '../dtos/chat_response_dto.dart';
import 'chat_api_client.dart';

/// Remote Chat data, behind the network boundary.
///
/// Every failure surfaces as a [NetworkException]; Dio and decoding errors do
/// not escape this class.
class ChatRemoteDataSource {
  ChatRemoteDataSource(this._client);

  final ChatApiClient _client;

  Future<ConversationResponseDto> startConversation() =>
      _guard(_client.startConversation);

  Future<ChatResponseDto> chat(ChatRequestDto request) =>
      _guard(() => _client.chat(request));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    } on CheckedFromJsonException catch (cause) {
      throw InvalidResponseException(cause: cause);
    } on FormatException catch (cause) {
      throw InvalidResponseException(cause: cause);
    }
  }
}
