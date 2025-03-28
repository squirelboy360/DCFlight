# DCMAUI Native Bridge

The Native Bridge package provides high-performance communication between Dart and native platforms (iOS, macOS, Android).

## Architecture Overview

DCMAUI implements a dual-threaded architecture that balances performance and reliability:

### Dual-Thread Design
- **UI Thread**: Fast, direct operations via FFI or JNI for all UI rendering
- **Logic Thread**: Reliable event handling via method channels 

This separation allows for maximum performance while ensuring reliability:
- UI operations happen at native speed
- Events are delivered with guaranteed consistency
- No thread contention or UI jank

## Platform-Specific Implementations

### iOS/macOS (FFI Bridge)
The `FFINativeBridge` uses Foreign Function Interface (FFI) for direct communication with native code.
- Direct memory access
- Zero-copy performance
- Minimal overhead

### Android (JNI Bridge)
The `JNINativeBridge` uses Java Native Interface (JNI) for fast communication with the Android environment.
- Direct Java method calls
- Fast object construction
- Native-speed rendering

## Event Architecture

For both platforms, events use method channels:
- Events are dispatched through dedicated method channels
- This ensures reliable delivery even when the UI thread is busy
- No race conditions or thread safety issues

## Usage

The `NativeBridgeFactory` automatically selects the appropriate implementation:

```dart
// Create the appropriate bridge for the current platform
final bridge = NativeBridgeFactory.create();

// Initialize the bridge
await bridge.initialize();

// Create a native view
await bridge.createView('view1', 'Button', {'title': 'Click me'});
```

## Performance

This architecture delivers exceptional performance metrics compared to JavaScript bridge approaches:
- **UI Operations**: Near-native performance with FFI/JNI
- **Event Handling**: Reliable delivery without compromising UI performance
- **Thread Isolation**: Complete decoupling prevents UI jank
