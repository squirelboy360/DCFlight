import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../packages/native_bridge/native_bridge.dart';
import 'vdom.dart';
import 'vdom_node.dart';
import 'component_node.dart';
import 'vdom_element.dart';
import 'fragment.dart';

/// Debugging tools for the Virtual DOM
class VDomDebugTools {
  /// The VDom instance to debug
  final VDom _vdom;

  /// The native bridge for communication
  final NativeBridge _nativeBridge;

  /// Whether debug visualization is enabled
  bool _debugVisualizationEnabled = false;

  /// Create a VDomDebugTools instance
  VDomDebugTools(this._vdom, this._nativeBridge) {
    developer.log('VDomDebugTools initialized', name: 'VDom');
  }

  /// Enable or disable debug visualization
  Future<void> setDebugVisualizationEnabled(bool enabled) async {
    _debugVisualizationEnabled = enabled;

    // Send command to native side
    await _nativeBridge
        .invokeMethod('setDebugVisualizationEnabled', {'enabled': enabled});

    developer.log('Debug visualization ${enabled ? 'enabled' : 'disabled'}',
        name: 'VDom');
  }

  /// Check if debug visualization is enabled
  bool get isDebugVisualizationEnabled => _debugVisualizationEnabled;

  /// Generate a tree representation of the current VDOM
  Map<String, dynamic> generateVDomTree() {
    final rootNode = _vdom.rootComponentNode;
    if (rootNode == null) {
      return {'error': 'Root node is null'};
    }

    return _generateNodeTree(rootNode);
  }

  /// Generate tree representation for a specific node
  Map<String, dynamic> _generateNodeTree(VDomNode rootNode) {
    final children = <Map<String, dynamic>>[];

    // Process each child based on node type
    if (rootNode is VDomElement) {
      // For VDomElement, use its children property
      for (final child in rootNode.children) {
        final childTree = _generateNodeTree(child);
        if (!childTree.containsKey('error')) {
          children.add(childTree);
        }
      }
    } else if (rootNode is ComponentNode && rootNode.renderedNode != null) {
      // For ComponentNode, use its renderedNode
      final childTree = _generateNodeTree(rootNode.renderedNode!);
      if (!childTree.containsKey('error')) {
        children.add(childTree);
      }
    } else if (rootNode is Fragment) {
      // For Fragment, process its children
      for (final child in rootNode.children) {
        final childTree = _generateNodeTree(child);
        if (!childTree.containsKey('error')) {
          children.add(childTree);
        }
      }
    }

    final result = <String, dynamic>{
      'id': rootNode.nativeViewId ?? 'unknown',
      'type': rootNode is ComponentNode
          ? 'ComponentNode'
          : rootNode.runtimeType.toString(),
      'children': children,
    };

    return result;
  }

  /// Compare VDOM and native trees to find inconsistencies
  Future<Map<String, dynamic>> compareVDomAndNativeTrees() async {
    // Generate VDOM tree
    final vdomTree = generateVDomTree();

    // Get native tree
    final nativeTree = await _vdom.getNativeNodeHierarchy(
        nodeId: _vdom.rootComponentNode?.nativeViewId ?? 'root');

    // Compare trees
    final mismatches = <String>{};
    _compareTreesRecursively(
        vdomTree, nativeTree as Map<String, dynamic>, mismatches);

    return {
      'matches': mismatches.isEmpty,
      'mismatches': mismatches.toList(),
      'vdomTree': vdomTree,
      'nativeTree': nativeTree,
    };
  }

  /// Recursively compare trees to find mismatches
  void _compareTreesRecursively(Map<String, dynamic> vdomNode,
      Map<String, dynamic> nativeNode, Set<String> mismatches) {
    // Compare node IDs
    final vdomId = vdomNode['id'] as String;
    final nativeId = nativeNode['id'] as String;

    if (vdomId != nativeId) {
      mismatches.add('Node ID mismatch: VDOM=$vdomId, Native=$nativeId');
    }

    // Compare children
    final vdomChildren = vdomNode['children'] as List<dynamic>;
    final nativeChildren = nativeNode['children'] as List<dynamic>;

    if (vdomChildren.length != nativeChildren.length) {
      mismatches.add(
          'Children count mismatch for $vdomId: VDOM=${vdomChildren.length}, Native=${nativeChildren.length}');
    }

    // Compare children recursively
    final minChildCount = vdomChildren.length < nativeChildren.length
        ? vdomChildren.length
        : nativeChildren.length;

    for (var i = 0; i < minChildCount; i++) {
      _compareTreesRecursively(vdomChildren[i] as Map<String, dynamic>,
          nativeChildren[i] as Map<String, dynamic>, mismatches);
    }
  }

  /// Take a layout snapshot for debugging
  Future<bool> takeLayoutSnapshot() async {
    try {
      await _nativeBridge.invokeMethod('takeLayoutSnapshot', {});
      return true;
    } catch (e) {
      developer.log('Failed to take layout snapshot: $e', name: 'VDom');
      return false;
    }
  }

  /// Generate a detailed layout report
  Future<String> generateLayoutReport() async {
    try {
      final result =
          await _nativeBridge.invokeMethod('generateLayoutReport', {});
      return result as String;
    } catch (e) {
      developer.log('Failed to generate layout report: $e', name: 'VDom');
      return 'Error generating layout report: $e';
    }
  }

  /// Sync node hierarchies with verbose logging
  Future<Map<String, dynamic>> syncNodeHierarchies(
      {bool verbose = false}) async {
    if (verbose) {
      developer.log('Starting verbose node hierarchy sync', name: 'VDomDebug');
    }

    // Generate VDOM tree
    final vdomTree = generateVDomTree();

    if (verbose) {
      developer.log('VDOM Tree: ${jsonEncode(vdomTree)}', name: 'VDomDebug');
    }

    // Sync with native
    final result = await _vdom.synchronizeNodeHierarchy(
        rootId: _vdom.rootComponentNode?.nativeViewId ?? 'root');

    if (verbose) {
      developer.log('Sync result: $result', name: 'VDomDebug');
    }

    // Get native tree after sync
    final nativeTree = await _vdom.getNativeNodeHierarchy(
        nodeId: _vdom.rootComponentNode?.nativeViewId ?? 'root');

    if (verbose) {
      developer.log('Native Tree after sync: ${jsonEncode(nativeTree)}',
          name: 'VDomDebug');
    }

    return {
      'success': result,
      'vdomTree': vdomTree,
      'nativeTree': nativeTree,
    };
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return _vdom.getPerformanceData();
  }
}
