import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/painting.dart' hide TextStyle;

/// A diagnostic component that shows issues and status
class DiagnosticComponent extends Component {
  // Internal state tracking
  List<String> _messages = [];
  bool _nativeUIReady = false;

  @override
  Map<String, dynamic> getInitialState() {
    return {
      'messages': <String>[],
      'nativeUIReady': false,
    };
  }

  @override
  void componentDidMount() {
    super.componentDidMount();

    // Listen for events from the native side
    MainViewCoordinatorInterface.eventStream.listen((event) {
      final List<String> newMessages = List<String>.from(_messages);

      // Special handling for native UI ready event
      if (event['viewId'] == 'system' &&
          event['eventName'] == 'nativeUIReady') {
        _nativeUIReady = true;

        // Trigger update if needed
        if (updateCallback != null) {
          updateCallback!();
        }
      }

      // Add the event to our messages
      newMessages.add('Event: ${event['eventName']} from ${event['viewId']}');

      // Keep only the latest 10 messages
      if (newMessages.length > 10) {
        newMessages.removeAt(0);
      }

      // Update messages state
      _messages = newMessages;

      // Trigger update if needed
      if (updateCallback != null) {
        updateCallback!();
      }
    });

    // Log diagnostic information periodically
    Future.delayed(Duration(seconds: 2), () {
      _logStatus();
    });
  }

  void _logStatus() {
    final newMessages = List<String>.from(_messages);
    newMessages.add('Status check: Native UI ready: $_nativeUIReady');
    _messages = newMessages;

    // Trigger update if needed
    if (updateCallback != null) {
      updateCallback!();
    }
  }

  // Implementation of the abstract buildRender method
  @override
  VNode buildRender() {
    // Create a list of text controls (not VNodes) for all messages
    final List<Control> messageViews = _messages
        .map<Control>((message) => DCText(
              text: message,
              style: DCTextStyle(
                fontSize: 12,
                color: Color(0xFFFFFFFF),
              ),
            ))
        .toList();

    // Create a container for the diagnostic info
    return DCView(
      style: ViewStyle(
        backgroundColor: Color(0x88000000),
        padding: EdgeInsets.all(8),
      ),
      additionalProps: {
        'style': {
          'position': 'absolute',
          'left': 0,
          'right': 0,
          'bottom': 0,
        }
      },
      children: messageViews,
    ).build();
  }
}
