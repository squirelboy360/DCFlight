import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

// Change from class to function that returns a VDomNode
UIComponent aboutScreen({
  required Color textColor,
  required Color accentColor,
}) {
  return view(
    layout: const LayoutProps(
      width: '100%',
      height: 600,
      justifyContent: YogaJustifyContent.flexStart,
      alignItems: YogaAlign.center,
      padding: 30,
    ),
    children: [
      text(
        content: "About DCFlight",
        textProps: TextProps(
          fontSize: 28,
          color: textColor,
          fontWeight: "bold",
        ),
        layout: const LayoutProps(
          marginBottom: 30,
        ),
      ),
      view(
        style: StyleSheet(
          backgroundColor: Color.fromARGB(
            25,
            accentColor.red,
            accentColor.green, 
            accentColor.blue,
          ),
        ),
        layout: const LayoutProps(
          width: '100%',
          padding: 20,
          marginBottom: 20,
        ),
        children: [
          text(
            content: "DCFlight is a high-performance cross-platform UI framework that combines React-like component architecture with native UI rendering.",
            textProps: TextProps(
              fontSize: 16,
              color: textColor,
            ),
            layout: const LayoutProps(
              marginBottom: 15,
            ),
          ),
          text(
            content: "Key Features:",
            textProps: TextProps(
              fontSize: 18,
              color: textColor,
              fontWeight: "bold",
            ),
            layout: const LayoutProps(
              marginBottom: 10,
            ),
          ),
          text(
            content: "• Declarative UI with VDOM\n• Yoga-powered layout engine\n• React-like hooks for state management\n• Native UI components for optimal performance\n• Cross-platform compatibility",
            textProps: TextProps(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
      button(
        buttonProps: ButtonProps(
          title: "Visit Repository",
          color: const Color(0xFFFFFFFF),
          backgroundColor: accentColor,
        ),
        layout: const LayoutProps(
          width: 200,
          height: 50,
          marginTop: 20,
        ),
        onPress: () {},
      ),
      view(
        layout: const LayoutProps(
          marginTop: 40,
        ),
        children: [
          text(
            content: "DCFlight © 2024",
            textProps: TextProps(
              fontSize: 14,
              color: Color.fromARGB(
                153,  // 0.6 opacity = ~153/255
                textColor.red,
                textColor.green,
                textColor.blue,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
