import 'package:dcflight/dcflight.dart';

/// Text style properties
class TextProps {
  /// Font size
  final double? fontSize;
  
  /// Font weight
  final String? fontWeight;
  
  /// Font family
  final String? fontFamily;
  
  /// Whether the font family refers to an asset path
  final bool isFontAsset;
  
  /// Text color
  final Color? color;
  
  /// Text alignment
  final String? textAlign;
  
  /// Number of lines (0 for unlimited)
  final int? numberOfLines;
  
  /// Create text props
  const TextProps({
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.isFontAsset = false,
    this.color,
    this.textAlign,
    this.numberOfLines,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      if (fontSize != null) 'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (isFontAsset) 'isFontAsset': isFontAsset,
      if (color != null) 'color': color,
      if (textAlign != null) 'textAlign': textAlign,
      if (numberOfLines != null) 'numberOfLines': numberOfLines,
    };
  }
}

/// A text component implementation using Component
class DCFText extends Component {
  /// The text content to display
  final String content;
  
  /// The text properties
  final TextProps textProps;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet style;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Create a text component
  DCFText({
    required this.content,
    this.textProps = const TextProps(),
       this.layout = const LayoutProps(
      flex: 1
    ),
    this.style = const StyleSheet(),
    this.events,
    super.key,
  });
  
  @override
  VDomNode render() {
    return VDomElement(
      type: 'Text',
      props: {
        'content': content,
        ...textProps.toMap(),
        ...layout.toMap(),
        ...style.toMap(),
        ...(events ?? {}),
      },
      children: [],
    );
  }
}
