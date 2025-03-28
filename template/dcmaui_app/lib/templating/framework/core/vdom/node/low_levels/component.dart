import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/state_controller.dart';
import 'package:flutter/foundation.dart';

/// Base Component class - exact 1:1 implementation of React.Component
abstract class Component {
  // React's internal component properties
  Map<String, dynamic> _props = {};
  bool mounted = false;
  Function? updateCallback;
  String? _componentId;

  // React's state storage
  final Map<String, dynamic> _state = {};
  final Map<String, StateValue> _stateHooks = {};

  // Performance tracking (React dev tools equivalent)
  static bool showPerformanceWarnings = kDebugMode;
  static bool _performanceTrackingEnabled = false;

  // React's exact props getter (immutable)
  Map<String, dynamic> get props => Map.unmodifiable(_props);

  // React's props setter (triggers updates)
  set props(Map<String, dynamic> newProps) {
    _props = Map<String, dynamic>.from(newProps);
  }

  // Component identity (React's internal component instance ID)
  String get componentId =>
      _componentId ?? 'component_${identityHashCode(this)}';

  // React's exact setState implementation
  void setState(Map<String, dynamic> newState) {
    // Check if component is mounted - React won't update unmounted components
    if (!mounted) {
      debugPrint('Warning: setState called on unmounted component');
      return;
    }

    bool hasChanges = false;
    final stateUpdates = <String, dynamic>{};

    // React's shallow copy and comparison
    for (final key in newState.keys) {
      final oldValue = _state[key];
      final newValue = newState[key];

      if (oldValue != newValue) {
        _state[key] = newValue;
        stateUpdates[key] = newValue;
        hasChanges = true;
      }
    }

    // Only trigger update if something changed
    if (hasChanges && updateCallback != null) {
      // React enqueues the update via its scheduler
      updateCallback!();
    }
  }

  // React's useState hook implementation
  StateValue<T> useState<T>(String name, T initialValue) {
    // React only initializes on first render
    if (_stateHooks.containsKey(name)) {
      return _stateHooks[name] as StateValue<T>;
    }

    // Initialize state if needed
    if (!_state.containsKey(name)) {
      _state[name] = initialValue;
    }

    // Create the hook with React's state updater
    final hook = StateValue<T>(
      name: name,
      initialValue: _state[name] as T,
      componentId: componentId,
      setState: setState,
    );

    // Store reference
    _stateHooks[name] = hook;

    return hook;
  }

  // Access to state fields for VDOM reconciliation (needed by React's internal logic)
  dynamic getStateField(String fieldName) {
    // Check if we have a state hook with this name
    if (_stateHooks.containsKey(fieldName)) {
      return _stateHooks[fieldName];
    }
    return null;
  }

  // React's exact lifecycle methods
  void componentDidMount() {}
  void componentWillUnmount() {}
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {}

  // React's error handling lifecycle method
  void componentDidCatch(dynamic error, StackTrace? stackTrace) {}

  // React's performance optimization method
  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {
    // Default implementation in React.Component always returns true
    return true;
  }

  // React's required render method
  VNode buildRender();

  // The public render interface (React's internal rendering)
  VNode render() {
    // React's performance measurement in dev mode
    if (_performanceTrackingEnabled && showPerformanceWarnings) {
      final stopwatch = Stopwatch()..start();
      final result = buildRender();
      stopwatch.stop();

      // React DevTools-like performance logging
      PerformanceMonitor.instance.trackRender(
          componentId, runtimeType.toString(), stopwatch.elapsedMicroseconds);

      return result;
    } else {
      return buildRender();
    }
  }

  // Debug representation (similar to React's component.toString())
  String toTreeString() {
    return "Component(${runtimeType.toString()})";
  }

  // React's dev mode helpers
  static void enablePerformanceTracking(bool enabled) {
    _performanceTrackingEnabled = enabled;
  }
}
