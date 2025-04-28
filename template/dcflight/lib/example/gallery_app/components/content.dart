  // Define tab content builders
    import 'package:dcflight/framework/components/comp_props/button_props.dart';
import 'package:dcflight/framework/components/comp_props/image_props.dart';
import 'package:dcflight/framework/components/comp_props/scroll_view_props.dart';
import 'package:dcflight/framework/components/dc_ui.dart';
import 'package:dcflight/framework/components/refs/scrollview_ref.dart';
import 'package:dcflight/framework/constants/layout_properties.dart';
import 'package:dcflight/framework/constants/style_properties.dart';
import 'package:dcflight/framework/constants/yoga_enums.dart';
import 'package:dcflight/framework/packages/vdom/component/state_hook.dart';
import 'package:dcflight/framework/packages/vdom/vdom_node.dart';
import 'package:dcflight/framework/utilities/flutter.dart';

UIComponent buildTabContent(int index, ScrollViewRef? scrollRef) {
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
          imageProps: ImageProps(source: imageUrl,resizeMode: 'cover'),
          layout: LayoutProps(
            width: 100,
            height: 100,
            margin: 5,
          ),
          style:
              StyleSheet(backgroundColor: Colors.grey[800],borderRadius: 20), // Placeholder bg
        );
      });

      return DC.ScrollView(
        // Pass the ref's current value to the ScrollView
        scrollViewProps: ScrollViewProps(
            scrollEnabled: true,
            ref: scrollRef,
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
    UIComponent buildTabButton(String title, int index, StateHook<int> selectedTab,
        ScrollViewRef? scrollRef) {
      final isSelected = selectedTab.value == index;
      return DC.Button(
        onPress: () {
          selectedTab.setValue(index);
          // Scroll to top when tab changes
          scrollRef?.scrollToTop(animated: false);
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
              isSelected ? Colors.blueAccent : Colors.grey.withOpacity(0.5),
        ),
        buttonProps: ButtonProps(titleColor: isSelected? Colors.white : Colors.black,
          title: title,
        ),
      );
    }