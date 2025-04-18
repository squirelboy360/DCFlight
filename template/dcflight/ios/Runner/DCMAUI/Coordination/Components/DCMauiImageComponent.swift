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
            if view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
        
        // Trigger event callbacks
        if success {
            triggerEvent(for: imageView, eventName: "onLoad", props: props)
        } else {
            triggerEvent(for: imageView, eventName: "onError", props: props)
        }
    }
    
    // Trigger event callback if registered
    private func triggerEvent(for imageView: UIImageView, eventName: String, props: [String: Any]) {
        if let viewId = imageView.getNodeId() {
            let eventData: [String: Any] = [
                "timestamp": Date().timeIntervalSince1970,
                "success": eventName == "onLoad"
            ]
            
            // Use proper type casting to Any for callbacks instead of 'Function'
            if let onLoad = props["onLoad"] as? Any, eventName == "onLoad" {
                DCMauiEventMethodHandler.shared.sendEvent(viewId: viewId, eventName: "onLoad", eventData: eventData)
            } else if let onError = props["onError"] as? Any, eventName == "onError" {
                DCMauiEventMethodHandler.shared.sendEvent(viewId: viewId, eventName: "onError", eventData: eventData)
            }
        }
    }
    
    // Helper to convert string resize mode to UIView.ContentMode
    private func contentModeFromString(_ resizeMode: String) -> UIView.ContentMode {
        switch resizeMode {
        case "cover":
            return .scaleAspectFill
        case "contain":
            return .scaleAspectFit
        case "stretch":
            return .scaleToFill
        case "center":
            return .center
        default:
            return .scaleAspectFit
        }
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply layout to the container
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // If this is a direct image view, also resize it
        if let imageView = view as? UIImageView {
            imageView.frame.size = CGSize(width: layout.width, height: layout.height)
        } else if let imageView = view.viewWithTag(1001) as? UIImageView {
            // Make sure image view fills container
            imageView.frame = view.bounds
        }
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Get the image view
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
