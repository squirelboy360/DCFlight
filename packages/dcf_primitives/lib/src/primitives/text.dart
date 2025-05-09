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

/// A text component with a custom font from an asset
VDomElement customFontText({
  required String content,
  required String fontAsset,
  double fontSize = 16.0,
  String fontWeight = 'regular',
  Color? color,
  String? textAlign,
  int? numberOfLines,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Map<String, dynamic>? events,
}) {
  return text(
    content: content,
    textProps: TextProps(
      fontFamily: fontAsset,
      isFontAsset: true,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      numberOfLines: numberOfLines,
    ),
    layout: layout,
    style: style,
    events: events,
  );
}