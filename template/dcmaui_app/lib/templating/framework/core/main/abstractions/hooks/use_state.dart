import 'package:dc_test/templating/framework/core/vdom/node/low_levels/event_bus.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Hook-like state management for function components
class UseState<T> {
  final String _componentId;
  final String _stateKey;
  final T _initialValue;
  late T _currentValue;
  Function? _updateCallback;

  /// Expose the state key as public getter for ComponentHooks
  String get key => _stateKey;

  /// Create a state hook
  ///
  /// Example usage:
  /// ```dart
  /// final counterState = UseState<int>('counter', 0);
  ///
  /// // Get the current value
  /// int count = counterState.value;
  ///
  /// // Update the value
  /// counterState.value = count + 1;
  /// ```
  UseState(String key, T initialValue,
      {String? componentId, Function? onChange})
      : _stateKey = key,
        _initialValue = initialValue,
        _componentId = componentId ?? 'global_${key}_${identityHashCode(key)}',
        _currentValue = initialValue {
    _updateCallback = onChange;

    // Initialize in the state manager
    _currentValue = GlobalStateManager.instance
            .getState<T>(_componentId, _stateKey, _initialValue) ??
        _initialValue;

    GlobalStateManager.instance
        .initializeState(_componentId, {_stateKey: _currentValue});

    // Listen for changes to this state from other components
    GlobalStateManager.instance.addStateListener(
      _componentId,
      _stateKey,
      _handleExternalStateChange,
    );
  }

  /// Get the current state value
  T get value =>
      GlobalStateManager.instance
          .getState<T>(_componentId, _stateKey, _currentValue) ??
      _currentValue;

  /// Set a new state value
  set value(T newValue) {
    // CRITICAL FIX: More robust equality check for objects
    bool hasChanged = _currentValue != newValue;
    if (hasChanged) {
      debugPrint(
          'UseState: Updating $_stateKey from $_currentValue to $newValue');
      _currentValue = newValue;

      // Update in global state manager
      GlobalStateManager.instance.setState(_componentId, _stateKey, newValue);

      // CRITICAL FIX: Explicitly trigger component update
      if (_updateCallback != null) {
        debugPrint('UseState: Triggering update callback for $_stateKey');
        _updateCallback!();
      }

      // Also notify any global event listeners
      ComponentEventBus.instance.publish('state:$_stateKey', newValue);

      // CRITICAL FIX: Always notify rebuild to ensure UI updates
      ComponentEventBus.instance.notifyRebuild();
    }
  }

  // Handle state changes from external sources
  void _handleExternalStateChange(dynamic newValue) {
    if (newValue is T && _currentValue != newValue) {
      _currentValue = newValue;

      // Notify the component to update
      if (_updateCallback != null) {
        debugPrint('UseState: External update triggered for $_stateKey');
        _updateCallback!();
      }
    }
  }

  /// Set the update callback that will be triggered when state changes
  void setUpdateCallback(Function callback) {
    _updateCallback = callback;
    debugPrint('UseState: Update callback set for $_stateKey');
  }

  /// Reset state to initial value
  void reset() {
    value = _initialValue;
  }

  /// Clean up this state hook
  void dispose() {
    // Remove the state listener
    GlobalStateManager.instance.removeStateListener(
      _componentId,
      _stateKey,
      _handleExternalStateChange,
    );

    GlobalStateManager.instance.cleanupState(_componentId);
  }
}
