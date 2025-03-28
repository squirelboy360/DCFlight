import 'vdom_node.dart';
import 'vdom_element.dart';
import 'component.dart';

/// Represents a context for sharing data throughout the component tree
class Context<T> {
  /// Default value when no provider is found
  final T defaultValue;

  /// Unique ID for this context
  final String _id;

  /// Create a context with default value
  Context(this.defaultValue)
      : _id = DateTime.now().millisecondsSinceEpoch.toString();

  /// Create a provider element for this context
  VDomElement createProvider(T value, {required VDomNode child}) {
    return VDomElement(
      type: 'ContextProvider',
      props: {
        'contextId': _id,
        'value': value,
      },
      children: [child],
    );
  }

  /// Get current value for this context (default if no provider found)
  T get value => defaultValue;

  /// Create a consumer element for this context
  VDomElement createConsumer({required Function(T) builder}) {
    return VDomElement(
      type: 'ContextConsumer',
      props: {
        'contextId': _id,
        'consumer': builder,
      },
      children: [],
    );
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
  VDomNode render() {
    return context.createProvider(value, child: child);
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
