import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

/// Home screen
VDomNode homeScreen(RouteContext context) {
  final navigator = context.navigator;
  
  return view(
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
          marginBottom: 24,
        ),
        style: StyleSheet(
          borderRadius: 75,
        ),
      ),
      text(
        content: 'Welcome to DCF Go!',
        textProps: TextProps(
          fontSize: 24,
          fontWeight: 'bold',
          color: Colors.black,
        ),
        layout: LayoutProps(
          marginBottom: 16,
        ),
      ),
      text(
        content: 'A cross-platform UI framework',
        textProps: TextProps(
          fontSize: 16,
          color: Colors.grey,
        ),
        layout: LayoutProps(
          marginBottom: 32,
        ),
      ),
      button(
        buttonProps: ButtonProps(
          title: 'View Details',
          backgroundColor: Colors.blue,
          color: Colors.white,
        ),
        layout: LayoutProps(
          width: 200,
          marginBottom: 16,
        ),
        onPress: () {
          context.navigator.pushNamed('details', params: {
            'title': 'Home Details',
            'description': 'This is a detailed view from the Home tab.',
          });
        },
      ),
    ],
  );
}

/// Details screen
VDomNode detailsScreen(RouteContext context) {
  final title = context.params['title'] as String? ?? 'Details';
  final description = context.params['description'] as String? ?? 'This is a detailed view.';
  
  return view(
    layout: LayoutProps(
      flex: 1,
      padding: 16,
      alignItems: YogaAlign.center,
    ),
    children: [
      text(
        content: title,
        textProps: TextProps(
          fontSize: 24,
          fontWeight: 'bold',
          color: Colors.black,
        ),
        layout: LayoutProps(
          marginBottom: 16,
        ),
      ),
      text(
        content: description,
        textProps: TextProps(
          fontSize: 16,
          color: Colors.grey,
          textAlign: 'center',
        ),
        layout: LayoutProps(
          marginBottom: 32,
        ),
      ),
      button(
        buttonProps: ButtonProps(
          title: 'Go Back',
          backgroundColor: Colors.blue,
          color: Colors.white,
        ),
        layout: LayoutProps(
          width: 200,
        ),
        onPress: () {
          context.navigator.pop();
        },
      ),
    ],
  );
}
