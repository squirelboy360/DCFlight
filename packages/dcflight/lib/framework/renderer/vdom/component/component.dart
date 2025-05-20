import 'state_hook.dart';
import 'store.dart';
import 'component_node.dart';

/// Stateful component with hooks
abstract class StatefulComponent extends ComponentNode {
  /// Current hook index during rendering
  int _hookIndex = 0;

  /// List of hooks
  final List<Hook> _hooks = [];

  /// Function to schedule updates when state changes
  Function() scheduleUpdate = () {};

  /// Create a stateful component
  StatefulComponent({super.key});
  
  @override
  bool get isStateful => true;
  
  /// Reset hook state for next render
  void _resetHookState() {
    _hookIndex = 0;
  }
  
  /// Prepare component for rendering - used by VDOM
  void prepareForRender() {
    _resetHookState();
  }
  
  /// Run effects after render - called by VDOM
  void runEffectsAfterRender() {
    for (var i = 0; i < _hooks.length; i++) {
      final hook = _hooks[i];
      if (hook is EffectHook) {
        hook.runEffect();
      }
    }
  }
  
  @override
  void componentWillUnmount() {
    // Clean up hooks
    for (final hook in _hooks) {
      hook.dispose();
    }
    _hooks.clear();
    super.componentWillUnmount();
  }
  
  /// Called after the component updates
  @override
  void componentDidUpdate() {
    runEffectsAfterRender();
  }

  /// Create a state hook
  StateHook<T> useState<T>(T initialValue, [String? name]) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = StateHook<T>(initialValue, name, () {
        scheduleUpdate();
      });
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as StateHook<T>;
    _hookIndex++;
    
    return hook;
  }

  /// Create an effect hook
  void useEffect(Function()? Function() effect,
      {List<dynamic> dependencies = const []}) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = EffectHook(effect, dependencies);
      _hooks.add(hook);
    }
    
    // Just increment the hook index
    _hookIndex++;
  }

  /// Create a ref hook
  RefObject<T> useRef<T>([T? initialValue]) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = RefHook<T>(initialValue);
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as RefHook<T>;
    _hookIndex++;
    
    return hook.ref;
  }

  /// Create a store hook for global state
  StoreHook<T> useStore<T>(Store<T> store) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = StoreHook<T>(store, () {
        scheduleUpdate();
      });
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as StoreHook<T>;
    _hookIndex++;
    
    return hook;
  }
}

/// Stateless component without hooks
abstract class StatelessComponent extends ComponentNode {
  /// Create a stateless component
  StatelessComponent({super.key});
  
  @override
  bool get isStateful => false;
}
