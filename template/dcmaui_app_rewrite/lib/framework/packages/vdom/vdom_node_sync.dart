import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';

import '../native_bridge/native_bridge.dart';
import 'vdom.dart';
import 'vdom_node.dart';
import 'component_node.dart';
import 'vdom_element.dart';
import 'fragment.dart';

/// Class responsible for synchronizing the VDOM hierarchy between Dart and native
class VDomNodeSync {
  /// Reference to the VDom
  final VDom _vdom;

  /// Native bridge for communication
  final NativeBridge _nativeBridge;

  /// Flag to track if synchronization is in progress
  bool _isSyncInProgress = false;

  /// Map of node synchronization states
  final Map<String, _NodeSyncState> _nodeSyncStates = {};

  /// Create a VDomNodeSync instance
  VDomNodeSync(this._vdom, this._nativeBridge);

  /// Check if we need to sync based on current state and threshold
  bool needsSync(String nodeId) {
    if (_isSyncInProgress) return false;

    final state = _nodeSyncStates[nodeId];
    if (state == null) return true;

    // Check if sync is recent enough
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - state.lastSyncTime > 5000; // 5 seconds threshold
  }

  /// Mark a node as needing sync
  void markNeedSync(String nodeId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _nodeSyncStates[nodeId] = _NodeSyncState(
      nodeId: nodeId,
      lastSyncTime: now,
      lastOperationType: 'manual_mark',
      syncStatus: SyncStatus.needsSync,
    );
  }

  /// Synchronize the VDOM hierarchy with the native side
  Future<bool> synchronizeHierarchy({required String rootId}) async {
    if (_isSyncInProgress) {
      developer.log('⚠️ Sync already in progress', name: 'VDomNodeSync');
      return false;
    }

    _isSyncInProgress = true;
    try {
      developer.log('🔄 Starting node hierarchy sync', name: 'VDomNodeSync');

      // Find the root node
      VDomNode? rootNode;
      if (rootId == 'root' && _vdom.rootComponentNode != null) {
        rootNode = _vdom.rootComponentNode;
      } else {
        // Search for node by ID
        rootNode = _vdom.findNodeById(rootId);
      }

      if (rootNode == null) {
        developer.log('❌ Root node not found for sync: $rootId',
            name: 'VDomNodeSync');
        return false;
      }

      // Generate tree representation for sync
      final nodeTree = _generateNodeTree(rootNode);

      // Send to native for verification and repair
      final result = await _nativeBridge.syncNodeHierarchy(
        rootId: rootId,
        nodeTree: nodeTree,
      );

      final success = result['success'] == true;

      if (success) {
        developer.log(
            '✅ Sync successful - checked: ${result['nodesChecked']}, '
            'mismatched: ${result['nodesMismatched']}, repaired: ${result['nodesRepaired']}',
            name: 'VDomNodeSync');

        // Update sync states for all nodes in the tree
        _updateSyncStates(rootNode, SyncStatus.synced);
      } else {
        developer.log('❌ Sync failed: ${result['error']}',
            name: 'VDomNodeSync');
        _updateSyncStates(rootNode, SyncStatus.error);
      }

      return success;
    } catch (e, stack) {
      developer.log('❌ Exception during sync: $e',
          name: 'VDomNodeSync', error: e, stackTrace: stack);
      return false;
    } finally {
      _isSyncInProgress = false;
    }
  }

  /// Generate a tree representation of the current VDOM for a specific root node
  Map<String, dynamic> _generateNodeTree(VDomNode rootNode) {
    final result = <String, dynamic>{
      'id': rootNode.nativeViewId ?? 'unknown',
      'type': rootNode is ComponentNode
          ? 'ComponentNode'
          : rootNode.runtimeType.toString(),
      'children': <Map<String, dynamic>>[],
    };

    // Process children
    if (rootNode is VDomElement) {
      for (final child in rootNode.children) {
        final childTree = _generateNodeTree(child);
        (result['children'] as List<Map<String, dynamic>>).add(childTree);
      }
    } else if (rootNode is ComponentNode && rootNode.renderedNode != null) {
      final childTree = _generateNodeTree(rootNode.renderedNode!);
      (result['children'] as List<Map<String, dynamic>>).add(childTree);
    } else if (rootNode is Fragment) {
      for (final child in rootNode.children) {
        final childTree = _generateNodeTree(child);
        (result['children'] as List<Map<String, dynamic>>).add(childTree);
      }
    }

    return result;
  }

  /// Get details about the native node hierarchy for a specific node
  Future<Map<String, dynamic>> getNativeHierarchy(String nodeId) async {
    try {
      final result = await _nativeBridge.getNodeHierarchy(nodeId: nodeId);
      if (result['success'] == true) {
        return result['hierarchy'] as Map<String, dynamic>;
      } else {
        developer.log('❌ Failed to get native hierarchy: ${result['error']}',
            name: 'VDomNodeSync');
        return {'error': result['error']};
      }
    } catch (e) {
      developer.log('❌ Exception getting native hierarchy: $e',
          name: 'VDomNodeSync');
      return {'error': e.toString()};
    }
  }

  /// Update sync states recursively
  void _updateSyncStates(VDomNode node, SyncStatus status) {
    if (node.nativeViewId != null) {
      _nodeSyncStates[node.nativeViewId!] = _NodeSyncState(
        nodeId: node.nativeViewId!,
        lastSyncTime: DateTime.now().millisecondsSinceEpoch,
        lastOperationType: 'hierarchy_sync',
        syncStatus: status,
      );
    }

    // Update children based on node type
    List<VDomNode> children = [];
    if (node is VDomElement) {
      children = node.children;
    } else if (node is ComponentNode && node.renderedNode != null) {
      children = [node.renderedNode!];
    } else if (node is Fragment) {
      children = node.children;
    }

    for (final child in children) {
      _updateSyncStates(child, status);
    }
  }

  /// Log the current sync states (for debugging)
  void logSyncStates() {
    developer.log('📊 Current sync states:', name: 'VDomNodeSync');
    for (final entry in _nodeSyncStates.entries) {
      developer.log('  - ${entry.key}: ${entry.value.syncStatus}',
          name: 'VDomNodeSync');
    }
  }
}

/// Node synchronization state
class _NodeSyncState {
  /// Node ID
  final String nodeId;

  /// Last sync time in milliseconds
  final int lastSyncTime;

  /// Last operation type
  final String lastOperationType;

  /// Sync status
  final SyncStatus syncStatus;

  _NodeSyncState({
    required this.nodeId,
    required this.lastSyncTime,
    required this.lastOperationType,
    required this.syncStatus,
  });
}

/// Synchronization status enum
enum SyncStatus {
  /// Node needs synchronization
  needsSync,

  /// Node is synchronized
  synced,

  /// Error during synchronization
  error,

  /// Node is being synchronized
  inProgress,
}
