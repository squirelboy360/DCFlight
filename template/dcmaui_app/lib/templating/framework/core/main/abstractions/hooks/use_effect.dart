import 'package:flutter/foundation.dart';

/// Manages side effects in a component, similar to React's useEffect
class UseEffect {
  Function? _cleanup;
  List<dynamic>? _dependencies;
  final String _effectName;

  /// Create an effect hook
  ///
  /// Example usage:
  /// ```dart
  /// final effect = UseEffect('timerEffect');
  ///
  /// // Run an effect with cleanup
  /// effect.run(() {
  ///   final timer = Timer.periodic(Duration(seconds: 1), (_) => print('tick'));
  ///   return () => timer.cancel();
  /// }, [someValue]);
  /// ```
  UseEffect(String name) : _effectName = name;

  /// Run an effect with optional dependencies
  /// Returns a cleanup function that should be called when the component unmounts
  void run(Function() effect, [List<dynamic>? dependencies]) {
    // Check if dependencies have changed
    bool shouldRun = _dependencies == null;
    if (!shouldRun && dependencies != null) {
      shouldRun = !_areListsEqual(_dependencies!, dependencies);
    }

    // Update dependencies
    _dependencies = dependencies;

    if (shouldRun) {
      if (kDebugMode) {
        print('UseEffect: Running effect $_effectName');
      }

      // Call cleanup from last effect
      if (_cleanup != null) {
        try {
          _cleanup!();
        } catch (e) {
          if (kDebugMode) {
            print('UseEffect: Error in cleanup: $e');
          }
        }
      }

      // Run the effect and store its cleanup
      try {
        _cleanup = effect();
      } catch (e) {
        if (kDebugMode) {
          print('UseEffect: Error in effect: $e');
        }
      }
    }
  }

  /// Clean up the effect
  void dispose() {
    if (_cleanup != null) {
      try {
        _cleanup!();
        _cleanup = null;
      } catch (e) {
        if (kDebugMode) {
          print('UseEffect: Error in final cleanup: $e');
        }
      }
    }
  }

  // Helper to compare dependency lists
  bool _areListsEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
