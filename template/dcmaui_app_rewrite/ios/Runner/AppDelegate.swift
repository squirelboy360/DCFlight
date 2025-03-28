import UIKit
import Flutter

@main
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Pre-load and register all custom fonts
        _ = FontLoader.shared
        
        // Set up the Flutter method channel for events
        if let controller = window?.rootViewController as? FlutterViewController {
            let nativeBridge = DCMauiNativeBridge.shared
            nativeBridge.setupEventChannel(binaryMessenger: controller.binaryMessenger)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
