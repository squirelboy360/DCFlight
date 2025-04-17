import 'package:flutter/foundation.dart';
import '../vdom_node.dart';
import 'component.dart';

// Required globals for hook system
Component? _currentComponent;
int _currentHookIndex = 0;
final Map<String, _HookStore> _hookStores = {};

class _HookStore {
  final List<StateHook> stateHooks = [];
  final List<EffectHook> effectHooks = [];
}

// Get hook store for component
_HookStore getHookStore(String componentId) {
  return _hookStores[componentId] ??= _HookStore();
}

class StateHook<T> {
  final String _name;
  final Component _component;
  T _value;

  StateHook(this._value, this._name, this._component);

  T get value => _value;

  void setValue(T newValue) {
    if (_value == newValue) {
      return;
    }

    debugPrint("[StateHook] State updated: $_name from $_value to $newValue");
    _value = newValue;

    if (_component is StatefulComponent) {
      (_component as StatefulComponent).scheduleUpdate?.call();
    }
  }
}

// Register component as current for hooks
void prepareComponentForHooks(Component component) {
  _currentComponent = component;
  _currentHookIndex = 0;
}

// Clean up after rendering
void cleanupAfterRender() {
  _currentComponent = null;
  _currentHookIndex = 0;
}

// FIXED: Use proper generic type handling for useState
StateHook<T> useState<T>(T initialValue, [String name = '']) {
  if (_currentComponent == null) {
    throw Exception(
        'useState can only be called within a component render function');
  }

  final component = _currentComponent!;
  final hookIndex = _currentHookIndex++;

  // Get the hook store for this component
  final hookStore = getHookStore(component.instanceId);

  // If hook doesn't exist yet, create it
  if (hookIndex >= hookStore.stateHooks.length) {
    final hookName = name.isNotEmpty ? name : 'state_$hookIndex';
    hookStore.stateHooks.add(StateHook<T>(initialValue, hookName, component));
    return hookStore.stateHooks.last as StateHook<T>;
  }

  // CRITICAL FIX: Handle type compatibility properly
  final existingHook = hookStore.stateHooks[hookIndex];

  // If the types don't match, we need to create a new hook with the correct type
  if (existingHook._value != null &&
      existingHook._value.runtimeType != initialValue.runtimeType) {
    debugPrint(
        "⚠️ Hook type mismatch: ${existingHook._value.runtimeType} vs ${initialValue.runtimeType}");
    // Replace the hook with a new one of correct type
    hookStore.stateHooks[hookIndex] =
        StateHook<T>(initialValue, existingHook._name, component);
  } else if (existingHook._value == null) {
    // Update null value with initialValue
    existingHook._value = initialValue;
  }

  return hookStore.stateHooks[hookIndex] as StateHook<T>;
}

// Effect hook implementation
class EffectHook {
  Function() effect;
  List<dynamic>? dependencies;
  Function? cleanup;
  List<dynamic>? lastDependencies;

  EffectHook(this.effect, this.dependencies);

  bool shouldRun() {
    if (lastDependencies == null || dependencies == null) {
      return true;
    }

    if (lastDependencies!.length != dependencies!.length) {
      return true;
    }

    for (var i = 0; i < dependencies!.length; i++) {
      if (dependencies![i] != lastDependencies![i]) {
        return true;
      }
    }

    return false;
  }

  void run() {
    // Call cleanup if it exists
    if (cleanup != null) {
      cleanup!();
      cleanup = null;
    }

    // Run effect and store cleanup if returned
    final result = effect();
    if (result is Function) {
      cleanup = result;
    }

    // Update dependencies
    if (dependencies != null) {
      lastDependencies = List.from(dependencies!);
    }
  }

  void dispose() {
    if (cleanup != null) {
      cleanup!();
      cleanup = null;
    }
  }
}

// useEffect hook implementation
void useEffect(Function() effect, {List<dynamic>? dependencies}) {
  if (_currentComponent == null) {
    throw Exception(
        'useEffect can only be called within a component render function');
  }

  final component = _currentComponent!;
  final hookIndex = _currentHookIndex++;

  // Get the hook store for this component
  final hookStore = getHookStore(component.instanceId);

  // If hook doesn't exist yet, create it
  if (hookIndex >= hookStore.effectHooks.length) {
    hookStore.effectHooks.add(EffectHook(effect, dependencies));
  } else {
    // Update effect and dependencies
    hookStore.effectHooks[hookIndex].effect = effect;
    hookStore.effectHooks[hookIndex].dependencies = dependencies;
  }
}

// Run effects for a component
void runEffects(String componentId) {
  final hookStore = _hookStores[componentId];
  if (hookStore == null) return;

  for (final hook in hookStore.effectHooks) {
    if (hook.shouldRun()) {
      hook.run();
    }
  }
}

// Run effect cleanups for a component
void runEffectCleanups(String componentId) {
  final hookStore = _hookStores[componentId];
  if (hookStore == null) return;

  for (final hook in hookStore.effectHooks) {
    hook.dispose();
  }
}
