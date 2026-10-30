import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_provider.dart';
import 'data/datasources/chat_api_client.dart';
import 'data/datasources/chat_remote_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';

part 'chat_providers.g.dart';

// Chat dependency graph:
// Dio → ChatApiClient → ChatRemoteDataSource → ChatRepositoryImpl
//     → ChatRepository.

@Riverpod(keepAlive: true)
ChatApiClient chatApiClient(Ref ref) => ChatApiClient(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ChatRemoteDataSource chatRemoteDataSource(Ref ref) =>
    ChatRemoteDataSource(ref.watch(chatApiClientProvider));

/// Binds [ChatRepository] to [ChatRepositoryImpl].
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) =>
    ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
