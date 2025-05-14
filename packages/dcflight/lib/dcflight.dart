// Main entry point for the DCFlight framework
library dcflight;

export 'package:dcflight/framework/utilities/flutter_framework.dart' hide PlatformDispatcher,
   Widget,View,StatefulWidget,State,BuildContext,MethodChannel,MethodCall,MethodCodec,PlatformException,AssetBundle,AssetBundleImageKey,AssetBundleImageProvider,ImageConfiguration,ImageStreamListener,ImageStream,ImageStreamCompleter,ImageInfo,ImageProvider,ImageErrorListener,ImageCache,Text,TextStyle,TextPainter,TextSpan,TextHeightBehavior,RenderBox,RenderObject,RenderObjectElement,RenderObjectWidget,StatefulElement,Element,ElementVisitor,WidgetInspectorService;
// Core Infrastructure
export 'framework/renderer/vdom/vdom.dart';
export 'framework/renderer/vdom/vdom_node.dart';
export 'framework/renderer/vdom/vdom_element.dart';
export 'framework/renderer/vdom/reconciler.dart';
export 'framework/renderer/vdom/fragment.dart';
export 'framework/renderer/vdom/hooks.dart';
// Native Bridge System
export 'framework/renderer/native_bridge/dispatcher.dart';
export 'framework/renderer/native_bridge/dispatcher_imp.dart';

// Core Constants and Properties - explicitly exported for component developers
export 'framework/constants/yoga_enums.dart';
export 'framework/constants/layout_properties.dart';
export 'framework/constants/style_properties.dart';

// Utilities
export 'framework/utilities/screen_utilities.dart';

// Protocol Interfaces
export 'framework/protocol/plugin_protocol.dart';

// Application Entry Point
import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/protocol/component_registry.dart';

import 'framework/renderer/vdom/vdom.dart';
import 'framework/renderer/vdom/vdom_element.dart';
import 'framework/renderer/native_bridge/dispatcher.dart';
import 'framework/utilities/screen_utilities.dart';
import 'framework/protocol/plugin_protocol.dart';
import 'package:flutter/material.dart';

/// DCFlight Framework entry points
class DCFlight {
  /// Initialize the DCFlight framework
  static Future<bool> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize platform dispatcher
    final bridge = NativeBridgeFactory.create();
    await bridge.initialize();
    
    // Initialize screen utilities
    ScreenUtilities.instance.refreshDimensions();
    
    // Register core plugin
    PluginRegistry.instance.registerPlugin(CorePlugin.instance);
    
    return true;
  }
  
  /// Start the application with a VDomElement as the root
  /// Uses hooks directly in VDomElements for state management
  static Future<void> start({required VDomElement element}) async {
    await _initialize();
    
    // Create VDOM instance
    final vdom = VDom();
    
    // Create a hook-enabled element (which sets up update scheduling)
    final rootElement = vdom.createHookElement(
      element.type, 
      props: element.props,
      children: element.children,
      key: element.key
    );
    
    // Render the element to native UI
    await vdom.renderToNative(rootElement, parentId: "root", index: 0);
    
    // Wait for the VDom to be ready
    vdom.isReady.whenComplete(() async {
      debugPrint('VDOM is ready to calculate');
      await vdom.calculateAndApplyLayout().then((v) {
        debugPrint('VDOM layout applied from entry point');
      });
    });
  }

    /// Register a component definition with the framework
  static void registerComponentDefinition(ComponentDefinition definition) {
    ComponentRegistry.instance.registerComponentDefinition(definition);
  }
}

