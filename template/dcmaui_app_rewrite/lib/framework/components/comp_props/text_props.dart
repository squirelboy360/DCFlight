/// Properties specific to Text components
class TextProps {
  /// Text color
  final String? color;

  /// Font size
  final double? fontSize;

  /// Font weight (bold, 100-900)
  final String? fontWeight;

  /// Font family name
  final String? fontFamily;

  /// Text alignment (left, center, right, justified)
  final String? textAlign;

  /// Line height
  final double? lineHeight;

  /// Letter spacing
  final double? letterSpacing;

  /// Number of lines (0 for unlimited)
  final int? numberOfLines;

  /// Create text component-specific props
  const TextProps({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.textAlign,
    this.lineHeight,
    this.letterSpacing,
    this.numberOfLines,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) map['color'] = color;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (textAlign != null) map['textAlign'] = textAlign;
    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;

    return map;
  }

  /// Create new TextProps by merging with another
  TextProps merge(TextProps other) {
    return TextProps(
      color: other.color ?? color,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      fontFamily: other.fontFamily ?? fontFamily,
      textAlign: other.textAlign ?? textAlign,
      lineHeight: other.lineHeight ?? lineHeight,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      numberOfLines: other.numberOfLines ?? numberOfLines,
    );
  }

  /// Create a copy with certain properties modified
  TextProps copyWith({
    String? color,
    double? fontSize,
    String? fontWeight,
    String? fontFamily,
    String? textAlign,
    double? lineHeight,
    double? letterSpacing,
    int? numberOfLines,
  }) {
    return TextProps(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      textAlign: textAlign ?? this.textAlign,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      numberOfLines: numberOfLines ?? this.numberOfLines,
    );
  }
}
