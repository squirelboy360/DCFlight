//
//  ViewFactory.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Protocol for views that can be updated
protocol ViewUpdatable {
    func updateProps(props: [String: Any])
}

/// Factory for creating native views from view types and props
class ViewFactory {
    // Keep track of created views for debugging
    static var createdViewsInfo: [String: String] = [:]
    
    /// Create a view of the specified type with the given props
    static func createView(viewType: String, viewId: String, props: [String: Any]) -> UIView? {
        print("DC MAUI: Creating view of type \(viewType) with ID \(viewId)")
        
        let view: UIView?
        
        // Map viewType to actual component - Standardized to match React Native's component names
        switch viewType {
        case "View", "DCView":
            view = DCView(viewId: viewId, props: props)
            
        case "Text", "DCText":
            view = DCText(viewId: viewId, props: props)
            
        case "Image", "DCImage":
            view = DCImage(viewId: viewId, props: props)
            
        case "Button", "DCButton":
            view = DCButton(viewId: viewId, props: props)
            
        case "TextInput", "DCTextInput":
            view = DCTextInput(viewId: viewId, props: props)
            
        case "ScrollView", "DCScrollView":
            view = DCScrollView(viewId: viewId, props: props)
            
        case "Switch", "DCSwitch":
            view = DCSwitch(viewId: viewId, props: props)
            
        case "Modal", "DCModal":
            view = DCModal(viewId: viewId, props: props)
            
        case "GestureDetector", "DCGestureDetector":
            view = DCGestureDetector(viewId: viewId, props: props)
            
        case "SafeAreaView", "DCSafeAreaView":
            view = DCSafeAreaView(viewId: viewId, props: props)
            
        case "CheckBox", "DCCheckbox":
            view = DCCheckbox(viewId: viewId, props: props)
            
        case "ActivityIndicator", "DCActivityIndicator":
            view = DCActivityIndicator(viewId: viewId, props: props)
            
        case "AnimatedView", "DCAnimatedView", "Animated.View":
            view = DCAnimatedView(viewId: viewId, props: props)
            
        case "TouchableOpacity", "DCTouchableOpacity":
            view = DCTouchableOpacity(viewId: viewId, props: props)
            
        case "TouchableHighlight", "DCTouchableHighlight":
            view = DCTouchableHighlight(viewId: viewId, props: props)
            
        case "TouchableWithoutFeedback", "DCTouchableWithoutFeedback":
            view = DCTouchableWithoutFeedback(viewId: viewId, props: props)
            
        case "ListView", "DCListView", "FlatList":
            view = DCListView(viewId: viewId, props: props)
            
        case "DCSectionList":
            view = DCSectionList(viewId: viewId, props: props)
            
        case "DCPressable":
            view = DCPressable(viewId: viewId, props: props)
            
        case "DCDrawer":
            view = DCDrawer(viewId: viewId, props: props)
            
        case "DCKeyboardAvoidingView":
            view = DCKeyboardAvoidingView(viewId: viewId, props: props)
            
        case "DCInputAccessoryView":
            view = DCInputAccessoryView(viewId: viewId, props: props)
            
        case "DCRefreshControl":
            let refreshControl = DCRefreshControl(viewId: viewId, props: props)
            // Note: RefreshControl is typically attached to a scroll view, not added directly to view hierarchy
            return refreshControl
            
        case "DCImageBackground":
            view = DCImageBackground(viewId: viewId, props: props)
            
        // Static/Utility components that don't create views directly
        case "DCActionSheetIOS":
            // Show action sheet with the provided options
            DCActionSheetIOS.showActionSheet(viewId: viewId, options: props)
            return UIView() // Return empty view since this is more of an action than a view
            
        case "DCShareActionSheet":
            // Handle share sheet (implementation would be similar to ActionSheetIOS)
            return UIView() // Return empty view 
            
        case "DCStatusBar":
            // Update status bar settings
            if let viewType = props["type"] as? String, viewType == "StatusBar" {
                return DCStatusBar(viewId: viewId, props: props)
            }
            return UIView() // Return empty view since StatusBar affects system UI
            
        default:
            // Default to base view for unknown types for graceful fallback
            print("DC MAUI: WARNING - Unknown view type: \(viewType), using default DCView")
            view = DCView(viewId: viewId, props: props)
        }
        
        // Track created views
        if let view = view {
            createdViewsInfo[viewId] = viewType
            
            // Root view handling
            if viewId == "view_0" {
                setupRootView(view)
            }
        }
        
        return view
    }
    
    // Separate method for cleaner root view setup (React Native style)
    private static func setupRootView(_ rootView: UIView) {
        // CRITICAL FIX: Don't add root view directly - DCViewCoordinator will handle it
        print("DC MAUI: Root view created with ID view_0 - it will be added to the root container")
        
        // Set accessibility identifier for debugging
        rootView.accessibilityIdentifier = "DCMAUIRootComponentView"
        
        // Make sure it will size correctly when added to container
        rootView.translatesAutoresizingMaskIntoConstraints = true
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Register with coordinator to add to root container
        if let container = DCViewCoordinator.shared?.viewRegistry.getView("root") {
            container.addSubview(rootView)
            rootView.frame = container.bounds
        } else {
            print("DC MAUI: WARNING - Root container not found, view_0 will need to be added later")
        }
    }
    
    // Add a debug method to print all created views
    static func debugPrintCreatedViews() {
        print("DC MAUI DEBUG: ---- CREATED VIEWS ----")
        for (viewId, viewType) in createdViewsInfo {
            print("DC MAUI DEBUG: View ID: \(viewId), Type: \(viewType)")
        }
        print("DC MAUI DEBUG: ---- END CREATED VIEWS ----")
    }
    
    /// Create an empty view with a placeholder
    static func createEmptyView(message: String = "Empty View") -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = UIColor.lightGray
        
        // Add a label to show it's an empty view
        let label = UILabel(frame: view.bounds)
        label.text = message
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        view.addSubview(label)
        
        return view
    }
}
