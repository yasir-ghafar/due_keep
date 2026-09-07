import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Default reminder hour and display currency.
abstract class SettingsStore {
  Future<TimeOfDay> reminderTime();

  Future<void> setReminderTime(TimeOfDay time);

  Future<String> currency();

  Future<void> setCurrency(String code);
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore({
    TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0),
    String currency = 'USD',
  })  : _reminderTime = reminderTime,
        _currency = currency;

  TimeOfDay _reminderTime;
  String _currency;

  @override
  Future<TimeOfDay> reminderTime() async => _reminderTime;

  @override
  Future<void> setReminderTime(TimeOfDay time) async => _reminderTime = time;

  @override
  Future<String> currency() async => _currency;

  @override
  Future<void> setCurrency(String code) async => _currency = code;
}

class PrefsSettingsStore implements SettingsStore {
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';
  static const _currencyKey = 'currency';

  @override
  Future<TimeOfDay> reminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_hourKey) ?? 9,
      minute: prefs.getInt(_minuteKey) ?? 0,
    );
  }

  @override
  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);
  }

  @override
  Future<String> currency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD';
  }

  @override
  Future<void> setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }
}
