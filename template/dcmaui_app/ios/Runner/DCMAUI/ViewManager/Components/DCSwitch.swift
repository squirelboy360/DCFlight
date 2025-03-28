//
//  DCSwitch.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Switch component
class DCSwitch: DCBaseView {
    private let switchControl = UISwitch()
    
    override func setupView() {
        super.setupView()
        
        // Set up switch control
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchControl)
        
        // Add target for value change
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        // Center the switch in the view
        NSLayoutConstraint.activate([
            switchControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle value
        if let value = props["value"] as? Bool {
            switchControl.isOn = value
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            switchControl.isEnabled = !disabled
        }
        
        // Handle track color (off state)
        if let trackColorString = props["trackColor"] as? String, trackColorString.hasPrefix("#") {
            switchControl.tintColor = UIColor(hexString: trackColorString).withAlphaComponent(0.4)
        }
        
        // Handle thumb color (off state)
        if let thumbColorString = props["thumbColor"] as? String, thumbColorString.hasPrefix("#") {
            // Note: iOS doesn't allow customizing thumb color directly in standard UISwitch
            // For iOS 13+, we can use the thumbTintColor property
            if #available(iOS 13.0, *) {
                switchControl.thumbTintColor = UIColor(hexString: thumbColorString)
            }
        }
        
        // Handle active track color (on state)
        if let activeTrackColorString = props["activeTrackColor"] as? String, activeTrackColorString.hasPrefix("#") {
            switchControl.onTintColor = UIColor(hexString: activeTrackColorString)
        }
        
        // Apply any custom style
        if let style = props["style"] as? [String: Any] {
            // Apply transform if specified
            if let transform = style["transform"] as? [[String: Any]] {
                var scaleX: CGFloat = 1.0
                var scaleY: CGFloat = 1.0
                
                for transformItem in transform {
                    if let scale = transformItem["scale"] as? CGFloat {
                        scaleX = scale
                        scaleY = scale
                    }
                    
                    if let scaleXValue = transformItem["scaleX"] as? CGFloat {
                        scaleX = scaleXValue
                    }
                    
                    if let scaleYValue = transformItem["scaleY"] as? CGFloat {
                        scaleY = scaleYValue
                    }
                }
                
                switchControl.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            }
        }
    }
    
    @objc private func switchValueChanged() {
        // Send event with React Native style parameters
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChange",
            params: [
                "value": switchControl.isOn,
                "target": viewId,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
    }
    
    override var intrinsicContentSize: CGSize {
        // Add some padding around the switch
        let switchSize = switchControl.intrinsicContentSize
        return CGSize(
            width: switchSize.width + 16,
            height: switchSize.height + 16
        )
    }
}
