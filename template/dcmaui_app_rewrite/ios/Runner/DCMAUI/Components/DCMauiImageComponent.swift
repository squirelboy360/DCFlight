import UIKit
import yoga

class DCMauiImageComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create image view
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Apply common styling first
        imageView.applyStyles(props: props)
        
        // Apply image-specific properties
        applyImageProps(imageView, props: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Apply common styling first
        imageView.applyStyles(props: props)
        
        // Apply image-specific properties
        applyImageProps(imageView, props: props)
        
        return true
    }
    
    private func applyImageProps(_ imageView: UIImageView, props: [String: Any]) {
        // Handle image source
        if let source = props["source"] as? String {
            loadImage(from: source, into: imageView)
        }
        
        // Handle resize mode
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
            default:
                imageView.contentMode = .scaleAspectFit
            }
        }
        
        // Handle tint color
        if let tintColor = props["tintColor"] as? String {
            imageView.tintColor = ColorUtilities.color(fromHexString: tintColor)
        }
        
        // Handle loading state
        if let isLoading = props["loading"] as? Bool, isLoading {
            // Add loading indicator if needed
            showLoadingIndicator(in: imageView)
        } else {
            // Remove loading indicator if present
            removeLoadingIndicator(from: imageView)
        }
    }
    
    private func loadImage(from source: String, into imageView: UIImageView) {
        // Reset current image
        imageView.image = nil
        
        // Local image resource
        if source.starts(with: "asset://") {
            let imageName = source.replacingOccurrences(of: "asset://", with: "")
            imageView.image = UIImage(named: imageName)
            return
        }
        
        // System icon
        if source.starts(with: "system://") {
            let iconName = source.replacingOccurrences(of: "system://", with: "")
            imageView.image = UIImage(systemName: iconName)
            return
        }
        
        // Remote URL
        if source.starts(with: "http://") || source.starts(with: "https://") {
            // Show loading indicator
            showLoadingIndicator(in: imageView)
            
            // Create URL
            guard let url = URL(string: source) else {
                print("Invalid image URL: \(source)")
                removeLoadingIndicator(from: imageView)
                return
            }
            
            // Use URLSession to fetch image
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    // Remove loading indicator
                    self.removeLoadingIndicator(from: imageView)
                    
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        print("Invalid image data from URL: \(url.absoluteString)")
                        return
                    }
                    
                    // Set image
                    imageView.image = image
                }
            }.resume()
        }
    }
    
    private func showLoadingIndicator(in imageView: UIImageView) {
        // Check if already has a loading indicator
        if imageView.viewWithTag(999) != nil {
            return
        }
        
        // Create and add activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tag = 999
        activityIndicator.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        activityIndicator.startAnimating()
        
        // Add to image view
        imageView.addSubview(activityIndicator)
        
        // Center the activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func removeLoadingIndicator(from imageView: UIImageView) {
        // Find and remove any existing activity indicator
        if let activityIndicator = imageView.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                         eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let imageView = view as? UIImageView else { return }
        
        if eventTypes.contains("load") {
            // Set up image load completion handler
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "onLoadCallback".hashValue)!,
                eventCallback,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                viewId,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        if eventTypes.contains("press") {
            // Enable user interaction
            imageView.isUserInteractionEnabled = true
            
            // Create tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            // Store callback and viewId
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "onPressCallback".hashValue)!,
                eventCallback,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // ViewId should already be set from above
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let imageView = view as? UIImageView else { return }
        
        if eventTypes.contains("load") {
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "onLoadCallback".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        if eventTypes.contains("press") {
            // Remove tap gestures
            imageView.gestureRecognizers?.forEach { recognizer in
                if let tapRecognizer = recognizer as? UITapGestureRecognizer {
                    imageView.removeGestureRecognizer(tapRecognizer)
                }
            }
            
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "onPressCallback".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Reset user interaction if no other gestures are present
            if imageView.gestureRecognizers?.isEmpty ?? true {
                imageView.isUserInteractionEnabled = false
            }
        }
        
        // Clean up viewId if no other callbacks
        if !eventTypes.contains("load") && !eventTypes.contains("press") {
            objc_setAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let callback = objc_getAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "onPressCallback".hashValue)!
              ) as? (String, String, [String: Any]) -> Void,
              let viewId = objc_getAssociatedObject(
                imageView,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!
              ) as? String else {
            return
        }
        
        callback(viewId, "press", [:])
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
