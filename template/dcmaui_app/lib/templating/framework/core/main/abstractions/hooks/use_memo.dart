import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Hook for memoized values that only recompute when dependencies change
class UseMemo<T> {
  final String _componentId;
  final String _memoKey;
  final T Function() _computeFn;
  final List<String> _dependencies;
  T? _cachedValue;
  bool _initialized = false;

  /// Create a memoized value
  ///
  /// Example usage:
  /// ```dart
  /// // Create a memo that depends on count
  /// final expensiveValue = UseMemo(
  ///   'expensiveCalculation',
  ///   () => computeExpensiveValue(count),
  ///   ['count'],
  ///   componentId: myComponentId,
  /// );
  ///
  /// // Access the memoized value
  /// int result = expensiveValue.value;
  /// ```
  UseMemo(
    String key,
    T Function() computeFn,
    List<String> dependencies, {
    String? componentId,
  })  : _memoKey = key,
        _computeFn = computeFn,
        _dependencies = dependencies,
        _componentId = componentId ?? 'global_${key}_${identityHashCode(key)}';

  /// Get the memoized value - recomputes only when dependencies change
  T get value {
    if (!_initialized) {
      _cachedValue = _computeFn();
      _initialized = true;
      return _cachedValue as T;
    }

    return GlobalStateManager.instance.memoize<T>(
      _componentId,
      _memoKey,
      _computeFn,
      _dependencies,
    );
  }

  /// Force recomputation of the memoized value
  void invalidate() {
    _cachedValue = _computeFn();
    if (kDebugMode) {
      print('UseMemo: Invalidated $_memoKey');
    }
  }

  /// Clean up this hook
  void dispose() {
    // Nothing to do - GlobalStateManager handles cleanup by component ID
  }
}
