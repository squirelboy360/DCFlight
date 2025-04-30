// Main entry point for the DCFlight framework
library dcflight;

// Core Infrastructure
export 'framework/packages/vdom/vdom.dart';
export 'framework/packages/vdom/vdom_node.dart';
export 'framework/packages/vdom/vdom_element.dart';
export 'framework/packages/vdom/reconciler.dart';
export 'framework/packages/vdom/fragment.dart';
export 'framework/packages/vdom/component/component.dart';

// Native Bridge System
export 'framework/packages/native_bridge/dispatcher.dart';
export 'framework/packages/native_bridge/dispatcher_imp.dart';

// Core Constants and Properties - explicitly exported for component developers
export 'framework/constants/yoga_enums.dart';
export 'framework/constants/layout_properties.dart';
export 'framework/constants/style_properties.dart';

// Utilities
export 'framework/utilities/screen_utilities.dart';


// Component Protocol Interfaces - no implementations
export 'framework/protocol/component_protocol.dart';
export 'framework/protocol/component_registry.dart';
export 'framework/protocol/plugin_protocol.dart';

// Application Entry Point
import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/protocol/component_registry.dart';

import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/component/component.dart';
import 'framework/packages/native_bridge/dispatcher.dart';
import 'framework/utilities/screen_utilities.dart';
import 'framework/protocol/plugin_protocol.dart';
import 'package:flutter/material.dart';

/// DCFlight Framework entry points
class DCFlight {
  /// Initialize the DCFlight framework
  static Future<bool> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize platform dispatcher
    final bridge = NativeBridgeFactory.create();
    PlatformDispatcher.initializeInstance(bridge);
    await bridge.initialize();
    
    // Initialize screen utilities
    ScreenUtilities.instance.refreshDimensions();
    
    // Register core plugin
    PluginRegistry.instance.registerPlugin(CorePlugin.instance);
    
    return true;
  }
  
  /// Start the application with the given root component
  static Future<void> start({required Component app}) async {
    // Create VDOM instance
    final vdom = VDom();
    
    // Create our main app component
    final mainApp = app;
    
    // Create a component node
    final appNode = vdom.createComponent(mainApp);
    
    // Render the component to native UI
    await vdom.renderToNative(appNode, parentId: "root", index: 0);
    
    // Wait for the VDom to be ready
    vdom.isReady.whenComplete(() async {
      debugPrint('VDOM is ready to calculate');
      await vdom.calculateAndApplyLayout().then((v) {
        debugPrint('VDOM layout applied from entry point');
      });
    });
  }
  
  /// Register a plugin with the framework
  static void registerPlugin(DCFPlugin plugin) {
    PluginRegistry.instance.registerPlugin(plugin);
  }
  
  /// Register a component factory with the framework
  static void registerComponent(String type, ComponentFactory factory) {
    ComponentRegistry.instance.registerComponent(type, factory);
  }
  
  /// Register a component definition with the framework
  static void registerComponentDefinition(ComponentDefinition definition) {
    ComponentRegistry.instance.registerComponentDefinition(definition);
  }
}

/// Simplified version of the original entry point for backward compatibility
void initializeApplication(Component app) async {
  await DCFlight.initialize();
  await DCFlight.start(app: app);
}

/// Simplified version of startNativeApp for backward compatibility
void startNativeApp({required Component app}) async {
  await DCFlight.start(app: app);
}