import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for iOS to hand notification taps and action buttons back to
    // the plugin, and to show a reminder that fires while the app is open.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerTimezoneChannel(with: engineBridge.pluginRegistry)
  }

  /// Counterpart to the Android `MainActivity` handler.
  ///
  /// Without it the Dart side falls back to the timezone package default,
  /// which is UTC — every reminder then fires hours away from the time the
  /// user picked (seven, for WIB).
  private func registerTimezoneChannel(with registry: FlutterPluginRegistry) {
    guard let messenger = registry.registrar(forPlugin: "OpenLifeTimezone")?.messenger() else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "openlife_routine/timezone",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "getLocalTimezone" {
        result(TimeZone.current.identifier)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
