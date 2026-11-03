import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/network_exception.dart';
import '../../domain/models/chat_reply.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../dtos/chat_request_dto.dart';
import '../mappers/chat_dto_mapper.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<Either<Failure, Conversation>> startConversation() =>
      _run(() async => conversationFromDto(await _remote.startConversation()));

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String conversationId,
    required String message,
  }) => _chat(
    MessageRequestDto(conversationId: conversationId, message: message),
  );

  @override
  Future<Either<Failure, ChatReply>> confirm({
    required String conversationId,
    required String operationId,
  }) => _chat(
    ConfirmRequestDto(
      conversationId: conversationId,
      payload: ConfirmPayloadDto(operationId: operationId),
    ),
  );

  @override
  Future<Either<Failure, ChatReply>> cancel({required String conversationId}) =>
      _chat(CancelRequestDto(conversationId: conversationId));

  @override
  Future<Either<Failure, ChatReply>> selectCard({
    required String conversationId,
    required String cardId,
  }) => _chat(
    SelectCardRequestDto(
      conversationId: conversationId,
      payload: SelectCardPayloadDto(cardId: cardId),
    ),
  );

  Future<Either<Failure, ChatReply>> _chat(ChatRequestDto request) =>
      _run(() async => chatReplyFromDto(await _remote.chat(request)));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on NetworkException catch (exception) {
      return Left(mapNetworkException(exception));
    }
  }
}
