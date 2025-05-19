import 'package:dcf_go/app/components/user_card.dart';
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
            flexDirection: YogaFlexDirection.row,
            flexWrap: YogaWrap.wrap,
            justifyContent: YogaJustifyContent.spaceBetween,
            alignItems: YogaAlign.stretch,
            paddingTop: ScreenUtilities.instance.statusBarHeight,
          ),
          style: StyleSheet(backgroundColor: Colors.indigo[400]),
          children: [
            DCFText(
              content: "Framework Reconciliation Test ",
              textProps: TextProps(fontSize: 20, fontWeight: 'bold'),

              style: StyleSheet(backgroundColor: Colors.yellow),
            ),

            DCFText(
              content: "Counter Local ${counter.value}",
              textProps: TextProps(fontSize: 12, fontWeight: 'normal'),
            ),
            DCFText(
              content: "Counter Gobal ${globalCounter.state}",
              textProps: TextProps(fontSize: 12, fontWeight: 'normal'),
            ),
          ],
        ),
        DCFScrollView(
          showsScrollIndicator: true,
          style: StyleSheet(backgroundColor: Colors.deepPurpleAccent),
          layout: LayoutProps(
            paddingHorizontal: 20,
            justifyContent: YogaJustifyContent.spaceBetween,
            flex: 1,
            width: "100%",
            flexDirection: YogaFlexDirection.column,
          ),
          children: [
            UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ), UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ), UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ), UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
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
    return DCFView(
      layout: LayoutProps(
        height: 100,
        marginVertical: 20,
        flexDirection: YogaFlexDirection.column,
      ),
      children: [
        DCFText(
          content: "State change for global ${globalCounter.state}",
          textProps: TextProps(fontSize: 20, fontWeight: 'normal'),

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

          style: StyleSheet(backgroundColor: Colors.blue),
        ),
      ],
    );
  }
}
