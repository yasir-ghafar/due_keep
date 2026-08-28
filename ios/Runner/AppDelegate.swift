import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if window?.rootViewController is FlutterViewController {
      registerNotificationChannel()
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.registerNotificationChannel()
      }
    }
    return launched
  }

  private func registerNotificationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "com.techlad.duekeep/notifications",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "requestPermission" else {
        result(FlutterMethodNotImplemented)
        return
      }
      UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
      ) { granted, error in
        DispatchQueue.main.async {
          if let error {
            result(
              FlutterError(
                code: "permission",
                message: error.localizedDescription,
                details: nil
              )
            )
          } else {
            result(granted)
          }
        }
      }
    }
  }
}
