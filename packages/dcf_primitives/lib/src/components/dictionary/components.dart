// Export all component implementations
export '../view_component.dart';
export '../text_component.dart';
export '../button_component.dart';
export '../image_component.dart';
export '../touchable_opacity_component.dart';
export '../scroll_view_component.dart';
export '../animated_view_component.dart';
export '../animated_text_component.dart';
export '../svg_component.dart';
export '../icon_component.dart';

//! Quick advise for contributors before you export a new component, verify this:
//  Components that are leaf nodes (like buttons, text, etc.(in case you are a novice, a leaf node does not take children, the chain ends there)) should have a flex of 1 by defaut if not leave the layoutProps empty.