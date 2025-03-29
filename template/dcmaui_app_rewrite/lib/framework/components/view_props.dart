import '../constants/layout_enums.dart';
import 'base_props.dart';

/// View component properties
class ViewProps extends BaseProps {
  const ViewProps({
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,
    super.pointerEvents,

    // Layout properties
    super.width,
    super.height,
    super.margin,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.marginLeft,
    super.marginHorizontal,
    super.marginVertical,
    super.padding,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.paddingLeft,
    super.paddingHorizontal,
    super.paddingVertical,

    // Flexbox properties
    super.flexDirection,
    super.flexWrap,
    super.justifyContent,
    super.alignItems,
    super.alignContent,
    super.alignSelf,
    super.flex,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,
    super.aspectRatio,

    // Min/max dimensions
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,

    // Styling
    super.backgroundColor,
    super.opacity,
    super.borderRadius,
    super.borderTopLeftRadius,
    super.borderTopRightRadius,
    super.borderBottomLeftRadius,
    super.borderBottomRightRadius,
    super.borderColor,
    super.borderWidth,
    super.transform,

    // Shadow
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffset,

    // Position
    super.overflow,
    super.zIndex,
    super.position,
    super.top,
    super.right,
    super.bottom,
    super.left,
    super.start,
    super.end,
  });
}
