package com.example.dc_test;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class DcMauiViewManager {
    private static final String TAG = "DcMauiViewManager";
    private static DcMauiViewManager instance;
    
    // Use a component registry to track component types
    private final ComponentRegistry componentRegistry;
    
    // View registry now tracks both views and their component types
    private final Map<String, ViewInfo> viewRegistry = new HashMap<>();
    private final Context context;
    private ViewGroup rootView;
    
    // Class to hold view info
    private static class ViewInfo {
        final View view;
        final String componentType;
        
        ViewInfo(View view, String componentType) {
            this.view = view;
            this.componentType = componentType;
        }
    }
    
    // Event callback interface
    public interface EventCallback {
        void onEvent(String viewId, String eventType, Map<String, Object> eventData);
    }
    
    private EventCallback eventCallback;
    
    private DcMauiViewManager(Context context) {
        this.context = context;
        this.componentRegistry = new ComponentRegistry(context);
    }
    
    public static DcMauiViewManager getInstance(Context context) {
        if (instance == null) {
            instance = new DcMauiViewManager(context);
        }
        return instance;
    }
    
    public void setRootView(ViewGroup rootView) {
        this.rootView = rootView;
    }
    
    public void setEventCallback(EventCallback callback) {
        this.eventCallback = callback;
    }
    
    // Native JNI methods that will be called from Dart via JNI
    public static boolean initialize() {
        Log.d(TAG, "Initializing DCMAUI Native Bridge");
        return true;
    }
    
    public static boolean createView(String viewId, String type, String propsJson) {
        if (instance == null) {
            Log.e(TAG, "DcMauiViewManager not initialized");
            return false;
        }
        
        try {
            JSONObject props = new JSONObject(propsJson);
            return instance.createViewInternal(viewId, type, props);
        } catch (JSONException e) {
            Log.e(TAG, "Failed to parse props JSON", e);
            return false;
        }
    }
    
    private boolean createViewInternal(String viewId, String type, JSONObject props) {
        // Get component handler from registry
        ComponentHandler handler = componentRegistry.getHandler(type);
        if (handler == null) {
            Log.e(TAG, "No handler for component type: " + type);
            return false;
        }
        
        try {
            // Create the view using the handler
            View view = handler.createView(props);
            
            // Store both view and component type
            viewRegistry.put(viewId, new ViewInfo(view, type));
            
            // If root view is available and this is the root component, add it
            if (rootView != null && viewId.equals("root")) {
                rootView.addView(view);
            }
            
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error creating view", e);
            return false;
        }
    }
    
    public static boolean updateView(String viewId, String propsJson) {
        if (instance == null) {
            return false;
        }
        
        try {
            JSONObject props = new JSONObject(propsJson);
            return instance.updateViewInternal(viewId, props);
        } catch (JSONException e) {
            Log.e(TAG, "Failed to parse props JSON", e);
            return false;
        }
    }
    
    private boolean updateViewInternal(String viewId, JSONObject props) {
        ViewInfo viewInfo = viewRegistry.get(viewId);
        if (viewInfo == null) {
            return false;
        }
        
        try {
            // Get the component handler and update the view
            ComponentHandler handler = componentRegistry.getHandler(viewInfo.componentType);
            if (handler != null) {
                handler.updateView(viewInfo.view, props);
                return true;
            }
            return false;
        } catch (Exception e) {
            Log.e(TAG, "Error updating view", e);
            return false;
        }
    }
    
    // Similar pattern for other methods...
    // The rest of the methods would follow the same approach - get the handler from registry 
    // and delegate the operation
}

// Interface for component handlers
interface ComponentHandler {
    View createView(JSONObject props) throws JSONException;
    void updateView(View view, JSONObject props) throws JSONException;
    void addEventListeners(View view, String viewId, JSONArray eventTypes, DcMauiViewManager.EventCallback callback);
    void removeEventListeners(View view, String viewId, JSONArray eventTypes);
}

// Registry of component handlers
class ComponentRegistry {
    private final Context context;
    private final Map<String, ComponentHandler> handlers = new HashMap<>();
    
    ComponentRegistry(Context context) {
        this.context = context;
        // Register built-in components
        registerHandler("View", new ViewComponentHandler(context));
        registerHandler("Text", new TextComponentHandler(context));
        registerHandler("Button", new ButtonComponentHandler(context));
        registerHandler("Image", new ImageComponentHandler(context));
    }
    
    void registerHandler(String type, ComponentHandler handler) {
        handlers.put(type, handler);
        Log.d("ComponentRegistry", "Registered handler for: " + type);
    }
    
    ComponentHandler getHandler(String type) {
        return handlers.get(type);
    }
}

// Implementation of component handlers would go here
class ViewComponentHandler implements ComponentHandler {
    private final Context context;
    
    ViewComponentHandler(Context context) {
        this.context = context;
    }
    
    @Override
    public View createView(JSONObject props) {
        // Implementation
        return new FrameLayout(context);
    }
    
    @Override
    public void updateView(View view, JSONObject props) {
        // Implementation
    }
    
    @Override
    public void addEventListeners(View view, String viewId, JSONArray eventTypes, DcMauiViewManager.EventCallback callback) {
        // Implementation
    }
    
    @Override
    public void removeEventListeners(View view, String viewId, JSONArray eventTypes) {
        // Implementation
    }
}

// Similar implementations for TextComponentHandler, ButtonComponentHandler, ImageComponentHandler