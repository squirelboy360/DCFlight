import 'package:dcflight/framework/utilities/flutter.dart';

import '../vdom_node.dart';
import 'state_hook.dart';

/// Base class for all components
abstract class Component {
  /// Unique instance ID for this component
  final String instanceId =
      '${DateTime.now().millisecondsSinceEpoch}_${++_lastId}';

  /// Type name for this component
  String get typeName => runtimeType.toString();

  /// Key for component identification (optional)
  final String? key;

  /// Static counter for generating unique IDs
  static int _lastId = 0;

  Component({this.key});

  /// Render the component
  UIComponent render();

  /// Called when component is mounted
  void componentDidMount() {}

  /// Called when component will be unmounted
  void componentWillUnmount() {}
}

/// Class for components with state
abstract class StatelessComponent extends Component {
  /// Hook for scheduling updates - can be set by parent
  void Function()? scheduleUpdate;

  /// Whether effect cleanup has been called
  bool _effectCleanupCalled = false;

  StatelessComponent({super.key});

  @override
  void componentDidMount() {}

  /// Called when component props are updated
  void componentDidUpdate(Map<String, dynamic> prevProps) {}

  @override
  void componentWillUnmount() {
    // Only call effect cleanup once
    if (!_effectCleanupCalled) {
      _effectCleanupCalled = true;

      // Run effect cleanups for this component
      runEffectCleanups(instanceId);
    }
  }

  /// Prepare for rendering - reset hook state
  void prepareForRender() {
    print("🏁 Preparing component for render: $instanceId");
    prepareComponentForHooks(this);
  }

  /// Run effects after render
  void runEffectsAfterRender() {
    debugPrint("🏁 Running effects after render for component: $instanceId");

    // CRITICAL FIX: Use Future.microtask to ensure effects run after render is complete
    Future.microtask(() {
      runEffects(instanceId);
      cleanupAfterRender();
    });
  }

  @override
  UIComponent render() {
    return build();
  }
@override
  /// Build method to be implemented by subclasses
  // ignore: override_on_non_overriding_member
  UIComponent build();
}

