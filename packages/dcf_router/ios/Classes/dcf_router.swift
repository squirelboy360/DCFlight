import UIKit
import Flutter
import dcflight

@objc public class DcfRouter: NSObject {
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        print("DCF Primitives plugin registered with Flutter")
        registerComponents()
    }
    
    @objc public static func registerComponents() {
        DCFComponentRegistry.shared.registerComponent("View", componentClass: DCFViewComponent.self)
    }
}
