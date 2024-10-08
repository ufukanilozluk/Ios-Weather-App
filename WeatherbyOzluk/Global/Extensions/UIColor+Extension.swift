import UIKit

extension UIColor {
  static func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
    UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
  }
}
