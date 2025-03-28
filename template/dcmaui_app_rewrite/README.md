# 🚧 This CLI is Under Development

Its aim is to simplify cross-platform app development for personal future projects.

## ⚠️ Important Notice

If you want to test it, do not use the CLI as it currently does nothing. However, you can run the example to see how it works. The example serves as an experimental implementation and will eventually be broken down, optimized, and integrated into the complete CLI.

## 📌 Key Points

### 1️⃣ Flutter Engine Usage

Developers might notice that the framework is built on Flutter—but in actuality, it is not.  
It is almost impossible to decouple the Dart VM from Flutter. To work around this:

- The framework is built on top of Flutter, but not as a Flutter framework.
- When abstracting the Flutter engine, I separate it into a dedicated package.
- The framework only exposes method channels and essential functions like `runApp()`.
- This allows communication with the Flutter engine in headless mode, letting the native side handle rendering.

### 2️⃣ Current Syntax Needs Improvement 🤦‍♂️

The current syntax is not great, but I will abstract over it later.

## 📝 Dart Example

```import 'package:dc_test/core/types/events.dart';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:logging/logging.dart';
import 'package:dc_test/core/types/layout/yoga_types.dart';
import 'package:dc_test/layout/layout_config.dart';
import 'package:dc_test/style/view_style.dart';
import 'package:dc_test/ui_apis.dart';

final _logger = Logger('ModernApp');
final bridge = NativeUIBridge();
int _counter = 0; // Global state

void main() {
  _setupLogging();
  runApp(const SizedBox());
  startApp();
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });
}

// State management functions
void _incrementCounter() {
  _counter++;
  _logger.info('Counter incremented: $_counter');
}

void _decrementCounter() {
  _counter--;
  _logger.info('Counter decremented: $_counter');
}

void _resetCounter() {
  _counter = 0;
  _logger.info('Counter reset');
}

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Main container with gradient background
  final mainContainer = await bridge.createView('View');
  if (mainContainer == null) return;
  await bridge.attachView(rootId, mainContainer);

  // Configure main layout
  await bridge.setLayout(
    mainContainer,
    LayoutConfig(
      position: YGPositionType.relative,
      display: YGDisplay.flex,
      flexDirection: YGFlexDirection.column,
      width: YGValue(100, YGUnit.percent),
      height: YGValue(100, YGUnit.percent),
      alignItems: YGAlign.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
    ),
  );

  // Apply gradient background
  await bridge.updateView(
      mainContainer,
      ViewStyle(
          gradient: GradientStyle(
        colors: [Color(0xFF1A1A1A), Color(0xFF2E3192)],
        stops: [0.0, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )).toJson());

  // Create header section
  final headerContainer = await bridge.createView('View');
  if (headerContainer == null) return;
  await bridge.attachView(mainContainer, headerContainer);

  await bridge.setLayout(
      headerContainer,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        alignItems: YGAlign.center,
        margin: const EdgeInsets.only(top: 60, bottom: 40),
      ));

  // Title
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(headerContainer, titleLabel);

  await bridge.updateView(
      titleLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: 'Modern Counter',
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      )).toJson());

  // Subtitle
  final subtitleLabel = await bridge.createView('Label');
  if (subtitleLabel == null) return;
  await bridge.attachView(headerContainer, subtitleLabel);

  await bridge.updateView(
      subtitleLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: 'Tap buttons to count',
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
      )).toJson());

  // Counter card
  final card = await bridge.createView('View');
  if (card == null) return;
  await bridge.attachView(mainContainer, card);

  await bridge.setLayout(
      card,
      LayoutConfig(
        display: YGDisplay.flex,
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        width: YGValue(300, YGUnit.point),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(vertical: 40),
      ));

  await bridge.updateView(
      card,
      ViewStyle(backgroundColor: Colors.white, cornerRadius: 24, shadows: [
        ShadowStyle(
          color:
              Colors.black.withOpacity(0.3), // Keep using withOpacity for now
          offset: const Offset(0, 15),
          radius: 30,
        )
      ]).toJson());

  // Counter display
  final counterDisplay = await bridge.createView('View');
  if (counterDisplay == null) return;
  await bridge.attachView(card, counterDisplay);

  await bridge.setLayout(
      counterDisplay,
      LayoutConfig(
        width: YGValue(180, YGUnit.point),
        height: YGValue(180, YGUnit.point),
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        margin: const EdgeInsets.symmetric(vertical: 24),
      ));

  await bridge.updateView(
      counterDisplay,
      ViewStyle(
          gradient: GradientStyle(
            colors: [Color(0xFFF0F7FF), Color(0xFFE6F0FF)],
            stops: [0.0, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          cornerRadius: 90,
          shadows: [
            ShadowStyle(
              color: Color(0xFF2E3192).withOpacity(0.1),
              offset: const Offset(0, 8),
              radius: 16,
            )
          ]).toJson());

  // Counter label
  final counterLabel = await bridge.createView('Label');
  if (counterLabel == null) return;
  await bridge.attachView(counterDisplay, counterLabel);

  await bridge.updateView(
      counterLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: '0',
        color: Color(0xFF2E3192),
        fontSize: 72,
        fontWeight: FontWeight.bold,
      )).toJson());

  // Buttons container
  final buttonsContainer = await bridge.createView('View');
  if (buttonsContainer == null) return;
  await bridge.attachView(card, buttonsContainer);

  await bridge.setLayout(
      buttonsContainer,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(100, YGUnit.percent),
        margin: const EdgeInsets.only(top: 24),
      ));

  // Update button creation with proper sizing and style
  final decrementButton = await bridge.createButton(
    text: '-',
    style: ViewStyle(
      backgroundColor: Color(0xFFFF3B30),
      cornerRadius: 28,
      width: 56, // Explicitly set width
      height: 56, // Explicitly set height
      textStyle: TextStyle(
        text: '-',
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      shadows: [
        ShadowStyle(
          color: Color(0xFFFF3B30).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        _decrementCounter();
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: _counter.toString(),
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );

  final resetButton = await bridge.createButton(
    text: '↺',
    style: ViewStyle(
      backgroundColor: Color(0xFF007AFF),
      cornerRadius: 28,
      width: 80, // Wider for reset button
      height: 56,
      textStyle: TextStyle(
        text: '↺',
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      shadows: [
        ShadowStyle(
          color: Color(0xFF007AFF).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        _resetCounter();
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: _counter.toString(),
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );

  final incrementButton = await bridge.createButton(
    text: '+',
    style: ViewStyle(
      backgroundColor: Color(0xFF34C759),
      cornerRadius: 28,
      width: 56,
      height: 56,
      textStyle: TextStyle(
        text: '+',
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      shadows: [
        ShadowStyle(
          color: Color(0xFF34C759).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        _incrementCounter();
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: _counter.toString(),
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );

  // Attach buttons (no need for registerEvent anymore)
  if (decrementButton != null) {
    await bridge.attachView(buttonsContainer, decrementButton);
  }
  if (resetButton != null) {
    await bridge.attachView(buttonsContainer, resetButton);
  }
  if (incrementButton != null) {
    await bridge.attachView(buttonsContainer, incrementButton);
  }
}
```


### 3️⃣ Inspired by .NET MAUI

The architecture is loosely inspired by .NET MAUI, but instead of .NET, Flutter serves as the toolset.

### 4️⃣ Hot Reload/Restart Issues ⚡

- Hot Reload does not work ❌.
- Hot Restart works but duplicates the native UIs or stacks them on top of each other, which is annoying. 😕

---

This project is still in early development, and many improvements will be made along the way.  
Contributions, suggestions, and feedback are always welcome! 🚀
