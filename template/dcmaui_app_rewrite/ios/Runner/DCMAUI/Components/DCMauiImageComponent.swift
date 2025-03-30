import UIKit
// Remove or conditionally import Kingfisher, since it might not be available
// import Kingfisher

class DCMauiImageComponent: NSObject, DCMauiComponent {
    // Required initializer to conform to DCMauiComponent
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create an image view
        let imageView = UIImageView()
        
        // Default configuration
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Apply provided props
        updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Apply image source
        if let source = props["source"] as? String {
            loadImage(from: source, into: imageView)
        }
        
        // Apply resize mode / content mode
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
        
        // Apply non-layout styling (border radius, etc.)
        DCMauiLayoutManager.shared.applyStyles(to: imageView, props: props)
        
        return true
    }
    
    private func loadImage(from source: String, into imageView: UIImageView) {
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            // Remote image - load asynchronously
            if let url = URL(string: source) {
                // Create a URLSession task to load the image
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        // Update UI on main thread
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }.resume()
            }
        } else if source.hasPrefix("data:image/") {
            // Base64 encoded image
            if let imageData = parseBase64Image(source) {
                imageView.image = UIImage(data: imageData)
            }
        } else {
            // Local image
            imageView.image = UIImage(named: source)
        }
    }
    
    private func parseBase64Image(_ source: String) -> Data? {
        // Extract base64 data
        if let commaIndex = source.range(of: ",")?.upperBound {
            let base64String = String(source[commaIndex...])
            return Data(base64Encoded: String(base64String))
        }
        return nil
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let imageView = view as? UIImageView else { return }
        
        for eventType in eventTypes {
            switch eventType {
            case "load":
                // Add load event listener - requires a custom implementation
                // We can use Kingfisher's completion handler in the updateView method
                break
                
            case "error":
                // Add error event listener
                break
                
            default:
                break
            }
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clean up any event listeners that were added
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
