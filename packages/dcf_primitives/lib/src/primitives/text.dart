import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/utilities/flutter.dart' show Color;

/// Text style properties
class TextProps {
  /// Font size
  final double? fontSize;
  
  /// Font weight
  final String? fontWeight;
  
  /// Font family
  final String? fontFamily;
  
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
      if (color != null) 'color': color,
      if (textAlign != null) 'textAlign': textAlign,
      if (numberOfLines != null) 'numberOfLines': numberOfLines,
    };
  }
}

/// A text component
VDomElement text({
  required String content,
  TextProps textProps = const TextProps(),
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Map<String, dynamic>? events,
}) {
  return VDomElement(
    type: 'Text',
    props: {
      'content': content,
      ...textProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: [],
    events: events,
  );
}