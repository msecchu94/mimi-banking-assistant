import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_provider.dart';
import 'data/datasources/home_api_client.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_home_summary.dart';

part 'home_providers.g.dart';

// Home dependency graph:
// Dio → HomeApiClient → HomeRemoteDataSource → HomeRepositoryImpl
//     → HomeRepository → GetHomeSummary (consumed by Presentation).

@Riverpod(keepAlive: true)
HomeApiClient homeApiClient(Ref ref) => HomeApiClient(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
HomeRemoteDataSource homeRemoteDataSource(Ref ref) =>
    HomeRemoteDataSource(ref.watch(homeApiClientProvider));

/// Binds [HomeRepository] to [HomeRepositoryImpl].
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) =>
    HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
GetHomeSummary getHomeSummary(Ref ref) =>
    GetHomeSummary(ref.watch(homeRepositoryProvider));
