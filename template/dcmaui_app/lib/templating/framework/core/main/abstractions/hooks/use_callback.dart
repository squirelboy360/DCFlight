import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Hook for memoized callbacks that only recreate when dependencies change
class UseCallback<T extends Function> {
  final String _componentId;
  final String _callbackKey;
  final T _callback;
  final List<String> _dependencies;

  /// Create a memoized callback
  ///
  /// Example usage:
  /// ```dart
  /// // Create a callback that only changes when dependencies change
  /// final handleClick = UseCallback(
  ///   'handleClick',
  ///   () => incrementCounter(count),
  ///   ['count'],
  ///   componentId: myComponentId,
  /// );
  ///
  /// // Use the memoized callback
  /// DCButton(
  ///   title: 'Increment',
  ///   onPress: handleClick.value,
  /// )
  /// ```
  UseCallback(
    String key,
    T callback,
    List<String> dependencies, {
    String? componentId,
  })  : _callbackKey = key,
        _callback = callback,
        _dependencies = dependencies,
        _componentId = componentId ?? 'global_${key}_${identityHashCode(key)}';

  /// Get the memoized callback - returns the same function reference
  /// if dependencies haven't changed
  T get value {
    return GlobalStateManager.instance.memoize<T>(
      _componentId,
      _callbackKey,
      () => _callback,
      _dependencies,
    );
  }

  /// Force callback recreation regardless of dependencies
  void invalidate() {
    if (kDebugMode) {
      print('UseCallback: Invalidated $_callbackKey');
    }
  }

  /// Clean up this hook
  void dispose() {
    // Nothing to do - GlobalStateManager handles cleanup by component ID
  }
}
