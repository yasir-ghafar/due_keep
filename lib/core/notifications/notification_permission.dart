import 'package:flutter/services.dart';

/// Asks the OS for local notification permission. Failure is non-fatal.
class NotificationPermission {
  const NotificationPermission({
    MethodChannel channel =
        const MethodChannel('com.techlad.duekeep/notifications'),
  }) : _channel = channel;

  final MethodChannel _channel;

  /// Returns whether the user granted alerts. `false` on deny or if the
  /// platform has no handler yet.
  Future<bool> request() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
