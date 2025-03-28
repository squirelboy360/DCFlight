import 'package:dc_test/templating/framework/controls/list_view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Represents a section in a SectionList
class DCSection<T> {
  final String key;
  final List<T> data;
  final Control? Function(Map<String, dynamic>)? renderSectionHeader;
  final Control? Function(Map<String, dynamic>)? renderSectionFooter;

  DCSection({
    required this.key,
    required this.data,
    this.renderSectionHeader,
    this.renderSectionFooter,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'key': key,
      'data': data is List<Map<String, dynamic>>
          ? data
          : data
              .map((item) =>
                  item is Map<String, dynamic> ? item : {'data': item})
              .toList(),
    };

    if (renderSectionHeader != null) {
      map['renderSectionHeader'] = {
        'functionId': renderSectionHeader.hashCode.toString(),
        'function': renderSectionHeader,
      };
    }

    if (renderSectionFooter != null) {
      map['renderSectionFooter'] = {
        'functionId': renderSectionFooter.hashCode.toString(),
        'function': renderSectionFooter,
      };
    }

    return map;
  }
}

/// Props for SectionList component
class DCSectionListProps implements ControlProps {
  final List<DCSection> sections;
  final Control Function(Map<String, dynamic>)? renderItem;
  final Control? Function(Map<String, dynamic>)? renderSectionHeader;
  final Control? Function(Map<String, dynamic>)? renderSectionFooter;
  final String Function(Map<String, dynamic>, int)? keyExtractor;
  final String Function(Map<String, dynamic>, int)? sectionKeyExtractor;
  final Function(Map<String, dynamic>)? onRefresh;
  final bool? refreshing;
  final Function(Map<String, dynamic>)? onEndReached;
  final double? onEndReachedThreshold;
  final Function(Map<String, dynamic>)? onViewableItemsChanged;
  final bool? stickySectionHeadersEnabled;
  final DCListViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCSectionListProps({
    required this.sections,
    this.renderItem,
    this.renderSectionHeader,
    this.renderSectionFooter,
    this.keyExtractor,
    this.sectionKeyExtractor,
    this.onRefresh,
    this.refreshing,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onViewableItemsChanged,
    this.stickySectionHeadersEnabled,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'sections': sections.map((section) => section.toMap()).toList(),
      ...additionalProps,
    };

    if (renderItem != null) {
      map['renderItem'] = {
        'functionId': renderItem.hashCode.toString(),
        'function': renderItem,
      };
    }

    if (renderSectionHeader != null) {
      map['renderSectionHeader'] = {
        'functionId': renderSectionHeader.hashCode.toString(),
        'function': renderSectionHeader,
      };
    }

    if (renderSectionFooter != null) {
      map['renderSectionFooter'] = {
        'functionId': renderSectionFooter.hashCode.toString(),
        'function': renderSectionFooter,
      };
    }

    if (keyExtractor != null) {
      map['keyExtractor'] = {
        'functionId': keyExtractor.hashCode.toString(),
        'function': keyExtractor,
      };
    }

    if (sectionKeyExtractor != null) {
      map['sectionKeyExtractor'] = {
        'functionId': sectionKeyExtractor.hashCode.toString(),
        'function': sectionKeyExtractor,
      };
    }

    if (onRefresh != null) map['onRefresh'] = onRefresh;
    if (refreshing != null) map['refreshing'] = refreshing;
    if (onEndReached != null) map['onEndReached'] = onEndReached;
    if (onEndReachedThreshold != null) {
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    }
    if (onViewableItemsChanged != null) {
      map['onViewableItemsChanged'] = onViewableItemsChanged;
    }
    if (stickySectionHeadersEnabled != null) {
      map['stickySectionHeadersEnabled'] = stickySectionHeadersEnabled;
    }
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// SectionList component for displaying sectioned lists
class DCSectionList extends Control {
  final DCSectionListProps props;

  DCSectionList({
    required List<DCSection> sections,
    Control Function(Map<String, dynamic>)? renderItem,
    Control? Function(Map<String, dynamic>)? renderSectionHeader,
    Control? Function(Map<String, dynamic>)? renderSectionFooter,
    String Function(Map<String, dynamic>, int)? keyExtractor,
    String Function(Map<String, dynamic>, int)? sectionKeyExtractor,
    Function(Map<String, dynamic>)? onRefresh,
    bool? refreshing,
    Function(Map<String, dynamic>)? onEndReached,
    double? onEndReachedThreshold,
    Function(Map<String, dynamic>)? onViewableItemsChanged,
    bool? stickySectionHeadersEnabled,
    DCListViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCSectionListProps(
          sections: sections,
          renderItem: renderItem,
          renderSectionHeader: renderSectionHeader,
          renderSectionFooter: renderSectionFooter,
          keyExtractor: keyExtractor,
          sectionKeyExtractor: sectionKeyExtractor,
          onRefresh: onRefresh,
          refreshing: refreshing,
          onEndReached: onEndReached,
          onEndReachedThreshold: onEndReachedThreshold,
          onViewableItemsChanged: onViewableItemsChanged,
          stickySectionHeadersEnabled: stickySectionHeadersEnabled,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCSectionList',
      props.toMap(),
      [], // SectionList doesn't accept children directly
    );
  }

  /// Convenience method to create a sectioned list with common settings
  static DCSectionList create<T>({
    required List<DCSection<T>> sections,
    required Control Function(T item, int index) itemBuilder,
    Control Function(DCSection<T> section, int sectionIndex)? headerBuilder,
    Control Function(DCSection<T> section, int sectionIndex)? footerBuilder,
    String Function(T item, int index)? keyExtractor,
    bool? stickySectionHeadersEnabled,
    Function(Map<String, dynamic>)? onRefresh,
    bool? refreshing,
    DCListViewStyle? style,
  }) {
    return DCSectionList(
      sections: sections,
      renderItem: (params) {
        final item = params['item'] as Map<String, dynamic>;
        final index = params['index'] as int;
        final T typedItem;

        if (T == Map<String, dynamic>) {
          typedItem = item as T;
        } else if (item.containsKey('data')) {
          typedItem = item['data'] as T;
        } else {
          // This is a fallback conversion, might not always work
          typedItem = item as T;
        }

        return itemBuilder(typedItem, index);
      },
      renderSectionHeader: headerBuilder != null
          ? (params) {
              final sectionData = params['section'] as Map<String, dynamic>;
              final sectionIndex = params['sectionIndex'] as int;
              final section = sections[sectionIndex];
              return headerBuilder(section, sectionIndex);
            }
          : null,
      renderSectionFooter: footerBuilder != null
          ? (params) {
              final sectionData = params['section'] as Map<String, dynamic>;
              final sectionIndex = params['sectionIndex'] as int;
              final section = sections[sectionIndex];
              return footerBuilder(section, sectionIndex);
            }
          : null,
      keyExtractor: keyExtractor != null
          ? (itemData, index) {
              final item = itemData['item'] as Map<String, dynamic>;
              final T typedItem;

              if (T == Map<String, dynamic>) {
                typedItem = item as T;
              } else if (item.containsKey('data')) {
                typedItem = item['data'] as T;
              } else {
                typedItem = item as T;
              }

              return keyExtractor(typedItem, index);
            }
          : null,
      stickySectionHeadersEnabled: stickySectionHeadersEnabled ?? true,
      onRefresh: onRefresh,
      refreshing: refreshing,
      style: style,
    );
  }
}

/// Style properties for DCSectionList - extends DCListViewStyle
class DCSectionListStyle extends DCListViewStyle {
  final Color? sectionHeaderBackgroundColor;
  final EdgeInsets? sectionHeaderPadding;
  final EdgeInsets? sectionFooterPadding;
  final Color? sectionSeparatorColor;
  final double? sectionSeparatorHeight;

  const DCSectionListStyle({
    super.padding,
    super.margin,
    super.backgroundColor,
    super.scrollIndicatorThickness,
    super.height,
    super.width,
    super.contentSpacing,
    super.scrollPadding,
    this.sectionHeaderBackgroundColor,
    this.sectionHeaderPadding,
    this.sectionFooterPadding,
    this.sectionSeparatorColor,
    this.sectionSeparatorHeight,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (sectionHeaderBackgroundColor != null) {
      final colorValue =
          sectionHeaderBackgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['sectionHeaderBackgroundColor'] = '#$colorValue';
    }

    if (sectionHeaderPadding != null) {
      if (sectionHeaderPadding!.left == sectionHeaderPadding!.right &&
          sectionHeaderPadding!.top == sectionHeaderPadding!.bottom &&
          sectionHeaderPadding!.left == sectionHeaderPadding!.top) {
        map['sectionHeaderPadding'] = sectionHeaderPadding!.top;
      } else {
        map['sectionHeaderPaddingLeft'] = sectionHeaderPadding!.left;
        map['sectionHeaderPaddingRight'] = sectionHeaderPadding!.right;
        map['sectionHeaderPaddingTop'] = sectionHeaderPadding!.top;
        map['sectionHeaderPaddingBottom'] = sectionHeaderPadding!.bottom;
      }
    }

    if (sectionFooterPadding != null) {
      if (sectionFooterPadding!.left == sectionFooterPadding!.right &&
          sectionFooterPadding!.top == sectionFooterPadding!.bottom &&
          sectionFooterPadding!.left == sectionFooterPadding!.top) {
        map['sectionFooterPadding'] = sectionFooterPadding!.top;
      } else {
        map['sectionFooterPaddingLeft'] = sectionFooterPadding!.left;
        map['sectionFooterPaddingRight'] = sectionFooterPadding!.right;
        map['sectionFooterPaddingTop'] = sectionFooterPadding!.top;
        map['sectionFooterPaddingBottom'] = sectionFooterPadding!.bottom;
      }
    }

    if (sectionSeparatorColor != null) {
      final colorValue =
          sectionSeparatorColor!.value.toRadixString(16).padLeft(8, '0');
      map['sectionSeparatorColor'] = '#$colorValue';
    }

    if (sectionSeparatorHeight != null) {
      map['sectionSeparatorHeight'] = sectionSeparatorHeight;
    }

    return map;
  }
}
