package com.example.dc_test

import android.os.Bundle
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private lateinit var rootContainer: FrameLayout
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Note: The FlutterEngine is created in headless mode,
        // Flutter UI won't be displayed - we're using native UI instead
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create a native root container for our UI
        rootContainer = FrameLayout(this)
        rootContainer.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        
        // Set as our content view
        setContentView(rootContainer)
        
        // Initialize DCMAUI native bridge
        setupDCMauiNativeBridge(rootContainer)
    }
    
    private fun setupDCMauiNativeBridge(rootView: ViewGroup) {
        // Initialize the view manager
        val viewManager = DcMauiViewManager.getInstance(this)
        viewManager.setRootView(rootView)
        
        // Create a root container in the registry with a known ID
        DcMauiViewManager.createView(
            "root", 
            "View", 
            "{\"backgroundColor\":\"#FFFFFF\"}"
        )
        
        println("DC MAUI: Native bridge initialized")
    }
}
