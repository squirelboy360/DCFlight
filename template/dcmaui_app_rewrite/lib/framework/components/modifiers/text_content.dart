
import '../../packages/vdom/vdom_element.dart';
import '../text_props.dart';

/// Represents rich text content for text components
class TextContent {
  final String _text;
  final TextProps? _props;
  final List<TextContent> _children;

  TextContent(this._text, {TextProps? props})
      : _props = props,
        _children = [];

  /// Create interpolated text content
  TextContent.interpolated(this._text, this._props, this._children);

  /// Add another text segment to this text
  TextContent interpolate(dynamic segment, {TextProps? props}) {
    // Convert value to string
    final text = segment.toString();
    final interpolated = TextContent(text, props: props);

    // Return a new instance with combined text and children
    final List<TextContent> newChildren = List.from(_children);
    newChildren.add(interpolated);
    return TextContent.interpolated(_text, _props, newChildren);
  }

  /// Generate VDomElements to represent this text content
  List<VDomElement> generateTextNodes(VDomElement? parent) {
    final List<VDomElement> nodes = [];

    // Create base node from this content
    final Map<String, dynamic> props = {
      'content': _text,
    };

    // Add properties from TextProps if provided
    if (_props != null) {
      props.addAll(_props.toMap());
    }

    // Create element for this text
    final node = VDomElement(
      type: 'Text',
      props: props,
    );

    // Set parent reference
    if (parent != null) {
      node.parent = parent;
    }

    nodes.add(node);

    // Generate nodes for children
    for (final child in _children) {
      nodes.addAll(child.generateTextNodes(parent));
    }

    return nodes;
  }

  @override
  String toString() {
    if (_children.isEmpty) {
      return _text;
    }

    // Combine text from all children
    return _text + _children.map((child) => child.toString()).join('');
  }
}
