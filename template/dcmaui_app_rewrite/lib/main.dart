import 'dart:async';
import 'package:flutter/material.dart' hide View, Text, Image, ScrollView;
import 'dart:developer' as developer;

import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/comp_props/button_props.dart';
import 'framework/components/comp_props/image_props.dart';
import 'framework/components/comp_props/scroll_view_props.dart';
import 'framework/components/ui.dart';
import 'framework/constants/layout_properties.dart';
import 'framework/constants/style_properties.dart';
import 'framework/constants/yoga_enums.dart';
import 'framework/utilities/screen_utilities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Starting DCMAUI Demo Application', name: 'App');
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
  final mainApp = DCMauiDemoApp();

  // Create a component node
  final appNode = vdom.createComponent(mainApp);

  // Render the component to native UI
  await vdom.renderToNative(appNode, parentId: "root", index: 0);
  developer.log('DCMAUI Demo Application successfully initialized and running',
      name: 'App');
}

/// Demo app showing DCMAUI capabilities
class DCMauiDemoApp extends StatefulComponent {
  @override
  VDomNode render() {
    // State hooks
    final currentTabIndex = useState(0, 'currentTabIndex');
    final isMenuOpen = useState(false, 'isMenuOpen');
    final animatedValue = useState(0.0, 'animatedValue');

    // // Animation timer effect
    // useEffect(() {
    //   // // Create a timer that updates the animated value
    //   final timer = Timer.periodic(Duration(milliseconds: 50), (_) {
    //     final newValue = (animatedValue.value + 0.02) % 1.0;
    //     animatedValue.setValue(newValue);
    //     developer.log('Animated value updated: $newValue', name: 'Animation');
    //   });

    //   // Return cleanup function
    //   return () => timer.cancel();
    // }, dependencies: []);

    // Menu animation value based on isMenuOpen state
    final menuSlideValue = isMenuOpen.value ? 0.0 : -250.0;

    // Create tabs content
    final tabContent = [
      renderHomeTab(animatedValue.value),
      renderGalleryTab(),
      renderProfileTab(),
    ];

    // Main app structure with side menu
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        height: '100%',
      ),
      style: StyleSheet(
        backgroundColor: Colors.amber,
      ),
      children: [
        // Main content area
        UI.View(
          layout: LayoutProps(
            position: YogaPositionType.absolute,
            left: 0,
            top: 0,
            width: '100%',
            height: '100%',
          ),
          style: StyleSheet(),
          children: [
            // App bar
            renderAppBar(
                isMenuOpen: isMenuOpen.value,
                onMenuPress: () => isMenuOpen.setValue(!isMenuOpen.value)),

            // Tab content
            UI.View(
              layout: LayoutProps(flex: 1, width: '100%'),
              style: StyleSheet(),
              children: [tabContent[currentTabIndex.value]],
            ),

            // Bottom tab bar
            renderTabBar(
                currentIndex: currentTabIndex.value,
                onTabPress: (index) => currentTabIndex.setValue(index)),
          ],
        ),

        // Side menu overlay (shown when menu is open)
        isMenuOpen.value
            ? UI.View(
                layout: LayoutProps(
                  position: YogaPositionType.absolute,
                  left: 0,
                  top: 0,
                  width: '100%',
                  height: '100%',
                ),
                style: StyleSheet(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
                // REMOVED: events property since View doesn't support them natively
              )
            : UI.View(layout: LayoutProps()),

        // Side menu
        UI.View(
          layout: LayoutProps(
            position: YogaPositionType.absolute,
            left: menuSlideValue,
            top: 0,
            width: 250,
            height: '100%',
          ),
          style: StyleSheet(
            backgroundColor: Colors.red,
            shadowColor: Colors.black,
            shadowOffsetX: 2,
            shadowOffsetY: 0,
            shadowOpacity: 0.3,
            shadowRadius: 5,
          ),
          children: [renderSideMenu(onClose: () => isMenuOpen.setValue(false))],
        ),
      ],
    );
  }

  // App bar with title and menu button
  VDomNode renderAppBar(
      {required bool isMenuOpen, required Function onMenuPress}) {
    return UI.View(
      layout: LayoutProps(
        paddingVertical: ScreenUtilities.instance.statusBarHeight,
        width: '100%',
        flexDirection: YogaFlexDirection.row,
        alignItems: YogaAlign.center,
        paddingLeft: 16,
        paddingRight: 16,
      ),
      style: StyleSheet(
        backgroundColor: Colors.blue,
        shadowColor: Colors.black,
        shadowOffsetX: 0,
        shadowOffsetY: 2,
        shadowOpacity: 0.2,
        shadowRadius: 3,
      ),
      children: [
        // Menu button
        UI.Button(
          layout: LayoutProps(
            width: 40,
            height: 40,
            justifyContent: YogaJustifyContent.center,
            alignItems: YogaAlign.center,
          ),
          style: StyleSheet(backgroundColor: Colors.blueGrey),
          buttonProps: ButtonProps(
            title: isMenuOpen ? "✕" : "☰",
            titleColor: Colors.amber,
            fontSize: 24,
          ),
          onPress: () => onMenuPress(),
        ),

        // Title
        UI.Text(
          content: "DCMAUI Demo App",
          layout: LayoutProps(
            flex: 1,
            marginLeft: 16,
          ),
          style: StyleSheet(),
          textProps: TextProps(
            color: Colors.white,
            fontSize: 20,
            fontWeight: "bold",
          ),
        ),
      ],
    );
  }

  // Bottom tab bar
  VDomNode renderTabBar(
      {required int currentIndex, required Function onTabPress}) {
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        height: 120,
        paddingBottom: ScreenUtilities.instance.statusBarHeight,
        flexDirection: YogaFlexDirection.row,
        justifyContent: YogaJustifyContent.spaceAround,
        alignItems: YogaAlign.center,
      ),
      style: StyleSheet(
        backgroundColor: Colors.white,
        borderWidth: 1,
        borderColor: Colors.grey.shade200,
      ),
      children: [
        renderTabButton(
          icon: "🏠",
          label: "Home",
          isSelected: currentIndex == 0,
          onPress: () => {onTabPress(0), print("pressed button 0")},
        ),
        renderTabButton(
          icon: "🖼️",
          label: "Gallery",
          isSelected: currentIndex == 1,
          onPress: () => onTabPress(1),
        ),
        renderTabButton(
          icon: "👤",
          label: "Profile",
          isSelected: currentIndex == 2,
          onPress: () => onTabPress(2),
        ),
      ],
    );
  }

  // Individual tab button
  VDomNode renderTabButton({
    required String icon,
    required String label,
    required bool isSelected,
    required Function onPress,
  }) {
    // For tab buttons, we use a View with a Button inside since the View doesn't support events
    return UI.View(
      layout: LayoutProps(
        width: 80,
        height: 60,
        justifyContent: YogaJustifyContent.center,
        alignItems: YogaAlign.center,
      ),
      style: StyleSheet(),
      children: [
        UI.Button(
          layout: LayoutProps(
            width: '100%',
            height: '60%',
            justifyContent: YogaJustifyContent.center,
            alignItems: YogaAlign.center,
          ),
          style: StyleSheet(
            backgroundColor: Colors.grey.shade200,
          ),
          buttonProps: ButtonProps(
            title: icon,
            disabled: false,
            activeOpacity: 0.1,
          ),
          onPress: () => {onPress(), print("pressed button $label")},
        ),
        UI.Text(
          content: label,
          layout: LayoutProps(height: '40%'),
          style: StyleSheet(backgroundColor: Colors.transparent),
          textProps: TextProps(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Home tab content with animation
  VDomNode renderHomeTab(double animationValue) {
    // Calculate animated properties
    final cardScale = 0.9 + 0.1 * sin(animationValue * 6.28);
    final cardRotation = {
      'rotate': 5 * sin(animationValue * 6.28),
    };

    final cardColor = Color.lerp(
          Color(0xFF42A5F5), // Lighter blue
          Color(0xFF1976D2), // Darker blue
          sin(animationValue * 6.28) * 0.5 + 0.5,
        ) ??
        Colors.blue;

    return UI.ScrollView(
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
        // Welcome section
        UI.View(
          layout: LayoutProps(
            width: '100%',
            padding: 20,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
              content: "Welcome to DCMAUI",
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
            UI.Text(
              content: "A cross-platform UI framework inspired by React Native",
              layout: LayoutProps(
                width: '100%',
                marginBottom: 20,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // Animated card
        UI.View(
          layout: LayoutProps(
            width: 300 * cardScale, // Apply scale animation directly
            height: 200 * cardScale, // Apply scale animation directly
            marginBottom: 20,
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustifyContent.center,
            alignItems: YogaAlign.center,
          ),
          style: StyleSheet(
            backgroundColor: cardColor,
            borderRadius: 12,
            transform: cardRotation,
            shadowColor: Colors.black,
            shadowOffsetX: 0,
            shadowOffsetY: 4,
            shadowOpacity: 0.3,
            shadowRadius: 8,
          ),
          children: [
            UI.Text(
              content: "Animated Card",
              layout: LayoutProps(),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.white,
                fontSize: 24,
                fontWeight: "bold",
              ),
            ),
            UI.Text(
              content: "Using state-based animations",
              layout: LayoutProps(
                marginTop: 8,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // Features section
        UI.View(
          layout: LayoutProps(
            width: '100%',
            padding: 20,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
              content: "Features",
              layout: LayoutProps(
                width: '100%',
                marginBottom: 16,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 24,
                fontWeight: "bold",
              ),
            ),

            // Feature cards
            renderFeatureCard(
              icon: "🚀",
              title: "Fast Native UI",
              description: "Direct rendering to native components",
            ),
            renderFeatureCard(
              icon: "🧩",
              title: "Component-Based",
              description: "Build UIs with reusable components",
            ),
            renderFeatureCard(
              icon: "📱",
              title: "Cross-Platform",
              description: "Works seamlessly on iOS and Android",
            ),
            renderFeatureCard(
              icon: "⚡",
              title: "Performant",
              description: "Optimized layout engine and rendering",
            ),
          ],
        ),
      ],
    );
  }

  // Feature card component
  VDomNode renderFeatureCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        flexDirection: YogaFlexDirection.row,
        padding: 16,
        marginBottom: 16,
        alignItems: YogaAlign.center,
      ),
      style: StyleSheet(
        backgroundColor: Colors.white,
        borderRadius: 8,
        shadowColor: Colors.black,
        shadowOffsetX: 0,
        shadowOffsetY: 2,
        shadowOpacity: 0.1,
        shadowRadius: 4,
      ),
      children: [
        // Icon
        UI.Text(
          content: icon,
          layout: LayoutProps(
            width: 48,
            height: 48,
            justifyContent: YogaJustifyContent.center,
            alignItems: YogaAlign.center,
          ),
          style: StyleSheet(),
          textProps: TextProps(
            fontSize: 32,
          ),
        ),

        // Text content
        UI.View(
          layout: LayoutProps(
            flex: 1,
            marginLeft: 16,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
              content: title,
              layout: LayoutProps(
                width: '100%',
                marginBottom: 4,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 18,
                fontWeight: "bold",
              ),
            ),
            UI.Text(
              content: description,
              layout: LayoutProps(
                width: '100%',
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Gallery tab content
  VDomNode renderGalleryTab() {
    final images = [
      "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1568748141681-ccf431079c0c?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1559583985-c80d8ad9b29f?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1565214975484-3cfa9e56f914?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1493612276216-ee3925520721?ixlib=rb-4.0.3&w=800&q=80",
      "https://images.unsplash.com/photo-1559511260-66a654ae982a?ixlib=rb-4.0.3&w=800&q=80",
    ];

    return UI.ScrollView(
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
        UI.View(
          layout: LayoutProps(
            width: '100%',
            padding: 20,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
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
            UI.Text(
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
        UI.View(
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

  // Gallery image item
  VDomNode renderGalleryImage(String url) {
    // Calculate image dimensions - 2 columns with padding
    final screenWidth = ScreenUtilities.instance.screenWidth;
    final imageSize = (screenWidth / 2) - 24; // Account for padding

    return UI.View(
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
        UI.Image(
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
  }

  // Profile tab content
  VDomNode renderProfileTab() {
    // Demo user data
    final user = {
      "name": "John Doe",
      "username": "@johndoe",
      "bio":
          "Software developer passionate about UI frameworks and mobile development.",
      "location": "San Francisco, CA",
      "followers": "5.8K",
      "following": "432",
      "posts": "128",
    };

    return UI.ScrollView(
      layout: LayoutProps(
        flex: 1,
        width: '100%',
      ),
      style: StyleSheet(
        backgroundColor: Colors.grey.shade100,
      ),
      scrollViewProps: ScrollViewProps(),
      children: [
        // Profile header
        UI.View(
          layout: LayoutProps(
            width: '100%',
            alignItems: YogaAlign.center,
            padding: 20,
          ),
          style: StyleSheet(
            backgroundColor: Colors.white,
          ),
          children: [
            // Profile image
            UI.View(
              layout: LayoutProps(
                width: 100,
                height: 100,
                marginBottom: 16,
              ),
              style: StyleSheet(
                backgroundColor: Colors.blue,
                borderRadius: 50,
              ),
              children: [
                UI.Text(
                  content: "JD",
                  layout: LayoutProps(
                    width: '100%',
                    height: '100%',
                    justifyContent: YogaJustifyContent.center,
                    alignItems: YogaAlign.center,
                  ),
                  style: StyleSheet(),
                  textProps: TextProps(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: "bold",
                  ),
                ),
              ],
            ),

            // Name and username
            UI.Text(
              content: user["name"]!,
              layout: LayoutProps(
                marginBottom: 4,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 24,
                fontWeight: "bold",
              ),
            ),
            UI.Text(
              content: user["username"]!,
              layout: LayoutProps(
                marginBottom: 12,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            // Bio
            UI.Text(
              content: user["bio"]!,
              layout: LayoutProps(
                marginBottom: 16,
                maxWidth: 300,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 16,
                textAlign: "center",
              ),
            ),

            // Location
            UI.View(
              layout: LayoutProps(
                flexDirection: YogaFlexDirection.row,
                alignItems: YogaAlign.center,
                marginBottom: 20,
              ),
              style: StyleSheet(),
              children: [
                UI.Text(
                  content: "📍",
                  layout: LayoutProps(
                    marginRight: 4,
                  ),
                  style: StyleSheet(),
                  textProps: TextProps(
                    fontSize: 16,
                  ),
                ),
                UI.Text(
                  content: user["location"]!,
                  layout: LayoutProps(),
                  style: StyleSheet(),
                  textProps: TextProps(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Stats row
            UI.View(
              layout: LayoutProps(
                width: '100%',
                flexDirection: YogaFlexDirection.row,
                justifyContent: YogaJustifyContent.spaceAround,
                marginBottom: 16,
              ),
              style: StyleSheet(),
              children: [
                renderStatItem("Posts", user["posts"]!),
                renderStatItem("Followers", user["followers"]!),
                renderStatItem("Following", user["following"]!),
              ],
            ),

            // Edit profile button
            UI.Button(
              layout: LayoutProps(
                width: 200,
                height: 40,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              style: StyleSheet(
                backgroundColor: Colors.blue,
                borderRadius: 20,
              ),
              buttonProps: ButtonProps(
                title: "Edit Profile",
                titleColor: Colors.white,
                fontSize: 16,
              ),
              onPress: () {
                developer.log('Edit profile button pressed', name: 'UI');
              },
            ),
          ],
        ),

        // Activity section
        UI.View(
          layout: LayoutProps(
            width: '100%',
            padding: 20,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
              content: "Recent Activity",
              layout: LayoutProps(
                marginBottom: 16,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 20,
                fontWeight: "bold",
              ),
            ),

            // Activity items
            renderActivityItem(
              icon: "📝",
              title: "Updated project documentation",
              time: "2 hours ago",
            ),
            renderActivityItem(
              icon: "⭐",
              title: "Starred a repository",
              time: "Yesterday",
            ),
            renderActivityItem(
              icon: "🔄",
              title: "Forked a repository",
              time: "3 days ago",
            ),
            renderActivityItem(
              icon: "💬",
              title: "Commented on an issue",
              time: "5 days ago",
            ),
          ],
        ),
      ],
    );
  }

  // Profile stat item
  VDomNode renderStatItem(String label, String value) {
    return UI.View(
      layout: LayoutProps(
        alignItems: YogaAlign.center,
      ),
      style: StyleSheet(),
      children: [
        UI.Text(
          content: value,
          layout: LayoutProps(
            marginBottom: 4,
          ),
          style: StyleSheet(),
          textProps: TextProps(
            color: Colors.black,
            fontSize: 20,
            fontWeight: "bold",
          ),
        ),
        UI.Text(
          content: label,
          layout: LayoutProps(),
          style: StyleSheet(),
          textProps: TextProps(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Activity item
  VDomNode renderActivityItem({
    required String icon,
    required String title,
    required String time,
  }) {
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        flexDirection: YogaFlexDirection.row,
        padding: 16,
        marginBottom: 12,
      ),
      style: StyleSheet(
        backgroundColor: Colors.white,
        borderRadius: 8,
        shadowColor: Colors.black,
        shadowOffsetX: 0,
        shadowOffsetY: 1,
        shadowOpacity: 0.1,
        shadowRadius: 2,
      ),
      children: [
        // Icon
        UI.Text(
          content: icon,
          layout: LayoutProps(
            width: 32,
            height: 32,
            marginRight: 12,
          ),
          style: StyleSheet(),
          textProps: TextProps(
            fontSize: 24,
          ),
        ),

        // Content
        UI.View(
          layout: LayoutProps(
            flex: 1,
          ),
          style: StyleSheet(),
          children: [
            UI.Text(
              content: title,
              layout: LayoutProps(
                marginBottom: 4,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            UI.Text(
              content: time,
              layout: LayoutProps(),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Side menu content
  VDomNode renderSideMenu({required Function onClose}) {
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        height: '100%',
        paddingTop: 40,
      ),
      style: StyleSheet(),
      children: [
        // Header and close button
        UI.View(
          layout: LayoutProps(
            width: '100%',
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            paddingHorizontal: 16,
            paddingBottom: 20,
            marginBottom: 20,
          ),
          style: StyleSheet(
            borderWidth: 1,
            borderColor: Colors.grey.shade200,
          ),
          children: [
            UI.Text(
              content: "Menu",
              layout: LayoutProps(
                flex: 1,
              ),
              style: StyleSheet(),
              textProps: TextProps(
                color: Colors.black,
                fontSize: 24,
                fontWeight: "bold",
              ),
            ),
            UI.Button(
              layout: LayoutProps(
                width: 40,
                height: 40,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              style: StyleSheet(),
              buttonProps: ButtonProps(
                title: "✕",
                titleColor: Colors.black,
                fontSize: 20,
              ),
              onPress: () => onClose(),
            ),
          ],
        ),

        // Menu items - each needs a button for interactivity
        renderMenuItemWithButton(icon: "🏠", title: "Home"),
        renderMenuItemWithButton(icon: "🖼️", title: "Gallery"),
        renderMenuItemWithButton(icon: "👤", title: "Profile"),
        renderMenuItemWithButton(icon: "⚙️", title: "Settings"),
        renderMenuItemWithButton(icon: "❓", title: "Help & Support"),
        renderMenuItemWithButton(icon: "ℹ️", title: "About"),
      ],
    );
  }

  // Menu item with a button for proper event handling
  VDomNode renderMenuItemWithButton(
      {required String icon, required String title}) {
    return UI.View(
      layout: LayoutProps(
        width: '100%',
        height: 50,
        flexDirection: YogaFlexDirection.row,
        alignItems: YogaAlign.center,
      ),
      style: StyleSheet(),
      children: [
        // The button fills the view but is transparent
        UI.Button(
          layout: LayoutProps(
            position: YogaPositionType.absolute,
            width: '100%',
            height: '100%',
          ),
          style: StyleSheet(
            backgroundColor: Colors.transparent,
          ),
          buttonProps: ButtonProps(
            title: "",
          ),
          onPress: () {
            developer.log('Menu item pressed: $title', name: 'UI');
          },
        ),
        // Icon and title displayed over the button
        UI.Text(
          content: icon,
          layout: LayoutProps(
            width: 24,
            height: 24,
            marginLeft: 16,
            marginRight: 16,
          ),
          style: StyleSheet(),
          textProps: TextProps(
            fontSize: 20,
          ),
        ),
        UI.Text(
          content: title,
          layout: LayoutProps(),
          style: StyleSheet(),
          textProps: TextProps(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Helper to get simulated sin wave for animation
  double sin(double value) {
    // Simple sine wave approximation
    final wave = 4 * value * (1 - value);
    return 2 * wave - 1; // Scale from -1 to 1
  }
}
