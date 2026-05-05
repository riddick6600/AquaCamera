import Flutter
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "aqua_camera/camera_permission",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestCameraPermission":
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
          result("granted")
        case .notDetermined:
          AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
              result(granted ? "granted" : "denied")
            }
          }
        case .restricted:
          result("restricted")
        case .denied:
          result("denied")
        @unknown default:
          result("denied")
        }

      case "openAppSettings":
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }

        UIApplication.shared.open(url) { opened in
          result(opened)
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
