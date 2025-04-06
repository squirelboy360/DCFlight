import 'package:flutter/material.dart';

/// Properties specific to Button components
class ButtonProps {
  /// Button title text
  final String? title;

  /// Text color for the button
  final Color? titleColor; // Changed from String? to Color?

  /// Font size for button text
  final double? fontSize;

  /// Font weight for button text
  final String? fontWeight;

  /// Font family for button text
  final String? fontFamily;

  /// Whether the button is disabled
  final bool? disabled;

  /// Opacity when button is pressed
  final double? activeOpacity;

  /// Create button component-specific props
  const ButtonProps({
    this.title,
    this.titleColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.disabled,
    this.activeOpacity,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (title != null) map['title'] = title;
    if (titleColor != null)
      map['titleColor'] = titleColor; // Will be processed by _preprocessProps
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (disabled != null) map['disabled'] = disabled;
    if (activeOpacity != null) map['activeOpacity'] = activeOpacity;

    return map;
  }

  /// Create new ButtonProps by merging with another
  ButtonProps merge(ButtonProps other) {
    return ButtonProps(
      title: other.title ?? title,
      titleColor: other.titleColor ?? titleColor,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      fontFamily: other.fontFamily ?? fontFamily,
      disabled: other.disabled ?? disabled,
      activeOpacity: other.activeOpacity ?? activeOpacity,
    );
  }

  /// Create a copy with certain properties modified
  ButtonProps copyWith({
    String? title,
    Color? titleColor,
    double? fontSize,
    String? fontWeight,
    String? fontFamily,
    bool? disabled,
    double? activeOpacity,
  }) {
    return ButtonProps(
      title: title ?? this.title,
      titleColor: titleColor ?? this.titleColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      disabled: disabled ?? this.disabled,
      activeOpacity: activeOpacity ?? this.activeOpacity,
    );
  }
}
