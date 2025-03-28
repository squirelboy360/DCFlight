import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// UseReducer is similar to React's useReducer, for more complex state logic
class UseReducer<S, A> {
  final String _componentId;
  final String _stateKey;
  final S _initialState;
  final S Function(S state, A action) _reducer;

  /// Create a reducer hook
  ///
  /// Example usage:
  /// ```dart
  /// // Define action enum
  /// enum CounterAction { increment, decrement, reset }
  ///
  /// // Define reducer function
  /// int counterReducer(int state, CounterAction action) {
  ///   switch (action) {
  ///     case CounterAction.increment: return state + 1;
  ///     case CounterAction.decrement: return state - 1;
  ///     case CounterAction.reset: return 0;
  ///   }
  /// }
  ///
  /// // Create the hook
  /// final counter = UseReducer<int, CounterAction>(
  ///   'counter',
  ///   0,
  ///   counterReducer
  /// );
  ///
  /// // Use the state
  /// int count = counter.state;
  ///
  /// // Dispatch actions
  /// counter.dispatch(CounterAction.increment);
  /// ```
  UseReducer(String key, S initialState, this._reducer, {String? componentId})
      : _stateKey = key,
        _initialState = initialState,
        _componentId =
            componentId ?? 'reducer_${key}_${identityHashCode(key)}' {
    // Initialize in the state manager
    GlobalStateManager.instance
        .initializeState(_componentId, {_stateKey: initialState});
  }

  /// Get the current state
  S get state =>
      GlobalStateManager.instance
          .getState<S>(_componentId, _stateKey, _initialState) ??
      _initialState;

  /// Dispatch an action to update state
  void dispatch(A action) {
    final currentState = state;
    final newState = _reducer(currentState, action);

    if (newState != currentState) {
      GlobalStateManager.instance.setState(_componentId, _stateKey, newState);
      if (kDebugMode) {
        print('UseReducer: Action $action resulted in state update: $newState');
      }
    }
  }

  /// Reset state to initial value
  void reset() {
    GlobalStateManager.instance
        .setState(_componentId, _stateKey, _initialState);
  }

  /// Clean up this reducer hook
  void dispose() {
    GlobalStateManager.instance.cleanupState(_componentId);
  }
}
