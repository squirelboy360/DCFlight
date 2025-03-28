# DC Framework - Flutter VDOM UI Framework

## Overview
DC Framework is a Virtual DOM-based UI framework for Flutter, inspired by React's component model. It provides a declarative way to build UIs with efficient rendering, state management, and component lifecycle hooks.

## Core Features
- Virtual DOM implementation for efficient UI updates
- Component-based architecture with lifecycle methods
- Hooks system for functional components
- State management with global state and memoization
- Error boundaries for error handling
- Performance optimization for large lists and nested components

## Directory Structure

### Core Module
- **`core/`**: Core framework functionality
  - **`component.dart`**: Base Component class with lifecycle methods
  - **`pure_component.dart`**: PureComponent with shallow comparison optimization
  - **`error_boundary.dart`**: Error boundary implementation for exception handling
  - **`bootstrap.dart`**: Framework initialization and app mounting
  - **`vdom/`**: Virtual DOM implementation
    - **`node.dart`**: Virtual DOM node definition
    - **`vdom.dart`**: Base VDOM implementation
    - **`optimized_vdom.dart`**: Performance-optimized VDOM for large lists
    - **`element_factory.dart`**: Factory methods for creating VDOM elements
    - **`component_vdom.dart`**: Component-aware VDOM implementation
    - **`extensions/`**: VDOM extensions
      - **`native_method_channels+vdom.dart`**: Native bridge for VDOM

### Hooks System
- **`hooks/`**: React-like hooks implementation
  - **`use_state.dart`**: State hook for functional components
  - **`use_effect.dart`**: Side effect hook for handling effects
  - **`use_memo.dart`**: Memoization hook for performance optimization
  - **`use_callback.dart`**: Callback memoization hook
  - **`use_reducer.dart`**: Reducer state pattern hook
  - **`index.dart`**: Hook exports

### UI Components
- **`controls/`**: UI controls and components
  - **`low_levels/`**: Base control abstractions
    - **`control.dart`**: Base control class
    - **`component_adapter.dart`**: Adapter for component controls
  - **`view.dart`**: Container component
  - **`text.dart`**: Text component
  - **`button.dart`**: Button component
  - **`image.dart`**: Image component
  - **`checkbox.dart`**: Checkbox component
  - **`switch.dart`**: Switch component
  - **`touchable.dart`**: Touchable component
  - **`list_view.dart`**: List view component
  - **`optimized_list.dart`**: Performance-optimized list component

### Utilities
- **`utility/`**: Utility functions and services
  - **`state_abstraction.dart`**: Global state management
  - **`performance_monitor.dart`**: Performance monitoring and metrics
  - **`event_bus.dart`**: Event bus for cross-component communication
  - **`flutter.dart`**: Flutter integration helpers

## Key Files and Their Purpose

### Core Framework
- **`component.dart`**: Defines the base Component class with lifecycle methods like componentDidMount, componentDidUpdate, etc.
- **`pure_component.dart`**: Optimizes rendering by implementing shouldComponentUpdate with shallow comparison.
- **`bootstrap.dart`**: Provides the dcBind function to initialize and mount the app.

### VDOM Implementation
- **`node.dart`**: Defines VNode, the basic building block of the virtual DOM.
- **`vdom.dart`**: Implements the core reconciliation algorithm.
- **`optimized_vdom.dart`**: Extends VDOM with optimizations for large lists and trees.
- **`element_factory.dart`**: Factory for creating virtual DOM elements and components.

### State Management
- **`state_abstraction.dart`**: Global state manager with memoization and dependency tracking.
- **`hooks/*.dart`**: React-style hooks for functional component state and effects.

### UI Components
- **`control.dart`**: Base class for all UI controls.
- **`view.dart`, `text.dart`, etc.**: Specific UI components that map to native views.
- **`optimized_list.dart`**: High-performance list component with windowing.

### Error Handling
- **`error_boundary.dart`**: Catches errors in components and displays fallback UI.

### Performance
- **`performance_monitor.dart`**: Tracks and logs performance metrics.

## Usage

### Basic App Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dcBind(
    () => MyApp(),
    enableOptimizations: true,
    enablePerformanceTracking: true,
  );
}
```

### Using Hooks

```dart

// Create a counter component with hooks
final countState = UseState<int>('counter', 0);
final doubleCount = UseMemo<int>(
  'doubleCount',
  () => countState.value * 2,
  ['counter'],
);

DCButton(
  title: "Increment",
  onPress: (_) => countState.value += 1,
);
DCText('Double: ${doubleCount.value}');
```


### Error Handling

```dart

ErrorBoundary(
  ErrorBoundaryProps(
    fallback: (error, reset) => DCView(
      children: [
        DCText('Something went wrong!'),
        DCButton(
          title: 'Try Again',
          onPress: (_) => reset(),
        ),
      ],
    ),
  ),
  [MyComponent()],
);
```













































































































































































































































































































































































































































































The DC Framework is licensed under the MIT License.## LicenseBefore submitting code, please ensure it follows our style guide and passes all tests.   - Update documentation as needed   - Include tests for new functionality   - Follow the existing code style4. **Code Contributions**: Submit pull requests with improvements3. **Documentation**: Improve or extend documentation2. **Feature Requests**: Suggest new features1. **Bug Reports**: File detailed bug reportsWe welcome contributions to the DC Framework. Here's how you can help:## Contributing to the Framework```);  errorText: form.errors['username'],  onChangeText: (text) => form.setValue('username', text),  value: form.values['username'],DCTextField(});  'password': '',  'username': '',final form = UseForm<Map<String, dynamic>>('loginForm', {// Using the custom hook}  }    _errors.value = newErrors;    newErrors[field] = error;    final newErrors = Map<String, String>.from(_errors.value);  void setError(String field, String error) {    }    _formState.value = newState as T;    newState[field] = value;    final newState = Map<String, dynamic>.from(_formState.value as Map);  void setValue(String field, dynamic value) {    Map<String, String> get errors => _errors.value;  T get values => _formState.value;      _errors = UseState<Map<String, String>>('${key}_errors', {});    _formState = UseState<T>(key, initialValues),  UseForm(String key, T initialValues) :     final UseState<Map<String, String>> _errors;  final UseState<T> _formState;class UseForm<T> {// Custom hook for form handling```dart### Creating Custom Hooks```}  }();    }      return ElementFactory.createComponent(() => component, component.props);      component.props['setLoading'] = setLoading;      final component = WrappedComponent();            }        ).build();          children: [DCText('Loading...')],        return DCView(      if (loading) {            final loading = state['loading'] as bool;    VNode buildRender() {    @override    }      setState({'loading': value});    void setLoading(bool value) {    }      return {'loading': false};    Map<String, dynamic> getInitialState() {    @override  return () => class extends Component {Component withLoading(Component Function() WrappedComponent) {// HOC that adds loading state to a component```dartCreate reusable component logic:### Higher-Order Components```final theme = GlobalStateManager.instance.getState<String>('theme', 'current', 'light');// In any child component, consume the context}  }    );      { /* props */ },      () => childComponent,    return ElementFactory.createComponent(  VNode buildRender() {  @override  }    GlobalStateManager.instance.setState('theme', 'current', 'dark');  void componentDidMount() {  @overrideclass ThemeProvider extends Component {// Create a context provider component```dartUnlike React's Context API, DC Framework provides a simpler approach:### Context API## Advanced Usage| `getInitialState()` (legacy) | `getInitialState()` || `React.memo` | `UseMemo` + `PureComponent` || Context API | `GlobalStateManager` || `<button>` | `DCButton()` || `<span>` | `DCText()` || `<div>` | `DCView()` || `React.createElement` | `ElementFactory.createElement` || `ErrorBoundary` | `ErrorBoundary` || `React.PureComponent` | `PureComponent` || `React.Component` | `Component` || `useReducer()` | `UseReducer('key', initialState, reducer)` || `useCallback()` | `UseCallback('key', callback, [deps])` || `useMemo()` | `UseMemo('key', () => {}, [deps])` || `useEffect()` | `UseEffect('key').run(() => {}, [deps])` || `useState()` | `UseState('key', initialValue)` || `render()` | `buildRender()` ||-------|-------------|| React | DC Framework |For developers familiar with React, here's a comparison between React concepts and their DC Framework equivalents:## React Comparison Guide```print(report);final report = PerformanceMonitor.instance.getPerformanceReport();// Get performance reportPerformanceMonitor.instance.takeMemorySnapshot('after-operation');// ... perform operationPerformanceMonitor.instance.takeMemorySnapshot('before-operation');// Take memory snapshots```dart### Performance Profiling```print(node.toTreeString());final node = component.render();// Print a component's VDOM tree```dartInspect the VDOM tree during debugging:### Virtual DOM Inspection```)  ],    RiskyComponent(),    // Child components that might throw errors  [  ),    },      errorLoggingService.logError(error, stack);      // Log error to external service    onError: (error, stack) {  ErrorBoundaryProps(ErrorBoundary(```dartError boundaries catch errors in child components without crashing the entire app:### Error Boundaries```PerformanceMonitor.instance.collectDetailedMetrics = true;PerformanceMonitor.instance.enableLogging = true;// Enable detailed loggingComponent.enablePerformanceTracking(true);Component.showPerformanceWarnings = true;// Enable performance warnings```dart### Enabling Debug Mode## Debugging```print('Slow renders: ${report['renders']['slowCount']}');final report = PerformanceMonitor.instance.getPerformanceReport();// Monitor global performanceprint('Render time: ${metrics['render']?['averageTime']}ms');final metrics = component.getPerformanceMetrics();// Get performance metrics```dart9. Use the performance monitor to identify slow renders8. Avoid anonymous functions in render to prevent unnecessary re-renders7. Use keys for list items to help with reconciliation6. Batch state updates with component.batchUpdates()5. Keep component trees shallow where possible4. Use the OptimizedList for large data sets3. Use memoization (UseMemo) for expensive calculations2. Implement shouldComponentUpdate for custom update logic1. Use PureComponent for components that don't need to update frequently## Performance Tips```);  [value], // Only recreate when value changes  () => doSomething(value),  'handleClick',final handleClick = UseCallback<Function>(// Memoize callbacks to prevent unnecessary renders of child components);  [items, searchTerm], // Dependencies  },      .toList();      .where((item) => item.contains(searchTerm))    return items    // This will only run when dependencies change  () {  'filteredItems',final expensiveValue = UseMemo<List<String>>(```dartUse memoization to avoid expensive recalculations:### Memoization Hooks```),  ),    windowSize: 20, // Only render 20 items at a time    renderItem: (item, _) => ItemRow(item),    keyExtractor: (item, _) => item.id,    items: items,  props: DCOptimizedListProps(DCOptimizedList<Item>(```dart### OptimizedList for Large Data Sets```}  // Only updates if props or state actually changed  // PureComponent implements shouldComponentUpdate with shallow comparisonclass MyPureComponent extends PureComponent {```dartFor components that don't need to update frequently, extend PureComponent instead of Component:### PureComponent## Performance Optimization```}, [userId]); // Re-run when userId changes  return () => subscription.cancel();  // Return cleanup function    final subscription = api.fetchData().listen(handleData);  // Fetch dataeffect.run(() {final effect = UseEffect('dataFetcher');// Run effects after render with optional cleanup```dartFor functional components using hooks:### Hooks Lifecycle```}  return nextState['count'] != state['count'];  // Only update if count changedbool shouldComponentUpdate(Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {@override}  subscription.cancel();  // Clean up resourcesvoid componentWillUnmount() {@override}  }    fetchUserData(state['userId']);    // User ID changed, fetch new user data  if (state['userId'] != prevState['userId']) {void componentDidUpdate(Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {@override}  fetchData();  // Fetch data, set up subscriptionsvoid componentDidMount() {@override```dartExample usage:9. **componentDidCatch(error, stack)** - Handle errors in component tree8. **componentWillUnmount()** - Clean up before component is destroyed7. **componentDidUpdate(prevProps, prevState)** - Called after updates are applied to the DOM6. **shouldComponentUpdate(nextProps, nextState)** - Decide if component should re-render5. **componentDidMount()** - Called after first render, ideal for side effects4. **buildRender()** - Create the virtual DOM (equivalent to React's render)3. **componentWillMount()** - Called just before rendering (replacement for deprecated React method)2. **getInitialState()** - Define initial state (similar to React's constructor state initialization)1. **Constructor** - Component initializationThe DC Framework follows a React-like component lifecycle:### Component Lifecycle## Lifecycle Methods```);  onPress: (_) => counterReducer.dispatch(CounterAction.increment),  title: 'Increment',DCButton(// Dispatch actions to update state);  }    }      case CounterAction.reset: return 0;      case CounterAction.decrement: return state - 1;      case CounterAction.increment: return state + 1;    switch (action) {  (state, action) {  0,  'counterWithReducer',final counterReducer = UseReducer<int, CounterAction>(enum CounterAction { increment, decrement, reset }// useReducer hook for complex state logic);  onPress: (_) => counter.value++,  title: 'Increment',DCButton(DCText('Count: ${counter.value}');final counter = UseState<int>('counter', 0); // useState hook```dartFor more React-like state management:### State Hooks```GlobalStateManager.instance.setState('appState', 'count', globalCount + 1);// Update global state    .getState<int>('appState', 'count', 0);final globalCount = GlobalStateManager.instance// Access global state in any component```dartFor state that needs to be shared between components, use the GlobalStateManager:### Global State```}  });    setState({'count3': 0});    setState({'count2': 0});    setState({'count1': 0});  batchUpdates(() {void resetCounters() {// Batch multiple state updates}  setState({'count': state['count'] + 1});void incrementCount() {// Update state with setState}  return {'count': 0, 'name': 'User'};Map<String, dynamic> getInitialState() {@override// Initialize state in getInitialState```dartThe DC Framework provides built-in state management for components:### Component State## State Management```);  [MyComponent()],  ),    ),      ],        ),          onPress: (_) => reset(),          title: 'Try Again',        DCButton(        DCText('Something went wrong!'),      children: [    fallback: (error, reset) => DCView(  ErrorBoundaryProps(ErrorBoundary(```dart### Error Handling```DCText('Double: ${doubleCount.value}'););  onPress: (_) => countState.value += 1,  title: "Increment",DCButton();  ['counter'],  () => countState.value * 2,  'doubleCount',final doubleCount = UseMemo<int>(final countState = UseState<int>('counter', 0);// Create a counter component with hooks```dart### Using Hooks```}  }    ).build();      ],        ),          onPress: (_) => setState({'count': count + 1}),          title: 'Increment',        DCButton(        DCText('Count: $count'),      children: [      ),        style: DCViewStyle(padding: EdgeInsets.all(16)),      props: DCViewProps(    return DCView(        final count = state['count'] as int? ?? 0;  VNode buildRender() {  @override  }    return {'count': 0};  Map<String, dynamic> getInitialState() {  @overrideclass MyComponent extends Component {```dart### Creating a Component```

# DC Framework - Flutter VDOM UI Framework

## Overview
DC Framework is a Virtual DOM-based UI framework for Flutter, inspired by React's component model. It provides a declarative way to build UIs with efficient rendering, state management, and component lifecycle hooks.

## Core Features
- Virtual DOM implementation for efficient UI updates
- Component-based architecture with lifecycle methods
- Hooks system for functional components
- State management with global state and memoization
- Error boundaries for error handling
- Performance optimization for large lists and nested components

## Directory Structure

### Core Module
- **`core/`**: Core framework functionality
  - **`component.dart`**: Base Component class with lifecycle methods
  - **`pure_component.dart`**: PureComponent with shallow comparison optimization
  - **`error_boundary.dart`**: Error boundary implementation for exception handling
  - **`bootstrap.dart`**: Framework initialization and app mounting
  - **`vdom/`**: Virtual DOM implementation
    - **`node.dart`**: Virtual DOM node definition
    - **`vdom.dart`**: Base VDOM implementation
    - **`optimized_vdom.dart`**: Performance-optimized VDOM for large lists
    - **`element_factory.dart`**: Factory methods for creating VDOM elements
    - **`component_vdom.dart`**: Component-aware VDOM implementation
    - **`extensions/`**: VDOM extensions
      - **`native_method_channels+vdom.dart`**: Native bridge for VDOM

### Hooks System
- **`hooks/`**: React-like hooks implementation
  - **`use_state.dart`**: State hook for functional components
  - **`use_effect.dart`**: Side effect hook for handling effects
  - **`use_memo.dart`**: Memoization hook for performance optimization
  - **`use_callback.dart`**: Callback memoization hook
  - **`use_reducer.dart`**: Reducer state pattern hook
  - **`index.dart`**: Hook exports

### UI Components
- **`controls/`**: UI controls and components
  - **`low_levels/`**: Base control abstractions
    - **`control.dart`**: Base control class
    - **`component_adapter.dart`**: Adapter for component controls
  - **`view.dart`**: Container component
  - **`text.dart`**: Text component
  - **`button.dart`**: Button component
  - **`image.dart`**: Image component
  - **`checkbox.dart`**: Checkbox component
  - **`switch.dart`**: Switch component
  - **`touchable.dart`**: Touchable component
  - **`list_view.dart`**: List view component
  - **`optimized_list.dart`**: Performance-optimized list component

### Utilities
- **`utility/`**: Utility functions and services
  - **`state_abstraction.dart`**: Global state management
  - **`performance_monitor.dart`**: Performance monitoring and metrics
  - **`event_bus.dart`**: Event bus for cross-component communication
  - **`flutter.dart`**: Flutter integration helpers

## Key Files and Their Purpose

### Core Framework
- **`component.dart`**: Defines the base Component class with lifecycle methods like componentDidMount, componentDidUpdate, etc.
- **`pure_component.dart`**: Optimizes rendering by implementing shouldComponentUpdate with shallow comparison.
- **`bootstrap.dart`**: Provides the dcBind function to initialize and mount the app.

### VDOM Implementation
- **`node.dart`**: Defines VNode, the basic building block of the virtual DOM.
- **`vdom.dart`**: Implements the core reconciliation algorithm.
- **`optimized_vdom.dart`**: Extends VDOM with optimizations for large lists and trees.
- **`element_factory.dart`**: Factory for creating virtual DOM elements and components.

### State Management
- **`state_abstraction.dart`**: Global state manager with memoization and dependency tracking.
- **`hooks/*.dart`**: React-style hooks for functional component state and effects.

### UI Components
- **`control.dart`**: Base class for all UI controls.
- **`view.dart`, `text.dart`, etc.**: Specific UI components that map to native views.
- **`optimized_list.dart`**: High-performance list component with windowing.

### Error Handling
- **`error_boundary.dart`**: Catches errors in components and displays fallback UI.

### Performance
- **`performance_monitor.dart`**: Tracks and logs performance metrics.

## Usage

### Basic App Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dcBind(
    () => MyApp(),
    enableOptimizations: true,
    enablePerformanceTracking: true,
  );
}
