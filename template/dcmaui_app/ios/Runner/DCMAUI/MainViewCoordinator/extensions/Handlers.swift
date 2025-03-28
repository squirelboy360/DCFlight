//
//  Handlers.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit
import Flutter

// Extension to implement React Native-compatible method handlers
extension DCViewCoordinator {
    // MARK: - Core View Manipulation Methods
    
    // Create a view with the given type, id, and props
    func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let viewType = args["viewType"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for createView", details: nil))
            return
        }
        
        // CRITICAL FIX: Add extra logging
        debugPrint("DC MAUI: Creating view with ID \(viewId) of type \(viewType)")
        
        // Create the view
        guard let view = ViewFactory.createView(viewType: viewType, viewId: viewId, props: props) else {
            result(FlutterError(code: "VIEW_CREATION_FAILED", message: "Failed to create view of type: \(viewType)", details: nil))
            return
        }
        
        // Store the view in our registry
        viewRegistry.registerView(view, withId: viewId)
        
        // CRITICAL FIX: Add special handling for the first (root) view
        if viewId == "view_0" {
            // Find root container
            if let rootContainer = viewRegistry.getView("root") {
                if view.superview == nil {
                    rootContainer.addSubview(view)
                    view.frame = rootContainer.bounds
                    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    debugPrint("DC MAUI: Added root view (view_0) to container with frame: \(view.frame)")
                }
            } else {
                debugPrint("DC MAUI: WARNING - Root container not found, view_0 will be added when container is created")
            }
        }
        
        // Register event listeners
        if let eventListeners = props["_eventListeners"] as? [String] {
            for eventType in eventListeners {
                if let dcView = view as? DCBaseView {
                    dcView.addEventListener(eventType)
                }
            }
        }
        
        result(true)
    }
    
    // Attach a child view to a parent view
    func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for attachView", details: nil))
            return
        }
        
        guard let parentView = viewRegistry.getView(parentId), 
              let childView = viewRegistry.getView(childId) else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "Parent or child view not found", details: nil))
            return
        }
        
        // Update our registry
        viewRegistry.addChild(childId, toParent: parentId)
        
        // Attach the child to the parent in the view hierarchy
        parentView.addSubview(childView)
        
        result(true)
    }
    
    // Set children of a view in the specified order
    func handleSetChildren(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childIds = args["childIds"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setChildren", details: nil))
            return
        }
        
        guard let parentView = viewRegistry.getView(parentId) else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "Parent view not found", details: nil))
            return
        }
        
        // Update our registry
        viewRegistry.setChildren(childIds, forParent: parentId)
        
        // Remove all existing children
        for subview in parentView.subviews {
            if let dcView = subview as? DCBaseView {
                // Only remove DCBaseView subviews, not internal components of our views
                if viewRegistry.getView(dcView.viewId) != nil {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // Add all children in the specified order
        for childId in childIds {
            if let childView = viewRegistry.getView(childId) {
                parentView.addSubview(childView)
            } else {
                print("DC MAUI: Warning - Child view \(childId) not found when setting children of \(parentId)")
            }
        }
        
        // Force layout update
        parentView.setNeedsLayout()
        parentView.layoutIfNeeded()
        
        result(true)
    }
    
    // Update the props of a view
    func handleUpdateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for updateView", details: nil))
            return
        }
        
        guard let view = viewRegistry.getView(viewId) as? DCBaseView else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: nil))
            return
        }
        
        // Update event listeners
        if let eventListeners = props["_eventListeners"] as? [String] {
            for eventType in eventListeners {
                view.addEventListener(eventType)
            }
        }
        
        // Update the view's props
        view.updateProps(props: props)
        
        result(true)
    }
    
    // Delete a view and its children
    func handleDeleteView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for deleteView", details: nil))
            return
        }
        
        // Get the view to be removed
        guard let view = viewRegistry.getView(viewId) else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: nil))
            return
        }
        
        // Remove from superview
        view.removeFromSuperview()
        
        // Remove from registry (this will handle all children recursively)
        viewRegistry.removeView(viewId)
        
        result(true)
    }
    
    // MARK: - Event Handling Methods
    
    // Add event listeners to a view
    func handleAddEventListeners(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypes = args["eventTypes"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for addEventListeners", details: nil))
            return
        }
        
        guard let view = viewRegistry.getView(viewId) as? DCBaseView else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: nil))
            return
        }
        
        // Register each event listener
        for eventType in eventTypes {
            view.addEventListener(eventType)
        }
        
        result(true)
    }
    
    // Remove event listeners from a view
    func handleRemoveEventListeners(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // In a simple implementation we might not need to explicitly remove listeners
        result(true)
    }
    
    // Simulate events (for testing or direct invocation)
    func handleSimulateEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventName = args["eventName"] as? String,
              let params = args["params"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for simulateEvent", details: nil))
            return
        }
        
        sendEvent(viewId: viewId, eventName: eventName, params: params)
        result(true)
    }
    
    // MARK: - Helper Methods for View Hierarchy
    
    // Helper function to describe the view hierarchy
    internal func describeViewHierarchy(_ view: UIView, depth: Int = 0) -> String {
        let indent = String(repeating: "  ", count: depth)
        let viewId = (view as? DCBaseView)?.viewId ?? "unknown"
        var description = "\(indent)- \(viewId): \(type(of: view))"
        
        for subview in view.subviews {
            description += "\n" + describeViewHierarchy(subview, depth: depth + 1)
        }
        
        return description
    }
}
