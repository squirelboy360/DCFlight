import UIKit
import yoga

class DCMauiImageComponent: NSObject, DCMauiComponent {
    // Create shared image cache
    private let imageCache = ImageCache.shared
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create container view to handle background styling properly
        let containerView = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Tag the image view for identification
        imageView.tag = 1001
        
        // Add image view to container
        containerView.addSubview(imageView)
        
        // Setup constraints to make image view fill the container
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Apply properties
        _ = updateView(containerView, withProps: props)
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Find the image view inside the container
        guard let imageView = view.viewWithTag(1001) as? UIImageView else {
            // Direct image view case (legacy)
            if let directImageView = view as? UIImageView {
                return updateImageViewDirectly(directImageView, withProps: props)
            }
            print("❌ ERROR: Could not find image view inside container")
            return false
        }
        
        // Apply styles to container
        view.applyStyles(props: props)
        
        // Apply image-specific props to the image view
        return updateImageViewDirectly(imageView, withProps: props)
    }
    
    private func updateImageViewDirectly(_ imageView: UIImageView, withProps props: [String: Any]) -> Bool {
        // Handle image source
        if let source = props["source"] as? String {
            loadImage(for: imageView, source: source, props: props)
        }
        
        // Set content mode based on resize mode
        if let resizeMode = props["resizeMode"] as? String {
            imageView.contentMode = contentModeFromString(resizeMode)
        }
        
        // Apply tint color for icons
        if let tintColorString = props["tintColor"] as? String {
            imageView.tintColor = ColorUtilities.color(fromHexString: tintColorString)
            
            // If tint color is set, make sure the image is template
            if imageView.image != nil {
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            // Reset to original rendering if no tint color
            if imageView.image != nil {
                imageView.image = imageView.image?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        return true
    }
    
    // Load image from source
    private func loadImage(for imageView: UIImageView, source: String, props: [String: Any]) {
        // First check if we're updating to the same image source
        if let imageSource = objc_getAssociatedObject(imageView, 
                                                    UnsafeRawPointer(bitPattern: "imageSource".hashValue)!) as? String,
           imageSource == source {
            print("🖼️ Image source unchanged: \(source)")
            return
        }
        
        // Store the new source
        objc_setAssociatedObject(imageView, 
                               UnsafeRawPointer(bitPattern: "imageSource".hashValue)!,
                               source,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Check image source type
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            loadRemoteImage(imageView, url: source, props: props)
        } else {
            loadLocalImage(imageView, name: source, props: props)
        }
    }
    
    // Load remote image with caching
    private func loadRemoteImage(_ imageView: UIImageView, url: String, props: [String: Any]) {
        // Show loading indicator if specified
        if let showLoading = props["loading"] as? Bool, showLoading {
            showLoadingIndicator(on: imageView)
        }
        
        // Check cache first
        if let cachedImage = imageCache.getImage(for: url) {
            imageView.image = cachedImage
            processFinishedLoading(imageView, success: true, props: props)
            return
        }
        
        guard let imageUrl = URL(string: url) else {
            processFinishedLoading(imageView, success: false, props: props)
            return
        }
        
        // Load from network
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    // Cache the image
                    self.imageCache.setImage(image, for: url)
                    
                    // Apply tint if needed
                    if let tintColorString = props["tintColor"] as? String {
                        imageView.image = image.withRenderingMode(.alwaysTemplate)
                        imageView.tintColor = ColorUtilities.color(fromHexString: tintColorString)
                    } else {
                        imageView.image = image
                    }
                    
                    self.processFinishedLoading(imageView, success: true, props: props)
                } else {
                    self.processFinishedLoading(imageView, success: false, props: props)
                }
            }
        }
        
        task.resume()
    }
    
    // Load local image
    private func loadLocalImage(_ imageView: UIImageView, name: String, props: [String: Any]) {
        // Try loading from bundle
        if let image = UIImage(named: name) {
            // Apply tint if needed
            if let tintColorString = props["tintColor"] as? String {
                imageView.image = image.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = ColorUtilities.color(fromHexString: tintColorString)
            } else {
                imageView.image = image
            }
            processFinishedLoading(imageView, success: true, props: props)
        } else {
            print("⚠️ Local image not found: \(name)")
            processFinishedLoading(imageView, success: false, props: props)
        }
    }
    
    // Show loading indicator on image view
    private func showLoadingIndicator(on imageView: UIImageView) {
        // Remove any existing activity indicator first
        imageView.subviews.forEach { view in
            if view is UIActivityIndicatorView {
                view.removeFromSuperview()
            }
        }
        
        // Use a style that's compatible with earlier iOS versions
        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            // For iOS 12 and earlier, use gray style
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        
        activityIndicator.startAnimating()
        
        // Center in the image view
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        // Tag it for later removal
        activityIndicator.tag = 9999
    }
    
    // Process finished loading state
    private func processFinishedLoading(_ imageView: UIImageView, success: Bool, props: [String: Any]) {
        // Remove loading indicator if any
        imageView.subviews.forEach { view in
            if view.tag == 9999 { // Tag for activity indicator
                view.removeFromSuperview()
            }
        }

        // --- START EVENT FIX ---
        // Trigger event callbacks using the component protocol's helper
        let eventName = success ? "onLoad" : "onError"
        let eventData: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970 * 1000, // Use ms
            "success": success,
            "source": props["source"] as? String ?? "unknown",
            // Add image dimensions if successful
            "width": success ? imageView.image?.size.width ?? 0 : 0,
            "height": success ? imageView.image?.size.height ?? 0 : 0
        ]
        
        // Use the triggerEvent helper from the protocol extension
        // We need the CONTAINER view to call triggerEvent on, as that's where the callback is stored.
        guard let containerView = imageView.superview else {
             print("⚠️ ImageComponent: Cannot trigger event \(eventName) - container view not found.")
             return
        }
        
        // Check if the container view has the necessary event info stored
        guard let _ = objc_getAssociatedObject(containerView, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) else {
             print("⚠️ ImageComponent: Event callback info not found on container view for event \(eventName). View ID: \(containerView.getNodeId() ?? "unknown")")
             return
        }
        
        // Trigger the event on the container view
        triggerEvent(on: containerView, eventType: eventName, eventData: eventData)
        // FIX: Escaped the double quotes within the string literal
        print("🚀 Sent image event '\(eventName)' for Image \(containerView.getNodeId())")
        // --- END EVENT FIX ---
    }

    // Override addEventListeners to store callback info on the CONTAINER view
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        print("📣 Registering Image events \(eventTypes) for view \(viewId)")
        
        // Store the event callback and view ID on the CONTAINER view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                               eventCallback,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                               viewId,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Store the registered event types
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                               eventTypes,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        print("✅ Image event registration complete for \(viewId)")
    }

    // Override removeEventListeners to clear callback info from the CONTAINER view
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        print("🔴 Removing Image event listeners \(eventTypes) from view \(viewId)")

        // Update the stored event types on the CONTAINER view
        if let existingTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] {
            var remainingTypes = existingTypes
            for type in eventTypes {
                if let index = remainingTypes.firstIndex(of: type) {
                    remainingTypes.remove(at: index)
                }
            }

            if remainingTypes.isEmpty {
                // Clean up all event data if no events remain
                objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                print("🧹 Cleared all Image event data for view \(viewId)")
            } else {
                // Store updated event types
                objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!, remainingTypes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                print("🔄 Updated Image event types for view \(viewId): \(remainingTypes)")
            }
        }
    }

    func getViewSize(_ view: UIView) -> CGSize {
        let imageView: UIImageView?
        if let directImageView = view as? UIImageView {
            imageView = directImageView
        } else {
            imageView = view.viewWithTag(1001) as? UIImageView
        }
        
        guard let image = imageView?.image else {
            // Default size if no image loaded yet
            return CGSize(width: 100, height: 100)
        }
        
        return image.size
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
        
        // Also set the node ID
        view.setNodeId(nodeId)
        
        // If this is a container, also set on the image view
        if let imageView = view.viewWithTag(1001) as? UIImageView {
            imageView.setNodeId(nodeId)
        }
    }
    
    // Helper to convert string resize mode to UIView.ContentMode
    private func contentModeFromString(_ resizeMode: String) -> UIView.ContentMode {
        switch resizeMode.lowercased() {
        case "cover", "covercrop":
            return .scaleAspectFill
        case "contain", "scaleaspectfit":
            return .scaleAspectFit
        case "stretch", "scaletofill":
            return .scaleToFill
        case "center":
            return .center
        case "repeat":
            // UIKit doesn't have a direct equivalent to "repeat", default to .center
            return .center
        default:
            // Default to aspect fit which preserves aspect ratio
            return .scaleAspectFit
        }
    }
}

// Simple image cache
class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100
    }
    
    func getImage(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
