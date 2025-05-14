
import 'dart:developer' as developer;
import 'package:dcflight/framework/renderer/native_bridge/dispatcher_imp.dart';

import 'vdom_node.dart';
import 'hooks.dart';

/// Represents an element in the Virtual DOM tree
class VDomElement extends VDomNode {
  /// Type of the element (e.g., 'View', 'Text', 'Button')
  final String type;

  /// Properties of the element
  Map<String, dynamic>
      props; // MODIFIED: Removed 'final' to allow property updates

  /// Child nodes
  final List<VDomNode> children;

  // FIXED: Changed from final to private Map that can be modified
  // Event handlers map
  Map<String, dynamic>? _events;

  /// Current hook index during rendering
  int _hookIndex = 0;

  /// List of hooks for this element
  final List<Hook> _hooks = [];

  /// Whether this element is mounted
  bool _isMounted = false;

  /// Function to schedule updates when state changes
  Function() scheduleUpdate = () {};

  /// Unique ID for this component instance
  final String instanceId;

  // Add getter for events
  // ignore: unnecessary_getters_setters
  Map<String, dynamic>? get events => _events;

  // setter for events
  set events(Map<String, dynamic>? value) {
    _events = value;
  }

  /// Get whether the component is mounted
  bool get isMounted => _isMounted;

  VDomElement({
    required this.type,
    super.key,
    required this.props,
    this.children = const [],
    Map<String, dynamic>? events,
  }) : 
    _events = events, 
    instanceId = DateTime.now().millisecondsSinceEpoch.toString() + (0.5 + DateTime.now().microsecond / 1000000).toString() {
    
    // Set parent reference for children
    for (var child in children) {
      child.parent = this;
    }

    // Automatically extract onX props into events
    if (props.isNotEmpty) {
      _extractEventHandlersFromProps();
    }
  }

  /// Extract event handlers from props - any prop starting with "on" is an event
  void _extractEventHandlersFromProps() {
    final extractedEvents = <String, dynamic>{};

    // Get all keys starting with "on"
    final eventKeys =
        props.keys.where((key) => key.startsWith('on') && key.length > 2);

    for (final key in eventKeys) {
      final handler = props[key];
      if (handler is Function) {
        // Convert onEvent to 'event' format for native bridge
        final eventName = key.substring(2, 3).toLowerCase() + key.substring(3);
        extractedEvents[eventName] = handler;
      }
    }

    // Set the extracted events if any were found
    if (extractedEvents.isNotEmpty) {
      if (_events == null) {
        _events = extractedEvents;
      } else {
        _events!.addAll(extractedEvents);
      }
    }
  }

  @override
  VDomNode clone() {
    return VDomElement(
      type: type,
      key: key,
      props: Map<String, dynamic>.from(props),
      children: children.map((child) => child.clone()).toList(),
      events: events != null ? Map<String, dynamic>.from(events!) : null,
    );
  }

  @override
  bool equals(VDomNode other) {
    if (other is! VDomElement) return false;
    if (type != other.type) return false;
    if (key != other.key) return false;

    return true;
  }

  @override
  String toString() {
    return 'VDomElement(type: $type, key: $key, props: ${props.length}, children: ${children.length})';
  }

  /// Get all descendant nodes flattened into a list
  List<VDomNode> getDescendants() {
    final result = <VDomNode>[];

    for (var child in children) {
      result.add(child);
      if (child is VDomElement) {
        result.addAll(child.getDescendants());
      }
    }

    return result;
  }

  /// Get child at index, returns EmptyVDomNode if out of bounds
  VDomNode childAt(int index) {
    if (index < 0 || index >= children.length) {
      return EmptyVDomNode();
    }
    return children[index];
  }

  @override
  void mount(VDomNode? parent) {
    // Call mount on children
    for (final child in children) {
      child.mount(this);
    }
  }

  /// Get list of event types from events map
  List<String> get eventTypes {
    List<String> types = [];

    // Add explicit events from events map
    if (events != null) {
      types.addAll(events!.keys);
    }

    // Also check props for event handlers (onX pattern)
    props.forEach((key, value) {
      if (key.startsWith('on') && value is Function) {
        // Convert camelCase to lowercase (e.g. onPress -> press)
        final eventName = key[2].toLowerCase() + key.substring(3);
        if (!types.contains(eventName)) {
          types.add(eventName);
        }
      }
    });

    return types;
  }

  @override
  void unmount() {
    // Clean up hooks
    for (final hook in _hooks) {
      hook.dispose();
    }
    _hooks.clear();
    _isMounted = false;
    
    // Call unmount on children
    for (final child in children) {
      child.unmount();
    }
  }

  // Register events with the native bridge
  void registerEvents() {
    final types = eventTypes;
    if (types.isNotEmpty && nativeViewId != null) {
      // Register events with the native bridge
      PlatformDispatcherIml().addEventListeners(nativeViewId!, types);
    }
  }

  /// Reset hook state for next render
  void prepareForRender() {
    _hookIndex = 0;
  }

  /// Create a state hook
  StateHook<T> useState<T>(T initialValue, [String? name]) {
    return _createHook(() {
      return StateHook<T>(initialValue, name, () {
        // Schedule an update when state changes
        scheduleUpdate();
      });
    }) as StateHook<T>;
  }

  /// Create an effect hook
  void useEffect(Function()? Function() effect,
      {List<dynamic> dependencies = const []}) {
    _createHook(() => EffectHook(effect, dependencies));
    // Don't run effects here - they will be run after render
  }

  /// Create a memo hook
  T useMemo<T>(T Function() compute, {List<dynamic> dependencies = const []}) {
    final hook = _createHook(() => MemoHook<T>(compute, dependencies));
    return (hook as MemoHook<T>).value;
  }

  /// Create a ref hook
  RefObject<T> useRef<T>([T? initialValue]) {
    final hook = _createHook(() => RefHook<T>(initialValue));
    return (hook as RefHook<T>).current;
  }

  /// Helper to create/retrieve hooks
  Hook _createHook(Hook Function() createHook) {
    // Get or create the hook
    Hook hook;
    if (_hookIndex < _hooks.length) {
      // Reuse existing hook
      hook = _hooks[_hookIndex];
    } else {
      // Create new hook
      hook = createHook();
      _hooks.add(hook);
    }

    // Initialize the hook if needed
    hook.initIfNeeded();

    // Move to next hook
    _hookIndex++;

    return hook;
  }

  /// Run effects after render - called by VDom
  void runEffectsAfterRender() {
    for (var i = 0; i < _hooks.length; i++) {
      final hook = _hooks[i];
      if (hook is EffectHook) {
        // Run each effect hook
        developer.log('Running effect hook #$i in element of type $type',
            name: 'VDomElement');
        hook.runEffect();
      }
    }
  }
  
  /// Called when the element is mounted
  void didMount() {
    _isMounted = true;
  }
}
