import 'package:shared_preferences/shared_preferences.dart';

/// Whether first-launch onboarding has been finished.
abstract class OnboardingStore {
  Future<bool> isComplete();

  Future<void> markComplete();
}

/// In-memory store for tests and when persistence is not wanted.
class MemoryOnboardingStore implements OnboardingStore {
  MemoryOnboardingStore({bool complete = false}) : _complete = complete;

  bool _complete;

  @override
  Future<bool> isComplete() async => _complete;

  @override
  Future<void> markComplete() async => _complete = true;
}

class PrefsOnboardingStore implements OnboardingStore {
  static const _key = 'onboarding_complete';

  @override
  Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
