//
//  DCRefreshControl.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// RefreshControl component that matches React Native's RefreshControl
class DCRefreshControl: DCBaseView {
    // The actual refresh control
    private let refreshControl = UIRefreshControl()
    
    // Properties
    private var tintColorValue: UIColor = .systemBlue
    private var titleColor: UIColor = .darkGray
    private var title: String?
    private var isRefreshing: Bool = false
    
    override func setupView() {
        super.setupView()
        
        // Set up refresh control
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        
        // Apply initial configuration
        refreshControl.tintColor = tintColorValue
        
        if let title = title {
            setRefreshControlTitle(title)
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle refresh tint color
        if let colorString = props["tintColor"] as? String, colorString.hasPrefix("#") {
            tintColorValue = UIColor(hexString: colorString)
            refreshControl.tintColor = tintColorValue
        }
        
        // Handle title
        if let title = props["title"] as? String {
            self.title = title
            setRefreshControlTitle(title)
        }
        
        // Handle title color
        if let colorString = props["titleColor"] as? String, colorString.hasPrefix("#") {
            titleColor = UIColor(hexString: colorString)
            if title != nil {
                setRefreshControlTitle(title!)
            }
        }
        
        // Handle refreshing state
        if let refreshing = props["refreshing"] as? Bool {
            isRefreshing = refreshing
            
            if isRefreshing {
                if !refreshControl.isRefreshing {
                    refreshControl.beginRefreshing()
                }
            } else {
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    private func setRefreshControlTitle(_ title: String) {
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.foregroundColor: titleColor]
        )
        refreshControl.attributedTitle = attributedTitle
    }
    
    @objc private func refreshTriggered() {
        // Only send refresh event if this wasn't programmatically triggered
        if !isRefreshing {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onRefresh",
                params: ["target": viewId]
            )
        }
    }
    
    /// Attach this refresh control to a scroll view
    func attachToScrollView(_ scrollView: UIScrollView) {
        scrollView.refreshControl = refreshControl
    }
    
    /// Detach this refresh control from its scroll view
    func detachFromScrollView() {
        refreshControl.removeFromSuperview()
    }
}
