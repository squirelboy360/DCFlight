
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
  DCFlight.start(app: DCFlightDemoApp());
}

class DCFlightDemoApp extends StatefulComponent {
  @override
  UIComponent render() {
    // State for theme
    final isDarkTheme = useState(false);
    
    // State for active tab
    final activeTabIndex = useState(0);
    
    // State for counter
    final counterState = useState(0);
    
    // Derive theme colors based on isDarkTheme
    final backgroundColor = isDarkTheme.value 
        ? const Color(0xFF121212) 
        : const Color(0xFFF5F5F5);
    
    final textColor = isDarkTheme.value 
        ? const Color(0xFFFFFFFF) 
        : const Color(0xFF000000);
    
    final accentColor = isDarkTheme.value 
        ? const Color(0xFF536DFE) 
        : const Color(0xFF3D5AFE);
    
    // Define tabs
    final tabs = [
      "Counter",
      "Gallery",
      "About",
    ];
    
    return view(
      style: StyleSheet(
        backgroundColor: backgroundColor,
      ),
      layout: const LayoutProps(
        width: '100%',
        height: '100%',
        justifyContent: YogaJustifyContent.flexStart,
        alignItems: YogaAlign.center,
      ),
      children: [
        // Header
        view(
          style: StyleSheet(
            backgroundColor: accentColor,
          ),
          layout:  LayoutProps(flexWrap: YogaWrap.wrap,
            width: '100%',
            height: 80,
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceBetween,
            alignItems: YogaAlign.center,
            padding: ScreenUtilities.instance.statusBarHeight,
            paddingLeft: 20,
            paddingRight: 20,
          ),
          children: [
            text(
              layout: const LayoutProps(
                width: 200,
                height: 40,

              ),
              content: "DCFlight Demo",
              textProps: const TextProps(
                fontSize: 24,
                color: Color(0xFFFFFFFF),
                fontWeight: "bold",
              ),
            ),
            button(
              buttonProps: ButtonProps(
                title: isDarkTheme.value ? "☀️" : "🌙",
                color: isDarkTheme.value ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                backgroundColor: isDarkTheme.value ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
              ),
              layout: const LayoutProps(
                width: 50,
                height: 40,
              ),
              onPress: () {
                isDarkTheme.setValue(!isDarkTheme.value);
              },
            ),
          ],
        ),
        
        // Tabs
        view(
          style: StyleSheet(
            backgroundColor: isDarkTheme.value ? const Color(0xFF1E1E1E) : const Color(0xFFE0E0E0),
          ),
          layout: const LayoutProps(
            width: '100%',
            height: 50,
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceEvenly,
            alignItems: YogaAlign.center,
          ),
          children: [
            for (int i = 0; i < tabs.length; i++)
              button(
                buttonProps: ButtonProps(
                  title: tabs[i],
                  color: i == activeTabIndex.value 
                      ? const Color(0xFFFFFFFF) 
                      : textColor,
                  backgroundColor: i == activeTabIndex.value 
                      ? accentColor
                      : Colors.transparent,
                ),
                layout: const LayoutProps(
                  width: 100,
                  height: 40,
                ),
                onPress: () {
                  activeTabIndex.setValue(i);
                },
              ),
          ],
        ),
        
        // Content based on active tab
        renderTabContent(
          activeTabIndex.value, 
          counterState, 
          textColor, 
          accentColor,
          backgroundColor,
        ),
      ],
    );
  }
  
  // Helper method to render the content of the active tab
  UIComponent renderTabContent(
    int activeTab, 
    StateHook<int> counterState, 
    Color textColor, 
    Color accentColor,
    Color backgroundColor,
  ) {
    switch (activeTab) {
      case 0:
        return CounterScreen(
          counterState: counterState,
          textColor: textColor,
          accentColor: accentColor,
        );
      case 1:
        return galleryScreen(
          textColor: textColor,
          accentColor: accentColor,
          backgroundColor: backgroundColor,
        );
      case 2:
        return aboutScreen(
          textColor: textColor,
          accentColor: accentColor,
        );
      default:
        return view();
    }
  }
}







```


### 3️⃣ Initially Inspired React

The architecture is loosely inspired by Flutter and React, Flutter Engine serves as the dart runtime, more like Hermes for React Native. The syntax has been made flutter-like for familiarity and has borrowed concepts like state hooks and vdom-like architecture from React Native.


