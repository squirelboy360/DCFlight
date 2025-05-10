import UIKit
import Flutter
import dcflight

@objc public class DcfPrimitives: NSObject {
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This is required by the Flutter plugin system
        print("DCF Primitives plugin registered with Flutter")
        
        // Register all primitive components when the plugin is registered
        registerComponents()
    }
    
    @objc public static func registerComponents() {
        // Register all primitive components with the DCFlight component registry
        DCFComponentRegistry.shared.registerComponent("View", componentClass: DCFViewComponent.self)
        DCFComponentRegistry.shared.registerComponent("Button", componentClass: DCFButtonComponent.self)
        DCFComponentRegistry.shared.registerComponent("Text", componentClass: DCFTextComponent.self)
        DCFComponentRegistry.shared.registerComponent("Image", componentClass: DCFImageComponent.self)
        DCFComponentRegistry.shared.registerComponent("ScrollView", componentClass: DCFScrollViewComponent.self)
        
        // Register new primitives
        DCFComponentRegistry.shared.registerComponent("Svg", componentClass: DCFSvgComponent.self)
        DCFComponentRegistry.shared.registerComponent("DCFIcon", componentClass: DCFIconComponent.self)
        
        // Register navigation primitives
        DCFComponentRegistry.shared.registerComponent("Modal", componentClass: DCFModalComponent.self)
        DCFComponentRegistry.shared.registerComponent("Alert", componentClass: DCFAlertComponent.self)
        DCFComponentRegistry.shared.registerComponent("StackNavigator", componentClass: DCFStackNavigatorComponent.self)
        DCFComponentRegistry.shared.registerComponent("TabNavigator", componentClass: DCFTabNavigatorComponent.self)
        
        print("✅ DCF Primitives: All components registered successfully")
    }
}
