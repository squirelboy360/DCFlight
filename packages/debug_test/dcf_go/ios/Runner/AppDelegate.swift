import Flutter
import UIKit
import dcflight

@main                                                  
@objc class AppDelegate: DCAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Add UIScene configuration support - the minimal amount needed to suppress warnings
  @available(iOS 13.0, *)
  override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      // This is required to suppress the UIScene lifecycle warning
      return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
