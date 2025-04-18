
# DCFlight
# 🚧 This CLI is Under Development

Its aim is to simplify cross-platform app development for personal future projects.

## ⚠️ Important Notice

If you want to test it, do not use the CLI as it currently does nothing. However, you can run the example to see how it works. The example serves as an experimental implementation and will eventually be broken down, optimized, and integrated into the complete CLI.

## 📌 Key Points

### 1️⃣ Flutter Engine Usage (Current branch uses C header file to communicates between native and dart, no more abstaction for UI rendering, the Vdom uses direct native communication for UI CRUD i short)

Developers might notice that the framework is built on Flutter—but in actuality, it is not.  
It is almost impossible to decouple the Dart VM from Flutter. To work around this:

- The framework is built parallel to Flutter Engine and not on top(This means we get Dart VM and the rest is handled by the native layer instead of Platform Views or any flutter abstraction while your usual flutter engine runs parallel for the dart runtime as its needed to start the the communication with native side and if flutter View is needed to be spawned for canvas rendering.
- When abstracting the Flutter engine, I separate it into a dedicated package. Currenttly everything is handled as a package.
- This allows communication with the Flutter engine in headless mode, letting the native side handle rendering.

### 2️⃣ Current Syntax Needs Improvement 🤦‍♂️

The current syntax is not great, but I will abstract over it later.

## 📝 Dart Example

```dart

void main() {
  initializeApplication(DCMauiDemoApp());
}

class DCMauiDemoApp extends StatefulComponent {
  @override
  UIComponent build() {
    // State hooks
    final counter = useState(0, 'counter');

    final bg = useState(Color(Colors.indigoAccent.toARGB32()), 'bg');

    // Use an effect to update the ScrollView background color every second
    useEffect(() {
      final rnd = math.Random();
      Color color() => Color(rnd.nextInt(0xffffffff));
      // Set up a timer to update the color every second
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        // Update the background color
        bg.setValue(color());
        counter.setValue(counter.value + 1);
        print("use effect per 5 second ${timer.tick}");
        
        
      });

      // Clean up the timer when the component is unmounted
      return () {
        timer.cancel();
        developer.log('Canceled background color animation timer',
            name: 'ColorAnimation');
      };
    }, dependencies: []);

    return DC.View(
        layout: LayoutProps(
            flex: 1,
            alignContent: YogaAlign.center,
            justifyContent: YogaJustifyContent.center),
        style: StyleSheet(backgroundColor: bg.value),
        children: [
          DC.Button(
              onPress: () {
                print(counter.value);
                // counter.setValue(counter.value + 1);
              },
              layout: LayoutProps(padding: 10),
              buttonProps: ButtonProps(
                title: "increment",
              )),
          DC.Text(
              textProps: TextProps(
                  fontSize: 24,
                  color: Colors.white,
                  textAlign: 'center',
              ),
              content: counter.value.toString(),
              layout: LayoutProps(paddingHorizontal: 50, width: '100%'),
              style: StyleSheet(backgroundColor: Colors.teal)),
        ]);
  }
}

```


### 3️⃣ Initially Inspired React

The architecture is loosely inspired by Flutter and React, Flutter Engine serves as the dart runtime, more like Hermes for React Native. The syntax has been made flutter-like for familiarity and has borrowed concepts like state hooks and vdom-like architecture from React Native.


