import UIKit
import dcflight

class DCFModalComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Keep track of active modal controllers
    private static var activeModals = [String: UIViewController]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        
        // Apply props
        _ = updateView(containerView, withProps: props)
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // The modal container doesn't have styling properties
        // Most properties are applied when presenting
        return true
    }
    
    // Get the appropriate presentation style
    private func getPresentationStyle(from styleName: String?) -> UIModalPresentationStyle {
        guard let styleName = styleName else {
            return .pageSheet
        }
        
        switch styleName {
        case "fullScreen":
            return .fullScreen
        case "pageSheet":
            return .pageSheet
        case "formSheet":
            return .formSheet
        case "overCurrentContext":
            return .overCurrentContext
        default:
            return .pageSheet
        }
    }
    
    // Get the appropriate transition style
    private func getTransitionStyle(from styleName: String?) -> UIModalTransitionStyle {
        guard let styleName = styleName else {
            return .coverVertical
        }
        
        switch styleName {
        case "coverVertical":
            return .coverVertical
        case "flipHorizontal":
            return .flipHorizontal
        case "crossDissolve":
            return .crossDissolve
        case "partialCurl":
            return .partialCurl
        default:
            return .coverVertical
        }
    }
    
    // Handle modal-specific methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        // Get the view ID associated with this view
        guard let viewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String else {
            print("❌ Cannot handle method for modal: missing viewId")
            return false
        }
        
        switch methodName {
        case "present":
            return presentModal(viewId: viewId, containerView: view, args: args)
            
        case "dismiss":
            return dismissModal(viewId: viewId, args: args)
            
        case "setBackdropOpacity":
            if let opacity = args["opacity"] as? CGFloat,
               let modalVC = DCFModalComponent.activeModals[viewId] as? DCFModalViewController {
                modalVC.backdropView.alpha = opacity
                return true
            }
            return false
            
        default:
            return false
        }
    }
    
    // Present the modal
    private func presentModal(viewId: String, containerView: UIView, args: [String: Any]) -> Bool {
        // Get the animated flag
        let animated = args["animated"] as? Bool ?? true
        
        // Get root view controller - iOS 13 compatible way
        let rootVC: UIViewController?
        if #available(iOS 13.0, *) {
            // Use the scene-based approach for iOS 13+
            rootVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
        } else {
            // Use the old approach for iOS 12 and earlier
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        guard let rootViewController = rootVC else {
            print("❌ Cannot present modal: no root view controller")
            return false
        }
        
        // Get the top-most presented view controller
        var topVC = rootViewController
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        // Get the subviews to present in the modal
        let subviews = containerView.subviews
        
        // Create a modal view controller
        let modalVC = DCFModalViewController()
        modalVC.modalPresentationStyle = getPresentationStyle(from: args["presentationStyle"] as? String)
        modalVC.modalTransitionStyle = getTransitionStyle(from: args["transitionStyle"] as? String)
        
        // Configure backdrop interaction
        modalVC.dismissOnBackdropTap = args["dismissOnBackdropTap"] as? Bool ?? true
        
        // Set backdrop opacity
        modalVC.backdropOpacity = args["backdropOpacity"] as? CGFloat ?? 0.5
        
        // Copy subviews to the modal content view
        for subview in subviews {
            subview.removeFromSuperview()
            modalVC.addContent(subview)
        }
        
        // Set up dismiss callback
        modalVC.onDismiss = { [weak self] in
            self?.handleModalDismissed(viewId: viewId, containerView: containerView)
        }
        
        // Present the modal
        topVC.present(modalVC, animated: animated) {
            print("✅ Modal presented: \(viewId)")
        }
        
        // Store the modal view controller
        DCFModalComponent.activeModals[viewId] = modalVC
        
        return true
    }
    
    // Dismiss the modal
    private func dismissModal(viewId: String, args: [String: Any]) -> Bool {
        // Get the animated flag
        let animated = args["animated"] as? Bool ?? true
        
        // Get the modal view controller
        guard let modalVC = DCFModalComponent.activeModals[viewId] else {
            print("❌ Cannot dismiss modal: not found")
            return false
        }
        
        // Dismiss the modal
        modalVC.dismiss(animated: animated) {
            print("✅ Modal dismissed: \(viewId)")
        }
        
        return true
    }
    
    // Handle modal dismissed event (either programmatically or by user interaction)
    private func handleModalDismissed(viewId: String, containerView: UIView) {
        // Get the modal view controller
        guard let modalVC = DCFModalComponent.activeModals[viewId] as? DCFModalViewController else {
            return
        }
        
        // Move content views back to the container
        let contentSubviews = modalVC.contentView.subviews
        for subview in contentSubviews {
            subview.removeFromSuperview()
            containerView.addSubview(subview)
            
            // Reset auto layout constraints
            subview.translatesAutoresizingMaskIntoConstraints = true
            subview.frame = containerView.bounds
        }
        
        // Remove from active modals
        DCFModalComponent.activeModals.removeValue(forKey: viewId)
        
        // Trigger dismiss event
        triggerEvent(on: containerView, eventType: "onDismiss", eventData: [:])
    }
    
    // Add a custom view hook for when the view is registered with the shadow tree
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Store node ID on the view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "viewId".hashValue)!, 
                               nodeId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Check if we should present initially
        if let props = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "initialProps".hashValue)!) as? [String: Any],
           let visible = props["visible"] as? Bool, visible {
            _ = presentModal(viewId: nodeId, containerView: view, args: props)
        }
    }
}

// Custom view controller for modal presentation
class DCFModalViewController: UIViewController {
    // Content view for modal content
    let contentView = UIView()
    
    // Backdrop view for modal background
    let backdropView = UIView()
    
    // Backdrop opacity
    var backdropOpacity: CGFloat = 0.5 {
        didSet {
            backdropView.alpha = backdropOpacity
        }
    }
    
    // Whether tapping the backdrop should dismiss the modal
    var dismissOnBackdropTap: Bool = true
    
    // Callback for when modal is dismissed
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view hierarchy
        view.backgroundColor = UIColor.clear
        
        // Add backdrop
        backdropView.backgroundColor = UIColor.black
        backdropView.alpha = backdropOpacity
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropView)
        
        // Add content view
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Backdrop fills the entire view
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Content view is centered with padding
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])
        
        // Add tap gesture to backdrop
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleBackdropTap() {
        if dismissOnBackdropTap {
            dismiss(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If being dismissed, call onDismiss
        if isBeingDismissed {
            onDismiss?()
        }
    }
    
    // Add content to the modal
    func addContent(_ contentSubview: UIView) {
        // Remove existing content
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // Add the content
        contentSubview.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentSubview)
        
        // Set up constraints to fill the content view
        NSLayoutConstraint.activate([
            contentSubview.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
