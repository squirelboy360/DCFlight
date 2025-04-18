import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dcflight/framework/utilities/entry.dart';
import 'package:dcflight/framework/utilities/flutter.dart';
import 'dart:developer' as developer;
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component/component.dart';
import 'framework/packages/vdom/component/state_hook.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/button_props.dart';
import 'framework/components/dc_ui.dart';
import 'framework/constants/layout_properties.dart';
import 'framework/constants/style_properties.dart';
import 'framework/constants/yoga_enums.dart';

void main() {
  initializeApplication(MyApp());
}

class MyApp extends StatelessComponent {
  @override
  UIComponent build() {
    // State hooks
    final counter = useState(0);

    final bg = useState(Color(Colors.indigoAccent.toARGB32()));

    // Use an effect to update the ScrollView background color every second
    useEffect(() {
      final rnd = math.Random();
      Color color() => Color(rnd.nextInt(0xffffffff));
      // Set up a timer to update the color every second
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Update the background color
        bg.setValue(color());
        counter.setValue(counter.value + 1);
        print("use effect per 5 second ${timer.tick}");
        
        
      });

      // Clean up the timer when the component is unmounted
      return () {
        timer.cancel();
        developer.log('Canceled background color animation timer',
            name: 'ColorAnimation');
      };
    }, dependencies: []);

    return DC.View(
        layout: LayoutProps(
            flex: 1,
            alignContent: YogaAlign.center,
            justifyContent: YogaJustifyContent.center),
        style: StyleSheet(backgroundColor: bg.value),
        children: [
          DC.Button(
              onPress: () {
                    final rnd = math.Random();
      Color color() => Color(rnd.nextInt(0xffffffff));
                print(counter.value);
                    bg.setValue(color());
                // counter.setValue(counter.value + 1);
              },
              layout: LayoutProps(padding: 10),
              buttonProps: ButtonProps(
                title: "increment",
              )),
          DC.Text(
              textProps: TextProps(
                  fontSize: 24,
                  color: Colors.white,
                  textAlign: 'center',
              ),
              content: counter.value.toString(),
              layout: LayoutProps(paddingHorizontal: 50, width: '100%'),
              style: StyleSheet(backgroundColor: Colors.teal)),DC.Text(
              textProps: TextProps(
                  fontSize: 24,
                  color: Colors.white,
                  textAlign: 'center',
              ),
              content: "This is your platform: ${Platform.operatingSystem}", 
              layout: LayoutProps(paddingHorizontal: 50, width: '100%'),
              style: StyleSheet(backgroundColor: Colors.red))
        ]);
  }
}
