import '../text_props.dart';
import '../../../framework/packages/vdom/vdom_element.dart';

/// A text segment with its own props
class TextSegment {
  final String text;
  final TextProps? props;

  TextSegment(this.text, {this.props});
}

/// Represents text content with support for rich text formatting
class TextContent {
  final List<TextSegment> _segments = [];
  final TextProps? _globalProps;

  /// Create text content with initial text and optional props
  TextContent(String initialText, {TextProps? props}) : _globalProps = props {
    _segments.add(TextSegment(initialText, props: null));
  }

  /// Add a value to interpolate with optional props specific to this segment
  TextContent interpolate(dynamic value, {TextProps? props}) {
    _segments.add(TextSegment(value.toString(), props: props));
    return this;
  }

  /// Add more text after an interpolated value with optional props
  TextContent addText(String text, {TextProps? props}) {
    _segments.add(TextSegment(text, props: props));
    return this;
  }

  /// Generate  text nodes from segments
  List<VDomElement> generateTextNodes(TextProps? parentProps) {
    final nodes = <VDomElement>[];

    for (var segment in _segments) {
      // Merge props: segment props override global props which override parent props
      final mergedProps =
          _mergeTextProps(parentProps, _globalProps, segment.props);

      // Convert to map with content
      final propsMap = mergedProps?.toMap() ?? {};
      propsMap['content'] = segment.text;

      // Create text element
      nodes.add(VDomElement(
        type: 'Text',
        props: propsMap,
      ));
    }

    return nodes;
  }

  /// Merge multiple TextProps objects with priority to the rightmost non-null one
  TextProps? _mergeTextProps(
      TextProps? parent, TextProps? global, TextProps? segment) {
    // Start with parent props or empty
    var result = parent != null
        ? TextProps(
            // Copy all properties from parent
            fontFamily: parent.fontFamily,
            fontSize: parent.fontSize,
            fontWeight: parent.fontWeight,
            fontStyle: parent.fontStyle,
            letterSpacing: parent.letterSpacing,
            lineHeight: parent.lineHeight,
            textAlign: parent.textAlign,
            textDecorationLine: parent.textDecorationLine,
            textTransform: parent.textTransform,
            color: parent.color,
            numberOfLines: parent.numberOfLines,
            selectable: parent.selectable,
            adjustsFontSizeToFit: parent.adjustsFontSizeToFit,
            minimumFontSize: parent.minimumFontSize,
          )
        : null;

    // Apply global props if present
    if (global != null) {
      result = _overrideProps(result, global);
    }

    // Apply segment props if present (highest priority)
    if (segment != null) {
      result = _overrideProps(result, segment);
    }

    return result;
  }

  /// Override base props with properties from override that are non-null
  TextProps _overrideProps(TextProps? base, TextProps override) {
    if (base == null) return override;

    return TextProps(
      // For each property, use override if non-null, otherwise use base
      fontFamily: override.fontFamily ?? base.fontFamily,
      fontSize: override.fontSize ?? base.fontSize,
      fontWeight: override.fontWeight ?? base.fontWeight,
      fontStyle: override.fontStyle ?? base.fontStyle,
      letterSpacing: override.letterSpacing ?? base.letterSpacing,
      lineHeight: override.lineHeight ?? base.lineHeight,
      textAlign: override.textAlign ?? base.textAlign,
      textDecorationLine:
          override.textDecorationLine ?? base.textDecorationLine,
      textTransform: override.textTransform ?? base.textTransform,
      color: override.color ?? base.color,
      numberOfLines: override.numberOfLines ?? base.numberOfLines,
      selectable: override.selectable ?? base.selectable,
      adjustsFontSizeToFit:
          override.adjustsFontSizeToFit ?? base.adjustsFontSizeToFit,
      minimumFontSize: override.minimumFontSize ?? base.minimumFontSize,
    );
  }

  /// String representation (for debugging)
  @override
  String toString() => _segments.map((segment) => segment.text).join('');
}
