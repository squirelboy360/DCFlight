import 'package:dcflight/dcflight.dart';

/// Alert action style
enum AlertActionStyle {
  /// Default action style
  defaultStyle,
  
  /// Cancel action style
  cancel,
  
  /// Destructive action style (typically red)
  destructive,
}

/// Alert style
enum AlertStyle {
  /// Default alert style
  defaultStyle,
  
  /// Action sheet style
  actionSheet,
}

/// Alert button action
class AlertAction {
  /// Title of the button
  final String title;
  
  /// Style of the button
  final AlertActionStyle style;
  
  /// Callback when button is pressed
  final Function? onPress;
  
  /// Create an alert action
  const AlertAction({
    required this.title,
    this.style = AlertActionStyle.defaultStyle,
    this.onPress,
  });
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'style': style.toString().split('.').last,
    };
  }
}

/// Alert properties
class AlertProps {
  /// Title of the alert
  final String title;
  
  /// Message body of the alert
  final String message;
  
  /// Style of the alert
  final AlertStyle style;
  
  /// Alert actions/buttons
  final List<AlertAction> actions;
  
  /// Whether the alert is visible
  final bool visible;
  
  /// Create alert props
  const AlertProps({
    this.title = '',
    this.message = '',
    this.style = AlertStyle.defaultStyle,
    this.actions = const [],
    this.visible = false,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'style': style.toString().split('.').last,
      'visible': visible,
    };
  }
}

/// Reference object to control an Alert component
class AlertRef {
  final String _viewId;
  
  /// Create an alert reference
  AlertRef(this._viewId);
  
  /// Show the alert
  Future<void> show() async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'show',
      {},
    );
  }
  
  /// Dismiss the alert
  Future<void> dismiss() async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'dismiss',
      {},
    );
  }
  
  /// Add an action to the alert
  Future<void> addAction(AlertAction action) async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'addAction',
      action.toMap(),
    );
  }
}

/// Alert component
class Alert extends Component {
  /// Alert properties
  final Map<String, dynamic> _props;
  
  /// Alert reference
  final AlertRef? ref;
  
  /// Alert actions
  final List<AlertAction> actions;
  
  /// Map of action callbacks by title
  final Map<String, Function> _actionCallbacks = {};
  
  /// Create an alert
  Alert({
    this.ref,
    String title = '',
    String message = '',
    AlertStyle style = AlertStyle.defaultStyle,
    this.actions = const [],
    bool visible = false,
    super.key,
  }) : _props = AlertProps(
         title: title,
         message: message,
         style: style,
         actions: actions,
         visible: visible,
       ).toMap() {
    // Store action callbacks
    for (final action in actions) {
      if (action.onPress != null) {
        _actionCallbacks[action.title] = action.onPress!;
      }
    }
  }
  
  @override
  void componentDidMount() {
    if (ref != null) {
      if (_props['visible'] == true) {
        ref!.show();
      }
    }
  }
  
  @override
  VDomNode render() {
    final alertProps = {
      ..._props,
      'onAction': _handleAction,
    };
    
    return VDomElement(
      type: 'Alert',
      props: alertProps,
      children: [],
    );
  }
  
  /// Handle action callbacks
  void _handleAction(Map<String, dynamic> data) {
    final String actionTitle = data['title'] ?? '';
    
    if (_actionCallbacks.containsKey(actionTitle)) {
      _actionCallbacks[actionTitle]!();
    }
  }
}
