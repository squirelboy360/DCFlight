import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

/// Profile screen
VDomNode profileScreen(RouteContext context) {
  return view(
    layout: LayoutProps(
      flex: 1,
      padding: 16,
      alignItems: YogaAlign.center,
    ),
    children: [
      view(
        layout: LayoutProps(
          width: 120,
          height: 120,
          marginBottom: 24,
          alignItems: YogaAlign.center,
          justifyContent: YogaJustifyContent.center,
        ),
        style: StyleSheet(
          borderRadius: 60,
          backgroundColor: Colors.grey[100],
        ),
        children: [
          dcfIcon(
      
              name: 'person',
              size: 60,
              color: Colors.grey,
            
          ),
        ],
      ),
      text(
        content: 'John Doe',
        textProps: TextProps(
          fontSize: 24,
          fontWeight: 'bold',
          color: Colors.black,
        ),
        layout: LayoutProps(
          marginBottom: 8,
        ),
      ),
      text(
        content: 'john.doe@example.com',
        textProps: TextProps(
          fontSize: 16,
          color: Colors.grey,
        ),
        layout: LayoutProps(
          marginBottom: 32,
        ),
      ),
      button(
        buttonProps: ButtonProps(
          title: 'Edit Profile',
          backgroundColor: Colors.blue,
          color: Colors.white,
        ),
        layout: LayoutProps(
          width: 200,
          marginBottom: 16,
        ),
        onPress: () {
          context.navigator.pushNamed('details', params: {
            'title': 'Edit Profile',
            'description': 'Here you can edit your profile information.',
          });
        },
      ),
    ],
  );
}

/// Settings screen
VDomNode settingsScreen(RouteContext context) {
  return view(
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
      _settingItem(
        'Notifications',
        'Manage your notification preferences',
        () {
          context.navigator.pushNamed('details', params: {
            'title': 'Notifications',
            'description': 'Configure your notification settings here.',
          });
        },
      ),
      _settingItem(
        'Privacy',
        'Control your privacy settings',
        () {
          context.navigator.pushNamed('details', params: {
            'title': 'Privacy',
            'description': 'Manage your privacy preferences and data.',
          });
        },
      ),
      _settingItem(
        'Appearance',
        'Change app theme and appearance',
        () {
          context.navigator.pushNamed('details', params: {
            'title': 'Appearance',
            'description': 'Customize the look and feel of the app.',
          });
        },
      ),
      _settingItem(
        'About',
        'View app information and version',
        () {
          context.navigator.pushNamed('details', params: {
            'title': 'About',
            'description': 'DCF Go App\nVersion 1.0.0\nBuilt with DCFlight Framework',
          });
        },
      ),
    ],
  );
}

/// Helper to create a settings item
VDomNode _settingItem(String title, String subtitle, Function() onTap) {
  return view(
    layout: LayoutProps(
      flexDirection: YogaFlexDirection.row,
      padding: 16,
      marginBottom: 8,
      alignItems: YogaAlign.center,
    ),
    style: StyleSheet(
      backgroundColor: Colors.grey[100],
      borderRadius: 8,
    ),
  // onTap: onTap,
    children: [
      view(
        layout: LayoutProps(
          flex: 1,
        ),
        children: [
          text(
            content: title,
            textProps: TextProps(
              fontSize: 16,
              fontWeight: 'medium',
              color: Colors.black,
            ),
            layout: LayoutProps(
              marginBottom: 4,
            ),
          ),
          text(
            content: subtitle,
            textProps: TextProps(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      dcfIcon(
    
          name: 'arrow-right',
          size: 24,
          color: Colors.grey,
        
      ),
    ],
  );
}
