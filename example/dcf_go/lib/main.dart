import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

void main() { 
  // First, register the primitives plugin
  DCFlight.initialize().then((_) {
    // Register the primitives plugin                                                                                                                                                                                                                               
    DCFlight.registerPlugin(DCFPrimitivesPlugin.instance);
    
    // Start the app
    DCFlight.start(app: GalleryApp());
  });
}

class GalleryApp extends StatefulComponent {
  @override
  UIComponent render() {
    // Create an instance of view using lowerCamelCase naming
    return view(
      style: StyleSheet(
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      layout: const LayoutProps(
        width: '100%',
        height: '100%',
        alignItems: YogaAlign.center,
        justifyContent: YogaJustifyContent.center,
      ),
      children: [
        text(
          content: "Welcome to DCFlight",
          textProps: TextProps(
            fontSize: 24,
            color: const Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}