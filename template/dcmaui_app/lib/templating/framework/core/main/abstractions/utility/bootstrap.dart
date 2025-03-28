import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/error_boundary.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// DC Framework bootstrap function - initializes the framework and renders the app
///
/// Example usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await dcBind(() => MyApp());
/// }
/// ```
Future<void> dcBind(
  Component Function() appComponentConstructor, {
  bool enablePerformanceTracking = kDebugMode,
  ErrorBoundaryProps? errorBoundaryProps,
  Map<String, dynamic>? appProps,
}) async {
  try {
    // Initialize native bridge
    await MainViewCoordinatorInterface.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to initialize DC Framework native bridge: $e');
    }
  }

  // Configure performance monitoring
  PerformanceMonitor.instance.trackingEnabled = enablePerformanceTracking;
  if (enablePerformanceTracking) {
    PerformanceMonitor.instance.takeMemorySnapshot('app_start');
    Component.showPerformanceWarnings = true;
    Component.enablePerformanceTracking(true);
  }

  // Create VDOM instance with optimization toggle
  final vdom = VDOM();

  // CRITICAL FIX: Ensure both ErrorBoundary and MainApp have proper keys
  final appPropsWithKey = appProps ?? {};
  if (!appPropsWithKey.containsKey('key')) {
    appPropsWithKey['key'] = 'root-app';
  }

  // CRITICAL FIX: Directly use app component for simpler rendering and debugging
  debugPrint(
      'Bootstrap: Creating app component with key ${appPropsWithKey["key"]}');

  // Create app component
  final rootComponent = ElementFactory.createComponent(
    appComponentConstructor,
    appPropsWithKey,
  );

  try {
    // CRITICAL FIX: Add more detailed debug information
    debugPrint('DC Bootstrap: Component tree before render:');
    debugPrint(rootComponent.toTreeString());

    // Render the app
    debugPrint('DC Bootstrap: Rendering root component');
    vdom.render(rootComponent);

    // Log debug information
    if (kDebugMode) {
      // CRITICAL FIX: Use instance method instead of static
      final coordinator = MainViewCoordinatorInterface();
      coordinator.logNativeViewTree();

      if (enablePerformanceTracking) {
        PerformanceMonitor.instance.takeMemorySnapshot('app_rendered');

        // Log initial performance report after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          final report = PerformanceMonitor.instance.getPerformanceReport();
          debugPrint('DC Framework Performance Report: $report');
        });
      }
    }
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERROR: Failed to render DC app: $e');
      print(stack);
    }
  }

  return Future.value();
}
