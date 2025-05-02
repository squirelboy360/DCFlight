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
      style: StyleSheet(backgroundColor: Colors.amber),
      layout: const LayoutProps(
        width: '100%',
        height: '100%',
        alignItems: YogaAlign.center,
        alignContent: YogaAlign.center,

        justifyContent: YogaJustifyContent.center,
      ),
      children: [
        text(
          content: "Welcome to DCFlight",
          layout: LayoutProps(width: 300, height: 50),
          textProps: TextProps(fontSize: 24, color: Colors.white),
        ),
        button(
          layout: LayoutProps(width: 200, height: 50),
          buttonProps: ButtonProps(title: "Click Me"),
          onPress: () {
            print("Button clicked");
          },
        ),
      ],
    );
  }
}
