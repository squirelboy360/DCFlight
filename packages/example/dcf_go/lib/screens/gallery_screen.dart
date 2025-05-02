import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

// Change from class to function that returns a VDomNode
VDomNode galleryScreen({
  required Color textColor,
  required Color accentColor,
  required Color backgroundColor,
}) {
  return scrollView(
    layout: const LayoutProps(
      width: '100%',
      height: 600,
      padding: 20,
    ),
    children: [
      text(
        content: "Image Gallery",
        textProps: TextProps(
          fontSize: 28,
          color: textColor,
          fontWeight: "bold",
        ),
        layout: const LayoutProps(
          marginBottom: 20,
          alignSelf: YogaAlign.center,
        ),
      ),
      view(
        layout: const LayoutProps(
          width: '100%',
          justifyContent: YogaJustifyContent.center,
          alignItems: YogaAlign.center,
          marginBottom: 20,
        ),
        children: [
          image(
            imageProps: const ImageProps(
              source: "https://picsum.photos/400/300",
              resizeMode: "cover",
            ),
            layout: const LayoutProps(
              width: 400,
              height: 300,
              marginBottom: 10,
            ),
            onLoad: () {},
          ),
          text(
            content: "Random Image",
            textProps: TextProps(
              fontSize: 18,
              color: textColor,
            ),
          ),
        ],
      ),
      view(
        style: StyleSheet(
          backgroundColor: backgroundColor,
        ),
        layout: const LayoutProps(
          width: '100%',
          marginTop: 20,
          marginBottom: 20,
          padding: 15,
        ),
        children: [
          text(
            content: "DCFlight Components",
            textProps: TextProps(
              fontSize: 24,
              color: textColor,
              fontWeight: "bold",
            ),
            layout: const LayoutProps(
              marginBottom: 15,
            ),
          ),
          text(
            content: "This demo showcases the core primitive components of DCFlight:\n\n• View\n• Text\n• Button\n• Image\n• ScrollView",
            textProps: TextProps(
              fontSize: 16,
              color: textColor,
            ),
            layout: const LayoutProps(
              marginBottom: 15,
            ),
          ),
        ],
      ),
      view(
        style: StyleSheet(
          backgroundColor: Color.fromARGB(
            50,
            accentColor.red,
            accentColor.green,
            accentColor.blue,
          ),
        ),
        layout: const LayoutProps(
          width: '100%',
          marginTop: 20,
          marginBottom: 20,
          padding: 15,
        ),
        children: [
          text(
            content: "State Management",
            textProps: TextProps(
              fontSize: 24,
              color: textColor,
              fontWeight: "bold",
            ),
            layout: const LayoutProps(
              marginBottom: 15,
            ),
          ),
          text(
            content: "DCFlight provides React-like state hooks for managing component state:\n\n• useState - Manages state within components\n• useEffect - For side effects and lifecycle events\n• useContext - For sharing state across components",
            textProps: TextProps(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    ],
  );
}
