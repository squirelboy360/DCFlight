import UIKit
import dcflight // for sharedFlutterViewController

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

        // Use Flutter lookupKey to resolve logical asset path
        guard let key = sharedFlutterViewController?.lookupKey(forAsset: "assets/icons/\(iconName)", fromPackage: "dcf_primitives") else {
            print("❌ Could not resolve asset key for \(iconName)")
            return false
        }

        // Load the asset from the dcf_primitives bundle
        guard let frameworkURL = Bundle.main.privateFrameworksURL?.appendingPathComponent("dcf_primitives.framework"),
              let bundle = Bundle(url: frameworkURL) else {
            print("❌ Could not load dcf_primitives framework bundle")
            return false
        }

        let assetURL = bundle.url(forResource: key, withExtension: nil)

        if let assetPath = assetURL?.path {
            var svgProps = props
            svgProps["asset"] = assetPath
            return svgComponent.updateView(imageView, withProps: svgProps)
        } else {
            print("❌ Could not find asset at resolved path for \(iconName)")
        }

        return false
    }
}
