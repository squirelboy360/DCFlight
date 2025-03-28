import 'dart:math';

import 'vdom_node.dart';
import 'state_hook.dart';

/// Base component class
abstract class Component {
  /// Unique ID for this component instance
  final String instanceId;

  /// Key for reconciliation
  final String? key;

  /// Fully qualified type name for component
  final String typeName;

  /// Create a component
  Component({this.key})
      : instanceId = DateTime.now().millisecondsSinceEpoch.toString() +
            Random().nextDouble().toString(),
        typeName = StackTrace.current.toString().split('\n')[1].split(' ')[0];

  /// Render the component
  VDomNode render();

  /// Called when the component is mounted
  void componentDidMount() {}
}

/// Stateful component with hooks
abstract class StatefulComponent extends Component {
  /// Whether the component is mounted
  bool _isMounted = false;

  /// Current hook index during rendering
  int _hookIndex = 0;

  /// List of hooks
  final List<Hook> _hooks = [];

  /// Function to schedule updates when state changes
  Function() scheduleUpdate = () {};

  /// Create a stateful component
  StatefulComponent({super.key});

  /// Get whether the component is mounted
  bool get isMounted => _isMounted;

  /// Called when the component is mounted
  @override
  void componentDidMount() {
    _isMounted = true;
  }

  /// Called when the component will unmount
  void componentWillUnmount() {
    // Clean up hooks
    for (final hook in _hooks) {
      hook.dispose();
    }
    _hooks.clear();
    _isMounted = false;
  }

  /// Called after the component updates
  void componentDidUpdate(Map<String, dynamic> prevProps) {}

  /// Reset hook state for next render
  void _resetHookState() {
    _hookIndex = 0;
  }

  /// Create a state hook
  StateHook<T> useState<T>(T initialValue, [String? name]) {
    return _createHook(() {
      return StateHook<T>(initialValue, name, () {
        // Schedule an update when state changes
        scheduleUpdate();
      });
    }) as StateHook<T>;
  }

  /// Create an effect hook
  void useEffect(Function()? Function() effect,
      {List<dynamic> dependencies = const []}) {
    final hook = _createHook(() => EffectHook(effect, dependencies));

    // Cast to EffectHook to access its methods
    (hook as EffectHook).runEffect();
  }

  /// Create a memo hook
  T useMemo<T>(T Function() compute, {List<dynamic> dependencies = const []}) {
    final hook = _createHook(() => MemoHook<T>(compute, dependencies));

    // Cast to MemoHook to access its methods
    return (hook as MemoHook<T>).value;
  }

  /// Create a ref hook
  RefObject<T> useRef<T>([T? initialValue]) {
    final hook = _createHook(() => RefHook<T>(initialValue));

    // Cast to RefHook to access its methods
    return (hook as RefHook<T>).current;
  }

  /// Helper to create/retrieve hooks
  Hook _createHook(Hook Function() createHook) {
    // Get or create the hook
    Hook hook;
    if (_hookIndex < _hooks.length) {
      // Reuse existing hook
      hook = _hooks[_hookIndex];
    } else {
      // Create new hook
      hook = createHook();
      _hooks.add(hook);
    }

    // Initialize the hook if needed
    hook.initIfNeeded();

    // Move to next hook
    _hookIndex++;

    return hook;
  }

  /// Get hooks for testing and debugging
  List<Hook> get hooks => List.unmodifiable(_hooks);

  /// Prepare component for rendering - used by VDOM
  void prepareForRender() {
    _resetHookState();
  }

  /// Run effects after render - called by VDOM
  void runEffectsAfterRender() {
    // This would run any pending effects if needed
  }

  @override
  String toString() {
    return '$typeName($instanceId)';
  }
}
