//
//  DCTextInput.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// TextInput component that mirrors React Native's TextInput
class DCTextInput: DCBaseView, UITextFieldDelegate, UITextViewDelegate {
    // The actual input element - either textField or textView
    private var textField: UITextField?
    private var textView: UITextView?
    
    // Properties
    private var isMultiline = false
    private var isSecureEntry = false
    private var placeholder: String?
    private var placeholderColor: UIColor = .lightGray
    private var returnKeyType: UIReturnKeyType = .default
    private var keyboardType: UIKeyboardType = .default
    private var autocapitalizationType: UITextAutocapitalizationType = .sentences
    private var autocorrectionType: UITextAutocorrectionType = .default
    private var enablesReturnKeyAutomatically = false
    private var editable = true
    
    override func setupView() {
        super.setupView()
        
        // Default to single line text field
        setupTextField()
        
        // By default, text inputs should be at least 40 pts high for good touch target
        frame.size.height = max(frame.size.height, 40)
    }
    
    private func setupTextField() {
        if isMultiline {
            setupTextView()
        } else {
            textField = UITextField()
            guard let textField = textField else { return }
            
            textField.delegate = self
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.borderStyle = .none
            textField.backgroundColor = .clear
            
            // Set placeholder if exists
            if let placeholder = placeholder {
                textField.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [.foregroundColor: placeholderColor]
                )
            }
            
            // Configure other properties
            textField.returnKeyType = returnKeyType
            textField.keyboardType = keyboardType
            textField.autocapitalizationType = autocapitalizationType
            textField.autocorrectionType = autocorrectionType
            textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
            textField.isEnabled = editable
            textField.isSecureTextEntry = isSecureEntry
            
            // Add target for text changes
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            
            addSubview(textField)
            
            // Constrain the textField to fill the view
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ])
        }
    }
    
    private func setupTextView() {
        textView = UITextView()
        guard let textView = textView else { return }
        
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        
        // Configure text view properties
        textView.returnKeyType = returnKeyType
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.isEditable = editable
        textView.isScrollEnabled = true
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Add placeholder as needed (UITextView doesn't have native placeholder)
        if placeholder != nil {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        
        addSubview(textView)
        
        // Constrain the textView to fill the view
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        // Check if we need to swap input types
        let wasMultiline = isMultiline
        if let multiline = props["multiline"] as? Bool {
            isMultiline = multiline
            
            // If input type changed, recreate the appropriate view
            if wasMultiline != isMultiline {
                // Remove existing input view
                textField?.removeFromSuperview()
                textField = nil
                textView?.removeFromSuperview()
                textView = nil
                
                // Set up the new input view
                if isMultiline {
                    setupTextView()
                } else {
                    setupTextField()
                }
            }
        }
        
        // Handle value (controlled component)
        if let value = props["value"] as? String {
            if isMultiline {
                if let textView = textView, textView.text != value {
                    textView.text = value
                    textView.textColor = .black // Reset text color in case it was showing placeholder
                }
            } else {
                if let textField = textField, textField.text != value {
                    textField.text = value
                }
            }
        }
        
        // Handle placeholder
        if let placeholder = props["placeholder"] as? String {
            self.placeholder = placeholder
            
            if isMultiline {
                if let textView = textView, textView.text.isEmpty || textView.text == self.placeholder {
                    textView.text = placeholder
                    textView.textColor = placeholderColor
                }
            } else {
                if let textField = textField {
                    textField.attributedPlaceholder = NSAttributedString(
                        string: placeholder,
                        attributes: [.foregroundColor: placeholderColor]
                    )
                }
            }
        }
        
        // Handle placeholder color
        if let placeholderColorString = props["placeholderTextColor"] as? String, placeholderColorString.hasPrefix("#") {
            placeholderColor = UIColor(hexString: placeholderColorString)
            
            if isMultiline {
                if let textView = textView, textView.text == placeholder {
                    textView.textColor = placeholderColor
                }
            } else {
                if let textField = textField, let placeholder = placeholder {
                    textField.attributedPlaceholder = NSAttributedString(
                        string: placeholder,
                        attributes: [.foregroundColor: placeholderColor]
                    )
                }
            }
        }
        
        // Handle security text entry
        if let secureTextEntry = props["secureTextEntry"] as? Bool {
            isSecureEntry = secureTextEntry
            textField?.isSecureTextEntry = secureTextEntry
        }
        
        // Handle keyboard type
        if let keyboardTypeStr = props["keyboardType"] as? String {
            keyboardType = getKeyboardType(keyboardTypeStr)
            textField?.keyboardType = keyboardType
            textView?.keyboardType = keyboardType
        }
        
        // Handle return key type
        if let returnKeyTypeStr = props["returnKeyType"] as? String {
            returnKeyType = getReturnKeyType(returnKeyTypeStr)
            textField?.returnKeyType = returnKeyType
            textView?.returnKeyType = returnKeyType
        }
        
        // Handle auto-capitalization
        if let autoCapitalizeStr = props["autoCapitalize"] as? String {
            autocapitalizationType = getAutocapitalizationType(autoCapitalizeStr)
            textField?.autocapitalizationType = autocapitalizationType
            textView?.autocapitalizationType = autocapitalizationType
        }
        
        // Handle auto-correction
        if let autocorrect = props["autoCorrect"] as? Bool {
            autocorrectionType = autocorrect ? .yes : .no
            textField?.autocorrectionType = autocorrectionType
            textView?.autocorrectionType = autocorrectionType
        }
        
        // Handle editable state
        if let editable = props["editable"] as? Bool {
            self.editable = editable
            textField?.isEnabled = editable
            textView?.isEditable = editable
        }
        
        // Handle auto-focus
        if let autoFocus = props["autoFocus"] as? Bool, autoFocus {
            DispatchQueue.main.async {
                if self.isMultiline {
                    self.textView?.becomeFirstResponder()
                } else {
                    self.textField?.becomeFirstResponder()
                }
            }
        }
        
        // Handle style properties
        if let style = props["style"] as? [String: Any] {
            // Text color
            if let textColorStr = style["color"] as? String, textColorStr.hasPrefix("#") {
                let textColor = UIColor(hexString: textColorStr)
                textField?.textColor = textColor
                
                // For TextView, only change if not showing placeholder
                if let textView = textView, textView.text != placeholder {
                    textView.textColor = textColor
                }
            }
            
            // Font size
            if let fontSize = style["fontSize"] as? CGFloat {
                let fontDescriptor = textField?.font?.fontDescriptor ?? UIFont.systemFont(ofSize: fontSize).fontDescriptor
                let font = UIFont(descriptor: fontDescriptor, size: fontSize)
                textField?.font = font
                textView?.font = font
            }
            
            // Font weight
            if let fontWeightStr = style["fontWeight"] as? String {
                var weight: UIFont.Weight = .regular
                
                switch fontWeightStr {
                    case "bold": weight = .bold
                    case "normal": weight = .regular
                    case "100": weight = .ultraLight
                    case "200": weight = .thin
                    case "300": weight = .light
                    case "400": weight = .regular
                    case "500": weight = .medium
                    case "600": weight = .semibold
                    case "700": weight = .bold
                    case "800": weight = .heavy
                    case "900": weight = .black
                    default: break
                }
                
                let fontSize = textField?.font?.pointSize ?? textView?.font?.pointSize ?? UIFont.systemFontSize
                let font = UIFont.systemFont(ofSize: fontSize, weight: weight)
                
                textField?.font = font
                textView?.font = font
            }
            
            // Text alignment
            if let textAlignStr = style["textAlign"] as? String {
                let alignment: NSTextAlignment
                
                switch textAlignStr {
                    case "center": alignment = .center
                    case "right": alignment = .right
                    case "justify": alignment = .justified
                    default: alignment = .left
                }
                
                textField?.textAlignment = alignment
                textView?.textAlignment = alignment
            }
        }
        
        // Call super after our setup to ensure proper layout
        super.updateProps(props: props)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        let eventParams: [String: Any] = [
            "text": text,
            "target": viewId
        ]
        
        // Send both events with identical parameters
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChange",
            params: eventParams
        )
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChangeText",
            params: eventParams
        )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onFocus",
            params: ["target": viewId]
        )
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onBlur",
            params: ["target": viewId]
        )
        
        // Also send onEndEditing for compatibility
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onEndEditing",
            params: [
                "text": textField.text ?? "",
                "target": viewId
            ]
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Send submitEditing event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onSubmitEditing",
            params: [
                "text": textField.text ?? "",
                "target": viewId
            ]
        )
        
        // Resign first responder (hide keyboard)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let selectedTextRange = textField.selectedTextRange else { return }
        
        let start = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.start)
        let end = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onSelectionChange",
            params: [
                "selection": [
                    "start": start,
                    "end": end
                ],
                "target": viewId
            ]
        )
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        // Handle placeholder
        if let placeholder = placeholder {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textColor = placeholderColor
                return
            } else if textView.text == placeholder && textView.textColor == placeholderColor {
                // Don't send change events for placeholder text
                return
            }
        }
        
        let text = textView.text ?? ""
        let eventParams: [String: Any] = [
            "text": text,
            "target": viewId
        ]
        
        // Send both events with identical parameters
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChange",
            params: eventParams
        )
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onChangeText",
            params: eventParams
        )
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Clear placeholder when editing starts
        if let placeholder = placeholder, textView.text == placeholder && textView.textColor == placeholderColor {
            textView.text = ""
            textView.textColor = .black // Default text color
        }
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onFocus",
            params: ["target": viewId]
        )
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Restore placeholder if needed
        if textView.text.isEmpty, let placeholder = placeholder {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onBlur",
            params: ["target": viewId]
        )
        
        // Also send onEndEditing for compatibility
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onEndEditing",
            params: [
                "text": textView.text,
                "target": viewId
            ]
        )
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textView.selectedRange
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onSelectionChange",
            params: [
                "selection": [
                    "start": selectedRange.location,
                    "end": selectedRange.location + selectedRange.length
                ],
                "target": viewId
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func getKeyboardType(_ type: String) -> UIKeyboardType {
        switch type {
            case "numeric": return .numberPad
            case "decimal-pad": return .decimalPad
            case "number-pad": return .numberPad
            case "phone-pad": return .phonePad
            case "email-address": return .emailAddress
            case "url": return .URL
            default: return .default
        }
    }
    
    private func getReturnKeyType(_ type: String) -> UIReturnKeyType {
        switch type {
            case "done": return .done
            case "go": return .go
            case "next": return .next
            case "search": return .search
            case "send": return .send
            default: return .default
        }
    }
    
    private func getAutocapitalizationType(_ type: String) -> UITextAutocapitalizationType {
        switch type {
            case "characters": return .allCharacters
            case "words": return .words
            case "sentences": return .sentences
            case "none": return .none
            default: return .sentences
        }
    }

    // Public method to set input accessory view
    func setInputAccessoryView(_ accessoryView: UIView?) {
        textField?.inputAccessoryView = accessoryView
        textView?.inputAccessoryView = accessoryView
    }
}
