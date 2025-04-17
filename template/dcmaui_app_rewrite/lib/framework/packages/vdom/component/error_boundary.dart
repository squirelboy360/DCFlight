import 'dart:developer' as developer;

import 'package:dc_test/framework/packages/vdom/component/state_hook.dart';

import '../vdom_node.dart';
import 'component.dart';

/// Component that catches errors in its subtree
abstract class ErrorBoundary extends StatefulComponent {
  ErrorBoundary({super.key});

  /// Current error state
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  /// Handle error in child component
  void handleError(Object error, StackTrace stackTrace) {
    _error = error;
    _stackTrace = stackTrace;
    _hasError = true;

    // Log the error
    developer.log('Error caught by ErrorBoundary: $error',
        name: 'ErrorBoundary', error: error, stackTrace: stackTrace);

    // Define a state hook to trigger a rerender
    final forceUpdate = useState<bool>(false);
    forceUpdate.setValue(!forceUpdate.value);
  }

  /// Reset error state
  void resetError() {
    _error = null;
    _stackTrace = null;
    _hasError = false;

    // Define a state hook to trigger a rerender
    final forceUpdate = useState<bool>(false);
    forceUpdate.setValue(!forceUpdate.value);
  }

  /// Get whether there's an error
  bool get hasError => _hasError;

  /// Get current error
  Object? get error => _error;

  /// Get error stack trace
  StackTrace? get stackTrace => _stackTrace;

  /// Render fallback UI when error occurs
  VDomNode renderFallback(Object error, StackTrace? stackTrace);

  @override
  VDomNode render() {
    // Add a state hook just for triggering rerenders from error handling
    final _ = useState<bool>(false);

    if (_hasError) {
      return renderFallback(_error!, _stackTrace);
    }

    return renderContent();
  }

  /// Render content when no error
  VDomNode renderContent();
}
