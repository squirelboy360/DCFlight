import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import '../native_bridge/native_bridge.dart';
import 'vdom.dart';
import 'vdom_node.dart';
import 'vdom_element.dart';

/// Class responsible for synchronizing node hierarchies between Dart and native
class VDomNodeSync {
  /// Reference to the VDOM
  final VDom vdom;

  /// Native bridge for UI operations
  final NativeBridge _nativeBridge;

  /// Last synchronization results
  Map<String, dynamic>? _lastSyncResults;

  /// Constructor
  VDomNodeSync(this.vdom, this._nativeBridge);

  /// Synchronize the node hierarchy between Dart and native
  Future<bool> synchronizeHierarchy({required String rootId}) async {
    developer.log('Synchronizing node hierarchy from root: $rootId',
        name: 'NodeSync');

    try {
      // Get the Dart-side hierarchy representation
      final hierarchy = _buildNodeTree(vdom.findNodeById(rootId));

      if (hierarchy.isEmpty) {
        developer.log('Failed to build node tree for root: $rootId',
            name: 'NodeSync');
        return false;
      }

      // Get the native-side hierarchy and compare
      final result = await _nativeBridge.syncNodeHierarchy(
          rootId: rootId,
          nodeTree: jsonEncode(hierarchy)); // Fixed parameter name

      // Store last results
      _lastSyncResults = result;

      if (result['success'] == true) {
        developer.log(
            'Hierarchy synchronization successful: Checked ${result['nodesChecked']} nodes, fixed ${result['nodesRepaired']} issues',
            name: 'NodeSync');
        return true;
      } else {
        developer.log('Hierarchy synchronization failed: ${result['error']}',
            name: 'NodeSync');
        return false;
      }
    } catch (e) {
      developer.log('Error during hierarchy synchronization: $e',
          name: 'NodeSync', error: e);
      return false;
    }
  }

  /// Get the native node hierarchy
  Future<Map<String, dynamic>> getNativeHierarchy(String nodeId) async {
    try {
      final result = await _nativeBridge.getNodeHierarchy(nodeId: nodeId);
      return result;
    } catch (e) {
      developer.log('Error getting native hierarchy: $e',
          name: 'NodeSync', error: e);
      return {'error': e.toString()};
    }
  }

  /// Build a tree representation of the node hierarchy
  Map<String, dynamic> _buildNodeTree(VDomNode? node) {
    if (node == null) {
      return {};
    }

    // Get basic node info
    final nodeId = node.nativeViewId;
    if (nodeId == null) {
      return {};
    }

    // Build children array
    final children = <Map<String, dynamic>>[];

    if (node is VDomElement) {
      for (var child in node.children) {
        final childTree = _buildNodeTree(child);
        if (childTree.isNotEmpty) {
          children.add(childTree);
        }
      }
    }

    // Return node representation
    return {
      'id': nodeId,
      'type': _getNodeType(node),
      'children': children,
    };
  }

  /// Get node type string
  String _getNodeType(VDomNode node) {
    if (node is VDomElement) {
      return node.type;
    } else {
      return node.runtimeType.toString();
    }
  }

  /// Get last sync results
  Map<String, dynamic>? get lastSyncResults => _lastSyncResults;
}
