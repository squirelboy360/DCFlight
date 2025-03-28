
# DCNative (MAUI/Multi-platform App UI)
## 🚧 This CLI is Under Development

Its aim is to simplify cross-platform app development for personal future projects.

## ⚠️ Important Notice

If you want to test it, do not use the CLI as it currently does nothing. However, you can run the example to see how it works. The example serves as an experimental implementation and will eventually be broken down, optimized, and integrated into the complete CLI.

## 📌 Key Points

### 1️⃣ Flutter Engine Usage (Current branch uses C header file to communicates between native and dart, no more abstaction for UI rendering, the Vdom uses direct native communication for UI CRUD i short)

Developers might notice that the framework is built on Flutter—but in actuality, it is not.  
It is almost impossible to decouple the Dart VM from Flutter. To work around this:

- The framework is built parallel to Flutter Engine and not on top(This means we get Dart VM and the rest is handled by the native layer instead of Platform Views or any flutter abstraction while your usual flutter engine runs parallel idle untle(obviously the the dart runtime is not idle as its needed to start the the communication with native side and if flutter View is needed to be spawned for canvas rendering the flutter view definately is full active), but not as a Flutter framework.
- When abstracting the Flutter engine, I separate it into a dedicated package.
- The framework only exposes method channels and essential functions like `runApp()(no more needed)`.
- This allows communication with the Flutter engine in headless mode, letting the native side handle rendering.

### 2️⃣ Current Syntax Needs Improvement 🤦‍♂️

The current syntax is not great, but I will abstract over it later.

## 📝 Dart Example

```dart
import 'package:flutter/material.dart';
import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component.dart';
import 'framework/packages/performance/performance_monitor.dart';
import 'dart:developer' as developer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start performance monitoring
  PerformanceMonitor().startMonitoring();

  startNativeApp();
}

void startNativeApp() async {
  // Create VDOM instance
  final vdom = VDom();

  // Wait for the VDom to be ready
  await vdom.isReady;
  developer.log('VDom is ready', name: 'App');

  // Create a counter component with initial props
  final counterComponent = CounterComponent();

  // Create a component node with our component
  final counterNode = VDom.createComponent(counterComponent);

  // Render to the native UI
  final viewId =
      await vdom.renderToNative(counterNode, parentId: "root", index: 0);
  developer.log('Rendered counter component with ID: $viewId', name: 'App');

  developer.log('DCMAUI framework started in headless mode', name: 'App');

  // Artificially generate some load to demonstrate dual-thread benefits
  _runPerformanceDemo();
}

// Create artificial load to demonstrate the dual-thread architecture benefits
void _runPerformanceDemo() {
  Future.delayed(Duration(seconds: 5), () {
    developer.log('Starting performance demonstration...', name: 'PerfDemo');

    // Simulate heavy UI operations in the background
    _simulateHeavyUIWork();

    // Simultaneously handle events to show non-blocking behavior
    _simulateEventHandling();

    developer.log('Performance demonstration started', name: 'PerfDemo');
  });
}

// Simulate heavy UI operations (would run on FFI thread)
void _simulateHeavyUIWork() {
  for (int i = 0; i < 10; i++) {
    Future.delayed(Duration(seconds: i * 2), () {
      final perf = PerformanceMonitor();

      // Time a heavy UI operation
      perf.startTimer('complex_layout_update_$i');

      // Simulate complex layout work
      final result = _performHeavyCalculation();

      perf.endTimer('complex_layout_update_$i');

      developer.log('Completed heavy UI work batch $i: $result',
          name: 'PerfDemo');
    });
  }
}

// Simulate event handling (would run on method channel thread)
void _simulateEventHandling() {
  for (int i = 0; i < 20; i++) {
    Future.delayed(Duration(milliseconds: i * 750), () {
      final perf = PerformanceMonitor();

      // Time an event operation
      perf.startTimer('button_press_event_$i');

      // Simulate event handling logic
      final eventResult = _handleSimulatedEvent(i);

      perf.endTimer('button_press_event_$i', category: 'event');

      developer.log('Processed event $i: $eventResult', name: 'PerfDemo');
    });
  }
}

// Perform a computationally intensive task to simulate UI work
int _performHeavyCalculation() {
  int result = 0;
  // Simulate a complex calculation that would block the thread
  for (int i = 0; i < 5000000; i++) {
    result += i % 17;
  }
  return result;
}

// Handle a simulated event
String _handleSimulatedEvent(int eventId) {
  // Simulate event processing logic
  String result = 'Event-$eventId';

  // Add some work to make it measurable
  for (int i = 0; i < 1000000; i++) {
    if (i % 10000 == 0) {
      result += '.';
    }
  }

  return result;
}

// A stateful counter component using the simpler hook-based API
class CounterComponent extends StatefulComponent {
  @override
  VDomNode render() {
    // Use the hook-based API from component.dart directly
    final counter = useState(0, 'count');

    developer.log("Rendering with count=${counter.value}",
        name: 'CounterComponent');

    // Create a container view with more explicit styling
    return VDom.createElement('View', props: {
      'backgroundColor': '#372FB8', // Strong blue background
      'padding': 20,
      'width': 400.0, // Explicit width
      'height': 800.0, // Explicit height
    }, children: [
      // Spacer
      VDom.createElement('View', props: {
        'height': 50,
      }),

      // Title text with proper spacing
      VDom.createElement('Text', props: {
        'content': "App Counter",
        'fontSize': 24,
        'fontWeight': 'bold',
        'color': '#000000',
        'textAlign': 'center',
      }),

      // Spacer
      VDom.createElement('View', props: {
        'height': 50,
      }),

      // Counter text with better styling - should update with state
      VDom.createElement('Text', props: {
        'content': 'Count: ${counter.value}',
        'fontSize': 36,
        'color': '#000000',
        'textAlign': 'center',
        'testId': 'counter-text',
      }),

      // Spacer
      VDom.createElement('View', props: {
        'height': 40,
      }),

      // Button with better interactivity and styling
      VDom.createElement('Button', props: {
        'title': 'Tap to Increment',
        'backgroundColor': '#4CAF50', // Keep green color
        'color': '#FFFFFF',
        'disabled': false,
        'fontSize': 18.0,
        'padding': 12.0,
        'margin': 12.0,
        'width': 200.0, // Explicit width
        'height': 50.0, // Explicit height
        'onPress': (eventData) {
          // With hooks, we can simply call setValue with the new value
          counter.setValue(counter.value + 1);
          developer.log('Button pressed, new count: ${counter.value}',
              name: 'CounterComponent');
        },
      }),

      VDom.createElement('View', props: {
        'height': 50,
        'backgroundColor': '#FFFFFF',
      }),

      VDom.createElement('Button', props: {
        'title': 'Tap to Decrement',
        'backgroundColor': '#9600ff',
        'color': '#FFFFFF',
        'disabled': false,
        'fontSize': 18.0,
        'padding': 12.0,
        'margin': 12.0,
        'width': 200.0, // Explicit width
        'height': 50.0, // Explicit height
        'onPress': (eventData) {
          // Just a one-liner with the hook API
          counter.setValue(counter.value - 1);
          developer.log('Decremented counter to ${counter.value}',
              name: 'CounterComponent');
        },
      }),
    ]);
  }
}
```


### 3️⃣ Initially Inspired by .NET MAUI and React

The architecture is loosely inspired by .NET MAUI, Flutter and React, but instead of .NET, Flutter serves as the toolset. The syntax has been made flutter-like for familiarity and has borrowed concepts like state hooks and vdom-like architecture.

### 4️⃣ Hot Reload/Restart Issues ⚡

- Hot Reload does not work ❌.
- Hot Restart works but duplicates the native UIs or stacks them on top of each other, which is annoying. 😕

---

This project is still in early development, and many improvements will be made along the way.  
Contributions, suggestions, and feedback are always welcome! 🚀
