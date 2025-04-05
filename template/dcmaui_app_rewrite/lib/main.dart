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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  developer.log('Starting DCMAUI application', name: 'App');

  // Start the native UI application
  startNativeApp();
}

void startNativeApp() async {
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
  final viewId = await vdom.renderToNative(appNode, parentId: "root", index: 0);
  developer.log('Rendered main app component with ID: $viewId', name: 'App');

  developer.log('DCMAUI framework started in headless mode', name: 'App');
}

class AnimatedAppComponent extends StatefulComponent {
  // Helper method to generate colored boxes
  VDomNode createBox(int index, int counter) {
    final hue = (index * 30 + counter * 5) % 360;
    final color = HSVColor.fromAHSV(1.0, hue.toDouble(), 0.8, 0.9).toColor();

    return UI.View(
      layout: LayoutProps(
        width: 80,
        height: 80,
        margin: 8,
        alignItems: YogaAlign.center,
        justifyContent: YogaJustifyContent.center,
      ),
      style: StyleSheet(
        backgroundColor: color,
        borderRadius: 8,
        elevation: 3,
      ),
      children: [
        UI.Text(
          content: (index + 1).toString(),
          textProps: TextProps(
            color: '#FFFFFF',
            fontSize: 20,
            fontWeight: 'bold',
          ),
        ),
      ],
    );
  }

  @override
  VDomNode render() {
    // State hooks
    final counter = useState(0, 'counter');
    final cardColor = useState('#6A1B9A', 'cardColor');
    final accentColor = useState('#E91E63', 'accentColor');
    final borderWidth = useState(5.0, 'borderWidth');
    final rotation = useState(0.0, 'rotation');
    final boxCount = useState(30, 'boxCount');

    // Animation effect for color transitions
    useEffect(() {
      final colorTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        final rnd = math.Random();
        final r = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');
        final g = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');
        final b = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');

        cardColor.setValue('#$r$g$b');
        developer.log('Updated card color to: #$r$g$b', name: 'Animation');
      });

      return () {
        colorTimer.cancel();
        developer.log('Canceled color animation timer', name: 'Animation');
      };
    }, dependencies: []);

    // Animation effect for accent color and border width
    useEffect(() {
      final accentTimer =
          Timer.periodic(const Duration(milliseconds: 1500), (_) {
        final rnd = math.Random();
        final r = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');
        final g = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');
        final b = (rnd.nextInt(200) + 55).toRadixString(16).padLeft(2, '0');

        accentColor.setValue('#$r$g$b');
        borderWidth.setValue(rnd.nextDouble() * 10 + 2);
      });

      return () {
        accentTimer.cancel();
      };
    }, dependencies: []);

    // Animation effect for rotation
    useEffect(() {
      final rotationTimer =
          Timer.periodic(const Duration(milliseconds: 50), (_) {
        rotation.setValue((rotation.value + 1) % 360);
      });

      return () {
        rotationTimer.cancel();
      };
    }, dependencies: []);

    // Generate box grid items
    final boxes = List.generate(
      boxCount.value,
      (i) => createBox(i, counter.value),
    );

    // Calculate rotation transform
    final transform = {
      'rotate': '${rotation.value}deg',
    };

    return UI.View(
      layout: LayoutProps(
        width: '100%',
        height: '100%',
        flexDirection: YogaFlexDirection.column,
      ),
      style: StyleSheet(
        backgroundColor: Color(0xFFF5F5F5),
      ),
      children: [
        // Header
        UI.View(
          layout: LayoutProps(
            height: 80,
            width: '100%',
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            paddingLeft: 16,
            paddingRight: 16,
          ),
          style: StyleSheet(
            backgroundColor:
                ColorUtilities.color(fromHexString: accentColor.value),
            elevation: 4,
          ),
          children: [
            UI.Image(
              layout: LayoutProps(
                width: 40,
                height: 40,
              ),
              imageProps: ImageProps(
                source: 'system://sparkles',
                tintColor: '#FFFFFF',
              ),
            ),
            UI.Text(
              content: "DCMAUI Demo App",
              layout: LayoutProps(
                marginLeft: 12,
                flex: 1,
              ),
              textProps: TextProps(
                fontSize: 22,
                color: '#FFFFFF',
                fontWeight: 'bold',
              ),
            ),
            UI.View(
              layout: LayoutProps(
                width: 40,
                height: 40,
              ),
              style: StyleSheet(
                backgroundColor: Colors.white,
                borderRadius: 20,
                transform: transform,
              ),
              children: [
                UI.Text(
                  content: "🔄",
                  layout: LayoutProps(
                    alignSelf: YogaAlign.center,
                  ),
                  textProps: TextProps(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Main content
        UI.ScrollView(
          layout: LayoutProps(
            flex: 1,
            width: '100%',
          ),
          scrollViewProps: ScrollViewProps(
            showsVerticalScrollIndicator: true,
          ),
          children: [
            // Counter display card
            UI.View(
              layout: LayoutProps(
                width: '90%',
                alignSelf: YogaAlign.center,
                margin: 16,
                padding: 16,
                alignItems: YogaAlign.center,
                justifyContent: YogaJustifyContent.center,
              ),
              style: StyleSheet(
                backgroundColor:
                    ColorUtilities.color(fromHexString: cardColor.value),
                borderRadius: 16,
                elevation: 10,
              ),
              children: [
                UI.Text(
                  content: "Counter Value",
                  textProps: TextProps(
                    fontSize: 18,
                    color: '#FFFFFF',
                    fontWeight: 'medium',
                  ),
                ),
                UI.View(
                  layout: LayoutProps(
                    width: 120,
                    height: 120,
                    margin: 16,
                    alignItems: YogaAlign.center,
                    justifyContent: YogaJustifyContent.center,
                  ),
                  style: StyleSheet(
                    backgroundColor: Colors.white,
                    borderRadius: 60,
                    borderColor:
                        ColorUtilities.color(fromHexString: accentColor.value),
                    borderWidth: borderWidth.value,
                  ),
                  children: [
                    UI.Text(
                      content: counter.value.toString(),
                      textProps: TextProps(
                        fontSize: 48,
                        color: cardColor.value,
                        fontWeight: 'bold',
                      ),
                    ),
                  ],
                ),

                // Counter controls
                UI.View(
                  layout: LayoutProps(
                    flexDirection: YogaFlexDirection.row,
                    marginTop: 16,
                  ),
                  children: [
                    UI.Button(
                      layout: LayoutProps(
                        marginRight: 8,
                      ),
                      style: StyleSheet(
                        backgroundColor: Colors.white,
                        borderRadius: 8,
                      ),
                      buttonProps: ButtonProps(
                        title: "−",
                        titleColor: cardColor.value,
                        fontSize: 24,
                        fontWeight: 'bold',
                      ),
                      onPress: () => counter.setValue(counter.value - 1),
                    ),
                    UI.Button(
                      layout: LayoutProps(
                        marginLeft: 8,
                        marginRight: 8,
                      ),
                      style: StyleSheet(
                        backgroundColor: Colors.white,
                        borderRadius: 8,
                      ),
                      buttonProps: ButtonProps(
                        title: "Reset",
                        titleColor: cardColor.value,
                        fontSize: 16,
                        fontWeight: 'bold',
                      ),
                      onPress: () => counter.setValue(0),
                    ),
                    UI.Button(
                      layout: LayoutProps(
                        marginLeft: 8,
                      ),
                      style: StyleSheet(
                        backgroundColor: Colors.white,
                        borderRadius: 8,
                      ),
                      buttonProps: ButtonProps(
                        title: "+",
                        titleColor: cardColor.value,
                        fontSize: 24,
                        fontWeight: 'bold',
                      ),
                      onPress: () => counter.setValue(counter.value + 1),
                    ),
                  ],
                ),
              ],
            ),

            // Color display card
            UI.View(
              layout: LayoutProps(
                width: '90%',
                alignSelf: YogaAlign.center,
                marginBottom: 16,
                padding: 16,
              ),
              style: StyleSheet(
                backgroundColor: Colors.white,
                borderRadius: 16,
                elevation: 5,
              ),
              children: [
                UI.Text(
                  content: "Animated Colors",
                  layout: LayoutProps(
                    alignSelf: YogaAlign.center,
                    marginBottom: 12,
                  ),
                  textProps: TextProps(
                    fontSize: 18,
                    color: '#333333',
                    fontWeight: 'medium',
                  ),
                ),
                UI.View(
                  layout: LayoutProps(
                    width: '100%',
                    height: 40,
                    marginBottom: 12,
                  ),
                  style: StyleSheet(
                    backgroundColor:
                        ColorUtilities.color(fromHexString: cardColor.value),
                    borderRadius: 8,
                  ),
                  children: [
                    UI.Text(
                      content: "Main Color: ${cardColor.value}",
                      layout: LayoutProps(
                        alignSelf: YogaAlign.center,
                        marginTop: 10,
                      ),
                      textProps: TextProps(
                        fontSize: 14,
                        color: '#FFFFFF',
                        fontWeight: 'medium',
                      ),
                    ),
                  ],
                ),
                UI.View(
                  layout: LayoutProps(
                    width: '100%',
                    height: 40,
                  ),
                  style: StyleSheet(
                    backgroundColor:
                        ColorUtilities.color(fromHexString: accentColor.value),
                    borderRadius: 8,
                  ),
                  children: [
                    UI.Text(
                      content: "Accent Color: ${accentColor.value}",
                      layout: LayoutProps(
                        alignSelf: YogaAlign.center,
                        marginTop: 10,
                      ),
                      textProps: TextProps(
                        fontSize: 14,
                        color: '#FFFFFF',
                        fontWeight: 'medium',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Grid of colored boxes
            UI.View(
              layout: LayoutProps(
                width: '90%',
                alignSelf: YogaAlign.center,
                marginBottom: 16,
                padding: 16,
              ),
              style: StyleSheet(
                backgroundColor: Colors.white,
                borderRadius: 16,
                elevation: 5,
              ),
              children: [
                UI.Text(
                  content: "Color Grid",
                  layout: LayoutProps(
                    alignSelf: YogaAlign.center,
                    marginBottom: 12,
                  ),
                  textProps: TextProps(
                    fontSize: 18,
                    color: '#333333',
                    fontWeight: 'medium',
                  ),
                ),

                // Scrollable grid of boxes
                UI.ScrollView(
                  layout: LayoutProps(
                    width: '100%',
                    height: 200,
                  ),
                  scrollViewProps: ScrollViewProps(
                    horizontal: true,
                    showsHorizontalScrollIndicator: true,
                  ),
                  children: [
                    UI.View(
                      layout: LayoutProps(
                        flexDirection: YogaFlexDirection.row,
                        flexWrap: YogaWrap.wrap,
                        padding: 8,
                      ),
                      children: boxes,
                    ),
                  ],
                ),

                // Box count controls
                UI.View(
                  layout: LayoutProps(
                    flexDirection: YogaFlexDirection.row,
                    justifyContent: YogaJustifyContent.center,
                    marginTop: 16,
                  ),
                  children: [
                    UI.Button(
                      layout: LayoutProps(
                        marginRight: 8,
                      ),
                      style: StyleSheet(
                        backgroundColor: ColorUtilities.color(
                            fromHexString: accentColor.value),
                        borderRadius: 8,
                      ),
                      buttonProps: ButtonProps(
                        title: "Fewer Boxes",
                        titleColor: '#FFFFFF',
                      ),
                      onPress: () =>
                          boxCount.setValue(math.max(5, boxCount.value - 5)),
                    ),
                    UI.Button(
                      layout: LayoutProps(
                        marginLeft: 8,
                      ),
                      style: StyleSheet(
                        backgroundColor: ColorUtilities.color(
                            fromHexString: accentColor.value),
                        borderRadius: 8,
                      ),
                      buttonProps: ButtonProps(
                        title: "More Boxes",
                        titleColor: '#FFFFFF',
                      ),
                      onPress: () => boxCount.setValue(boxCount.value + 5),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Footer
        UI.View(
          layout: LayoutProps(
            height: 60,
            width: '100%',
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.center,
          ),
          style: StyleSheet(
            backgroundColor:
                ColorUtilities.color(fromHexString: accentColor.value),
          ),
          children: [
            UI.Text(
              content: "Built with DCMAUI Framework",
              textProps: TextProps(
                fontSize: 16,
                color: '#FFFFFF',
                fontWeight: '500',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper class for color utilities (simpler version for bridging)
class ColorUtilities {
  /// Convert hex string to Color
  static Color color({required String fromHexString}) {
    var hexString = fromHexString.replaceAll('#', '');

    if (hexString.length == 6) {
      hexString = 'FF' + hexString; // Add alpha if not provided
    }

    return Color(int.parse(hexString, radix: 16));
  }
}
