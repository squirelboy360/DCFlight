import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    return scrollView(
      scrollViewProps: ScrollViewProps(
        showsIndicator: true,
        clipsToBounds: true,
      ),
      style: StyleSheet(),
      layout: LayoutProps(
        flex: 1,
        padding: 8,
        paddingVertical: ScreenUtilities.instance.statusBarHeight,
        alignContent: YogaAlign.center,
        alignItems: YogaAlign.center
      ),
      children: [
        image(imageProps: ImageProps(source: 'assets/logo_bg.png'),layout: LayoutProps(
          width: 150,
          height: 150,
          padding: 8,
          marginBottom: 16,
        ),style: StyleSheet(
          borderRadius:50,
        )),
        text(
          content: 'Hello, DCF Go!',
          textProps: TextProps(fontSize: 24, color: Colors.black),
        ),
        button(
          onPress: () {
            print('Button clicked!');
          },
        layout: LayoutProps(width: 200),
          buttonProps: ButtonProps(title: 'Click Me'),
        ),
      ],
    );
  }
}



