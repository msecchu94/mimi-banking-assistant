import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_provider.dart';
import 'data/datasources/chat_api_client.dart';
import 'data/datasources/chat_remote_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/cancel_interaction.dart';
import 'domain/usecases/confirm_interaction.dart';
import 'domain/usecases/select_card.dart';
import 'domain/usecases/send_message.dart';
import 'domain/usecases/start_conversation.dart';

part 'chat_providers.g.dart';

// Chat dependency graph:
// Dio → ChatApiClient → ChatRemoteDataSource → ChatRepositoryImpl
//     → ChatRepository → use cases (consumed by Presentation).

@Riverpod(keepAlive: true)
ChatApiClient chatApiClient(Ref ref) => ChatApiClient(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ChatRemoteDataSource chatRemoteDataSource(Ref ref) =>
    ChatRemoteDataSource(ref.watch(chatApiClientProvider));

/// Binds [ChatRepository] to [ChatRepositoryImpl].
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) =>
    ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
StartConversation startConversation(Ref ref) =>
    StartConversation(ref.watch(chatRepositoryProvider));

@Riverpod(keepAlive: true)
SendMessage sendMessage(Ref ref) =>
    SendMessage(ref.watch(chatRepositoryProvider));

@Riverpod(keepAlive: true)
ConfirmInteraction confirmInteraction(Ref ref) =>
    ConfirmInteraction(ref.watch(chatRepositoryProvider));

@Riverpod(keepAlive: true)
CancelInteraction cancelInteraction(Ref ref) =>
    CancelInteraction(ref.watch(chatRepositoryProvider));

@Riverpod(keepAlive: true)
SelectCard selectCard(Ref ref) => SelectCard(ref.watch(chatRepositoryProvider));
