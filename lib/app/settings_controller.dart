import 'package:flutter/material.dart';

import '../data/datasources/settings_store.dart';

/// Reminder time and currency for Settings. Persistence via [SettingsStore].
class SettingsController extends ChangeNotifier {
  SettingsController({SettingsStore? store})
      : _store = store ?? MemorySettingsStore() {
    _load();
  }

  final SettingsStore _store;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _currency = 'USD';
  bool _ready = false;

  TimeOfDay get reminderTime => _reminderTime;
  String get currency => _currency;
  bool get ready => _ready;

  static const currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'INR'];

  Future<void> _load() async {
    _reminderTime = await _store.reminderTime();
    _currency = await _store.currency();
    _ready = true;
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (time.hour == _reminderTime.hour && time.minute == _reminderTime.minute) {
      return;
    }
    _reminderTime = time;
    notifyListeners();
    await _store.setReminderTime(time);
  }

  Future<void> setCurrency(String code) async {
    if (code == _currency) return;
    _currency = code;
    notifyListeners();
    await _store.setCurrency(code);
  }
}

extension SettingsTimeFormat on TimeOfDay {
  /// e.g. 09:00
  String get hhmm {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
