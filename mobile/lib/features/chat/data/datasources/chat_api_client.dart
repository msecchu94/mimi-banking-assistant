import 'package:dio/dio.dart';

import '../dtos/chat_request_dto.dart';
import '../dtos/chat_response_dto.dart';

/// HTTP calls of the Chat API.
///
/// Throws [DioException] for transport and HTTP errors, and
/// `CheckedFromJsonException` or [FormatException] for a body outside the
/// contract; `ChatRemoteDataSource` classifies them.
class ChatApiClient {
  ChatApiClient(this._dio);

  final Dio _dio;

  /// `POST /conversations`.
  Future<ConversationResponseDto> startConversation() async {
    final response = await _dio.post<Object?>('/conversations');
    return ConversationResponseDto.fromJson(_jsonObject(response.data));
  }

  /// `POST /chat`.
  Future<ChatResponseDto> chat(ChatRequestDto request) async {
    final response = await _dio.post<Object?>('/chat', data: request.toJson());
    return ChatResponseDto.fromJson(_jsonObject(response.data));
  }

  Map<String, dynamic> _jsonObject(Object? body) => body is Map<String, dynamic>
      ? body
      : throw FormatException('Expected a JSON object', body);
}
