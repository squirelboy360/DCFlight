import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

final globalCounterState = StoreHelpers.createGlobalStore<int>('globalCounterState', 0);

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    final globalCounter = useStore(globalCounterState);
     final counter = useState(0);
    return DCFView(
      layout: LayoutProps(
        flex: 1,
       
      ),
      style: StyleSheet(backgroundColor: Colors.grey[100]),
      children: [
        DCFView(
          layout: LayoutProps(height: 320, width: '100%',
           paddingVertical: ScreenUtilities.instance.statusBarHeight, padding: 20),
          style: StyleSheet(backgroundColor: Colors.blueAccent),
          children: [
            DCFIcon(
              iconProps: IconProps(name: DCFIcons.alarmClock),
              layout: LayoutProps(margin: 10,height: 50,width: 50),
              style: StyleSheet(backgroundColor: Colors.red),
            ),

          DCFTouchableOpacity(
            layout: LayoutProps(
              height: 100
            ),
            onPress: (){
            counter.setValue(counter.value + 1);
            print("Counter: ${counter.value}");
          },children: [
              DCFIcon(
              iconProps: IconProps(name: DCFIcons.plus),
              layout: LayoutProps(margin: 10,height: 50,width: 50),
              style: StyleSheet(backgroundColor: Colors.red),
            ),
          ]),

           DCFTouchableOpacity(
            layout: LayoutProps(
              height: 100
            ),
            onPress: (){
            globalCounter.setState(counter.value + 1);
            print("Global increment Counter: ${counter.value}");
          },children: [
            DCFText(
              content: "Increment Global Counter",
              textProps: TextProps(fontSize: 15),
              layout: LayoutProps(margin: 10,height: 50,width: 100),
              style: StyleSheet(backgroundColor: Colors.green),
            ),
              DCFIcon(
              iconProps: IconProps(name: DCFIcons.plus),
              layout: LayoutProps(margin: 10,height: 50,width: 50),
              style: StyleSheet(backgroundColor: Colors.red),
            ),
          ])
          ],
        ),
        DCFText(content: "State change ${counter.value}",
        textProps: TextProps(fontSize: 30, fontWeight: 'bold'),
          layout: LayoutProps(height: 200, width: '100%',
          ),
          style: StyleSheet(backgroundColor: Colors.red),
        ),

         DCFText(content: "State change for global ${globalCounter.state}",
        textProps: TextProps(fontSize: 30, fontWeight: 'bold'),
          layout: LayoutProps(height: 200, width: '100%',
          ),
          style: StyleSheet(backgroundColor: Colors.red),
        ),



        // 

        
    
      ]
    );
  }
}
