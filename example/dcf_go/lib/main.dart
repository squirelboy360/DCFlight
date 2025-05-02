import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/renderer/vdom/component/state_hook.dart';
import 'package:flutter/material.dart' show Colors;

void main() async {
  DCFlight.start(app: DCFlightDemoApp());
}

class DCFlightDemoApp extends StatefulComponent {
  @override
  UIComponent render() {
    // State for counter
    final counterState = useState(0);
    
    // State for theme
    final isDarkTheme = useState(false);
    
    // State for active tab
    final activeTabIndex = useState(0);
    
    // Derive theme colors based on isDarkTheme
    final backgroundColor = isDarkTheme.value 
        ? const Color(0xFF121212) 
        : const Color(0xFFF5F5F5);
    
    final textColor = isDarkTheme.value 
        ? const Color(0xFFFFFFFF) 
        : const Color(0xFF000000);
    
    final accentColor = isDarkTheme.value 
        ? const Color(0xFF536DFE) 
        : const Color(0xFF3D5AFE);
    
    // Define tabs
    final tabs = [
      "Counter",
      "Gallery",
      "About",
    ];
    
    return view(
      style: StyleSheet(
        backgroundColor: backgroundColor,
      ),
      layout: const LayoutProps(
        width: '100%',
        height: '100%',
        justifyContent: YogaJustifyContent.flexStart,
        alignItems: YogaAlign.center,
      ),
      children: [
        // Header
        view(
          style: StyleSheet(
            backgroundColor: accentColor,
          ),
          layout: const LayoutProps(
            width: '100%',
            height: 80,
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceBetween,
            alignItems: YogaAlign.center,
            paddingLeft: 20,
            paddingRight: 20,
          ),
          children: [
            text(
              content: "DCFlight Demo",
              textProps: const TextProps(
                fontSize: 24,
                color: Color(0xFFFFFFFF),
                fontWeight: "bold",
              ),
            ),
            button(
              buttonProps: ButtonProps(
                title: isDarkTheme.value ? "Light Mode" : "Dark Mode",
                color: isDarkTheme.value ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                backgroundColor: isDarkTheme.value ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
              ),
              layout: const LayoutProps(
                width: 120,
                height: 40,
              ),
              onPress: () {
                isDarkTheme.setValue(!isDarkTheme.value);
              },
            ),
          ],
        ),
        
        // Tabs
        view(
          style: StyleSheet(
            backgroundColor: isDarkTheme.value ? const Color(0xFF1E1E1E) : const Color(0xFFE0E0E0),
          ),
          layout: const LayoutProps(
            width: '100%',
            height: 50,
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceEvenly,
            alignItems: YogaAlign.center,
          ),
          children: [
            for (int i = 0; i < tabs.length; i++)
              button(
                buttonProps: ButtonProps(
                  title: tabs[i],
                  color: i == activeTabIndex.value 
                      ? const Color(0xFFFFFFFF) 
                      : textColor,
                  backgroundColor: i == activeTabIndex.value 
                      ? accentColor
                      : Colors.transparent,
                ),
                layout: const LayoutProps(
                  width: 100,
                  height: 40,
                ),
                onPress: () {
                  activeTabIndex.setValue(i);
                },
              ),
          ],
        ),
        
        // Content based on active tab
        renderTabContent(
          activeTabIndex.value, 
          counterState, 
          textColor, 
          accentColor,
          backgroundColor,
        ),
      ],
    );
  }
  
  // Helper method to render the content of the active tab
  UIComponent renderTabContent(
    int activeTab, 
    StateHook<int> counterState, 
    Color textColor, 
    Color accentColor,
    Color backgroundColor,
  ) {
    switch (activeTab) {
      case 0:
        return renderCounterTab(counterState, textColor, accentColor);
      case 1:
        return renderGalleryTab(textColor, accentColor, backgroundColor);
      case 2:
        return renderAboutTab(textColor, accentColor);
      default:
        return view();
    }
  }
  
  // Counter tab content
  UIComponent renderCounterTab(StateHook<int> counterState, Color textColor, Color accentColor) {
    return view(
      layout: const LayoutProps(
        width: '100%',
        height: 600,
        justifyContent: YogaJustifyContent.center,
        alignItems: YogaAlign.center,
        padding: 20,
      ),
      children: [
        text(
          content: "Counter: ${counterState.value}",
          textProps: TextProps(
            fontSize: 36,
            color: textColor,
            fontWeight: "bold",
          ),
          layout: const LayoutProps(
            marginBottom: 40,
          ),
        ),
        view(
          layout: const LayoutProps(
            width: '100%',
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceEvenly,
            alignItems: YogaAlign.center,
          ),
          children: [
            button(
              buttonProps: ButtonProps(
                title: "Decrement",
                color: const Color(0xFFFFFFFF),
                backgroundColor: counterState.value > 0 ? accentColor : const Color(0xFFAAAAAA),
              ),
              layout: const LayoutProps(
                width: 120,
                height: 50,
              ),
              onPress: () {
                if (counterState.value > 0) {
                  counterState.setValue(counterState.value - 1);
                }
              },
            ),
            button(
              buttonProps: ButtonProps(
                title: "ResetValue",
                color: const Color(0xFFFFFFFF),
                backgroundColor: counterState.value != 0 ? const Color(0xFFFF5722) : const Color(0xFFAAAAAA),
              ),
              layout: const LayoutProps(
                width: 120,
                height: 50,
              ),
              onPress: () {
                if (counterState.value != 0) {
                  counterState.setValue(0);
                }
              },
            ),
            button(
              buttonProps: ButtonProps(
                title: "Increment",
                color: const Color(0xFFFFFFFF),
                backgroundColor: accentColor,
              ),
              layout: const LayoutProps(
                width: 120,
                height: 50,
              ),
              onPress: () {
                counterState.setValue(counterState.value + 1);
              },
            ),
          ],
        ),
      ],
    );
  }
  
  // Gallery tab content
  UIComponent renderGalleryTab(Color textColor, Color accentColor, Color backgroundColor) {
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
  
  // About tab content
  UIComponent renderAboutTab(Color textColor, Color accentColor) {
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
}
