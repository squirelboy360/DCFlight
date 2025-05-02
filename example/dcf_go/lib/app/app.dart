import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/renderer/vdom/component/state_hook.dart';
import 'package:flutter/material.dart' show Colors;

import '../screens/counter_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/about_screen.dart';

class DCFlightDemoApp extends StatefulComponent {
  @override
  UIComponent render() {
    // State for theme
    final isDarkTheme = useState(false);
    
    // State for active tab
    final activeTabIndex = useState(0);
    
    // State for counter
    final counterState = useState(0);
    
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
        return CounterScreen(
          counterState: counterState,
          textColor: textColor,
          accentColor: accentColor,
        );
      case 1:
        return galleryScreen(
          textColor: textColor,
          accentColor: accentColor,
          backgroundColor: backgroundColor,
        );
      case 2:
        return aboutScreen(
          textColor: textColor,
          accentColor: accentColor,
        );
      default:
        return view();
    }
  }
}
