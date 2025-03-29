/// Flexbox direction
enum FlexDirection {
  row,
  rowReverse,
  column,
  columnReverse;

  String get value {
    switch (this) {
      case FlexDirection.row:
        return 'row';
      case FlexDirection.rowReverse:
        return 'rowReverse';
      case FlexDirection.column:
        return 'column';
      case FlexDirection.columnReverse:
        return 'columnReverse';
    }
  }
}

/// Flexbox wrap behavior
enum FlexWrap {
  wrap,
  nowrap,
  wrapReverse;

  String get value {
    switch (this) {
      case FlexWrap.wrap:
        return 'wrap';
      case FlexWrap.nowrap:
        return 'nowrap';
      case FlexWrap.wrapReverse:
        return 'wrapReverse';
    }
  }
}

/// Flexbox justify content
enum JustifyContent {
  flexStart,
  center,
  flexEnd,
  spaceBetween,
  spaceAround,
  spaceEvenly;

  String get value {
    switch (this) {
      case JustifyContent.flexStart:
        return 'flexStart';
      case JustifyContent.center:
        return 'center';
      case JustifyContent.flexEnd:
        return 'flexEnd';
      case JustifyContent.spaceBetween:
        return 'spaceBetween';
      case JustifyContent.spaceAround:
        return 'spaceAround';
      case JustifyContent.spaceEvenly:
        return 'spaceEvenly';
    }
  }
}

/// Flexbox align items
enum AlignItems {
  flexStart,
  center,
  flexEnd,
  stretch,
  baseline;

  String get value {
    switch (this) {
      case AlignItems.flexStart:
        return 'flexStart';
      case AlignItems.center:
        return 'center';
      case AlignItems.flexEnd:
        return 'flexEnd';
      case AlignItems.stretch:
        return 'stretch';
      case AlignItems.baseline:
        return 'baseline';
    }
  }
}

/// Flexbox align content
enum AlignContent {
  flexStart,
  center,
  flexEnd,
  stretch,
  spaceBetween,
  spaceAround;

  String get value {
    switch (this) {
      case AlignContent.flexStart:
        return 'flexStart';
      case AlignContent.center:
        return 'center';
      case AlignContent.flexEnd:
        return 'flexEnd';
      case AlignContent.stretch:
        return 'stretch';
      case AlignContent.spaceBetween:
        return 'spaceBetween';
      case AlignContent.spaceAround:
        return 'spaceAround';
    }
  }
}

/// Flexbox align self
enum AlignSelf {
  auto,
  flexStart,
  center,
  flexEnd,
  stretch,
  baseline;

  String get value {
    switch (this) {
      case AlignSelf.auto:
        return 'auto';
      case AlignSelf.flexStart:
        return 'flexStart';
      case AlignSelf.center:
        return 'center';
      case AlignSelf.flexEnd:
        return 'flexEnd';
      case AlignSelf.stretch:
        return 'stretch';
      case AlignSelf.baseline:
        return 'baseline';
    }
  }
}

/// Text align options
enum TextAlign {
  left,
  center,
  right,
  justify,
  auto;

  String get value {
    switch (this) {
      case TextAlign.left:
        return 'left';
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      case TextAlign.justify:
        return 'justify';
      case TextAlign.auto:
        return 'auto';
    }
  }
}

/// Font weight options
enum FontWeight {
  normal,
  bold,
  w100,
  w200,
  w300,
  w400,
  w500,
  w600,
  w700,
  w800,
  w900;

  String get value {
    switch (this) {
      case FontWeight.normal:
        return 'normal';
      case FontWeight.bold:
        return 'bold';
      case FontWeight.w100:
        return '100';
      case FontWeight.w200:
        return '200';
      case FontWeight.w300:
        return '300';
      case FontWeight.w400:
        return '400';
      case FontWeight.w500:
        return '500';
      case FontWeight.w600:
        return '600';
      case FontWeight.w700:
        return '700';
      case FontWeight.w800:
        return '800';
      case FontWeight.w900:
        return '900';
    }
  }
}

/// Position type options
enum Position {
  relative,
  absolute;

  String get value {
    switch (this) {
      case Position.relative:
        return 'relative';
      case Position.absolute:
        return 'absolute';
    }
  }
}

/// Font style options
enum FontStyle {
  normal,
  italic;

  String get value {
    switch (this) {
      case FontStyle.normal:
        return 'normal';
      case FontStyle.italic:
        return 'italic';
    }
  }
}

/// Text decoration line options
enum TextDecorationLine {
  none,
  underline,
  lineThrough,
  underlineLineThrough;

  String get value {
    switch (this) {
      case TextDecorationLine.none:
        return 'none';
      case TextDecorationLine.underline:
        return 'underline';
      case TextDecorationLine.lineThrough:
        return 'line-through';
      case TextDecorationLine.underlineLineThrough:
        return 'underline line-through';
    }
  }
}

/// Text transform options
enum TextTransform {
  none,
  uppercase,
  lowercase,
  capitalize;

  String get value {
    switch (this) {
      case TextTransform.none:
        return 'none';
      case TextTransform.uppercase:
        return 'uppercase';
      case TextTransform.lowercase:
        return 'lowercase';
      case TextTransform.capitalize:
        return 'capitalize';
    }
  }
}
