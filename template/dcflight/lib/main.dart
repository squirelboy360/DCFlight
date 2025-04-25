import 'package:dcflight/framework/utilities/entry.dart';
import 'package:dcflight/framework/utilities/flutter.dart'; // Assuming Color and Colors are defined here
import 'package:dcflight/framework/utilities/screen_utilities.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component/component.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/button_props.dart';
import 'framework/components/comp_props/image_props.dart'; // Added ImageProps
import 'framework/components/comp_props/scroll_view_props.dart'; // Added ScrollViewProps
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
        layout: LayoutProps(flex: 1),
        scrollViewProps: ScrollViewProps(scrollEnabled: true),
        children: [
          DC.View(
            layout: LayoutProps(
              flexDirection: YogaFlexDirection.row,
              flexWrap: YogaWrap.wrap,
              justifyContent:
                  YogaJustifyContent.center, // Center images horizontally
              padding: 10,
            ),
            children: images, // Add the list of images
          ),
        ],
      );
    }

    // Define tab bar button builder
    UIComponent buildTabButton(String title, int index) {
      final isSelected = selectedTab.value == index;
      return DC.Button(
        onPress: () {
          selectedTab.setValue(index);
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
        // App Bar
        DC.View(
          layout: LayoutProps(
            height: 60, // Fixed height for app bar
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
            flexDirection: YogaFlexDirection.row, // Arrange tabs horizontally
            justifyContent: YogaJustifyContent.spaceAround, // Distribute tabs
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
    );
  }
}
