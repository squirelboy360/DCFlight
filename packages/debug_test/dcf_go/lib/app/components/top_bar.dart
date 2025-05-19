import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class TopBar extends StatefulComponent{
  final StoreHook<int> globalCounter;
  final StateHook<int> counter;
  TopBar({
    super.key,
    required this.globalCounter,
    required this.counter,
  });
  @override
  VDomNode render() {
    return  DCFView(
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
        );
  } 
}