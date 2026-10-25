import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide key/value storage.
///
/// Created once in `main()` and injected with `overrideWithValue`, so every
/// repository can read synchronously from the in-memory cache.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);
