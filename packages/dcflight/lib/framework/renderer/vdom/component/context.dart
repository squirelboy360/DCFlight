import '../vdom_node.dart';
import 'component.dart';

/// Simple context system for passing values down the component tree
/// This is a minimal implementation that doesn't rely on provider chains
class Context<T> {
  /// Default value when no provider is found
  final T defaultValue;
  
  /// Current value - will be managed by the VDOM
  T _value;

  /// Create a context with default value
  Context(this.defaultValue) : _value = defaultValue;

  /// Get current value
  T get value => _value;
  
  /// Set current value (should only be used by providers)
  set value(T newValue) {
    _value = newValue;
  }
}

/// Context provider component
class ContextProvider<T> extends Component {
  /// The context being provided
  final Context<T> context;

  /// The value to provide
  final T value;

  /// Child node
  final VDomNode child;

  ContextProvider({
    required this.context,
    required this.value,
    required this.child,
    super.key,
  });

  @override
  void componentDidMount() {
    super.componentDidMount();
    context.value = value;
  }

  @override
  void componentWillUnmount() {
    super.componentWillUnmount();
    context.value = context.defaultValue;
  }

  @override
  VDomNode render() {
    return child;
  }
}

/// Context consumer component
class ContextConsumer<T> extends Component {
  /// The context to consume
  final Context<T> context;

  /// Builder function that uses the context value
  final VDomNode Function(T) builder;

  ContextConsumer({
    required this.context,
    required this.builder,
    super.key,
  });

  @override
  VDomNode render() {
    return builder(context.value);
  }
}

/// Context registry for the VDOM
class ContextRegistry {
  /// Map of context values by context ID and provider ID
  final Map<String, Map<String, dynamic>> _contextValues = {};

  /// Set a context value for a provider
  void setContextValue(String contextId, String providerId, dynamic value) {
    _contextValues[contextId] ??= {};
    _contextValues[contextId]![providerId] = value;
  }

  /// Get a context value
  dynamic getContextValue(String contextId, List<String> providerChain) {
    if (!_contextValues.containsKey(contextId)) {
      return null;
    }

    // Search for the nearest provider in the chain
    for (final providerId in providerChain) {
      if (_contextValues[contextId]!.containsKey(providerId)) {
        return _contextValues[contextId]![providerId];
      }
    }

    return null;
  }

  /// Remove a provider's context values
  void removeProvider(String providerId) {
    for (final contextId in _contextValues.keys) {
      _contextValues[contextId]?.remove(providerId);
    }
  }
}
