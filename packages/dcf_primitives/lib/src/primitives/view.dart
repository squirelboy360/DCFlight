import 'package:dcflight/dcflight.dart';

/// A basic container view component
VDomElement view({
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  List<VDomNode> children = const [],
  Map<String, dynamic>? events,
}) {
  return VDomElement(
    type: 'View',
    props: {
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: children,

  );
}