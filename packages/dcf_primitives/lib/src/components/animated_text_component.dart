import 'package:dcf_primitives/src/components/text_component.dart';
import 'package:dcflight/dcflight.dart';

/// An animated text component implementation using Component
class DCFAnimatedText extends Component {
  /// The text content to display
  final String content;
  
  /// The text properties
  final TextProps textProps;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet style;
  
  /// The animation configuration
  final Map<String, dynamic> animation;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Animation end event handler
  final Function? onAnimationEnd;
  
  /// Create an animated text component
  DCFAnimatedText({
    required this.content,
    required this.animation,
    this.textProps = const TextProps(),
       this.layout = const LayoutProps(
      flex: 1
    ),
    this.style = const StyleSheet(),
    this.onAnimationEnd,
    this.events,
    super.key,
  });
  
  @override
  VDomNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onAnimationEnd != null) {
      eventMap['onAnimationEnd'] = onAnimationEnd;
    }
    
    return VDomElement(
      type: 'AnimatedText',
      props: {
        'content': content,
        'animation': animation,
        ...textProps.toMap(),
        ...layout.toMap(),
        ...style.toMap(),
        ...eventMap,
      },
      children: [],
    );
  }
}
