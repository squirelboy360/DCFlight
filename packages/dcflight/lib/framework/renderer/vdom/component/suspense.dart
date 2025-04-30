import 'dart:async';

import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';


import 'component.dart';


/// Resource for loading async data with suspense
class Resource<T> {
  /// The async data
  T? _data;

  /// Error if any
  Object? _error;

  /// Whether the resource is loading
  bool _isLoading = false;

  /// Completer for pending promise
  Completer<T>? _pendingPromise;

  /// Create a resource
  Resource();

  /// Load data from a future
  T read(Future<T> Function() fetcher) {
    // If we already have data, return it
    if (_data != null) {
      return _data as T;
    }

    // If we have an error, throw it
    if (_error != null) {
      throw _error!;
    }

    // If we're not loading, start loading
    if (!_isLoading) {
      _isLoading = true;
      _pendingPromise = Completer<T>();

      fetcher().then((data) {
        _data = data;
        _isLoading = false;
        _pendingPromise?.complete(data);
        _pendingPromise = null;
      }).catchError((error) {
        _error = error;
        _isLoading = false;
        _pendingPromise?.completeError(error);
        _pendingPromise = null;
      });
    }

    // Throw the promise to suspend
    throw _pendingPromise!.future;
  }

  /// Reset the resource to force refetch
  void reset() {
    _data = null;
    _error = null;
    _isLoading = false;
    _pendingPromise = null;
  }
}

/// Suspense component that shows fallback while children are loading
class Suspense extends StatefulComponent {
  /// Fallback UI to show while loading
  final VDomNode fallback;

  /// Children that may suspend
  final List<VDomNode> children;

  /// Whether we're currently suspended
  final bool _isSuspended = false;

  Suspense({required this.fallback, required this.children, super.key});

  @override
  void componentDidMount() {
    super.componentDidMount();

    // Set up error handler for catching suspense promises
    useEffect(() {
      // This will be implemented in the reconciler
      return () {};
    });
  }

  @override
  VDomNode render() {
    return VDomElement(
      type: 'Suspense',
      props: {
        'isSuspended': _isSuspended,
      },
      children: _isSuspended ? [fallback] : children,
    );
  }
}
