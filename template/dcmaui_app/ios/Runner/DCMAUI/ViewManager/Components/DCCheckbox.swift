//
//  DCCheckbox.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Custom Checkbox component (similar to React Native pattern for custom components)
class DCCheckbox: DCBaseView {
    private let checkboxView = UIView()
    private let checkmarkImageView = UIImageView()
    private var isChecked = false
    
    // Renamed to avoid conflicts with UIView's tintColor
    private var checkboxTintColor: UIColor = .systemBlue
    private var checkedColor: UIColor = .systemBlue
    private var boxSize: CGFloat = 24.0
    
    override func setupView() {
        super.setupView()
        
        // Set up the checkbox container
        checkboxView.translatesAutoresizingMaskIntoConstraints = false
        checkboxView.layer.borderWidth = 2.0
        checkboxView.layer.borderColor = checkboxTintColor.cgColor
        checkboxView.layer.cornerRadius = 4.0
        addSubview(checkboxView)
        
        NSLayoutConstraint.activate([
            checkboxView.widthAnchor.constraint(equalToConstant: boxSize),
            checkboxView.heightAnchor.constraint(equalToConstant: boxSize),
            checkboxView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        // Set up checkmark image
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .white
        checkmarkImageView.isHidden = true
        
        // Use SF Symbol for checkmark on iOS 13+
        if #available(iOS 13.0, *) {
            checkmarkImageView.image = UIImage(systemName: "checkmark")
        } else {
            // Create a simple checkmark for older iOS
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 16), false, 0)
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.white.cgColor)
            context?.setLineWidth(2)
            context?.move(to: CGPoint(x: 4, y: 8))
            context?.addLine(to: CGPoint(x: 7, y: 12))
            context?.addLine(to: CGPoint(x: 12, y: 5))
            context?.strokePath()
            let checkmark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            checkmarkImageView.image = checkmark
        }
        
        checkboxView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalTo: checkboxView.widthAnchor, multiplier: 0.6),
            checkmarkImageView.heightAnchor.constraint(equalTo: checkboxView.heightAnchor, multiplier: 0.6)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle value (checked state)
        if let checked = props["value"] as? Bool {
            setChecked(checked, animated: false)
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.6 : 1.0
        }
        
        // Handle colors
        if let style = props["style"] as? [String: Any] {
            if let colorStr = style["tintColor"] as? String, colorStr.hasPrefix("#") {
                checkboxTintColor = UIColor(hexString: colorStr)
                checkboxView.layer.borderColor = checkboxTintColor.cgColor
            }
            
            if let colorStr = style["checkedColor"] as? String, colorStr.hasPrefix("#") {
                checkedColor = UIColor(hexString: colorStr)
                if isChecked {
                    checkboxView.backgroundColor = checkedColor
                }
            }
            
            if let size = style["boxSize"] as? CGFloat, size > 0 {
                boxSize = size
                
                // Update size constraints
                for constraint in checkboxView.constraints {
                    if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                        constraint.constant = boxSize
                    }
                }
            }
        }
    }
    
    @objc private func handleTap() {
        // Toggle checked state
        let newValue = !isChecked
        setChecked(newValue, animated: true)
        
        // Send event in React Native style
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChange",
            params: [
                "value": newValue
            ]
        )
    }
    
    private func setChecked(_ checked: Bool, animated: Bool) {
        isChecked = checked
        
        let updateUI = {
            self.checkmarkImageView.isHidden = !self.isChecked
            self.checkboxView.backgroundColor = self.isChecked ? self.checkedColor : UIColor.clear
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: updateUI)
        } else {
            updateUI()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Provide a size that includes both the checkbox and reasonable padding
        return CGSize(width: boxSize + 16, height: boxSize + 8)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: boxSize + 16, height: boxSize + 8)
    }
}
