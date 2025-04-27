import 'package:dcflight/framework/utilities/entry.dart';
import 'package:dcflight/framework/utilities/flutter.dart'; // Assuming Color and Colors are defined here
import 'package:dcflight/framework/utilities/screen_utilities.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component/component.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/button_props.dart';
import 'framework/components/comp_props/image_props.dart'; // Added ImageProps
import 'framework/components/comp_props/scroll_view_props.dart'; // Added ScrollViewProps
import 'framework/components/refs/scrollview_ref.dart'; // Import ScrollViewRef
import 'framework/components/dc_ui.dart';
import 'framework/constants/layout_properties.dart';
import 'framework/constants/style_properties.dart';
import 'framework/constants/yoga_enums.dart';

void main() {
  initializeApplication(GalleryApp());
}

class GalleryApp extends StatefulComponent {
  @override
  UIComponent render() {
    // State hook for selected tab index
    final selectedTab = useState(0);
    // Ref hook for the ScrollView
    final scrollRef = useRef<ScrollViewRef?>(null);

    // Define tab content builders
    UIComponent buildTabContent(int index) {
      String category;
      switch (index) {
        case 0:
          category = "nature";
          break;
        case 1:
          category = "city";
          break;
        case 2:
          category = "animals";
          break;
        default:
          category = "abstract";
      }

      // Generate a list of image components
      final List<UIComponent> images = List.generate(100, (i) {
        // Use different seeds for variety
        final seed = "${category}_$i";
        final imageUrl = "https://picsum.photos/seed/$seed/100/100";
        return DC.Image(
          imageProps: ImageProps(source: imageUrl),
          layout: LayoutProps(
            width: 100,
            height: 100,
            margin: 5,
          ),
          style:
              StyleSheet(backgroundColor: Colors.grey[800]), // Placeholder bg
        );
      });

      return DC.ScrollView(
        // Pass the ref's current value to the ScrollView
        scrollViewProps: ScrollViewProps(
            scrollEnabled: true,
            ref: scrollRef.value,
            onScroll: (v) {
              print("Scroll event: $v");
            }),
        layout: LayoutProps(
          flex: 1,
          flexDirection: YogaFlexDirection.row,
          flexWrap: YogaWrap.wrap,
          justifyContent:
              YogaJustifyContent.center, // Center images horizontally
          padding: 10,
        ),
        children: images,
      );
    }

    // Define tab bar button builder
    UIComponent buildTabButton(String title, int index) {
      final isSelected = selectedTab.value == index;
      return DC.Button(
        onPress: () {
          selectedTab.setValue(index);
          // Scroll to top when tab changes
          scrollRef.value?.scrollToTop(animated: false);
          print("Selected tab: $index");
        },
        layout: LayoutProps(
          flex: 1, // Distribute space evenly
          padding: 10,
          justifyContent: YogaJustifyContent.center,
          alignItems: YogaAlign.center,
        ),
        style: StyleSheet(
          backgroundColor:
              isSelected ? Colors.deepPurpleAccent : Colors.blueGrey[700],
        ),
        buttonProps: ButtonProps(
          title: title,
        ),
      );
    }

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
                buildTabContent(selectedTab.value), // Dynamically show content
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
                buildTabButton("Nature", 0), // Updated title
                buildTabButton("Cities", 1), // Updated title
                buildTabButton("Animals", 2), // Updated title
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
