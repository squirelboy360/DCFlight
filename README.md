
# DCFlight
# 🚧 This CLI is Under Development

Its aim is to simplify cross-platform app development for personal future projects.

## ⚠️ Important Notice

Just move from experimental to modularization where the framework is now modularised into a package. Although cli is not complete to allow the app run independent from the flutter cli, with hot reload support etc, the main framework as a package is complete (More platforms can be ported over but fundamentally done)


## 📌 Key Points
DCFlight can be used in any flutter app to diverge from the flutter framework and render native UI. This involves extra work with no guarantee of hot relaod/ restart support or any dev tools. The DCFlight Cli is therefopre advised to be used.
It is almost impossible to decouple the Dart VM from Flutter. To work around this:

## 📝 Dart Example

```dart

void main() {
  DCFlight.start(app: CounterScreen());
}

UIComponent CounterScreen({
  required StateHook<int> counterState,
  required Color textColor,
  required Color accentColor,
}) {
  return view(
    layout: const LayoutProps(
      width: '100%',
      height: 600,
      justifyContent: YogaJustifyContent.center,
      alignItems: YogaAlign.center,
      flexWrap: YogaWrap.wrap,
      padding: 20,
    ),
    children: [
      view(
        layout: const LayoutProps(
          width: '100%',
          height: 300,
          justifyContent: YogaJustifyContent.center,
          alignItems: YogaAlign.center,
          marginBottom: 20,
        ),
        style: StyleSheet(backgroundColor: Colors.teal, borderRadius: 20),
        children: [
          dcfIcon(
            name: DCFIcons.folder,
            color: Colors.purpleAccent,
            size: 20,
            style: StyleSheet(backgroundColor: Colors.white, borderRadius: 20),
            layout: const LayoutProps(
              padding: 5,
              margin: 20,
              height: 50,
              width: 50,
            ),
          ),
          dcfIcon(
            name: DCFIcons.edit,
            color: Colors.purpleAccent,
            size: 50,
            style: StyleSheet(backgroundColor: Colors.white, borderRadius: 20),
            layout: const LayoutProps(
                padding: 5,
              margin: 20,
              height: 50,
              width: 50,
            ),
          ),
          svg(
            asset: 'assets/logo_bg.svg',
            style: StyleSheet(backgroundColor: Colors.white, borderRadius: 20),
            layout: const LayoutProps(
              padding: 5,
              margin: 20,
              height: 50,
              width: 50,
            ),
          ),
        ],
      ),

      text(
        content: "Counter: ${counterState.value}",
        textProps: TextProps(
          fontSize: 36,
          color: textColor,
          fontWeight: "bold",
        ),
        layout: const LayoutProps(marginBottom: 40),
      ),
      view(
        layout: const LayoutProps(
          width: '100%',
          flexDirection: YogaFlexDirection.row,
          justifyContent: YogaJustifyContent.spaceEvenly,
          alignItems: YogaAlign.center,
        ),
        children: [
          button(
            buttonProps: ButtonProps(
              title: "Decrement",
              color: const Color(0xFFFFFFFF),
              backgroundColor:
                  counterState.value > 0
                      ? accentColor
                      : const Color(0xFFAAAAAA),
            ),
            layout: const LayoutProps(width: 120, height: 50),
            onPress: () {
              if (counterState.value > 0) {
                counterState.setValue(counterState.value - 1);
              }
            },
          ),
          button(
            buttonProps: ButtonProps(
              title: "Reset",
              color: const Color(0xFFFFFFFF),
              backgroundColor:
                  counterState.value != 0
                      ? const Color(0xFFFF5722)
                      : const Color(0xFFAAAAAA),
            ),
            layout: const LayoutProps(width: 120, height: 50),
            onPress: () {
              if (counterState.value != 0) {
                counterState.setValue(0);
              }
            },
          ),
          button(
            buttonProps: ButtonProps(
              title: "Increment",
              color: const Color(0xFFFFFFFF),
              backgroundColor: accentColor,
            ),
            layout: const LayoutProps(width: 120, height: 50),
            onPress: () {
              counterState.setValue(counterState.value + 1);
            },
          ),
        ],
      ),
    ],
  );
}


```


### 3️⃣ Initially Inspired React

The architecture is loosely inspired by Flutter and React, Flutter Engine serves as the dart runtime, more like Hermes for React Native. The syntax has been made flutter-like for familiarity and has borrowed concepts like state hooks and vdom-like architecture from React Native.


