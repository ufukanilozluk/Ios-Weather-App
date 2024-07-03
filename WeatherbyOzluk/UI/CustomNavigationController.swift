import Foundation
import UIKit

class CustomNavigationController: UINavigationController {
  override init(rootViewController: UIViewController) {
  super.init(rootViewController: rootViewController)
  applyTheme()
  }
  required init?(coder aDecoder: NSCoder) {
  super.init(coder: aDecoder)
  applyTheme()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
  }
  private func applyTheme() {
  // Navigation Bar title text attributes
  let textAttributes = [NSAttributedString.Key.foregroundColor: Colors.tint]
  navigationBar.titleTextAttributes = textAttributes
  navigationBar.barTintColor = Colors.tint
  navigationBar.tintColor = Colors.tint
  }
}
