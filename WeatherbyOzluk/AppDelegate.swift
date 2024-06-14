import Network
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Başlangıç view controller'ını al
      if let rootViewController = window?.rootViewController {
          APIManager.netWorkConnectivityCheck(onViewController: rootViewController)
      }
      return true
  }
}
