import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component.dart';
import 'framework/components/comp_props/button_props.dart';
import 'framework/components/comp_props/scroll_view_props.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/image_props.dart';
import 'framework/components/ui.dart';
import 'framework/constants/layout_properties.dart';
import 'framework/constants/style_properties.dart';
import 'framework/packages/yoga/yoga_enums.dart';
import 'framework/utilities/screen_utilities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  developer.log('Starting DCMAUI application', name: 'App');

  // Start the native UI application
  startNativeApp();
}

void startNativeApp() async {
  // Initialize screen utilities first
  await ScreenUtilities.instance.refreshDimensions();

  // Log actual screen dimensions for debugging
  developer.log(
      'Screen dimensions: ${ScreenUtilities.instance.screenWidth} x ${ScreenUtilities.instance.screenHeight}',
      name: 'App');

  // Create VDOM instance
  final vdom = VDom();

  // Wait for the VDom to be ready
  await vdom.isReady;
  developer.log('VDom is ready', name: 'App');

  // Create our main app component
  final mainApp = AnimatedAppComponent();

  // Create a component node
  final appNode = vdom.createComponent(mainApp);

  // Render the component to native UI
  await vdom.renderToNative(appNode, parentId: "root", index: 0);
  developer.log(
      'DCMAUI framework successfully initialized and running in headless mode',
      name: 'App');
}

class AnimatedAppComponent extends StatefulComponent {
  @override
  VDomNode render() {
    // State hooks
    final counter = useState(0, 'counter');

    useEffect(() {
      // Set up a timer to update the color every second
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Update the background color
        counter.setValue(counter.value + 1);
      });

      // Clean up the timer when the component is unmounted
      return () {
        timer.cancel();
        developer.log('Canceled background color animation timer',
            name: 'ColorAnimation');
      };
    }, dependencies: []);

    return UI.View(
        layout: LayoutProps(
          // Use explicit dimensions instead of percentages for testing
          height: ScreenUtilities.instance.screenHeight,
          width: ScreenUtilities.instance.screenWidth,
          alignItems: YogaAlign.center,
          justifyContent: YogaJustifyContent.center,
        ),
        style: StyleSheet(backgroundColor: Colors.amber),
        children: [
          UI.View(
            layout: LayoutProps(height: 100, width: 200),
            style: StyleSheet(
              backgroundColor: Colors.white,
              borderRadius: 8,
            ),
            children: [
              UI.Text(
                content: 'Counter: ${counter.value}',
                textProps: TextProps(
                  // Use explicit color hex string for testing
                  color: Colors.purpleAccent, // Explicit blue color
                  fontSize: 20,
                  fontWeight: 'bold',
                ),
              ),
            ],
          ),
        ]);
  }
}
