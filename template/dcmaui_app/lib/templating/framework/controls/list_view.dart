

import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

import 'package:flutter/material.dart';

/// Style properties for DCListView
class DCListViewStyle implements StyleProps {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? scrollIndicatorThickness;
  final double? height;
  final double? width;
  final double? contentSpacing;
  final double? scrollPadding;

  const DCListViewStyle({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.scrollIndicatorThickness,
    this.height,
    this.width,
    this.contentSpacing,
    this.scrollPadding,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (padding != null) {
      if (padding!.left == padding!.right &&
          padding!.top == padding!.bottom &&
          padding!.left == padding!.top) {
        map['padding'] = padding!.top;
      } else {
        map['paddingLeft'] = padding!.left;
        map['paddingRight'] = padding!.right;
        map['paddingTop'] = padding!.top;
        map['paddingBottom'] = padding!.bottom;
      }
    }

    if (margin != null) {
      if (margin!.left == margin!.right &&
          margin!.top == margin!.bottom &&
          margin!.left == margin!.top) {
        map['margin'] = margin!.top;
      } else {
        map['marginLeft'] = margin!.left;
        map['marginRight'] = margin!.right;
        map['marginTop'] = margin!.top;
        map['marginBottom'] = margin!.bottom;
      }
    }

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (scrollIndicatorThickness != null) {
      map['scrollIndicatorThickness'] = scrollIndicatorThickness;
    }

    if (height != null) map['height'] = height;
    if (width != null) map['width'] = width;
    if (contentSpacing != null) map['contentSpacing'] = contentSpacing;
    if (scrollPadding != null) map['scrollPadding'] = scrollPadding;

    return map;
  }
}

/// Props for ListView component
class DCListViewProps implements ControlProps {
  final bool? horizontal;
  final bool? showsScrollIndicator;
  final bool? bounces;
  final bool? pagingEnabled;
  final double? initialScrollIndex;
  final Function(Map<String, dynamic>)? onScroll;
  final Function()? onScrollBeginDrag;
  final Function()? onScrollEndDrag;
  final Function()? onMomentumScrollBegin;
  final Function()? onMomentumScrollEnd;
  final double? onEndReachedThreshold;
  final Function(Map<String, dynamic>)? onEndReached;
  final DCListViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCListViewProps({
    this.horizontal,
    this.showsScrollIndicator,
    this.bounces,
    this.pagingEnabled,
    this.initialScrollIndex,
    this.onScroll,
    this.onScrollBeginDrag,
    this.onScrollEndDrag,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    this.onEndReachedThreshold,
    this.onEndReached,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (horizontal != null) map['horizontal'] = horizontal;
    if (showsScrollIndicator != null) {
      map['showsScrollIndicator'] = showsScrollIndicator;
    }
    if (bounces != null) map['bounces'] = bounces;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (initialScrollIndex != null) {
      map['initialScrollIndex'] = initialScrollIndex;
    }
    if (onScroll != null) map['onScroll'] = onScroll;
    if (onScrollBeginDrag != null) map['onScrollBeginDrag'] = onScrollBeginDrag;
    if (onScrollEndDrag != null) map['onScrollEndDrag'] = onScrollEndDrag;
    if (onMomentumScrollBegin != null) {
      map['onMomentumScrollBegin'] = onMomentumScrollBegin;
    }
    if (onMomentumScrollEnd != null) {
      map['onMomentumScrollEnd'] = onMomentumScrollEnd;
    }
    if (onEndReachedThreshold != null) {
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    }
    if (onEndReached != null) map['onEndReached'] = onEndReached;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// ListView component for displaying scrollable lists
class DCListView extends Control {
  final DCListViewProps props;
  final List<Control> children;

  DCListView({
    bool? horizontal,
    bool? showsScrollIndicator,
    bool? bounces,
    bool? pagingEnabled,
    double? initialScrollIndex,
    Function(Map<String, dynamic>)? onScroll,
    Function()? onScrollBeginDrag,
    Function()? onScrollEndDrag,
    Function()? onMomentumScrollBegin,
    Function()? onMomentumScrollEnd,
    double? onEndReachedThreshold,
    Function(Map<String, dynamic>)? onEndReached,
    DCListViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCListViewProps(
          horizontal: horizontal,
          showsScrollIndicator: showsScrollIndicator,
          bounces: bounces,
          pagingEnabled: pagingEnabled,
          initialScrollIndex: initialScrollIndex,
          onScroll: onScroll,
          onScrollBeginDrag: onScrollBeginDrag,
          onScrollEndDrag: onScrollEndDrag,
          onMomentumScrollBegin: onMomentumScrollBegin,
          onMomentumScrollEnd: onMomentumScrollEnd,
          onEndReachedThreshold: onEndReachedThreshold,
          onEndReached: onEndReached,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCListView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Convenience constructor for a vertical ListView
  static DCListView vertical({
    List<Control> children = const [],
    bool? showsScrollIndicator,
    DCListViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
    Function(Map<String, dynamic>)? onEndReached,
    double? onEndReachedThreshold,
  }) {
    return DCListView(
      horizontal: false,
      showsScrollIndicator: showsScrollIndicator,
      style: style,
      onScroll: onScroll,
      onEndReached: onEndReached,
      onEndReachedThreshold: onEndReachedThreshold,
      children: children,
    );
  }

  /// Convenience constructor for a horizontal ListView
  static DCListView horizontal({
    List<Control> children = const [],
    bool? showsScrollIndicator,
    DCListViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
    Function(Map<String, dynamic>)? onEndReached,
    double? onEndReachedThreshold,
  }) {
    return DCListView(
      horizontal: true,
      showsScrollIndicator: showsScrollIndicator,
      style: style,
      onScroll: onScroll,
      onEndReached: onEndReached,
      onEndReachedThreshold: onEndReachedThreshold,
      children: children,
    );
  }
}
