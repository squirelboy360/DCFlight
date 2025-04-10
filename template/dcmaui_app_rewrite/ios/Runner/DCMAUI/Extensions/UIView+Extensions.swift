import UIKit

extension UIView {
    // Add extension to recursively traverse view hierarchy
    func findAllSubviews() -> [UIView] {
        var allSubviews = self.subviews
        for subview in self.subviews {
            allSubviews.append(contentsOf: subview.findAllSubviews())
        }
        return allSubviews
    }
    
    // Add color debugging - set a distinct background color
    func setDebugBackgroundColor() {
        // Generate a semi-random color based on object hash
        let hue = CGFloat(abs(self.hash % 100)) / 100.0
        self.backgroundColor = UIColor(
            hue: hue,
            saturation: 0.8,
            brightness: 0.8,
            alpha: 1.0
        )
    }
    
    // Add method to bring view to front of hierarchy
    func bringToFrontOfSuperviews() {
        if let superview = self.superview {
            superview.bringSubviewToFront(self)
            superview.bringToFrontOfSuperviews()
        }
    }
    
    // Add overlay with frame info
    func addFrameOverlay() {
       
        self.viewWithTag(999999)?.removeFromSuperview()
        
        let overlay = UILabel()
        overlay.tag = 999999
        overlay.font = UIFont.systemFont(ofSize: 10)
        overlay.textColor = .white
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlay.text = "(\(Int(frame.origin.x)), \(Int(frame.origin.y))) \(Int(frame.width))×\(Int(frame.height))"
        overlay.textAlignment = .center
        
        addSubview(overlay)
        bringSubviewToFront(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.centerXAnchor.constraint(equalTo: centerXAnchor),
            overlay.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
        ])
    }
}
