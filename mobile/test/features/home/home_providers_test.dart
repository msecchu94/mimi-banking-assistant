import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/config/api_base_url_provider.dart';
import 'package:mimi/features/home/data/repositories/home_repository_impl.dart';
import 'package:mimi/features/home/home_providers.dart';

import 'home_fixtures.dart';

void main() {
  test('binds HomeRepository to HomeRepositoryImpl', () {
    final container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWithValue(
          Uri.parse('http://localhost:8000'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(homeRepositoryProvider), isA<HomeRepositoryImpl>());
  });

  test('builds GetHomeSummary on the bound HomeRepository', () async {
    final repository = FakeHomeRepository();
    final container = ProviderContainer(
      overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(getHomeSummaryProvider)();

    expect(repository.accountRequests, 1);
  });
}
