import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice/core/storage/storage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Fresh in-memory storage for each test.
void useInMemoryPrefs() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
}

Future<SharedPreferencesWithCache> createPrefs() =>
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

/// A container backed by [prefs] (or a new in-memory store).
Future<ProviderContainer> createContainer({
  SharedPreferencesWithCache? prefs,
}) async {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs ?? await createPrefs()),
    ],
  );
  return container;
}
