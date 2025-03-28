import 'dart:async';

import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'dart:io' show Platform;

/// ActionSheetIOS utility class for showing iOS action sheets
class DCActionSheetIOS {
  /// Show an action sheet with options
  static Future<void> showActionSheetWithOptions({
    required Map<String, dynamic> options,
    required Function(int buttonIndex) callback,
  }) async {
    if (!Platform.isIOS) {
      // Only works on iOS
      return;
    }

    // Create a temporary view ID to track this action sheet
    final viewId = 'actionSheet_${DateTime.now().millisecondsSinceEpoch}';

    // Set up a one-time listener for the selection event
    final completer = Completer<int>();

    // Declare subscription variable before using it
    StreamSubscription<Map<String, dynamic>>? subscription;
    subscription = MainViewCoordinatorInterface.eventStream.listen((event) {
      if (event['viewId'] == viewId &&
          event['eventName'] == 'onActionSheetSelection') {
        final buttonIndex = event['params']['buttonIndex'] as int;
        completer.complete(buttonIndex);
        subscription?.cancel();
      }
    });

    // Send the show action sheet command
    MainViewCoordinatorInterface.createView(
        viewId, 'DCActionSheetIOS', options);

    // Wait for the selection and then call the callback
    final buttonIndex = await completer.future;
    callback(buttonIndex);
  }

  /// Show a share action sheet for iOS
  static Future<void> showShareActionSheetWithOptions({
    required Map<String, dynamic> options,
    required Function(Map<String, dynamic> error) failureCallback,
    required Function(bool completed, String activityType) successCallback,
  }) async {
    if (!Platform.isIOS) {
      // Only works on iOS
      return;
    }

    // Create a temporary view ID to track this share sheet
    final viewId = 'shareSheet_${DateTime.now().millisecondsSinceEpoch}';

    // Set up a one-time listener for the share result event
    final completer = Completer<Map<String, dynamic>>();

    // Declare subscription variable before using it
    StreamSubscription<Map<String, dynamic>>? subscription;
    subscription = MainViewCoordinatorInterface.eventStream.listen((event) {
      if (event['viewId'] == viewId) {
        if (event['eventName'] == 'onShareSuccess') {
          final completed = event['params']['completed'] as bool;
          final activityType = event['params']['activityType'] as String? ?? '';
          successCallback(completed, activityType);
        } else if (event['eventName'] == 'onShareFailure') {
          failureCallback(event['params']);
        }
        completer.complete(event['params']);
        subscription?.cancel();
      }
    });

    // Send the show share action sheet command with augmented options
    MainViewCoordinatorInterface.createView(viewId, 'DCShareActionSheet', {
      ...options,
      '_viewId': viewId,
    });

    // Wait for the result
    await completer.future;
  }
}
