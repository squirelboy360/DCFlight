import UIKit
import yoga

class DCMauiImageComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Apply properties
        _ = updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else {
            return false
        }
        
        // Apply style properties directly to view
        view.applyStyles(props: props)
        
        // Handle image source
        if let source = props["source"] as? String {
            // Load image based on source type
            if source.hasPrefix("http://") || source.hasPrefix("https://") {
                // Load remote image
                loadRemoteImage(imageView, url: source)
            } else {
                // Load local image
                loadLocalImage(imageView, name: source)
            }
        }
        
        // Image-specific properties
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
        
        return true
    }
    
    // Helper method to load remote image
    private func loadRemoteImage(_ imageView: UIImageView, url: String) {
        guard let imageUrl = URL(string: url) else { return }
        
        // Simple image loading - in production, use SDWebImage or similar
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    // Helper method to load local image
    private func loadLocalImage(_ imageView: UIImageView, name: String) {
        imageView.image = UIImage(named: name)
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        guard let imageView = view as? UIImageView,
              let image = imageView.image else {
            return .zero
        }
        
        return image.size
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
