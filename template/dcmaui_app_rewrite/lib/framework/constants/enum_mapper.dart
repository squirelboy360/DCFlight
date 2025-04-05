import '../constants/layout_enums.dart';
import '../packages/yoga/yoga_enums.dart';

/// Helper functions to map between Dart enums and Yoga enums
class EnumMapper {
  /// Map from Direction to YogaDirection
  static YogaDirection toYogaDirection(Direction direction) {
    switch (direction) {
      case Direction.ltr:
        return YogaDirection.ltr;
      case Direction.rtl:
        return YogaDirection.rtl;
    }
  }

  /// Map from FlexDirection to YogaFlexDirection
  static YogaFlexDirection toYogaFlexDirection(FlexDirection flexDirection) {
    switch (flexDirection) {
      case FlexDirection.column:
        return YogaFlexDirection.column;
      case FlexDirection.columnReverse:
        return YogaFlexDirection.columnReverse;
      case FlexDirection.row:
        return YogaFlexDirection.row;
      case FlexDirection.rowReverse:
        return YogaFlexDirection.rowReverse;
    }
  }

  /// Map from JustifyContent to YogaJustifyContent
  static YogaJustifyContent toYogaJustifyContent(
      JustifyContent justifyContent) {
    switch (justifyContent) {
      case JustifyContent.flexStart:
        return YogaJustifyContent.flexStart;
      case JustifyContent.center:
        return YogaJustifyContent.center;
      case JustifyContent.flexEnd:
        return YogaJustifyContent.flexEnd;
      case JustifyContent.spaceBetween:
        return YogaJustifyContent.spaceBetween;
      case JustifyContent.spaceAround:
        return YogaJustifyContent.spaceAround;
      case JustifyContent.spaceEvenly:
        return YogaJustifyContent.spaceEvenly;
    }
  }

  /// Map from AlignItems to YogaAlign
  static YogaAlign toYogaAlignItems(AlignItems alignItems) {
    switch (alignItems) {
      case AlignItems.auto:
        return YogaAlign.auto;
      case AlignItems.flexStart:
        return YogaAlign.flexStart;
      case AlignItems.center:
        return YogaAlign.center;
      case AlignItems.flexEnd:
        return YogaAlign.flexEnd;
      case AlignItems.stretch:
        return YogaAlign.stretch;
      case AlignItems.baseline:
        return YogaAlign.baseline;
      case AlignItems.spaceBetween:
        return YogaAlign.spaceBetween;
      case AlignItems.spaceAround:
        return YogaAlign.spaceAround;
    }
  }

  /// Map from AlignSelf to YogaAlign
  static YogaAlign toYogaAlignSelf(AlignSelf alignSelf) {
    switch (alignSelf) {
      case AlignSelf.auto:
        return YogaAlign.auto;
      case AlignSelf.flexStart:
        return YogaAlign.flexStart;
      case AlignSelf.center:
        return YogaAlign.center;
      case AlignSelf.flexEnd:
        return YogaAlign.flexEnd;
      case AlignSelf.stretch:
        return YogaAlign.stretch;
      case AlignSelf.baseline:
        return YogaAlign.baseline;
      case AlignSelf.spaceBetween:
        return YogaAlign.spaceBetween;
      case AlignSelf.spaceAround:
        return YogaAlign.spaceAround;
    }
  }

  /// Map from AlignContent to YogaAlign
  static YogaAlign toYogaAlignContent(AlignContent alignContent) {
    switch (alignContent) {
      case AlignContent.flexStart:
        return YogaAlign.flexStart;
      case AlignContent.center:
        return YogaAlign.center;
      case AlignContent.flexEnd:
        return YogaAlign.flexEnd;
      case AlignContent.stretch:
        return YogaAlign.stretch;
      case AlignContent.spaceBetween:
        return YogaAlign.spaceBetween;
      case AlignContent.spaceAround:
        return YogaAlign.spaceAround;
    }
  }

  /// Map from FlexWrap to YogaWrap
  static YogaWrap toYogaFlexWrap(FlexWrap flexWrap) {
    switch (flexWrap) {
      case FlexWrap.nowrap:
        return YogaWrap.nowrap;
      case FlexWrap.wrap:
        return YogaWrap.wrap;
      case FlexWrap.wrapReverse:
        return YogaWrap.wrapReverse;
    }
  }

  /// Map from PositionType to YogaPositionType
  static YogaPositionType toYogaPositionType(PositionType position) {
    switch (position) {
      case PositionType.relative:
        return YogaPositionType.relative;
      case PositionType.absolute:
        return YogaPositionType.absolute;
    }
  }

  /// Map from Display to YogaDisplay
  static YogaDisplay toYogaDisplay(Display display) {
    switch (display) {
      case Display.flex:
        return YogaDisplay.flex;
      case Display.none:
        return YogaDisplay.none;
    }
  }

  /// Map from Overflow to YogaOverflow
  static YogaOverflow toYogaOverflow(Overflow overflow) {
    switch (overflow) {
      case Overflow.visible:
        return YogaOverflow.visible;
      case Overflow.hidden:
        return YogaOverflow.hidden;
      case Overflow.scroll:
        return YogaOverflow.scroll;
    }
  }
}
