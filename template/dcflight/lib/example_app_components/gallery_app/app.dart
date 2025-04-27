import 'package:dcflight/example_app_components/gallery_app/components/content.dart';
import 'package:dcflight/framework/components/comp_props/button_props.dart';
import 'package:dcflight/framework/components/comp_props/text_props.dart';
import 'package:dcflight/framework/components/dc_ui.dart';
import 'package:dcflight/framework/components/refs/scrollview_ref.dart';
import 'package:dcflight/framework/constants/layout_properties.dart';
import 'package:dcflight/framework/constants/style_properties.dart';
import 'package:dcflight/framework/constants/yoga_enums.dart';
import 'package:dcflight/framework/packages/vdom/component/component.dart';
import 'package:dcflight/framework/packages/vdom/vdom_node.dart';

import 'package:dcflight/framework/utilities/flutter.dart'; 
import 'package:dcflight/framework/utilities/screen_utilities.dart';


class GalleryApp extends StatefulComponent {
  @override
  UIComponent render() {
    // State hook for selected tab index
    final selectedTab = useState(0);
    // Ref hook for the ScrollView
    final scrollRef = useRef<ScrollViewRef?>(null);

 
  

    return DC.View(
      layout: LayoutProps(
        flex: 1, // Take full screen height
        flexDirection: YogaFlexDirection.column,
      ),
      style: StyleSheet(backgroundColor: Colors.black), // Overall background
      children: [
        // Wrap existing content to allow absolute positioning of FAB
        DC.View(
          layout: LayoutProps(flex: 1), // Takes up all space except FAB
          children: [
            // App Bar
            DC.View(
              layout: LayoutProps(
                height: '10%',
                paddingHorizontal: 15,
                paddingTop: ScreenUtilities.instance.statusBarHeight,
                flexDirection: YogaFlexDirection.row,
                alignItems: YogaAlign.center,
                justifyContent: YogaJustifyContent
                    .spaceBetween, // Title left, actions right (if any)
              ),
              style: StyleSheet(backgroundColor: Colors.deepPurpleAccent),
              children: [
                DC.Text(
                  content: "My Gallery",
                  textProps: TextProps(
                      fontSize: 20, color: Colors.white, fontWeight: 'bold'),
                ),
              ],
            ),

            // Content Area
            DC.View(
              layout: LayoutProps(
                flex: 1, // Takes remaining vertical space
              ),
              children: [
                buildTabContent(selectedTab.value,scrollRef.value), // Dynamically show content
              ],
            ),

            // Tab Bar
            DC.View(
              layout: LayoutProps(
                height: 50,
                flexDirection:
                    YogaFlexDirection.row, // Arrange tabs horizontally
                justifyContent:
                    YogaJustifyContent.spaceAround, // Distribute tabs
                alignItems: YogaAlign.stretch, // Stretch buttons vertically
              ),
              style: StyleSheet(backgroundColor: Colors.deepPurpleAccent[900]),
              children: [
                buildTabButton("Nature", 0,selectedTab,scrollRef.value), // Updated title
                buildTabButton("Cities", 1,selectedTab,scrollRef.value), // Updated title
                buildTabButton("Animals", 2,selectedTab,scrollRef.value), // Updated title
              ],
            ),
          ],
        ),

        // Floating Action Button Container
        DC.View(
          layout: LayoutProps(
            height: 200,
            marginBottom: '5%',
            position: YogaPositionType.absolute, // Absolute positioning
            bottom: 70, // Position from bottom (above tab bar)
            right: 20, // Position from right
            flexDirection: YogaFlexDirection.column, // Stack buttons vertically
            alignItems: YogaAlign.flexEnd, // Align buttons to the right
          ),
          children: [
            // Scroll to Top Button
            DC.Button(
              onPress: () {
                print("Scrolling to top...");
                // Corrected: Use scrollToTop for the Top button
                scrollRef.value?.scrollToTop();
              },
              layout: LayoutProps(
                width: 56,
                height: 56,
                marginBottom: 50, // Space between buttons
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              style: StyleSheet(
                backgroundColor: Colors.pinkAccent,
                borderRadius: 28, // Make it circular
              ),
              buttonProps: ButtonProps(
                title: "Top", // Simple text for now
                // You might need specific TextProps for color/size if ButtonProps supports it
              ),
            ),
            // Scroll to Bottom Button
            DC.Button(
              onPress: () {
                print("--- End Button Pressed ---");
                print("Scrolling to bottom...");
                scrollRef.value?.scrollToBottom(); // Use the ref
              },
              layout: LayoutProps(
                width: 56,
                height: 56,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              style: StyleSheet(
                backgroundColor: Colors.pinkAccent,
                borderRadius: 28, // Make it circular
              ),
              buttonProps: ButtonProps(
                title: "End", // Simple text for now
              ),
            ),
          ],
        ),
      ],
    );
  }
}
 