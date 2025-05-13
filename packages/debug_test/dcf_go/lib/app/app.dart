import 'package:dcf_router/dcf_router.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    return view(
      style: StyleSheet(backgroundColor: Colors.amber),
      layout: LayoutProps(flex: 1),
    );
  }
}
