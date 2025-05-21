import 'package:dcflight/dcflight.dart';

/// A basic view component implementation using Component
class DCFView extends Component {
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet style;
  
  /// Child nodes
  final List<VDomNode> children;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Create a view component
  DCFView({
    required this.layout,
    this.style = const StyleSheet(),
    this.children = const [],
    this.events,
    super.key,
  });
  
  @override
  VDomNode render() {
    return VDomElement(
      type: 'View',
      props: {
     
        ...layout.toMap(),
        ...style.toMap(),
        ...(events ?? {}),
      },
      children: children,
    );
  }
}
