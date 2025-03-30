/// Flex direction enum
enum FlexDirection {
  row('row'),
  rowReverse('rowReverse'),
  column('column'),
  columnReverse('columnReverse');

  final String value;
  const FlexDirection(this.value);
}

/// Flex wrap enum
enum FlexWrap {
  nowrap('nowrap'),
  wrap('wrap'),
  wrapReverse('wrapReverse');

  final String value;
  const FlexWrap(this.value);
}

/// Justify content enum
enum JustifyContent {
  flexStart('flexStart'),
  center('center'),
  flexEnd('flexEnd'),
  spaceBetween('spaceBetween'),
  spaceAround('spaceAround'),
  spaceEvenly('spaceEvenly');

  final String value;
  const JustifyContent(this.value);
}

/// Align items enum
enum AlignItems {
  flexStart('flexStart'),
  center('center'),
  flexEnd('flexEnd'),
  stretch('stretch'),
  baseline('baseline');

  final String value;
  const AlignItems(this.value);
}

/// Align content enum
enum AlignContent {
  flexStart('flexStart'),
  center('center'),
  flexEnd('flexEnd'),
  stretch('stretch'),
  spaceBetween('spaceBetween'),
  spaceAround('spaceAround');

  final String value;
  const AlignContent(this.value);
}

/// Align self enum
enum AlignSelf {
  auto('auto'),
  flexStart('flexStart'),
  center('center'),
  flexEnd('flexEnd'),
  stretch('stretch'),
  baseline('baseline');

  final String value;
  const AlignSelf(this.value);
}

/// Position type enum
enum Position {
  relative('relative'),
  absolute('absolute');

  final String value;
  const Position(this.value);
}

/// Resize mode for images
enum ResizeMode {
  cover('cover'),
  contain('contain'),
  stretch('stretch'),
  center('center');

  final String value;
  const ResizeMode(this.value);
}

/// Overflow enum
enum Overflow {
  visible('visible'),
  hidden('hidden'),
  scroll('scroll');

  final String value;
  const Overflow(this.value);
}

/// Display enum
enum Display {
  flex('flex'),
  none('none');

  final String value;
  const Display(this.value);
}

// Removing duplicate enums to avoid conflicts
// Text-related enums have been moved solely to text_props.dart
