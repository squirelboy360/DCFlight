import 'package:dcflight/dcflight.dart';

/// DCFIcon - Similar to React Native's Ionicons
/// Provides a simple way to use built-in icons by name
// / module or packages that want to add more icons can do so by cloning the dcfIcon and changing the package prop to the name of your package and dont't forget to clone the native side of dcfPrimitives
VDomElement dcfIcon({
  required String name,
  double size = 24.0,
  Color? color,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onLoad,
  Function? onError,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onLoad != null) {
    eventMap['onLoad'] = onLoad;
  }
  
  if (onError != null) {
    eventMap['onError'] = onError;
  }
  
  return VDomElement(
    type: 'DCFIcon',
    props: {
      'name': name,
      'package': 'dcf_primitives',
      'size': size,
      if (color != null) 'color': color,
      ...layout.toMap(),
      ...style.toMap(),
       // non-direct svgs, where the icons are in packages like scf_icon for example are not relative as the native side will lookup the assets from the package being used in the app bundle 
      'isRelativePath': false,
    },
    children: [],
    events: eventMap.isEmpty ? null : eventMap,
  );
}

/// List of all available icon names in DCFIcons
/// Similar to how Ionicons works in React Native
class DCFIcons {
  // Navigation icons
  static const String home = "home";
  static const String back = "back";
  static const String forward = "forward";
  static const String menu = "menu";
  static const String close = "close";
  static const String arrowUp = "arrow-up";
  static const String arrowDown = "arrow-down";
  static const String arrowLeft = "arrow-left";
  static const String arrowRight = "arrow-right";
  
  // Action icons
  static const String add = "add";
  static const String remove = "remove";
  static const String edit = "edit";
  static const String delete = "delete";
  static const String save = "save";
  static const String search = "search";
  static const String refresh = "refresh";
  static const String settings = "settings";
  static const String share = "share";
  
  // Content icons
  static const String image = "image";
  static const String camera = "camera";
  static const String calendar = "calendar";
  static const String document = "document";
  static const String folder = "folder";
  static const String file = "file";
  
  // Communication icons
  static const String mail = "mail";
  static const String message = "message";
  static const String call = "call";
  static const String chat = "chat";
  static const String notification = "notification";
  
  // Status icons
  static const String checkmark = "checkmark";
  static const String error = "error";
  static const String warning = "warning";
  static const String info = "info";
  static const String help = "help";
  
  // Social icons
  static const String heart = "heart";
  static const String star = "star";
  static const String person = "person";
  static const String people = "people";
  static const String thumbsUp = "thumbs-up";
  static const String thumbsDown = "thumbs-down";
}