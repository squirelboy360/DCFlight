import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';

import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for ScrollView component
class DCScrollViewStyle implements StyleProps {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? scrollIndicatorThickness;
  final double? height;
  final double? width;
  final double? contentSpacing;

  const DCScrollViewStyle({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.scrollIndicatorThickness,
    this.height,
    this.width,
    this.contentSpacing,
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

    return map;
  }
}

/// Props for ScrollView component
class DCScrollViewProps implements ControlProps {
  final bool? horizontal;
  final bool? showsVerticalScrollIndicator;
  final bool? showsHorizontalScrollIndicator;
  final bool? pagingEnabled;
  final bool? bounces;
  final Map<String, double>? contentOffset;
  final bool? scrollToOffsetAnimated;
  final EdgeInsets? contentInset;
  final EdgeInsets? scrollIndicatorInsets;
  final String? keyboardDismissMode;
  final bool? refreshing;
  final Function()? onRefresh;
  final Function(Map<String, dynamic>)? onScroll;
  final Function()? onMomentumScrollBegin;
  final Function()? onMomentumScrollEnd;
  final Function()? onScrollBeginDrag;
  final Function()? onScrollEndDrag;
  final double? onEndReachedThreshold;
  final Function()? onEndReached;
  final DCScrollViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCScrollViewProps({
    this.horizontal,
    this.showsVerticalScrollIndicator,
    this.showsHorizontalScrollIndicator,
    this.pagingEnabled,
    this.bounces,
    this.contentOffset,
    this.scrollToOffsetAnimated,
    this.contentInset,
    this.scrollIndicatorInsets,
    this.keyboardDismissMode,
    this.refreshing,
    this.onRefresh,
    this.onScroll,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    this.onScrollBeginDrag,
    this.onScrollEndDrag,
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
    if (showsVerticalScrollIndicator != null) {
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    }
    if (showsHorizontalScrollIndicator != null) {
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    }
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (bounces != null) map['bounces'] = bounces;

    if (contentOffset != null) map['contentOffset'] = contentOffset;
    if (scrollToOffsetAnimated != null) {
      map['scrollToOffsetAnimated'] = scrollToOffsetAnimated;
    }

    // Convert EdgeInsets to maps
    if (contentInset != null) {
      map['contentInset'] = {
        'top': contentInset!.top,
        'left': contentInset!.left,
        'bottom': contentInset!.bottom,
        'right': contentInset!.right,
      };
    }

    if (scrollIndicatorInsets != null) {
      map['scrollIndicatorInsets'] = {
        'top': scrollIndicatorInsets!.top,
        'left': scrollIndicatorInsets!.left,
        'bottom': scrollIndicatorInsets!.bottom,
        'right': scrollIndicatorInsets!.right,
      };
    }

    if (keyboardDismissMode != null) {
      map['keyboardDismissMode'] = keyboardDismissMode;
    }
    if (refreshing != null) map['refreshing'] = refreshing;
    if (onRefresh != null) map['onRefresh'] = onRefresh;
    if (onScroll != null) map['onScroll'] = onScroll;
    if (onMomentumScrollBegin != null) {
      map['onMomentumScrollBegin'] = onMomentumScrollBegin;
    }
    if (onMomentumScrollEnd != null) {
      map['onMomentumScrollEnd'] = onMomentumScrollEnd;
    }
    if (onScrollBeginDrag != null) map['onScrollBeginDrag'] = onScrollBeginDrag;
    if (onScrollEndDrag != null) map['onScrollEndDrag'] = onScrollEndDrag;
    if (onEndReachedThreshold != null) {
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    }
    if (onEndReached != null) map['onEndReached'] = onEndReached;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// ScrollView component
class DCScrollView extends Control {
  final DCScrollViewProps props;
  final List<Control> children;

  DCScrollView({
    bool? horizontal,
    bool? showsVerticalScrollIndicator,
    bool? showsHorizontalScrollIndicator,
    bool? pagingEnabled,
    bool? bounces,
    Map<String, double>? contentOffset,
    bool? scrollToOffsetAnimated,
    EdgeInsets? contentInset,
    EdgeInsets? scrollIndicatorInsets,
    String? keyboardDismissMode,
    bool? refreshing,
    Function()? onRefresh,
    Function(Map<String, dynamic>)? onScroll,
    Function()? onMomentumScrollBegin,
    Function()? onMomentumScrollEnd,
    Function()? onScrollBeginDrag,
    Function()? onScrollEndDrag,
    double? onEndReachedThreshold,
    Function()? onEndReached,
    DCScrollViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCScrollViewProps(
          horizontal: horizontal,
          showsVerticalScrollIndicator: showsVerticalScrollIndicator,
          showsHorizontalScrollIndicator: showsHorizontalScrollIndicator,
          pagingEnabled: pagingEnabled,
          bounces: bounces,
          contentOffset: contentOffset,
          scrollToOffsetAnimated: scrollToOffsetAnimated,
          contentInset: contentInset,
          scrollIndicatorInsets: scrollIndicatorInsets,
          keyboardDismissMode: keyboardDismissMode,
          refreshing: refreshing,
          onRefresh: onRefresh,
          onScroll: onScroll,
          onMomentumScrollBegin: onMomentumScrollBegin,
          onMomentumScrollEnd: onMomentumScrollEnd,
          onScrollBeginDrag: onScrollBeginDrag,
          onScrollEndDrag: onScrollEndDrag,
          onEndReachedThreshold: onEndReachedThreshold,
          onEndReached: onEndReached,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCScrollView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Convenience constructor for a vertical scrollview
  static DCScrollView vertical({
    List<Control> children = const [],
    bool? showsScrollIndicator,
    DCScrollViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
    Function()? onEndReached,
  }) {
    return DCScrollView(
      horizontal: false,
      showsVerticalScrollIndicator: showsScrollIndicator,
      style: style,
      onScroll: onScroll,
      onEndReached: onEndReached,
      children: children,
    );
  }

  /// Convenience constructor for a horizontal scrollview
  static DCScrollView horizontal({
    List<Control> children = const [],
    bool? showsScrollIndicator,
    DCScrollViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
    Function()? onEndReached,
  }) {
    return DCScrollView(
      horizontal: true,
      showsHorizontalScrollIndicator: showsScrollIndicator,
      style: style,
      onScroll: onScroll,
      onEndReached: onEndReached,
      children: children,
    );
  }

  /// Scroll to a specific offset
  static void scrollTo(String scrollViewId, double x, double y,
      {bool animated = true}) {
    // Use MainViewCoordinatorInterface.updateView to send properties to the native side
    MainViewCoordinatorInterface.updateView(
      scrollViewId,
      {
        'scrollToOffset': {
          'x': x,
          'y': y,
          'animated': animated,
        }
      },
    );
  }
}
