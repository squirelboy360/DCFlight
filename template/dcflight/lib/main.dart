import 'package:dcflight/framework/utilities/entry.dart';
import 'package:dcflight/framework/utilities/flutter.dart'; // Assuming Color and Colors are defined here
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component/component.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/button_props.dart';
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
      String contentText;
      Color bgColor;
      switch (index) {
        case 0:
          contentText = "Photos Tab Content";
          bgColor = Colors.blueGrey;
          break;
        case 1:
          contentText = "Albums Tab Content";
          bgColor = Colors.teal;
          break;
        case 2:
          contentText = "Search Tab Content";
          bgColor = Colors.orange;
          break;
        default:
          contentText = "Unknown Tab";
          bgColor = Colors.grey;
      }
      return DC.View(
        layout: LayoutProps(
          flex: 1,
          justifyContent: YogaJustifyContent.center,
          alignItems: YogaAlign.center,
        ),
        style: StyleSheet(backgroundColor: bgColor),
        children: [
          DC.Text(
            content: contentText,
            textProps: TextProps(fontSize: 20, color: Colors.white),
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
          backgroundColor: isSelected ? Colors.blueAccent : Colors.blueGrey[700],
        ),
        buttonProps: ButtonProps(
          title: title,
          // Assuming ButtonProps can take text color, otherwise wrap DC.Text
          // For simplicity, using default button text color for now.
        ),
      );
    }

    return DC.View(
      layout: LayoutProps(
        flex: 1, // Take full screen height
        flexDirection: YogaFlexDirection.column, // Stack vertically
      ),
      style: StyleSheet(backgroundColor: Colors.black), // Overall background
      children: [
        // App Bar
        DC.View(
          layout: LayoutProps(
            height: 60, // Fixed height for app bar
            paddingHorizontal: 15,
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween, // Title left, actions right (if any)
          ),
          style: StyleSheet(backgroundColor: Colors.blue[800]),
          children: [
            DC.Text(
              content: "My Gallery",
              textProps: TextProps(fontSize: 20, color: Colors.white, fontWeight: 'bold'),
            ),
            // Add potential action buttons here if needed
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
            height: 50, // Fixed height for tab bar
            flexDirection: YogaFlexDirection.row, // Arrange tabs horizontally
            justifyContent: YogaJustifyContent.spaceAround, // Distribute tabs
            alignItems: YogaAlign.stretch, // Stretch buttons vertically
          ),
          style: StyleSheet(backgroundColor: Colors.blueGrey[900]),
          children: [
            buildTabButton("Photos", 0),
            buildTabButton("Albums", 1),
            buildTabButton("Search", 2),
          ],
        ),
      ],
    );
  }
}
