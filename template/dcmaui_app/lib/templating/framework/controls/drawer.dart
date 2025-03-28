import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:flutter/widgets.dart';

/// Props for Drawer component
class DCDrawerProps implements ControlProps {
  final bool? open;
  final String? drawerPosition;
  final double? drawerWidth;
  final Color? drawerBackgroundColor;
  final Color? contentBackgroundColor;
  final Color? statusBarBackgroundColor;
  final double? openDrawerThreshold;
  final double? closeDrawerThreshold;
  final String? drawerLockMode;
  final String? keyboardDismissMode;
  final bool? enableGestureInteraction;
  final bool? hideStatusBar;
  final Function(Map<String, dynamic>)? onDrawerSlide;
  final Function()? onDrawerOpen;
  final Function()? onDrawerClose;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCDrawerProps({
    this.open,
    this.drawerPosition,
    this.drawerWidth,
    this.drawerBackgroundColor,
    this.contentBackgroundColor,
    this.statusBarBackgroundColor,
    this.openDrawerThreshold,
    this.closeDrawerThreshold,
    this.drawerLockMode,
    this.keyboardDismissMode,
    this.enableGestureInteraction,
    this.hideStatusBar,
    this.onDrawerSlide,
    this.onDrawerOpen,
    this.onDrawerClose,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (open != null) map['open'] = open;
    if (drawerPosition != null) map['drawerPosition'] = drawerPosition;
    if (drawerWidth != null) map['drawerWidth'] = drawerWidth;

    if (drawerBackgroundColor != null) {
      final colorValue =
          drawerBackgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['drawerBackgroundColor'] = '#$colorValue';
    }

    if (contentBackgroundColor != null) {
      final colorValue =
          contentBackgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['contentBackgroundColor'] = '#$colorValue';
    }

    if (statusBarBackgroundColor != null) {
      final colorValue =
          statusBarBackgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['statusBarBackgroundColor'] = '#$colorValue';
    }

    if (openDrawerThreshold != null) {
      map['openDrawerThreshold'] = openDrawerThreshold;
    }
    if (closeDrawerThreshold != null) {
      map['closeDrawerThreshold'] = closeDrawerThreshold;
    }
    if (drawerLockMode != null) map['drawerLockMode'] = drawerLockMode;
    if (keyboardDismissMode != null) {
      map['keyboardDismissMode'] = keyboardDismissMode;
    }
    if (enableGestureInteraction != null) {
      map['enableGestureInteraction'] = enableGestureInteraction;
    }
    if (hideStatusBar != null) map['hideStatusBar'] = hideStatusBar;
    if (onDrawerSlide != null) map['onDrawerSlide'] = onDrawerSlide;
    if (onDrawerOpen != null) map['onDrawerOpen'] = onDrawerOpen;
    if (onDrawerClose != null) map['onDrawerClose'] = onDrawerClose;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// Drawer component that provides a sliding drawer navigation panel
class DCDrawer extends Control {
  final DCDrawerProps props;
  final List<Control> children;
  final List<Control> drawerContent;

  DCDrawer({
    bool? open,
    String? drawerPosition,
    double? drawerWidth,
    Color? drawerBackgroundColor,
    Color? contentBackgroundColor,
    Color? statusBarBackgroundColor,
    double? openDrawerThreshold,
    double? closeDrawerThreshold,
    String? drawerLockMode,
    String? keyboardDismissMode,
    bool? enableGestureInteraction,
    bool? hideStatusBar,
    Function(Map<String, dynamic>)? onDrawerSlide,
    Function()? onDrawerOpen,
    Function()? onDrawerClose,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
    required this.drawerContent,
  }) : props = DCDrawerProps(
          open: open,
          drawerPosition: drawerPosition,
          drawerWidth: drawerWidth,
          drawerBackgroundColor: drawerBackgroundColor,
          contentBackgroundColor: contentBackgroundColor,
          statusBarBackgroundColor: statusBarBackgroundColor,
          openDrawerThreshold: openDrawerThreshold,
          closeDrawerThreshold: closeDrawerThreshold,
          drawerLockMode: drawerLockMode,
          keyboardDismissMode: keyboardDismissMode,
          enableGestureInteraction: enableGestureInteraction,
          hideStatusBar: hideStatusBar,
          onDrawerSlide: onDrawerSlide,
          onDrawerOpen: onDrawerOpen,
          onDrawerClose: onDrawerClose,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    // Create container node for the drawer
    final containerNode = ElementFactory.createElement(
      'DCDrawer',
      props.toMap(),
      buildChildren(children),
    );

    // Tag all drawer content with special IDs to help them be placed in the drawer
    List<VNode> drawerNodes = [];
    for (var i = 0; i < drawerContent.length; i++) {
      final drawerItem = drawerContent[i];
      // Build the node
      final node = drawerItem.build();

      // Instead of modifying the key directly, create a new node with the drawer suffix
      final String drawerKey = '${node.key}_drawer';
      final drawerNode = VNode(
        node.type,
        props: node.props,
        key: drawerKey,
        children: node.children,
        componentId: node.componentId,
      );

      drawerNodes.add(drawerNode);
    }

    // Add drawer content as additional children
    containerNode.children.addAll(drawerNodes);

    return containerNode;
  }

  /// Open the drawer programmatically
  static void openDrawer(String drawerId) {
    MainViewCoordinatorInterface.updateView(drawerId, {'open': true});
  }

  /// Close the drawer programmatically
  static void closeDrawer(String drawerId) {
    MainViewCoordinatorInterface.updateView(drawerId, {'open': false});
  }

  /// Create a left-side drawer
  static DCDrawer left({
    required List<Control> drawerContent,
    required List<Control> children,
    bool? open,
    Color? drawerBackgroundColor,
    double? drawerWidth,
    Function()? onDrawerOpen,
    Function()? onDrawerClose,
  }) {
    return DCDrawer(
      open: open,
      drawerPosition: 'left',
      drawerWidth: drawerWidth,
      drawerBackgroundColor: drawerBackgroundColor,
      drawerContent: drawerContent,
      onDrawerOpen: onDrawerOpen,
      onDrawerClose: onDrawerClose,
      children: children,
    );
  }

  /// Create a right-side drawer
  static DCDrawer right({
    required List<Control> drawerContent,
    required List<Control> children,
    bool? open,
    Color? drawerBackgroundColor,
    double? drawerWidth,
    Function()? onDrawerOpen,
    Function()? onDrawerClose,
  }) {
    return DCDrawer(
      open: open,
      drawerPosition: 'right',
      drawerWidth: drawerWidth,
      drawerBackgroundColor: drawerBackgroundColor,
      drawerContent: drawerContent,
      onDrawerOpen: onDrawerOpen,
      onDrawerClose: onDrawerClose,
      children: children,
    );
  }
}
