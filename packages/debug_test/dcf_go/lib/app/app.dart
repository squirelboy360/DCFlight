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
            height: 150,
            flexDirection: YogaFlexDirection.row,
            // paddingTop: ScreenUtilities.instance.statusBarHeight,
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
            DCFTouchableOpacity(activeOpacity:0.5 ,
            onPress: (){},
              layout: LayoutProps(
                height: 200,
                width: "100%",
                alignContent: YogaAlign.stretch,
                flexWrap: YogaWrap.nowrap,
                justifyContent: YogaJustifyContent.spaceAround,
              ),children: [  DCFView(
              layout: LayoutProps(
                height: 200,
                width: "100%",
                alignContent: YogaAlign.stretch,
                flexWrap: YogaWrap.nowrap,
                justifyContent: YogaJustifyContent.spaceAround,
              ),
              style: StyleSheet(backgroundColor: Colors.grey[100]),
              children: [
                DCFImage(
                  imageProps: ImageProps(
                    resizeMode: "cover",
                    source:
                        "https://avatars.githubusercontent.com/u/130235676?v=4",
                  ),
                  layout: LayoutProps(height: 60, width: 60, borderWidth: 1),
                  style: StyleSheet(
                    borderRadius: 30,
                    borderColor: Colors.black,
                  ),
                ),
                DCFView(
                  layout: LayoutProps(
                  width: "60%",
                    alignContent: YogaAlign.center,
                    justifyContent: YogaJustifyContent.spaceAround,
                  ),
                  children: [
                    DCFText(
                      content: "DCFight",
                      textProps: TextProps(fontSize: 20, fontWeight: 'bold'),
                    ),
                    DCFText(
                      content: "Deveolper lead",
                      textProps: TextProps(fontSize: 12, fontWeight: 'normal'),
                    ),
                    DCFIcon(
                      iconProps: IconProps(name: DCFIcons.github),
                      layout: LayoutProps(height: 20, width: 20),
                    ),
                  ],
                ),
               
                  DCFIcon(
                  iconProps: IconProps(name: DCFIcons.chevronRight),
                  layout: LayoutProps(height: 20, width: 20),
                ),
              
              ]),
          ]),
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
      layout: LayoutProps(height: 200, flexDirection: YogaFlexDirection.column),
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

          style: StyleSheet(backgroundColor: Colors.blue),
        ),
      ],
    );
  }
}
