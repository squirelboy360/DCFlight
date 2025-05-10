import 'package:dcflight/dcflight.dart';

/// Modal presentation style
enum ModalPresentationStyle {
  /// Full screen presentation
  fullScreen,
  
  /// Page sheet presentation (smaller card)
  pageSheet,
  
  /// Form sheet presentation (centered small card)
  formSheet,
  
  /// Present over current context
  overCurrentContext,
}

/// Modal transition style
enum ModalTransitionStyle {
  /// Cover vertical transition
  coverVertical,
  
  /// Flip horizontal transition
  flipHorizontal,
  
  /// Cross dissolve transition
  crossDissolve,
  
  /// Partial curl transition
  partialCurl,
}

/// Modal properties
class ModalProps {
  /// Whether the modal is visible
  final bool visible;
  
  /// Whether to animate transitions
  final bool animated;
  
  /// Whether the modal can be dismissed by tapping the backdrop
  final bool dismissOnBackdropTap;
  
  /// The opacity of the backdrop
  final double backdropOpacity;
  
  /// The presentation style of the modal
  final ModalPresentationStyle presentationStyle;
  
  /// The transition style of the modal
  final ModalTransitionStyle transitionStyle;
  
  /// Create modal props
  const ModalProps({
    this.visible = false,
    this.animated = true,
    this.dismissOnBackdropTap = true,
    this.backdropOpacity = 0.5,
    this.presentationStyle = ModalPresentationStyle.pageSheet,
    this.transitionStyle = ModalTransitionStyle.coverVertical,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'visible': visible,
      'animated': animated,
      'dismissOnBackdropTap': dismissOnBackdropTap,
      'backdropOpacity': backdropOpacity,
      'presentationStyle': presentationStyle.toString().split('.').last,
      'transitionStyle': transitionStyle.toString().split('.').last,
    };
  }
}

/// Reference object to control a Modal component
class ModalRef {
  final String _viewId;
  
  /// Create a modal reference
  ModalRef(this._viewId);
  
  /// Present the modal
  Future<void> present({bool animated = true}) async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'present',
      {'animated': animated},
    );
  }
  
  /// Dismiss the modal
  Future<void> dismiss({bool animated = true}) async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'dismiss',
      {'animated': animated},
    );
  }
  
  /// Set the backdrop opacity
  Future<void> setBackdropOpacity(double opacity) async {
    await PlatformDispatcher.instance.callComponentMethod(
      _viewId,
      'setBackdropOpacity',
      {'opacity': opacity},
    );
  }
}

/// Modal component
class Modal extends Component {
  /// Modal properties
  final Map<String, dynamic> _props;
  
  /// Modal reference
  final ModalRef? ref;
  
  /// Modal content
  final VDomNode content;
  
  /// Create a modal
  Modal({
    this.ref,
    bool visible = false,
    bool animated = true,
    bool dismissOnBackdropTap = true,
    double backdropOpacity = 0.5,
    ModalPresentationStyle presentationStyle = ModalPresentationStyle.pageSheet,
    ModalTransitionStyle transitionStyle = ModalTransitionStyle.coverVertical,
    required this.content,
    super.key,
  }) : _props = ModalProps(
         visible: visible,
         animated: animated,
         dismissOnBackdropTap: dismissOnBackdropTap,
         backdropOpacity: backdropOpacity,
         presentationStyle: presentationStyle,
         transitionStyle: transitionStyle,
       ).toMap();
  
  @override
  void componentDidMount() {
    if (ref != null) {
      if (_props['visible'] == true) {
        ref!.present(animated: _props['animated'] ?? true);
      }
    }
  }
  
  @override
  VDomNode render() {
    return VDomElement(
      type: 'Modal',
      props: {
        ..._props,
      },
      children: [content],
    );
  }
}
