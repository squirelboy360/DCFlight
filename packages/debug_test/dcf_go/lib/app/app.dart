import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

final globalCounterState = StoreHelpers.createGlobalStore<int>(
  'globalCounterState',
  0,
);

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    final globalCounter = useStore(globalCounterState);
    final counter = useState(0);
    return Fragment(
      children: [
        DCFView(
          layout: LayoutProps(
            height: 200,
            paddingTop: ScreenUtilities.instance.statusBarHeight,
          ),
          style: StyleSheet(backgroundColor: Colors.indigo[400]),
          children: [
            DCFText(
              content: "Framework Reconciliation Test",
              textProps: TextProps(fontSize: 20, fontWeight: 'bod'),
              layout: LayoutProps(height: 200, width: 200),
              style: StyleSheet(backgroundColor: Colors.yellow),
            ),
          ],
        ),
        DCFView(
          layout: LayoutProps(
            flex: 8,
            alignContent: YogaAlign.center,
            alignItems: YogaAlign.center,

            justifyContent: YogaJustifyContent.center,
          ),
          style: StyleSheet(backgroundColor: Colors.grey[100]),
          children: [
            DCFText(
              content: "State change ${counter.value}",
              textProps: TextProps(fontSize: 20, fontWeight: 'normal'),
              layout: LayoutProps(height: 200, width: 200),
              style: StyleSheet(backgroundColor: Colors.yellow),
            ),
            DCFButton(
              buttonProps: ButtonProps(
                title: "Increment Internal State",
                color: Colors.white,
                backgroundColor: Colors.blue,
                disabled: false,
              ),
              onPress: () {
                counter.setValue(counter.value + 1);
              },
              layout: LayoutProps(margin: 20),
              style: StyleSheet(backgroundColor: Colors.blue),
            ),

            DCFButton(
              buttonProps: ButtonProps(
                title: "Increment Global",
                color: Colors.white,
                backgroundColor: Colors.blue,
                disabled: false,
              ),
              onPress: () {
                globalCounter.setState(globalCounter.state + 1);
              },
              layout: LayoutProps(margin: 20),
              style: StyleSheet(backgroundColor: Colors.blue),
            ),
          ],
        ),
        Fragment(children: [GobalStateCounterComp()]),
      ],
    );
  }
}

class GobalStateCounterComp extends StatefulComponent {
  @override
  VDomNode render() {
    final globalCounter = useStore(globalCounterState);
    return Fragment(
      children: [
        DCFText(
          content: "State change for global ${globalCounter.state}",
          textProps: TextProps(fontSize: 20, fontWeight: 'normal'),
          layout: LayoutProps(margin: 20),
          style: StyleSheet(backgroundColor: Colors.indigo),
        ),
        DCFButton(
          buttonProps: ButtonProps(
            title: "Increment Global",
            color: Colors.white,
            backgroundColor: Colors.blue,
            disabled: false,
          ),
          onPress: () {
            globalCounter.setState(globalCounter.state + 1);
          },
          layout: LayoutProps(margin: 20),
          style: StyleSheet(backgroundColor: Colors.blue),
        ),
      ],
    );
  }
}
