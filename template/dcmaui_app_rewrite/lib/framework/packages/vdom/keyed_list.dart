import 'vdom_node.dart';

/// Utility class for handling keyed lists in reconciliation
class KeyedList<T extends VDomNode> {
  /// Map of nodes by key
  final Map<String?, T> _itemsByKey = {};

  /// List of keys in order
  final List<String?> _keys = [];

  /// Create a keyed list from a list of nodes
  KeyedList(List<T> items) {
    for (var item in items) {
      final key = item.key ?? _generateKeyForNode(item);
      _itemsByKey[key] = item;
      _keys.add(key);
    }
  }

  /// Generate a key for a node that doesn't have one
  String _generateKeyForNode(T node) {
    // Use object hash as fallback key
    return node.hashCode.toString();
  }

  /// Get node by key
  T? getItem(String? key) {
    return _itemsByKey[key];
  }

  /// Check if list contains key
  bool containsKey(String? key) {
    return _itemsByKey.containsKey(key);
  }

  /// Get index of a key
  int indexOf(String? key) {
    return _keys.indexOf(key);
  }

  /// Get number of items
  int get length => _keys.length;

  /// Get item at index
  T? getItemAt(int index) {
    if (index < 0 || index >= _keys.length) return null;
    final key = _keys[index];
    return _itemsByKey[key];
  }

  /// Get key at index
  String? keyAt(int index) {
    if (index < 0 || index >= _keys.length) return null;
    return _keys[index];
  }

  /// Get all keys in order
  List<String?> get keys => List.unmodifiable(_keys);

  /// Get all items in order
  List<T> get items {
    return _keys.map((key) => _itemsByKey[key]!).toList();
  }

  /// Compute a minimum set of operations to transform this list into another
  /// Returns a list of operations (move, insert, remove)
  List<ListOperation<T>> getOperationsToMatch(KeyedList<T> newList) {
    final operations = <ListOperation<T>>[];

    // First pass: mark all existing items as potentially removable
    final removableKeys = Set<String?>.from(_keys);

    // Second pass: process each item in the new list
    for (int i = 0; i < newList.length; i++) {
      final newKey = newList.keyAt(i);

      // Skip null keys (should not happen with our key generation)
      if (newKey == null) continue;

      final oldIndex = indexOf(newKey);

      if (oldIndex >= 0) {
        // Item exists in old list - may need to move
        removableKeys.remove(newKey);

        // Check if position changed
        if (oldIndex != i) {
          operations.add(MoveOperation(
              item: _itemsByKey[newKey]!, fromIndex: oldIndex, toIndex: i));
        } else {
          // Item stayed in place - no operation needed
        }
      } else {
        // Item doesn't exist in old list - need to insert
        operations
            .add(InsertOperation(item: newList.getItem(newKey)!, atIndex: i));
      }
    }

    // Final pass: add remove operations for items not in new list
    for (var key in removableKeys) {
      final index = indexOf(key);
      final item = getItem(key);
      if (item != null) {
        operations.add(RemoveOperation(item: item, fromIndex: index));
      }
    }

    return operations;
  }
}

/// Base class for list operations
abstract class ListOperation<T extends VDomNode> {
  final T item;

  ListOperation({required this.item});
}

/// Operation to insert an item
class InsertOperation<T extends VDomNode> extends ListOperation<T> {
  final int atIndex;

  InsertOperation({required super.item, required this.atIndex});
}

/// Operation to remove an item
class RemoveOperation<T extends VDomNode> extends ListOperation<T> {
  final int fromIndex;

  RemoveOperation({required super.item, required this.fromIndex});
}

/// Operation to move an item
class MoveOperation<T extends VDomNode> extends ListOperation<T> {
  final int fromIndex;
  final int toIndex;

  MoveOperation(
      {required super.item, required this.fromIndex, required this.toIndex});
}
