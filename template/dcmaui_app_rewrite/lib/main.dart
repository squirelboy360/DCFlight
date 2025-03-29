import 'dart:async';
import 'dart:math' as math;

import 'package:dc_test/framework/components/button_props.dart';
import 'package:dc_test/framework/components/image_props.dart';
import 'package:dc_test/framework/components/scroll_view_props.dart';
import 'package:dc_test/framework/components/text_props.dart';

import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component.dart';
import 'framework/packages/performance/performance_monitor.dart';
import 'framework/components/view_props.dart';
import 'framework/components/ui.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Starting DCMAUI application', name: 'App');

  // Start performance monitoring
  PerformanceMonitor().startMonitoring();

  // Start the native UI application
  startNativeApp();
}

void startNativeApp() async {
  // Create VDOM instance
  final vdom = VDom();

  // Wait for the VDom to be ready
  await vdom.isReady;
  developer.log('VDom is ready', name: 'App');

  // Create our counter component
  final counterComponent = CounterComponent();

  // Create a component node
  final counterNode = vdom.createComponent(counterComponent);

  // Render the component to native UI
  final viewId =
      await vdom.renderToNative(counterNode, parentId: "root", index: 0);
  developer.log('Rendered counter component with ID: $viewId', name: 'App');

  developer.log('DCMAUI framework started in headless mode', name: 'App');
}

class CounterComponent extends StatefulComponent {
  @override
  VDomNode render() {
    final counter = useState(0, 'counter');
    final bg =
        useState(Color(Colors.indigoAccent.toARGB32()), 'scrollViewBGColor');

    final borderBgs =
        useState(Color(Colors.indigoAccent.toARGB32()), 'scrollViewBGColor');
    // Use an effect to update the ScrollView background color every second
    useEffect(() {
      final rnd = math.Random();
      Color color() => Color(rnd.nextInt(0xffffffff));
      // Set up a timer to update the color every second
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Update the background color
        bg.setValue(color());

        developer.log('Updated ScrollView background color to: $color',
            name: 'ColorAnimation');
      });

      // Clean up the timer when the component is unmounted
      return () {
        timer.cancel();
        developer.log('Canceled background color animation timer',
            name: 'ColorAnimation');
      };
    }, dependencies: []);

    useEffect(() {
      final rnd = math.Random();
      Color color() => Color(rnd.nextInt(0xffffffff));
      // Set up a timer to update the color every second
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Update the background color
        borderBgs.setValue(color());
        counter.setValue(counter.value + 1);
        developer.log('Updated border color to: $color',
            name: 'ColorAnimation');
      });

      // Clean up the timer when the component is unmounted
      return () {
        timer.cancel();
        developer.log('Canceled background color animation timer',
            name: 'ColorAnimation');
      };
    }, dependencies: []);

    return UI.View(
        props: ViewProps(
          height: '100%',
          width: '100%',
        ),
        children: [
          UI.ScrollView(
              props: ScrollViewProps(
                height: '80%',
                width: '100%',
                showsHorizontalScrollIndicator: true,
                backgroundColor: Colors.indigoAccent,
              ),
              children: [
                UI.View(
                    props: ViewProps(
                        padding: 20,
                        margin: 20,
                        borderRadius: 20,
                        borderWidth: 10,
                        width: '90%',
                        alignItems: 'center',
                        justifyContent: 'center',
                        height: '20%',
                        backgroundColor: bg.value),
                    children: [
                      UI.View(
                          props: ViewProps(
                            alignItems: 'center',
                            justifyContent: 'center',
                            borderRadius: 20,
                            borderColor: borderBgs.value,
                            borderWidth: 10,
                            height: '80%',
                            width: '80%',
                            backgroundColor: Colors.green,
                          ),
                          children: [
                            UI.Text(
                                content: "Test App ",
                                props: TextProps(
                                  fontSize: 20,
                                  color: Colors.white,
                                  textAlign: 'center',
                                  fontWeight: 'bold',
                                )),
                            UI.Text(
                                content: "Counter Value: ${counter.value}",
                                props: TextProps(
                                  fontSize: 20,
                                  color: Colors.amber,
                                  textAlign: 'center',
                                  fontWeight: 'bold',
                                ))
                          ]),
                    ]),
                UI.ScrollView(
                    props: ScrollViewProps(
                      height: '70%',
                      width: '100%',
                      showsHorizontalScrollIndicator: true,
                      backgroundColor: Colors.red,
                    ),
                    children: [
                      UI.Image(
                          props: ImageProps(
                        margin: 20,
                        resizeMode: 'cover',
                        borderRadius: 20,
                        borderWidth: 10,
                        height: '50%',
                        width: '90%',
                        borderColor: borderBgs.value,
                        source:
                            'https://avatars.githubusercontent.com/u/205313423?s=400&u=2abecc79555be8a9b63ddd607489676ab93b2373&v=4',
                      )),
                      UI.Image(
                          props: ImageProps(
                        margin: 20,
                        resizeMode: 'cover',
                        borderRadius: 20,
                        borderWidth: 10,
                        height: '50%',
                        width: '90%',
                        borderColor: borderBgs.value,
                        source:
                            'https://encrypted-tbn2.gstatic.com/licensed-image?q=tbn:ANd9GcQdMytXURczdY2WtIcNPaoFkgXdFhhbRLvujtCW4xHeSlQP02D_Lb6cwNuuxr7IiTsgbFpkUa7SQz5Xpsg',
                      )),
                      UI.Image(
                          props: ImageProps(
                        margin: 20,
                        resizeMode: 'cover',
                        borderRadius: 20,
                        borderWidth: 10,
                        height: '50%',
                        width: '90%',
                        borderColor: borderBgs.value,
                        source:
                            'https://encrypted-tbn2.gstatic.com/licensed-image?q=tbn:ANd9GcQdMytXURczdY2WtIcNPaoFkgXdFhhbRLvujtCW4xHeSlQP02D_Lb6cwNuuxr7IiTsgbFpkUa7SQz5Xpsg',
                      )),
                    ]),
              ]),
          UI.View(
              props: ViewProps(
                width: '100%',
                backgroundColor: Colors.red,
                height: 50,
                flexDirection: 'row',
              ),
              children: [
                UI.Button(
                    title: "Increment Counter",
                    props: ButtonProps(
                        marginBottom: 20,
                        width: '50%',
                        backgroundColor: Colors.amberAccent),
                    onPress: (v) {
                      counter.setValue(counter.value + 1);
                    })
              ])
        ]);
  }
}
