import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  // Tracking render count to verify reactivity
  int _renderCount = 0;
  
  // Define state hooks at class level
  late StateHook<int> activeTabIndex;
  late StateHook<String> pageViewId;
  late StateHook<int> tabChangeCount;
  late StateHook<String> lastTabChangeTime;


  // Status text for displaying current state
  String get _statusText => 
    'Tab: ${activeTabIndex.value} | Changes: ${tabChangeCount.value} | Last: ${lastTabChangeTime.value}';
  
  @override
  VDomNode render() {
    activeTabIndex = useState(0);
    pageViewId = useState('');
    tabChangeCount = useState(0);
    lastTabChangeTime = useState(DateTime.now().toString());
    // Increment render count to track UI updates
    _renderCount++;
    
    return view(
      layout: LayoutProps(
        flex: 1,
      ),
      style: StyleSheet(
        backgroundColor: Colors.white
      ),
      children: [
        // Section with animated title and state indicators
        view(
          layout: LayoutProps(
            marginTop: 60, 
            marginBottom: 10,
            flex: 1
          ),
          children: [
            animatedText(
              content: 'DCFlight Navigation Demo',
              textProps: TextProps(
                fontSize: 24,
                fontWeight: 'bold',
                color: Colors.black,
                textAlign: 'center',
              ),
              layout: LayoutProps(
                marginBottom: 10,
              ),
              animation: TextAnimationProps(
                duration: 500,
                curve: 'easeOut'
              ),
              onViewId: (id) {
                print('Animated text ID: $id');
              },
            ),
            
            // Status indicator showing current state (for proving reactivity)
            text(
              content: _statusText,
              textProps: TextProps(
                fontSize: 12,
                color: Colors.grey,
                textAlign: 'center',
              ),
              layout: LayoutProps(
                marginBottom: 10,
              ),
            ),
            
            // Render count indicator
            text(
              content: 'Rendered: $_renderCount times',
              textProps: TextProps(
                fontSize: 10,
                color: Colors.grey[600],
                textAlign: 'center',
              ),
            ),
          ],
        ),
        
        // Content area with page view
        pageView(
          layout: LayoutProps(
            flex: 3,
          ),
          pageViewProps: PageViewProps(
            initialPage: activeTabIndex.value,
            enableSwipe: true, 
            showIndicator: true,
            indicatorColor: Colors.indigo,
          ),
          onViewId: (id) {
            // Store page view ID for programmatic navigation
            pageViewId.setValue(id as String);
          },
          onPageChanged: (data) {
            // Update active tab index when page changes via swipe
            final page = data['page'] as int;
            onTabChanged(page);
          },
          children: [
            // Home content
            _buildHomeContent(),
            
            // Details page content
            _buildDetailsContent(),
            
            // Settings page content
            _buildSettingsContent(),
          ],
        ),
        
        // Tab bar
        animatedView(
          layout: LayoutProps(
            height: 100,
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceAround
          ),
          style: StyleSheet(
            backgroundColor: Colors.grey[100],
          ),
          animation: AnimationProps(
            duration: 300,
            curve: 'easeInOut',
          ),
          children: [
            // Home tab
            _buildTabButton('Home', 0),
            
            // Details tab
            _buildTabButton('Details', 1),
            
            // Settings tab
            _buildTabButton('Settings', 2),
          ],
        ),
      ],
    );
  }
  
  // Build tab button with icon and label
  VDomElement _buildTabButton(String title, int index) {
    final bool isSelected = activeTabIndex.value == index;
    
    return touchableOpacity(
      layout: LayoutProps(
     
        width: 60,
        height: 60,
        alignItems: YogaAlign.center,
        justifyContent: YogaJustifyContent.center,
      ),
      style: StyleSheet(
        opacity: isSelected ? 1.0 : 0.7,
      ),
      activeOpacity: 0.5,
      onPress: () {
        onTabChanged(index);
      },
      children: [
        // Icon (using emoji as placeholder)
        text(
          content: _getTabIcon(index),
          textProps: TextProps(
            fontSize: 20,
          ),
          layout: LayoutProps(
            marginBottom: 4,
          ),
        ),
        
        animatedText(
          content: title,
          textProps: TextProps(
            fontSize: 12,
            fontWeight: isSelected ? 'bold' : 'normal',
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          animation: TextAnimationProps(
            duration: 200,
          ),
        ),
      ],
    );
  }
  
  // Function to get tab icon
  String _getTabIcon(int index) {
    switch(index) {
      case 0: return '🏠';
      case 1: return 'ℹ️';
      case 2: return '⚙️';
      default: return '•';
    }
  }
  
  // Tab change handler - updates state and navigates PageView
  void onTabChanged(int index) {
    if (index != activeTabIndex.value) {
      // Update all state hooks to trigger reactivity
      activeTabIndex.setValue(index);
      tabChangeCount.setValue(tabChangeCount.value + 1);
      lastTabChangeTime.setValue(DateTime.now().toString());
      
      // Programmatically switch the page view if needed
      if (pageViewId.value.isNotEmpty) {
        PageViewMethods.goToPage(pageViewId.value, index);
      }
    }
  }
  
  // Home page content
  VDomElement _buildHomeContent() {
    return scrollView(
      scrollViewProps: ScrollViewProps(
        showsIndicator: true,
        clipsToBounds: true,
      ),
      layout: LayoutProps(
        flex: 1,
        padding: 16,
      ),
      children: [
        image(
          imageProps: ImageProps(source: 'assets/logo_bg.png'),
          layout: LayoutProps(
            width: 150,
            height: 150,
            alignSelf: YogaAlign.center,
            marginBottom: 24,
          ),
          style: StyleSheet(
            borderRadius: 75,
          ),
        ),
        text(
          content: 'Welcome to DCFlight',
          textProps: TextProps(
            fontSize: 24,
            fontWeight: 'bold',
            color: Colors.black,
            textAlign: 'center',
          ),
          layout: LayoutProps(
            marginBottom: 16,
          ),
        ),
        text(
          content: 'This demo shows how to use animation primitives to build a custom tab-based navigation',
          textProps: TextProps(
            fontSize: 16,
            color: Colors.black,
            textAlign: 'center',
          ),
          layout: LayoutProps(
            marginBottom: 32,
          ),
        ),
        touchableOpacity(
          layout: LayoutProps(
            height: 50,
            marginBottom: 16,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.center,
          ),
          style: StyleSheet(
            backgroundColor: Colors.blue,
            borderRadius: 8,
          ),
          activeOpacity: 0.6,
          onPress: () {
            // Switch to details tab
            onTabChanged(1);
          },
          children: [
            text(
              content: 'Go to Details',
              textProps: TextProps(
                fontSize: 16, 
                fontWeight: 'medium',
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Build details page content
  VDomElement _buildDetailsContent() {
    return scrollView(
      scrollViewProps: ScrollViewProps(
        showsIndicator: true,
      ),
      layout: LayoutProps(
        flex: 1,
        padding: 16,
      ),
      children: [
        text(
          content: 'Details',
          textProps: TextProps(
            fontSize: 24,
            fontWeight: 'bold',
            color: Colors.black,
          ),
          layout: LayoutProps(
            marginBottom: 16,
          ),
        ),
        text(
          content: 'This is the details page, showing how to navigate between tabs.',
          textProps: TextProps(
            fontSize: 16,
            color: Colors.black,
          ),
          layout: LayoutProps(
            marginBottom: 24,
          ),
        ),
        // Example of animated view with gesture detector
        gestureDetector(
          gestureProps: GestureProps(
            enabled: true,
            longPressMinDuration: 500,
          ),
          onTap: () {
            // Animate the view when tapped
            print('Animated view tapped');
          },
          onLongPress: () {
            print('Animated view long pressed');
          },
          children: [
            animatedView(
              layout: LayoutProps(
                height: 100,
                width: '100%',
                alignItems: YogaAlign.center,
                justifyContent: YogaJustifyContent.center,
                marginBottom: 24,
              ),
              style: StyleSheet(
                backgroundColor: Colors.blue,
                borderRadius: 8,
              ),
              animation: AnimationProps(
                duration: 500,
              ),
              onViewId: (id) {
                print('Animated view ID: $id');
              },
              children: [
                text(
                  content: 'Tap or long press this view',
                  textProps: TextProps(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  // Build settings page content
  VDomElement _buildSettingsContent() {
    return scrollView(
      scrollViewProps: ScrollViewProps(
        showsIndicator: true,
      ),
      layout: LayoutProps(
        flex: 1,
        padding: 16,
      ),
      children: [
        text(
          content: 'Settings',
          textProps: TextProps(
            fontSize: 24,
            fontWeight: 'bold',
            color: Colors.black,
          ),
          layout: LayoutProps(
            marginBottom: 24,
          ),
        ),
        // Settings items
        view(
          layout: LayoutProps(
            marginBottom: 16,
            padding: 12,
          ),
          style: StyleSheet(
            backgroundColor: Colors.grey[100],
            borderRadius: 8,
          ),
          children: [
            text(
              content: 'Notifications',
              textProps: TextProps(
                fontSize: 16,
                fontWeight: 'medium',
                color: Colors.black,
              ),
            ),
          ],
        ),
        view(
          layout: LayoutProps(
            marginBottom: 16,
            padding: 12,
          ),
          style: StyleSheet(
            backgroundColor: Colors.grey[100],
            borderRadius: 8,
          ),
          children: [
            text(
              content: 'Privacy',
              textProps: TextProps(
                fontSize: 16,
                fontWeight: 'medium',
                color: Colors.black,
              ),
            ),
          ],
        ),
        view(
          layout: LayoutProps(
            marginBottom: 16,
            padding: 12,
          ),
          style: StyleSheet(
            backgroundColor: Colors.grey[100],
            borderRadius: 8,
          ),
          children: [
            text(
              content: 'About',
              textProps: TextProps(
                fontSize: 16,
                fontWeight: 'medium',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



