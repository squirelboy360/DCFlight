import 'dart:async';
import 'package:flutter/foundation.dart';

/// Simple event bus for component communication
class ComponentEventBus {
  // Singleton instance
  static final ComponentEventBus _instance = ComponentEventBus._internal();
  static ComponentEventBus get instance => _instance;

  // Private constructor
  ComponentEventBus._internal();

  // Event stream controllers
  final Map<String, StreamController<dynamic>> _controllers = {};

  // Get stream for a specific event
  Stream<T> on<T>(String eventName) {
    if (!_controllers.containsKey(eventName)) {
      _controllers[eventName] = StreamController<T>.broadcast();
    }

    return _controllers[eventName]!.stream as Stream<T>;
  }

  // Publish an event
  void publish(String eventName, [dynamic data]) {
    debugPrint('EventBus: Publishing event "$eventName" with data: $data');

    if (_controllers.containsKey(eventName)) {
      _controllers[eventName]!.add(data);
    }
  }

  // Special method for rebuild notifications
  final StreamController<void> _rebuildController =
      StreamController<void>.broadcast();
  Stream<void> get rebuildStream => _rebuildController.stream;

  // Notify that a rebuild is needed
  void notifyRebuild() {
    debugPrint('ComponentEventBus: Notifying rebuild');
    _rebuildController.add(null);
  }

  // Dispose controllers
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _rebuildController.close();
  }
}
