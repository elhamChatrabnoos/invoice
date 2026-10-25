import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_provider.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(sharedPreferencesProvider)),
);

class OnboardingRepository {
  OnboardingRepository(this._prefs);

  static const _key = 'onboarding.completed';

  final SharedPreferencesWithCache _prefs;

  bool get isCompleted => _prefs.getBool(_key) ?? false;

  Future<void> markCompleted() => _prefs.setBool(_key, true);
}
