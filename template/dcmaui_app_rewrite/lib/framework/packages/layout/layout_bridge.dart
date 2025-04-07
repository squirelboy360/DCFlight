import 'dart:developer' as developer;

import '../native_bridge/native_bridge.dart';

/// Bridge to native layout functionality
/// This replaces the previous Yoga Dart implementation, delegating to native code
class LayoutBridge {
  /// Singleton instance
  static final LayoutBridge instance = LayoutBridge._();

  /// Reference to native bridge for communications
  late NativeBridge _nativeBridge;

  /// Flag to track if the bridge has been initialized
  bool _isInitialized = false;

  /// Map of node IDs to track nodes
  final Map<String, bool> _nodes = {};

  /// Private constructor for singleton
  LayoutBridge._();

  /// Initialize the layout bridge with native bridge instance
  void initialize(NativeBridge nativeBridge) {
    if (_isInitialized) return;

    _nativeBridge = nativeBridge;
    _isInitialized = true;

    developer.log('Layout bridge initialized', name: 'LayoutBridge');
  }

  /// Add a node to the native layout system
  void addNode(String nodeId, {String? parentId, int? index}) {
    // Track node locally
    _nodes[nodeId] = true;

    // The actual node creation is handled by the native bridge's createView method
    // And attachment is handled by attachView, so we don't need to do anything here

    developer.log('Layout node added: $nodeId', name: 'LayoutBridge');
  }

  /// Remove a node from the native layout system
  void removeNode(String nodeId) {
    // Remove from local tracking
    _nodes.remove(nodeId);

    // The actual node removal is handled by the native bridge's deleteView method

    developer.log('Layout node removed: $nodeId', name: 'LayoutBridge');
  }

  /// Update layout props for a node
  void updateNodeLayoutProps(String nodeId, Map<String, dynamic> props) {
    // The actual props are passed through the nativeBridge's updateView method
    // We just add some logging here

    developer.log('Layout props updated for node: $nodeId',
        name: 'LayoutBridge');
  }

  /// Calculate and apply layout to all nodes
  /// This triggers the native layout calculation and application
  Future<void> calculateAndApplyLayout(
      double width, double height, dynamic direction) async {
    // Since layout calculation happens natively, we just need to ensure
    // the props have been sent and potentially trigger a calculation

    developer.log('Layout calculation requested: ${width}x$height',
        name: 'LayoutBridge');

    // Nothing to do here - the native side handles layout calculation automatically
    // after we've updated props
  }

  /// Get the count of tracked nodes
  int get nodeCount => _nodes.length;
}
