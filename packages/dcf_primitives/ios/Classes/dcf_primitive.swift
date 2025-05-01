import UIKit
import Flutter
import dcflight

@objc public class DcfPrimitives: NSObject {
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        // This is required by the Flutter plugin system
        print("DCF Primitives plugin registered with Flutter")
    }
    
    @objc public static func registerComponents() {
        // Register all primitive components with the DCFlight component registry
        DCFComponentRegistry.shared.registerComponent("View", componentClass: DCFViewComponent.self)
        DCFComponentRegistry.shared.registerComponent("Button", componentClass: DCFButtonComponent.self)
        DCFComponentRegistry.shared.registerComponent("Text", componentClass: DCFTextComponent.self)
        DCFComponentRegistry.shared.registerComponent("Image", componentClass: DCFImageComponent.self)
        DCFComponentRegistry.shared.registerComponent("ScrollView", componentClass: DCFScrollViewComponent.self)
        
        print("✅ DCF Primitives: All components registered successfully")
    }
}