import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Props for RefreshControl component
class DCRefreshControlProps implements ControlProps {
  final bool refreshing;
  final Function()? onRefresh;
  final Color? tintColor;
  final String? title;
  final Color? titleColor;
  final int? progressViewOffset;
  final int? size;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCRefreshControlProps({
    required this.refreshing,
    this.onRefresh,
    this.tintColor,
    this.title,
    this.titleColor,
    this.progressViewOffset,
    this.size,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'refreshing': refreshing,
      ...additionalProps,
    };

    if (onRefresh != null) map['onRefresh'] = onRefresh;

    if (tintColor != null) {
      final colorValue = tintColor!.value.toRadixString(16).padLeft(8, '0');
      map['tintColor'] = '#$colorValue';
    }

    if (title != null) map['title'] = title;

    if (titleColor != null) {
      final colorValue = titleColor!.value.toRadixString(16).padLeft(8, '0');
      map['titleColor'] = '#$colorValue';
    }

    if (progressViewOffset != null) {
      map['progressViewOffset'] = progressViewOffset;
    }
    if (size != null) map['size'] = size;
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// RefreshControl component for adding pull-to-refresh functionality to ScrollView
class DCRefreshControl extends Control {
  final DCRefreshControlProps props;

  DCRefreshControl({
    required bool refreshing,
    Function()? onRefresh,
    Color? tintColor,
    String? title,
    Color? titleColor,
    int? progressViewOffset,
    int? size,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCRefreshControlProps(
          refreshing: refreshing,
          onRefresh: onRefresh,
          tintColor: tintColor,
          title: title,
          titleColor: titleColor,
          progressViewOffset: progressViewOffset,
          size: size,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCRefreshControl',
      props.toMap(),
      [],
    );
  }

  /// Create a simple refresh control with standard styling
  static DCRefreshControl simple({
    required bool refreshing,
    required Function() onRefresh,
    Color? tintColor,
  }) {
    return DCRefreshControl(
      refreshing: refreshing,
      onRefresh: onRefresh,
      tintColor: tintColor,
    );
  }

  /// Create a refresh control with a text indicator
  static DCRefreshControl withText({
    required bool refreshing,
    required Function() onRefresh,
    required String title,
    Color? titleColor,
    Color? tintColor,
  }) {
    return DCRefreshControl(
      refreshing: refreshing,
      onRefresh: onRefresh,
      title: title,
      titleColor: titleColor,
      tintColor: tintColor,
    );
  }
}
