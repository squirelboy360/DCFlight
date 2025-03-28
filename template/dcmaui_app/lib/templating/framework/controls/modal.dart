import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Props for Modal component
class DCModalProps implements ControlProps {
  final bool? visible;
  final String? animationType;
  final String? presentationStyle;
  final bool? transparent;
  final bool? statusBarTranslucent;
  final bool? hardwareAccelerated;
  final bool? closeByBackdrop;
  final bool? shouldCloseOnOverlayTap;
  final Function()? onShow;
  final Function()? onDismiss;
  final Function(Map<String, dynamic>)? onRequestClose;
  final ViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCModalProps({
    this.visible,
    this.animationType,
    this.presentationStyle,
    this.transparent,
    this.statusBarTranslucent,
    this.hardwareAccelerated,
    this.closeByBackdrop,
    this.shouldCloseOnOverlayTap,
    this.onShow,
    this.onDismiss,
    this.onRequestClose,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (visible != null) map['visible'] = visible;
    if (animationType != null) map['animationType'] = animationType;
    if (presentationStyle != null) map['presentationStyle'] = presentationStyle;
    if (transparent != null) map['transparent'] = transparent;
    if (statusBarTranslucent != null) {
      map['statusBarTranslucent'] = statusBarTranslucent;
    }
    if (hardwareAccelerated != null) {
      map['hardwareAccelerated'] = hardwareAccelerated;
    }
    if (closeByBackdrop != null) map['closeByBackdrop'] = closeByBackdrop;
    if (shouldCloseOnOverlayTap != null) {
      map['shouldCloseOnOverlayTap'] = shouldCloseOnOverlayTap;
    }
    if (onShow != null) map['onShow'] = onShow;
    if (onDismiss != null) map['onDismiss'] = onDismiss;
    if (onRequestClose != null) map['onRequestClose'] = onRequestClose;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Modal component
class DCModal extends Control {
  final DCModalProps props;
  final List<Control> children;

  DCModal({
    bool? visible,
    String? animationType,
    String? presentationStyle,
    bool? transparent,
    bool? statusBarTranslucent,
    bool? hardwareAccelerated,
    bool? closeByBackdrop,
    bool? shouldCloseOnOverlayTap,
    Function()? onShow,
    Function()? onDismiss,
    Function(Map<String, dynamic>)? onRequestClose,
    ViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCModalProps(
          visible: visible,
          animationType: animationType,
          presentationStyle: presentationStyle,
          transparent: transparent,
          statusBarTranslucent: statusBarTranslucent,
          hardwareAccelerated: hardwareAccelerated,
          closeByBackdrop: closeByBackdrop,
          shouldCloseOnOverlayTap: shouldCloseOnOverlayTap,
          onShow: onShow,
          onDismiss: onDismiss,
          onRequestClose: onRequestClose,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCModal',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Convenience constructor for a fullscreen fade modal
  static DCModal fade({
    required bool visible,
    required List<Control> children,
    Function()? onDismiss,
    Function(Map<String, dynamic>)? onRequestClose,
    bool? transparent,
  }) {
    return DCModal(
      visible: visible,
      animationType: 'fade',
      presentationStyle: 'fullScreen',
      transparent: transparent ?? true,
      onDismiss: onDismiss,
      onRequestClose: onRequestClose,
      children: children,
    );
  }

  /// Convenience constructor for a slide-up modal
  static DCModal slideUp({
    required bool visible,
    required List<Control> children,
    Function()? onDismiss,
    Function(Map<String, dynamic>)? onRequestClose,
    bool? transparent,
  }) {
    return DCModal(
      visible: visible,
      animationType: 'slide',
      presentationStyle: 'pageSheet',
      transparent: transparent ?? false,
      onDismiss: onDismiss,
      onRequestClose: onRequestClose,
      children: children,
    );
  }
}
