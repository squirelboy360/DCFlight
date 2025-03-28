import 'dart:developer' as developer;

/// Base hook class
abstract class Hook {
  /// Whether the hook is initialized
  bool _isInitialized = false;

  /// Whether the hook is dirty and needs to trigger an update
  bool _isDirty = false;

  /// Get whether the hook is dirty and should trigger an update
  bool get isDirty => _isDirty;

  /// Mark the hook as clean after processing
  void markClean() {
    _isDirty = false;
  }

  /// Initialize the hook if needed
  void initIfNeeded() {
    if (!_isInitialized) {
      _isInitialized = true;
      _init();
    }
  }

  /// Internal initialization
  void _init();

  /// Clean up the hook
  void dispose() {}
}

/// State hook for managing component state
class StateHook<T> extends Hook {
  /// Current value of the state
  T _value;

  /// Name for debugging
  final String? _name;

  /// Last render value - used to detect meaningless updates
  T? _lastRenderValue;

  /// The component that owns this state
  late final Function() _scheduleUpdate;

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

    _value = newValue;
    _isDirty = true;

    // Schedule update immediately for smooth animations
    _scheduleUpdate();
  }

  @override
  void _init() {
    // State hooks are already initialized with their initial value
  }

  /// Check if value changed since last render
  bool hasChanged() {
    if (_lastRenderValue != _value) {
      _lastRenderValue = _value;
      return true;
    }
    return false;
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
  void _init() {
    // Effects are run after rendering
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
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Memo hook for memoized values
class MemoHook<T> extends Hook {
  /// The memo function that computes the value
  final T Function() _compute;

  /// Dependencies array
  final List<dynamic> _dependencies;

  /// Memoized value
  T? _value;

  /// Previous dependencies
  List<dynamic>? _prevDeps;

  /// Create a memo hook
  MemoHook(this._compute, this._dependencies);

  /// Get the memoized value, recomputing if needed
  T get value {
    // If not initialized or deps changed, recompute
    if (!_isInitialized ||
        _dependencies.isEmpty ||
        _prevDeps == null ||
        !_areEqualDeps(_dependencies, _prevDeps!)) {
      _value = _compute();
      _prevDeps = List.from(_dependencies);
    }
    return _value as T;
  }

  @override
  void _init() {
    // Compute initial value
    _value = _compute();
    _prevDeps = List.from(_dependencies);
  }

  // Compare two dependency arrays
  bool _areEqualDeps(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Ref hook for mutable references
class RefHook<T> extends Hook {
  /// The current value of the reference
  T? _current;

  /// Create a ref hook
  RefHook(this._current);

  /// Get the current ref object
  RefObject<T> get current => RefObject<T>(_current);

  @override
  void _init() {
    // Nothing to initialize
  }
}

/// Reference object wrapper
class RefObject<T> {
  /// Current value
  final T? _value;

  /// Create a ref object
  RefObject(this._value);

  /// Get the current value
  T? get value => _value;
}
