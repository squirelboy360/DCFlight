import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';


void main() {
  DCFlight.start(element: view(
    layout: LayoutProps(
    flex: 1
    ),
    style: StyleSheet(
      backgroundColor: Colors.amber,
    ),
    children: [
      text(content: "DCFlight")
    ],
  ));
}

