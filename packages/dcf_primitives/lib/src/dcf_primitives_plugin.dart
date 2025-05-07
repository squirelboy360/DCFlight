import 'package:dcflight/dcflight.dart';

import 'primitives/button_definition.dart';
import 'primitives/text_definition.dart';
import 'primitives/view_definition.dart';
import 'primitives/image_definition.dart';
import 'primitives/scroll_view_definition.dart';
import 'primitives/svg_definition.dart';
import 'primitives/dcf_icon_definition.dart';

/// Plugin for DCFlight primitives
class DCFPrimitivesPlugin extends DCFPlugin {
  /// Singleton instance
  static final DCFPrimitivesPlugin instance = DCFPrimitivesPlugin._();
  
  /// Private constructor for singleton
  DCFPrimitivesPlugin._();
  
  @override
  String get name => 'dcf_primitives';
  
  @override
  int get priority => 10; // Higher priority than default (100)
  
  @override
  void registerComponents() {
    // Register the core primitives with the framework
    DCFlight.registerComponentDefinition(DCFViewDefinition());
    DCFlight.registerComponentDefinition(DCFButtonDefinition());
    DCFlight.registerComponentDefinition(DCFTextDefinition());
    DCFlight.registerComponentDefinition(DCFImageDefinition());
    DCFlight.registerComponentDefinition(DCFScrollViewDefinition());
    
    // Register the new primitives
    DCFlight.registerComponentDefinition(DCFSvgDefinition());
    DCFlight.registerComponentDefinition(DCFIconDefinition());
  }
}