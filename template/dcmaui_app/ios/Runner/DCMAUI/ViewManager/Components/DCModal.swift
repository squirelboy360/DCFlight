//
//  DCModal.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Modal component that matches React Native's Modal
class DCModal: DCBaseView {
    // Core properties
    private var visible: Bool = false
    private var animationType: String = "slide" // none, slide, fade
    private var presentationStyle: String = "formSheet" // fullScreen, pageSheet, formSheet, overFullScreen
    private var transparent: Bool = false
    private var statusBarTranslucent: Bool = false
    private var hardwareAccelerated: Bool = false
    
    // Additional properties
    private var closeByBackdrop: Bool = false
    private var shouldCloseOnOverlayTap: Bool = false
    
    // Content container that will be presented modally
    private var contentView: UIView?
    private var modalViewController: UIViewController?
    
    // Backdrop view for semi-transparent modals
    private var backdropView: UIView?
    
    override func setupView() {
        super.setupView()
        
        // We need a content container as modal container
        contentView = UIView()
        contentView?.backgroundColor = .clear
        
        // Configure modal view controller
        modalViewController = UIViewController()
        if let modalVC = modalViewController, let contentView = contentView {
            modalVC.view = contentView
            modalVC.modalPresentationStyle = .fullScreen
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Get visibility state
        let wasVisible = visible
        if let visible = props["visible"] as? Bool {
            self.visible = visible
        }
        
        // Configure modal appearance
        if let animationType = props["animationType"] as? String {
            self.animationType = animationType
        }
        
        if let presentationStyle = props["presentationStyle"] as? String {
            self.presentationStyle = presentationStyle
        }
        
        if let transparent = props["transparent"] as? Bool {
            self.transparent = transparent
        }
        
        if let statusBarTranslucent = props["statusBarTranslucent"] as? Bool {
            self.statusBarTranslucent = statusBarTranslucent
        }
        
        if let hardwareAccelerated = props["hardwareAccelerated"] as? Bool {
            self.hardwareAccelerated = hardwareAccelerated
        }
        
        if let closeByBackdrop = props["closeByBackdrop"] as? Bool {
            self.closeByBackdrop = closeByBackdrop
        }
        
        if let shouldCloseOnOverlayTap = props["shouldCloseOnOverlayTap"] as? Bool {
            self.shouldCloseOnOverlayTap = shouldCloseOnOverlayTap
        }
        
        // Apply the appropriate modal presentation style
        configureModalPresentation()
        
        // Handle visibility changes
        if wasVisible != visible {
            if visible {
                presentModal()
            } else {
                dismissModal()
            }
        }
    }
    
    private func configureModalPresentation() {
        guard let modalVC = modalViewController else { return }
        
        // Set presentation style
        switch presentationStyle {
        case "pageSheet":
            modalVC.modalPresentationStyle = .pageSheet
        case "formSheet":
            modalVC.modalPresentationStyle = .formSheet
        case "overFullScreen":
            modalVC.modalPresentationStyle = .overFullScreen
        default:
            modalVC.modalPresentationStyle = .fullScreen
        }
        
        // Set animation style
        switch animationType {
        case "slide":
            modalVC.modalTransitionStyle = .coverVertical
        case "fade":
            modalVC.modalTransitionStyle = .crossDissolve
        default:
            modalVC.modalTransitionStyle = .coverVertical
        }
        
        // Apply transparency
        if transparent {
            modalVC.view.backgroundColor = .clear
            
            // For fully transparent modals with overFullScreen or fullScreen style,
            // we need a semi-transparent backdrop to allow clicking through
            if modalVC.modalPresentationStyle == .overFullScreen || 
               modalVC.modalPresentationStyle == .fullScreen {
                
                // Create backdrop if needed
                if backdropView == nil {
                    backdropView = UIView()
                    backdropView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    backdropView?.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Add tap gesture for backdrop dismissal
                    if closeByBackdrop || shouldCloseOnOverlayTap {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
                        backdropView?.addGestureRecognizer(tapGesture)
                    }
                }
                
                if let backdropView = backdropView {
                    modalVC.view.insertSubview(backdropView, at: 0)
                    
                    // Make backdrop fill the container
                    NSLayoutConstraint.activate([
                        backdropView.topAnchor.constraint(equalTo: modalVC.view.topAnchor),
                        backdropView.leadingAnchor.constraint(equalTo: modalVC.view.leadingAnchor),
                        backdropView.trailingAnchor.constraint(equalTo: modalVC.view.trailingAnchor),
                        backdropView.bottomAnchor.constraint(equalTo: modalVC.view.bottomAnchor)
                    ])
                }
            }
        } else {
            modalVC.view.backgroundColor = .white
            
            // Remove backdrop if modal isn't transparent
            backdropView?.removeFromSuperview()
            backdropView = nil
        }
    }
    
    @objc private func handleBackdropTap() {
        if closeByBackdrop || shouldCloseOnOverlayTap {
            // Request modal close
            requestCloseModal()
        }
    }
    
    private func requestCloseModal() {
        // Send request close event to JavaScript
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onRequestClose",
            params: ["target": viewId]
        )
    }
    
    private func presentModal() {
        // Find the appropriate view controller to present from
        guard let presentingVC = findPresentingViewController() else { return }
        guard let modalVC = modalViewController else { return }
        
        // Ensure modal isn't already presented
        if modalVC.presentingViewController != nil {
            return
        }
        
        // Present the modal
        DispatchQueue.main.async {
            presentingVC.present(modalVC, animated: self.animationType != "none") {
                // Send show event
                self.handleModalShown()
            }
        }
    }
    
    private func dismissModal() {
        guard let modalVC = modalViewController, modalVC.presentingViewController != nil else { return }
        
        DispatchQueue.main.async {
            modalVC.dismiss(animated: self.animationType != "none") {
                // Send dismiss event
                self.handleModalDismissed()
            }
        }
    }
    
    private func handleModalShown() {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onShow",
            params: ["target": viewId]
        )
    }
    
    private func handleModalDismissed() {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onDismiss",
            params: ["target": viewId]
        )
    }
    
    private func findPresentingViewController() -> UIViewController? {
        // Start with the root view controller
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        
        // Find the topmost presented controller
        var topController = rootVC
        while let presentedController = topController.presentedViewController {
            // Skip our own modal controller
            if presentedController == modalViewController {
                break
            }
            topController = presentedController
        }
        
        return topController
    }
    
    // Override addSubview to add views to the content view
    override func addSubview(_ view: UIView) {
        if view == contentView {
            super.addSubview(view)
        } else {
            contentView?.addSubview(view)
        }
    }
    
    // Clean up when removed
    override func removeFromSuperview() {
        // Ensure modal is dismissed when view is removed
        if visible {
            dismissModal()
        }
        
        super.removeFromSuperview()
    }
}
