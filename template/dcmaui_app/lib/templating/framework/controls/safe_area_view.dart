import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Props for SafeAreaView component
class DCSafeAreaViewProps implements ControlProps {
  final List<String>? edges;
  final Function(Map<String, dynamic>)? onInsetsChange;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCSafeAreaViewProps({
    this.edges,
    this.onInsetsChange,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (edges != null) map['edges'] = edges;
    if (onInsetsChange != null) map['onInsetsChange'] = onInsetsChange;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// SafeAreaView component that respects device safe areas
class DCSafeAreaView extends Control {
  final DCSafeAreaViewProps props;
  final List<Control> children;

  DCSafeAreaView({
    List<String>? edges,
    Function(Map<String, dynamic>)? onInsetsChange,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCSafeAreaViewProps(
          edges: edges,
          onInsetsChange: onInsetsChange,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCSafeAreaView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a SafeAreaView that respects only top and bottom insets
  static DCSafeAreaView vertical({
    required List<Control> children,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onInsetsChange,
  }) {
    return DCSafeAreaView(
      edges: ['top', 'bottom'],
      style: style,
      onInsetsChange: onInsetsChange,
      children: children,
    );
  }

  /// Create a SafeAreaView that respects all device insets
  static DCSafeAreaView all({
    required List<Control> children,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onInsetsChange,
  }) {
    return DCSafeAreaView(
      edges: ['top', 'right', 'bottom', 'left'],
      style: style,
      onInsetsChange: onInsetsChange,
      children: children,
    );
  }
}
