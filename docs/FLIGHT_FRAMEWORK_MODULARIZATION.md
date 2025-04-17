# Flight Framework Modularization

This document outlines the technical approach for modularizing the DC MAUI (Flight) framework to create a plugin-based architecture that allows both framework distribution and extension.

## Table of Contents

1. [Overview](#overview)
2. [Framework Core Structure](#framework-core-structure)
3. [Native Module System](#native-module-system)
4. [Dart Package Architecture](#dart-package-architecture)
5. [Plugin System Design](#plugin-system-design)
6. [Integration Process](#integration-process)
7. [Developer Extension Points](#developer-extension-points)
8. [Example Implementation](#example-implementation)

## Overview

The modularization of the Flight framework will transform it from a template-based approach to a proper framework that can be installed as a dependency. This will enable:

1. **Easier Integration**: App developers can add the framework via dependency management
2. **Plugin Support**: Third-party developers can extend the framework with custom components
3. **Versioning**: Better version control and updates for the framework
4. **Separation of Concerns**: Clear boundaries between framework, plugins, and app code

## Framework Core Structure

### Directory Structure

```
flight/
├── ios/
│   ├── Flight.framework/            # iOS Framework bundle
│   │   ├── Headers/                 # Public headers
│   │   ├── Resources/               # Framework resources
│   │   └── Flight                   # Binary
│   └── Flight.podspec               # CocoaPods specification
├── android/
│   ├── src/                         # Android source files
│   ├── build.gradle                 # Gradle build script
│   └── AndroidManifest.xml          # Android manifest
└── dart/
    ├── lib/                         # Dart library code
    │   ├── flight.dart              # Main entry point
    │   ├── core/                    # Core framework
    │   │   ├── vdom/                # Virtual DOM system
    │   │   └── bridge/              # Native bridge
    │   ├── components/              # Built-in components
    │   └── plugins/                 # Plugin system
    ├── example/                     # Example usage
    └── pubspec.yaml                 # Dart package specification
```

## Native Module System

### iOS Framework Structure

The iOS framework will be compiled into a proper `.framework` bundle:

1. **Framework Creation**:
   - Convert current Swift code into a framework project
   - Define public headers for Objective-C compatibility
   - Create modulemap for Swift interface

2. **Module Registration**:
   - Create a central registry for plugin modules
   - Establish initialization sequence with priority levels

```swift
// Core framework registration
@objc public class Flight: NSObject {
    // Singleton instance
    @objc public static let shared = Flight()
    
    // Module registry
    private var modules: [FlightModule] = []
    
    // Initialize framework
    @objc public func initialize(with application: UIApplication) {
        // Initialize core modules first
        CoreModules.register()
        
        // Then initialize all registered modules
        for module in modules.sorted(by: { $0.priority < $1.priority }) {
            module.initialize()
        }
    }
    
    // Register a module
    @objc public func register(module: FlightModule) {
        modules.append(module)
    }
}

// Module protocol
@objc public protocol FlightModule {
    // Module name
    var name: String { get }
    
    // Priority (lower numbers initialize first)
    var priority: Int { get }
    
    // Initialize module
    func initialize()
    
    // Register components
    func registerComponents()
}
```

### Component Registry

The component registry will be expanded to support plugins:

```swift
@objc public class FlightComponentRegistry: NSObject {
    // Singleton instance
    @objc public static let shared = FlightComponentRegistry()
    
    // Component registry
    private var components: [String: FlightComponent.Type] = [:]
    
    // Register a component
    @objc public func register(name: String, component: FlightComponent.Type) {
        components[name] = component
    }
    
    // Get a component
    @objc public func component(for name: String) -> FlightComponent.Type? {
        return components[name]
    }
}
```

## Dart Package Architecture

### Package Structure

The Dart side will be organized as a proper package:

```dart
// Main entry point
library flight;

// Export core functionality
export 'src/core/vdom.dart';
export 'src/core/component.dart';
export 'src/core/hooks.dart';
export 'src/core/context.dart';

// Export built-in components
export 'src/components/view.dart';
export 'src/components/text.dart';
export 'src/components/button.dart';
export 'src/components/image.dart';
export 'src/components/scroll_view.dart';

// Export plugin system
export 'src/plugins/plugin.dart';
export 'src/plugins/registry.dart';
```

### Plugin System

Create a plugin registry for Dart-side extensions:

```dart
// Plugin registry
class FlightPluginRegistry {
  // Singleton instance
  static final FlightPluginRegistry instance = FlightPluginRegistry._();
  
  // Private constructor
  FlightPluginRegistry._();
  
  // Registered plugins
  final Map<String, FlightPlugin> _plugins = {};
  
  // Register a plugin
  void registerPlugin(FlightPlugin plugin) {
    _plugins[plugin.name] = plugin;
    plugin.initialize();
  }
  
  // Get a plugin
  T? getPlugin<T extends FlightPlugin>(String name) {
    return _plugins[name] as T?;
  }
}

// Plugin interface
abstract class FlightPlugin {
  // Plugin name
  String get name;
  
  // Initialize plugin
  void initialize();
  
  // Register components
  void registerComponents();
}
```

## Plugin System Design

### Plugin Structure

Plugins will have a consistent structure for both native and Dart code:

```
flight_plugin_example/
├── ios/
│   ├── Classes/
│   │   ├── ExamplePlugin.swift       # Plugin implementation
│   │   └── ExampleComponent.swift    # Custom components
│   └── flight_plugin_example.podspec # CocoaPods specification
├── android/
│   ├── src/                          # Android source files
│   └── build.gradle                  # Gradle build script
└── lib/
    ├── flight_plugin_example.dart    # Main entry point
    └── src/
        ├── components/               # Custom components
        └── plugin.dart               # Plugin registration
```

### Plugin Registration

Plugins will register with both native and Dart sides:

```swift
// Native side (iOS)
@objc public class ExamplePlugin: NSObject, FlightModule {
    @objc public static let shared = ExamplePlugin()
    
    @objc public var name: String {
        return "example_plugin"
    }
    
    @objc public var priority: Int {
        return 100 // Standard priority
    }
    
    @objc public func initialize() {
        // Initialize plugin
        registerComponents()
    }
    
    @objc public func registerComponents() {
        // Register custom components
        FlightComponentRegistry.shared.register(
            name: "ExampleComponent", 
            component: ExampleComponent.self
        )
    }
}
```

```dart
// Dart side
class ExamplePlugin extends FlightPlugin {
  // Singleton instance
  static final ExamplePlugin instance = ExamplePlugin._();
  
  // Private constructor
  ExamplePlugin._();
  
  @override
  String get name => 'example_plugin';
  
  @override
  void initialize() {
    // Initialize plugin
    registerComponents();
  }
  
  @override
  void registerComponents() {
    // Register custom components
    ComponentRegistry.instance.register(
      'ExampleComponent',
      (props) => ExampleComponent(props: props)
    );
  }
}

// Plugin registration
void registerPlugin() {
  FlightPluginRegistry.instance.registerPlugin(ExamplePlugin.instance);
}
```

## Integration Process

### For App Developers

1. **Add Framework Dependency**:

```yaml
# pubspec.yaml
dependencies:
  flight: ^1.0.0
```

2. **iOS Integration (Podfile)**:

```ruby
# Podfile
target 'YourApp' do
  pod 'Flight', '~> 1.0.0'
  # Optional - add plugins
  pod 'flight_plugin_example', '~> 1.0.0'
end
```

3. **Initialize Framework**:

```swift
// AppDelegate.swift
import Flight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Flight framework
        Flight.shared.initialize(with: application)
        return true
    }
}
```

```dart
// main.dart
import 'package:flight/flight.dart';
import 'package:flight_plugin_example/flight_plugin_example.dart';

void main() {
  // Initialize Flight
  FlightApp.initialize();
  
  // Register plugins
  registerExamplePlugin();
  
  // Run app
  FlightApp.run(
    app: MyApp()
  );
}
```

## Developer Extension Points

### Creating Custom Components

1. **Native Component (iOS)**:

```swift
@objc public class CustomComponent: NSObject, FlightComponent {
    @objc public static func create(props: [String: Any]) -> UIView {
        // Create and return a view
        let view = CustomView()
        return view
    }
    
    @objc public static func update(view: UIView, props: [String: Any]) -> Bool {
        // Update view with props
        guard let customView = view as? CustomView else {
            return false
        }
        
        // Apply properties
        if let text = props["text"] as? String {
            customView.text = text
        }
        
        return true
    }
}
```

2. **Dart Component**:

```dart
class CustomComponent extends FlightComponent {
  CustomComponent({
    Key? key,
    required Map<String, dynamic> props,
    List<Widget> children = const [],
  }) : super(key: key, props: props, children: children);
  
  @override
  String get type => 'CustomComponent';
}

// Usage
FlightUI.CustomComponent(
  props: {
    'text': 'Hello World',
    'color': Colors.blue,
  },
  children: [
    FlightUI.Text(
      props: {'text': 'Child Text'}
    ),
  ],
)
```

### Creating a Plugin

1. **Create Plugin Package**:
   - Use the template structure above
   - Implement both native and Dart sides

2. **Register Components**:
   - Create custom components
   - Register with both registries

3. **Publish Plugin**:
   - Publish to pub.dev for Dart
   - Publish to CocoaPods for iOS
   - Publish to Maven for Android

## Example Implementation

### Native Module Example

```swift
// ExampleModule.swift
import Flight

@objc public class ExampleModule: NSObject, FlightModule {
    @objc public static let shared = ExampleModule()
    
    @objc public var name: String {
        return "example_module"
    }
    
    @objc public var priority: Int {
        return 50 // Higher priority than standard plugins
    }
    
    @objc public func initialize() {
        print("Example module initialized")
        registerComponents()
    }
    
    @objc public func registerComponents() {
        FlightComponentRegistry.shared.register(
            name: "ExampleButton", 
            component: ExampleButton.self
        )
    }
}

// Register module in app
func registerExampleModule() {
    Flight.shared.register(module: ExampleModule.shared)
}
```

### Dart Plugin Example

```dart
// example_plugin.dart
import 'package:flight/flight.dart';

class ExamplePlugin extends FlightPlugin {
  static final ExamplePlugin instance = ExamplePlugin._();
  
  ExamplePlugin._();
  
  @override
  String get name => 'example_plugin';
  
  @override
  void initialize() {
    print('Example plugin initialized');
    registerComponents();
  }
  
  @override
  void registerComponents() {
    FlightUI.registerComponent(
      'ExampleButton',
      (props, children) => ExampleButton(props: props, children: children)
    );
  }
}

// ExampleButton component
class ExampleButton extends FlightComponent {
  ExampleButton({
    Key? key,
    required Map<String, dynamic> props,
    List<Widget> children = const [],
  }) : super(key: key, props: props, children: children);
  
  @override
  String get type => 'ExampleButton';
}

// Register plugin
void registerExamplePlugin() {
  FlightPluginRegistry.instance.registerPlugin(ExamplePlugin.instance);
}
```

## Conclusion

This modularization approach will transform the Flight framework into a powerful, extensible system that can be easily integrated into apps and extended with plugins. By following a consistent pattern for both native and Dart sides, developers will have a clear path to creating custom extensions while maintaining compatibility with the core framework.

The separation of concerns between the framework core, plugins, and app code will create a more maintainable and scalable architecture, allowing for future growth and adoption by the developer community.
