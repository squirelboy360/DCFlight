//
//  ViewRegistry.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Registry for tracking native views
class ViewRegistry {
    // Singleton instance
    static let shared = ViewRegistry()
    
    // Map of view ID to view
    private var viewMap = [String: UIView]()
    
    // Map of parent ID to child IDs
    private var parentChildMap = [String: [String]]()
    
    // Map of child ID to parent ID
    private var childParentMap = [String: String]()
    
    /// Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        // Add view to the registry
        viewMap[viewId] = view
        
        // Set view ID on DCBaseView if applicable
        if let dcView = view as? DCBaseView {
            // This method was added to DCBaseView already
            dcView.setViewIdIfNeeded(viewId)
        }
    }
    
    /// Register a view (uses view's viewId)
    func registerView(_ view: DCBaseView) {
        // Add view to the registry using its own viewId
        viewMap[view.viewId] = view
    }
    
    /// Get a view by its ID
    func getView(_ viewId: String) -> UIView? {
        return viewMap[viewId]
    }
    
    /// Remove a view and its children
    func removeView(_ viewId: String) {
        // Remove all child views first
        let childIds = parentChildMap[viewId] ?? []
        for childId in childIds {
            removeView(childId)
        }
        
        // Remove this view from parent's children list
        if let parentId = childParentMap[viewId] {
            parentChildMap[parentId]?.removeAll { $0 == viewId }
        }
        
        // Remove mappings
        childParentMap.removeValue(forKey: viewId)
        parentChildMap.removeValue(forKey: viewId)
        viewMap.removeValue(forKey: viewId)
    }
    
    /// Add a child view to a parent
    func addChild(_ childId: String, toParent parentId: String) {
        // Remove from previous parent if exists
        if let oldParentId = childParentMap[childId], oldParentId != parentId {
            parentChildMap[oldParentId]?.removeAll { $0 == childId }
        }
        
        // Add to new parent
        if parentChildMap[parentId] == nil {
            parentChildMap[parentId] = [childId]
        } else if !parentChildMap[parentId]!.contains(childId) {
            parentChildMap[parentId]!.append(childId)
        }
        
        // Update child->parent reference
        childParentMap[childId] = parentId
    }
    
    /// Set the children of a parent view
    func setChildren(_ childIds: [String], forParent parentId: String) {
        // Remove old parent references for current children
        let currentChildren = parentChildMap[parentId] ?? []
        for childId in currentChildren {
            if !childIds.contains(childId) {
                childParentMap.removeValue(forKey: childId)
            }
        }
        
        // Update parent->children map
        parentChildMap[parentId] = childIds
        
        // Update children->parent map
        for childId in childIds {
            childParentMap[childId] = parentId
        }
    }
    
    /// Get all registered views
    func getAllViews() -> [String: UIView] {
        return viewMap
    }
    
    /// Get the children of a view
    func getChildren(forParent parentId: String) -> [String] {
        return parentChildMap[parentId] ?? []
    }
    
    /// Get the parent of a view
    func getParent(forChild childId: String) -> String? {
        return childParentMap[childId]
    }
    
    /// Get a string representation of the view hierarchy
    private func describeView(_ view: UIView, viewId: String, depth: Int) -> String {
        let indent = String(repeating: "  ", count: depth)
        var description = "\(indent)- \(viewId): \(type(of: view))\n"
        
        // Add child descriptions
        let childIds = parentChildMap[viewId] ?? []
        for childId in childIds {
            if let childView = viewMap[childId] {
                description += describeView(childView, viewId: childId, depth: depth + 1)
            }
        }
        
        return description
    }
    
    // Debug method to log the entire view hierarchy
    func logViewHierarchy() -> String {
        var output = "View Registry Contents:\n"
        
        // Log all views
        output += "Registered Views:\n"
        for (viewId, _) in viewMap {
            output += "- \(viewId)\n"
        }
        
        // Log parent-child relationships
        output += "\nParent-Child Relationships:\n"
        for (parentId, childIds) in parentChildMap {
            output += "Parent \(parentId) -> Children: \(childIds.joined(separator: ", "))\n"
        }
        
        // Check for orphaned views (those without parents, excluding root)
        let orphanedViews = viewMap.keys.filter { viewId in
            return viewId != "root" && viewId != "window" && !childParentMap.keys.contains(viewId)
        }
        
        if !orphanedViews.isEmpty {
            output += "\nOrphaned Views (no parent):\n"
            for viewId in orphanedViews {
                output += "- \(viewId)\n"
            }
        }
        
        // Add detailed view tree
        output += "\nDetailed View Tree:\n"
        if let rootView = getView("root") {
            output += describeViewRecursively(rootView, viewId: "root", depth: 0)
        } else {
            output += "No root view found!\n"
        }
        
        return output
    }
    
    // Helper for recursively describing views
    private func describeViewRecursively(_ view: UIView, viewId: String, depth: Int) -> String {
        let indent = String(repeating: "  ", count: depth)
        let className = type(of: view)
        var output = "\(indent)- \(viewId): \(className)"
        
        // Add frame info
        output += " [frame: \(view.frame.origin.x),\(view.frame.origin.y),\(view.frame.size.width),\(view.frame.size.height)]"
        
        // Add hidden status
        if view.isHidden {
            output += " [HIDDEN]"
        }
        
        // Add alpha
        if view.alpha < 1.0 {
            output += " [alpha: \(view.alpha)]"
        }
        
        output += "\n"
        
        // Add children
        if let childIds = parentChildMap[viewId] {
            for childId in childIds {
                if let childView = getView(childId) {
                    output += describeViewRecursively(childView, viewId: childId, depth: depth + 1)
                } else {
                    output += "\(indent)  - \(childId): MISSING VIEW REFERENCE\n"
                }
            }
        }
        
        return output
    }
}
