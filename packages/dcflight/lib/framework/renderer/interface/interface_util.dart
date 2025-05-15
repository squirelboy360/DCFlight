
// ignore_for_file: deprecated_member_use

import 'package:dcflight/dcflight.dart';

Map<String, dynamic> preprocessProps(Map<String, dynamic> props) {
    final processedProps = <String, dynamic>{};

    props.forEach((key, value) {
      if (value is Function) {
        // Handle event handlers
        if (key.startsWith('on')) {
          key.substring(2).toLowerCase();
          processedProps['_has${key.substring(2)}Handler'] = true;
        }
      } else if (value is Color) {
        // Convert Color objects to hex strings with alpha
        processedProps[key] =
            '#${value.value.toRadixString(16).padLeft(8, '0')}';
      } else if (value == double.infinity) {
        // Convert infinity to 100% string for percentage sizing
        processedProps[key] = '100%';
      } else if (value is String &&
          (value.endsWith('%') || value.startsWith('#'))) {
        // Pass percentage strings and color strings through directly
        processedProps[key] = value;
      } else if (key == 'width' ||
          key == 'height' ||
          key.startsWith('margin') ||
          key.startsWith('padding')) {
        // Make sure numeric values go through as doubles for consistent handling
        if (value is num) {
          processedProps[key] = value.toDouble();
        } else {
          processedProps[key] = value;
        }
      } else if (value != null) {
        processedProps[key] = value;
      }
    });

    return processedProps;
  }
