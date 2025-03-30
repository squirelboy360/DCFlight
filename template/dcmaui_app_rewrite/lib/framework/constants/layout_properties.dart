/// This class serves as a single source of truth for layout property names
/// across the framework. This prevents hardcoding property names in multiple places
/// and ensures consistency.
class LayoutProperties {
  // Dimension properties
  static const String width = 'width';
  static const String height = 'height';
  static const String minWidth = 'minWidth';
  static const String minHeight = 'minHeight';
  static const String maxWidth = 'maxWidth';
  static const String maxHeight = 'maxHeight';
  static const String aspectRatio = 'aspectRatio';

  // Margin properties
  static const String margin = 'margin';
  static const String marginTop = 'marginTop';
  static const String marginRight = 'marginRight';
  static const String marginBottom = 'marginBottom';
  static const String marginLeft = 'marginLeft';
  static const String marginHorizontal = 'marginHorizontal';
  static const String marginVertical = 'marginVertical';

  // Padding properties
  static const String padding = 'padding';
  static const String paddingTop = 'paddingTop';
  static const String paddingRight = 'paddingRight';
  static const String paddingBottom = 'paddingBottom';
  static const String paddingLeft = 'paddingLeft';
  static const String paddingHorizontal = 'paddingHorizontal';
  static const String paddingVertical = 'paddingVertical';

  // Flexbox properties
  static const String flex = 'flex';
  static const String flexGrow = 'flexGrow';
  static const String flexShrink = 'flexShrink';
  static const String flexBasis = 'flexBasis';
  static const String alignSelf = 'alignSelf';
  static const String flexDirection = 'flexDirection';
  static const String flexWrap = 'flexWrap';
  static const String justifyContent = 'justifyContent';
  static const String alignItems = 'alignItems';
  static const String alignContent = 'alignContent';

  // Position properties
  static const String position = 'position';
  static const String top = 'top';
  static const String right = 'right';
  static const String bottom = 'bottom';
  static const String left = 'left';
  static const String zIndex = 'zIndex';

  /// Get all layout properties as a set
  static Set<String> get all => {
        // Dimensions
        width,
        height,
        minWidth,
        minHeight,
        maxWidth,
        maxHeight,
        aspectRatio,

        // Margins
        margin,
        marginTop,
        marginRight,
        marginBottom,
        marginLeft,
        marginHorizontal,
        marginVertical,

        // Paddings
        padding,
        paddingTop,
        paddingRight,
        paddingBottom,
        paddingLeft,
        paddingHorizontal,
        paddingVertical,

        // Flexbox
        flex,
        flexGrow,
        flexShrink,
        flexBasis,
        alignSelf,
        flexDirection,
        flexWrap,
        justifyContent,
        alignItems,
        alignContent,

        // Position
        position,
        top,
        right,
        bottom,
        left,
        zIndex,
      };
}
