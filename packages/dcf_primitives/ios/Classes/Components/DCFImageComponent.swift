import UIKit
import yoga
import dcflight

class DCFImageComponent: NSObject, DCFComponent, ComponentMethodHandler {
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
            loadImage(from: source, into: imageView, placeholder: props["placeholder"] as? String)
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
    private func loadImage(from source: String, into imageView: UIImageView, placeholder: String?) {
        // Check if it's a URL
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            // Load from URL
            if let url = URL(string: source) {
                // Set placeholder if available
                if let placeholder = placeholder, let placeholderImage = UIImage(named: placeholder) {
                    imageView.image = placeholderImage
                }
                
                // Load image asynchronously
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
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
                            self.triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Failed to load image"])
                        }
                    }
                }
            }
        } else {
            // Load from local resource
            if let image = UIImage(named: source) {
                imageView.image = image
                // Trigger onLoad event
                self.triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            } else {
                // Trigger onError event
                self.triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Image not found"])
            }
        }
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        switch methodName {
        case "setImage":
            if let uri = args["uri"] as? String {
                loadImage(from: uri, into: imageView, placeholder: nil)
                return true
            }
        case "reload":
            // Get the current source from associated object
            if let source = imageView.image {
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
