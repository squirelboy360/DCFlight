/// Registry for context values in the application
class ContextRegistry {
  /// Singleton instance
  static final ContextRegistry _instance = ContextRegistry._();
  
  /// Get the singleton instance
  static ContextRegistry get instance => _instance;

  /// Map of context values by provider chain
  final Map<String, Map<String, dynamic>> _contextValues = {};

  /// Private constructor
  ContextRegistry._();

  /// Constructor that forwards to singleton
  factory ContextRegistry() => _instance;

  /// Set a context value
  void setContextValue(String contextId, String providerId, dynamic value) {
    // Store the value indexed by both context ID and provider ID
    if (!_contextValues.containsKey(contextId)) {
      _contextValues[contextId] = <String, dynamic>{};
    }
    _contextValues[contextId]![providerId] = value;
  }

  /// Get a context value
  dynamic getContextValue(String contextId, List<String> providerChain) {
    // If context doesn't exist, return null
    if (!_contextValues.containsKey(contextId)) {
      return null;
    }

    // If no provider chain, return the first provider's value (if any)
    if (providerChain.isEmpty) {
      final providers = _contextValues[contextId]!;
      return providers.isNotEmpty ? providers.values.first : null;
    }

    // Try each provider in the chain from nearest to furthest
    for (final providerId in providerChain) {
      if (_contextValues[contextId]!.containsKey(providerId)) {
        return _contextValues[contextId]![providerId];
      }
    }

    // No matching provider found
    return null;
  }

  /// Clear all context values
  void clear() {
    _contextValues.clear();
  }
}
