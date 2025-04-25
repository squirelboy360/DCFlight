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
  


    // Calculate image dimensions - 2 columns with padding
    final screenWidth = ScreenUtilities.instance.screenWidth;
    final imageSize = (screenWidth / 2) - 24; // Account for padding

    return DC.View(
      layout: LayoutProps(
        width: imageSize,
        height: imageSize,
        margin: 8,
      ),
      style: StyleSheet(
        backgroundColor: Colors.white,
        borderRadius: 8,
        shadowColor: Colors.black,
        shadowOffsetX: 0,
        shadowOffsetY: 2,
        shadowOpacity: 0.1,
        shadowRadius: 3,
      ),
      children: [
        DC.Image(
          layout: LayoutProps(
            width: '100%',
            height: '100%',
          ),
          style: StyleSheet(
            borderRadius: 8,
          ),
          imageProps: ImageProps(
            source: url,
            resizeMode: "cover",
          ),
        ),
      ],
    );
  }}


  // Gallery tab content
  UIComponent renderGalleryTab() {
    final images = [
      "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1568748141681-ccf431079c0c?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1559583985-c80d8ad9b29f?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1565214975484-3cfa9e56f914?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1493612276216-ee3925520721?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1559511260-66a654ae982a?ixlib=rb-4.0.3&w=800&q=80",
    ];

    return DC.ScrollView(
      layout: LayoutProps(
        flex: 1,
        width: '100%',
      ),
      style: StyleSheet(
        backgroundColor: Colors.grey.shade100,
      ),
      scrollViewProps: ScrollViewProps(
        showsVerticalScrollIndicator: true,
      ),
      children: [
        // Gallery header
        DC.View(
          layout: LayoutProps(
            width: '100%',
            padding: 20,
          ),
          style: StyleSheet(),
          children: [
            DC.Text(
              content: "Image Gallery",
              layout: LayoutProps(
                width: '100%',
                marginBottom: 8,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 28,
                fontWeight: "bold",
              ),
            ),
            DC.Text(
              content: "Beautiful images from Unsplash",
              layout: LayoutProps(
                width: '100%',
                marginBottom: 16,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // Image grid
        DC.View(
          layout: LayoutProps(
            width: '100%',
            flexDirection: YogaFlexDirection.row,
            flexWrap: YogaWrap.wrap,
            padding: 8,
          ),
          style: StyleSheet(),
          children: images.map((url) => renderGalleryImage(url)).toList(),
        ),
      ],
    );
  }