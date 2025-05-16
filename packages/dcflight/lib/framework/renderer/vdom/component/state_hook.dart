// filepath: /Users/tahiruagbanwa/Desktop/Dotcorr/DCFlight/packages/dcflight/lib/framework/renderer/vdom/component/state_hook.dart
import 'dart:developer' as developer;

/// Base hook class
abstract class Hook {
  /// Clean up the hook
  void dispose() {}
}

/// State hook for managing component state
class StateHook<T> extends Hook {
  /// Current value of the state
  T _value;

  /// Name for debugging
  final String? _name;

  /// The component that owns this state
  final Function() _scheduleUpdate;

  /// Create a state hook
  StateHook(this._value, this._name, this._scheduleUpdate);

  /// Get the current value
  T get value => _value;

  /// Set the value and mark as dirty
  void setValue(T newValue) {
    // Skip update if value is identical (for references) or equal (for values)
    if (identical(_value, newValue) || _value == newValue) {
      return;
    }

    if (_name != null) {
      developer.log('State updated: $_name from $_value to $newValue',
          name: 'StateHook');
    }

    // Store the new value
    _value = newValue;

    // Schedule component update
    _scheduleUpdate();
  }
}

/// Effect hook for side effects in components
class EffectHook extends Hook {
  /// The effect function
  final Function()? Function() _effect;

  /// Dependencies array
  final List<dynamic> _dependencies;

  /// Cleanup function returned by the effect
  Function()? _cleanup;

  /// Previous dependencies
  List<dynamic>? _prevDeps;

  /// Create an effect hook
  EffectHook(this._effect, this._dependencies);

  /// Run the effect if needed
  void runEffect() {
    // Only run if:
    // 1. No previous dependencies (first run)
    // 2. Dependencies array is empty (run on every render)
    // 3. Dependencies changed since last run
    if (_prevDeps == null ||
        _dependencies.isEmpty ||
        !_areEqualDeps(_dependencies, _prevDeps!)) {
      // Run cleanup if exists
      if (_cleanup != null) {
        _cleanup!();
        _cleanup = null;
      }

      // Run effect and store cleanup
      _cleanup = _effect();

      // Store current dependencies for comparison
      _prevDeps = List.from(_dependencies);
    }
  }

  @override
  void dispose() {
    // Run cleanup if exists
    if (_cleanup != null) {
      _cleanup!();
      _cleanup = null;
    }
  }

  // Compare two dependency arrays
  bool _areEqualDeps(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    
    return true;
  }
}

/// Reference object wrapper
class RefObject<T> {
  /// Current value
  T? _value;

  /// Create a ref object
  RefObject(this._value);

  /// Get current value
  T? get current => _value;

  /// Set current value
  set current(T? value) {
    _value = value;
  }
}

/// Ref hook for storing mutable references that don't trigger rerenders
class RefHook<T> extends Hook {
  /// The ref object
  final RefObject<T> _ref;

  /// Create a ref hook
  RefHook(T? initialValue) : _ref = RefObject<T>(initialValue);

  /// Get the ref object
  RefObject<T> get ref => _ref;
}
