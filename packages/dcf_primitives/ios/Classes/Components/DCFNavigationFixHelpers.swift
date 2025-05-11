//
//  DCFNavigationFixHelpers.swift
//  dcf_primitives
//
//  Created on 2025-05-11.
//

import UIKit

/**
 * Classes to fix navigation constraint conflicts between Yoga and UIKit
 */

// MARK: - Safe Container Views

class SafeContainerView: UIView {
    override class var requiresConstraintBasedLayout: Bool {
        return false
    }
    
    override func updateConstraints() {
        // Prevent Auto Layout from being used in this view
        // This is crucial for mixing with Yoga layout
        super.updateConstraints()
    }
}

// MARK: - Safe Navigation Controller

class DCFSafeNavigationController: UINavigationController {
    // Track if we've already fixed the constraints
    private var constraintsFixed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Critical: force autoresizing mask for the view
        view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Fix the problematic constraint on every layout pass
        if !constraintsFixed {
            fixNavigationBarConstraints()
            constraintsFixed = true
        }
    }
    
    override func updateViewConstraints() {
        // Fix constraints before the update
        fixNavigationBarConstraints()
        super.updateViewConstraints()
    }
    
    private func fixNavigationBarConstraints() {
        // Find the conflicting constraint exactly matching the error description
        var constraintToFix: NSLayoutConstraint? = nil
        
        for constraint in view.constraints {
            if let firstItem = constraint.firstItem as? UINavigationBar,
               let secondItem = constraint.secondItem as? UILayoutGuide,
               secondItem.identifier == "UINavigationControllerContentFocusContainerGuide" {
                constraintToFix = constraint
                break
            }
            
            if let secondItem = constraint.secondItem as? UINavigationBar,
               let firstItem = constraint.firstItem as? UILayoutGuide,
               firstItem.identifier == "UINavigationControllerContentFocusContainerGuide" {
                constraintToFix = constraint
                break
            }
        }
        
        // Deactivate the problematic constraint
        constraintToFix?.isActive = false
    }
}

// MARK: - Safe Tab Bar Controller 

class DCFSafeTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Critical: force autoresizing mask for the view
        view.translatesAutoresizingMaskIntoConstraints = true
    }
}
