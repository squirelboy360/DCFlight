import UIKit
import dcflight

//Clone or copy this file with the accompanying dart side to create a custom icon package
class DCFIconComponent: NSObject, DCFComponent {
    private let svgComponent = DCFSvgComponent()

    required override init() {
        super.init()
    }

    func createView(props: [String: Any]) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        updateView(imageView, withProps: props)
        return imageView
    }

    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        guard let iconName = props["name"] as? String else { return false }
        guard let packageName = props["package"] as? String else { return false }

        // Use Flutter lookupKey to resolve logical asset path
        guard let key = sharedFlutterViewController?.lookupKey(forAsset: "assets/icons/\(iconName).svg", fromPackage: packageName) else {
            print("❌ Could not resolve asset key for \(iconName)")
            return false
        }
        let mainBundle = Bundle.main
        let path = mainBundle.path(forResource: key, ofType: nil)
print("icon path: \(String(describing: path))")
        var svgProps = props
        svgProps["asset"] = path
        return svgComponent.updateView(imageView, withProps: svgProps)
    }
}
