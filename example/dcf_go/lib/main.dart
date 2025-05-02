import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';
import 'package:flutter/material.dart';

void main() async {
print("Evidence of dart side running");
  DCFlight.start(app: GalleryApp());

}

class GalleryApp extends StatefulComponent {
  @override
  UIComponent render() {
    // Create an instance of view using lowerCamelCase naming
    return view(
      style: StyleSheet(
        backgroundColor: const Color.fromARGB(255, 228, 20, 20),
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
          textProps: TextProps(fontSize: 24, color: const Color(0xFF000000)),
        ),
      ],
    );
  }
}
