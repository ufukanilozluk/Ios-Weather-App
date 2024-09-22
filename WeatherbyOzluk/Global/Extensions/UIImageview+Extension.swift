import UIKit

extension UIImageView {
  convenience init?(named name: String, contentMode: UIView.ContentMode = .scaleToFill) {
    guard let image = UIImage(named: name) else {
      preconditionFailure("Image with name \(name) could not be found in assets.")
    }
    self.init(image: image)
    self.contentMode = contentMode
    translatesAutoresizingMaskIntoConstraints = false
  }
}
