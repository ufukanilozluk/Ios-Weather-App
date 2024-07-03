import Network
import UIKit

class CustomTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    UITabBarItem.appearance().setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: Colors.tint],
      for: .selected
    )
    tabBar.tintColor = Colors.tint
  }
}
