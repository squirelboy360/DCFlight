import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

void main(){
  initializeApplication(GalleryApp());
}


class GalleryApp extends StatefulComponent {
  @override
  UIComponent render() {
    return View();
  }}