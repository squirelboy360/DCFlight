import UIKit
import yoga

class DCMauiImageComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let imageView = UIImageView()
        
        // Set content mode to scale properly
        imageView.contentMode = .scaleAspectFit
        
        // Create Yoga node for this view for layout
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: imageView)
        
        // Apply all props
        updateView(imageView, props: props)
        return imageView
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let imageView = view as? UIImageView else { return }
        
        // Basic image source handling - load from bundle by default
        if let source = props["source"] as? String {
            // Handle different source types (bundle, URL, etc)
            if source.hasPrefix("http") {
                // Remote image URL
                loadImageFromURL(source, into: imageView)
            } else {
                // Local bundle image
                imageView.image = UIImage(named: source)
            }
        }
        
        // Handle resize mode (content mode in iOS)
        if let resizeMode = props["resizeMode"] as? String {
            switch resizeMode {
            case "cover":
                imageView.contentMode = .scaleAspectFill
            case "contain":
                imageView.contentMode = .scaleAspectFit
            case "stretch":
                imageView.contentMode = .scaleToFill
            case "center":
                imageView.contentMode = .center
            case "repeat":
                // UIKit doesn't support repeat directly, would need custom implementation
                imageView.contentMode = .scaleToFill
            default:
                imageView.contentMode = .scaleAspectFit
            }
        }
        
        // Handle aspect ratio
        if let aspectRatio = props["aspectRatio"] as? CGFloat {
            // Using constraints to maintain aspect ratio
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Remove any existing aspect ratio constraint
            for constraint in imageView.constraints {
                if constraint.firstAttribute == .width && constraint.secondAttribute == .height {
                    imageView.removeConstraint(constraint)
                }
            }
            
            // Add aspect ratio constraint
            let aspectConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .height,
                multiplier: aspectRatio,
                constant: 0
            )
            imageView.addConstraint(aspectConstraint)
        }
        
        // Handle fade duration for image loading
        if let fadeDuration = props["fadeDuration"] as? Double {
            // Store the fade duration as an associated object
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "fadeDuration".hashValue)!,
                fadeDuration,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Handle default source (placeholder)
        if let defaultSource = props["defaultSource"] as? String {
            if imageView.image == nil { // Only set if main image not loaded
                imageView.image = UIImage(named: defaultSource)
            }
        }
        
        // Apply standard visual styling
        applyCommonStyling(to: imageView, with: props)
        
        // Apply layout properties for positioning and sizing
        applyLayoutProps(imageView, props: props)
    }
    
    // Helper to apply common visual styling
    private static func applyCommonStyling(to view: UIView, with props: [String: Any]) {
        // Background color
        if let bgColorStr = props["backgroundColor"] as? String {
            view.backgroundColor = UIColorFromHex(bgColorStr)
        }
        
        // Opacity
        if let opacity = props["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        // Border radius (clip to bounds)
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
            view.clipsToBounds = true
        }
        
        // Directional border radii for individual corners
        let corners: [(String, CACornerMask)] = [
            ("borderTopLeftRadius", .layerMinXMinYCorner),
            ("borderTopRightRadius", .layerMaxXMinYCorner),
            ("borderBottomLeftRadius", .layerMinXMaxYCorner),
            ("borderBottomRightRadius", .layerMaxXMaxYCorner)
        ]
        
        var hasCustomCornerRadius = false
        
        for (propName, cornerMask) in corners {
            if let radius = props[propName] as? CGFloat {
                hasCustomCornerRadius = true
                view.layer.cornerRadius = radius // This will be overridden if multiple corners have different values
                view.layer.maskedCorners.insert(cornerMask)
            }
        }
        
        if hasCustomCornerRadius {
            view.clipsToBounds = true
        }
        
        // Border properties
        if let borderWidth = props["borderWidth"] as? CGFloat {
            view.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            view.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
    }
    
    // Helper to load remote images with caching
    static func loadImageFromURL(_ urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return
        }
        
        // Check for fade duration - use 0.0 if not specified
        let fadeDuration = objc_getAssociatedObject(
            imageView,
            UnsafeRawPointer(bitPattern: "fadeDuration".hashValue)!
        ) as? Double ?? 0.0
        
        // Check if image is already cached
        if let cachedImage = ImageCache.shared.getImage(for: urlString) {
            if fadeDuration > 0 {
                UIView.transition(with: imageView,
                                 duration: fadeDuration,
                                 options: .transitionCrossDissolve,
                                 animations: {
                                     imageView.image = cachedImage
                                 })
            } else {
                imageView.image = cachedImage
            }
            return
        }
        
        // Create data task to download image
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error loading image from URL: \(urlString) - \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Cache the image
            ImageCache.shared.setImage(image, for: urlString)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                if fadeDuration > 0 {
                    UIView.transition(with: imageView,
                                     duration: fadeDuration,
                                     options: .transitionCrossDissolve,
                                     animations: {
                                         imageView.image = image
                                     })
                } else {
                    imageView.image = image
                }
            }
        }
        
        task.resume()
    }
    
    // No standard events for image components in this basic implementation
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {}
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {}
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
