import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    return DCFView(
      layout: LayoutProps(flex: 1),
      style: StyleSheet(backgroundColor: Colors.amber),
    ).render();
  }
}
