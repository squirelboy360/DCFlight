import 'package:flutter/foundation.dart';

/// React's exact useState implementation for hooks
class StateValue<T> {
  final String name;
  final T initialValue;
  final String componentId;
  final Function(Map<String, dynamic>) setState;

  // React stores current value in the hook
  T _currentValue;

  // React tracks previous value for effect comparison
  T? _previousValue;

  // React uses this for bailout optimization
  bool _isDirty = false;

  StateValue({
    required this.name,
    required this.initialValue,
    required this.componentId,
    required this.setState,
  }) : _currentValue = initialValue;

  /// Get current value (React's hook.memoizedState)
  T get value => _currentValue;

  /// Set value (React's dispatchAction)
  set value(T newValue) {
    // React's Object.is comparison for bailout
    if (identical(newValue, _currentValue)) {
      return;
    }

    // React tracks previous value for effects
    _previousValue = _currentValue;

    // React updates value immediately
    _currentValue = newValue;
    _isDirty = true;

    // React creates an update object for processing
    final updates = <String, dynamic>{};
    updates[name] = newValue;

    // React dispatches the action
    setState(updates);
  }

  // React's internal state synchronization
  void updateCurrentValue(T newValue) {
    if (!identical(_currentValue, newValue)) {
      _previousValue = _currentValue;
      _currentValue = newValue;
      _isDirty = true;
    }
  }

  // For internal use - check if value changed
  bool hasChanged() {
    return _isDirty;
  }

  // React's usePrevious custom hook equivalent
  T? get previousValue => _previousValue;

  // Commit phase cleanup
  void commitUpdate() {
    _isDirty = false;
  }
}

/// React's exact batched update implementation
class ReactBatchedUpdates {
  static bool _isBatchingUpdates = false;
  static final List<Function> _pendingCallbacks = [];

  /// React.unstable_batchedUpdates implementation
  static void batchedUpdates(Function callback) {
    final prevIsBatching = _isBatchingUpdates;
    _isBatchingUpdates = true;

    try {
      callback();
    } finally {
      _isBatchingUpdates = prevIsBatching;

      if (!_isBatchingUpdates) {
        _processPendingCallbacks();
      }
    }
  }

  /// React's internal scheduler queue
  static void enqueueCallback(Function callback) {
    if (_isBatchingUpdates) {
      _pendingCallbacks.add(callback);
    } else {
      callback();
    }
  }

  /// React's callback processing logic
  static void _processPendingCallbacks() {
    if (_pendingCallbacks.isEmpty) return;

    final callbacks = List<Function>.from(_pendingCallbacks);
    _pendingCallbacks.clear();

    for (final callback in callbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in batched callback: $e');
      }
    }
  }

  /// React's internal batching status check
  static bool get isBatching => _isBatchingUpdates;
}
