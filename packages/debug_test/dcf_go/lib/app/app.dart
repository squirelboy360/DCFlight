import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    // Create reference to control navigation
    final homeStackRef = useRef<StackNavigatorRef?>(null);
    
    return view(
      style: StyleSheet(
        backgroundColor: Colors.grey[100],
      ),
      layout: LayoutProps(
        flex: 1,
      ),
      children: [
        // Use regular views for navigation instead
        view(
          layout: LayoutProps(flex: 1),
          children: [
            createHomeTab(homeStackRef),
          ],
        ),
      ],
    );
  }
  
  // Create Home tab with Stack Navigator
  VDomNode createHomeTab(RefObject<StackNavigatorRef?> homeStackRef) {
    final ref = StackNavigatorRef('homeStack');
    homeStackRef.value = ref; // Using .current instead of .setValue()
    
    return view(
      style: StyleSheet(backgroundColor: Colors.white),
      layout: LayoutProps(flex: 1),
      children: [
        createHomeMainScreen(homeStackRef),
      ],
    );
  }
  
  // Create Home Main Screen
  VDomNode createHomeMainScreen(RefObject<StackNavigatorRef?> homeStackRef) {
    return scrollView(
      scrollViewProps: ScrollViewProps(
        showsIndicator: true,
        clipsToBounds: true,
      ),
      style: StyleSheet(),
      layout: LayoutProps(
        flex: 1,
        padding: 16,
        alignItems: YogaAlign.center,
      ),
      children: [
        image(
          imageProps: ImageProps(source: 'assets/logo_bg.png'),
          layout: LayoutProps(
            width: 150,
            height: 150,
            padding: 8,
            marginBottom: 16,
          ),
          style: StyleSheet(
            borderRadius: 50,
          ),
        ),
        text(
          content: 'Hello, DCF Go!',
          layout: LayoutProps(marginBottom: 16),
          textProps: TextProps(fontSize: 24, color: Colors.black),
        ),
        button(
          onPress: () {
            // Navigate to details screen using stack navigator
            homeStackRef.value?.push('homeDetails');
          },
          layout: LayoutProps(width: 200, marginBottom: 16),
          buttonProps: ButtonProps(title: 'Go to Details'),
        ),
      ],
    );
  }
  
  // Create Details Screen
  VDomNode createDetailsScreen(RefObject<StackNavigatorRef?> stackRef) {
    return view(
      style: StyleSheet(
        backgroundColor: Colors.white,
      ),
      layout: LayoutProps(
        flex: 1,
        padding: 16,
        alignItems: YogaAlign.center,
        justifyContent: YogaJustifyContent.center,
      ),
      children: [
        text(
          content: 'Details Screen',
          layout: LayoutProps(marginBottom: 16),
          textProps: TextProps(fontSize: 24, color: Colors.black),
        ),
        text(
          content: 'This is a nested screen in the stack navigation',
          layout: LayoutProps(marginBottom: 24, width: 250),
          textProps: TextProps(fontSize: 16, color: Colors.grey[700], textAlign: "center"),
        ),
        button(
          onPress: () {
            // Pop back to previous screen
            stackRef.value?.pop();
          },
          layout: LayoutProps(width: 200),
          buttonProps: ButtonProps(title: 'Go Back'),
        ),
      ],
    );
  }
}
