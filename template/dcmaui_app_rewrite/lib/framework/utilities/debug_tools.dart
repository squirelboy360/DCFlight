import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../packages/native_bridge/dispatcher.dart';
import '../packages/vdom/vdom.dart';

/// Tools for debugging the VDOM
class VDomDebugTools {
  /// Reference to the VDOM
  final VDom vdom;

  /// Reference to the native bridge
  final PlatformDispatcher _nativeBridge;

  /// Constructor
  VDomDebugTools(this.vdom, this._nativeBridge) {
    developer.log('VDomDebugTools initialized', name: 'VDom');
  }

  /// Enable or disable visual debug mode
  Future<bool> setVisualDebugEnabled(bool enabled) async {
    return await _nativeBridge.setVisualDebugEnabled(enabled);
  }

  /// Get node hierarchy as JSON
  Future<Map<String, dynamic>> getNodeHierarchy(
      {required String nodeId}) async {
    return await vdom.getNativeNodeHierarchy(nodeId: nodeId);
  }

  /// Print the current performance metrics
  void logPerformanceMetrics() {
    final metrics = vdom.getPerformanceData();
    developer.log('Performance metrics: $metrics', name: 'VDom');
  }

  /// Validate the node hierarchy
  Future<bool> validateNodeHierarchy({String? rootId}) async {
    // Changed return type to bool
    return await vdom.synchronizeNodeHierarchy(rootId: rootId);
  }

  /// Find mismatches between Dart and native hierarchies
  Future<List<String>> findHierarchyMismatches() async {
    final mismatches = <String>[];

    // Check the root component
    if (vdom.rootComponentNode == null ||
        vdom.rootComponentNode?.nativeViewId == null) {
      mismatches.add('Root component is null or has no native view ID');
      return mismatches;
    }

    final rootId = vdom.rootComponentNode!.nativeViewId!;

    // Get native hierarchy - use the result without assigning to unused variable
    await getNodeHierarchy(nodeId: rootId);

    // Get validation results
    final isValid = await validateNodeHierarchy(rootId: rootId);

    if (!isValid) {
      mismatches.add('Validation failed - hierarchy mismatch detected');
    }

    return mismatches;
  }

  /// Debug logging helper
  void logDebugInfo(String message) {
    if (kDebugMode) {
      developer.log('🔍 DEBUG: $message', name: 'VDom');
    }
  }
}
