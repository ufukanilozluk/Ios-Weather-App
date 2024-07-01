import UIKit

class BaseVController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  func setConfig() {
    let textAttributes = [NSAttributedString.Key.foregroundColor: Colors.tint]
    navigationController?.navigationBar.titleTextAttributes = textAttributes
    // navigationController?.navigationBar.barTintColor = Colors.iosCasePurple
    navigationController?.navigationBar.tintColor = Colors.tint
  }
}
