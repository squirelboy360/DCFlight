import UIKit
import dcflight

class DCFImageComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Dictionary to cache loaded images
    private static var imageCache = [String: UIImage]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create an image view
        let imageView = UIImageView()
        
        // Apply initial styling
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Apply props
        updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Set image source if specified
        if let source = props["source"] as? String {
            // Check if we should use relative path resolution (for local assets)
            let isRelative = props["isRelativePath"] as? Bool ?? false
            
            if isRelative {
                // Use Flutter asset resolution for relative paths
                let key = sharedFlutterViewController?.lookupKey(forAsset: source)
                let mainBundle = Bundle.main
                let path = mainBundle.path(forResource: key, ofType: nil)
                
                print("🖼️ Image asset lookup - key: \(String(describing: key)), path: \(String(describing: path))")
                loadImage(from: source, into: imageView, isRelative: true, path: path)
            } else {
                // Use direct loading for absolute paths or URLs
                loadImage(from: source, into: imageView, isRelative: false, path: nil)
            }
        }
        
        // Set resize mode if specified
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
                imageView.contentMode = .scaleAspectFill
            }
        }
        
        return true
    }
    
    // Load image from URL or resource
    private func loadImage(from source: String, into imageView: UIImageView, isRelative: Bool, path: String?) {
        // Check cache first
        if let cachedImage = DCFImageComponent.imageCache[source] {
            imageView.image = cachedImage
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // If it's a relative path and we have a resolved path
        if isRelative, let resolvedPath = path {
            print("📦 Loading image from resolved path: \(resolvedPath)")
            if let image = UIImage(contentsOfFile: resolvedPath) {
                // Cache the image
                DCFImageComponent.imageCache[source] = image
                
                // Set the image
                imageView.image = image
                
                // Trigger onLoad event
                triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                return
            } else {
                print("❌ Failed to load image from resolved path: \(resolvedPath)")
                triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Image not found at resolved path"])
                return
            }
        }
        
        // Check if it's a URL
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            // Load from URL
            if let url = URL(string: source) {
                // Load image asynchronously
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        // Cache the image
                        DCFImageComponent.imageCache[source] = image
                        
                        DispatchQueue.main.async {
                            UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                imageView.image = image
                            }, completion: { _ in
                                // Trigger onLoad event
                                self.triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                            })
                        }
                    } else {
                        // Trigger onError event
                        DispatchQueue.main.async {
                            self.triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Failed to load image from URL"])
                        }
                    }
                }
                return
            }
        } else {
            // Try to load from bundle directly
            if let image = UIImage(named: source) {
                // Cache the image
                DCFImageComponent.imageCache[source] = image
                
                // Set the image
                imageView.image = image
                
                // Trigger onLoad event
                triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                return
            }
        }
        
        // If we reach here, the image couldn't be loaded
        print("❌ Failed to load image: \(source)")
        triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Image not found"])
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        switch methodName {
        case "setImage":
            if let uri = args["uri"] as? String {
                // Use the same loading logic
                let isRelative = args["isRelativePath"] as? Bool ?? false
                
                if isRelative {
                    let key = sharedFlutterViewController?.lookupKey(forAsset: uri)
                    let path = Bundle.main.path(forResource: key, ofType: nil)
                    loadImage(from: uri, into: imageView, isRelative: true, path: path)
                } else {
                    loadImage(from: uri, into: imageView, isRelative: false, path: nil)
                }
                return true
            }
        case "reload":
            // Force reload the current image
            if let image = imageView.image {
                // Just trigger the onLoad event again
                self.triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                return true
            }
        default:
            return false
        }
        
        return false
    }
}
