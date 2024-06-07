import UIKit

extension UIViewController {
  /// Presents an alert with the specified title and message.
  ///
  /// - Parameters:
  ///   - title: The title of the alert.
  ///   - message: The message body of the alert.
  ///   - actionTitle: The title of the action button. Default is "OK".
  ///   - completion: A closure to be executed when the action button is tapped. Default is `nil`.
  ///   - style: The style of the alert controller. Default is `.alert`.
  ///   - presentationCompletion: A closure to be executed after the alert is presented. Default is `nil`.
  func showAlert(
    title: String,
    message: String = "",
    actionTitle: String = "OK",
    completion: (() -> Void)? = nil,
    style: UIAlertController.Style = .alert,
    presentationCompletion: (() -> Void)? = nil,
    alertType: AlertType = .info
  ) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
    let action = UIAlertAction(title: actionTitle, style: .default) { _ in
      completion?()
    }
    switch alertType {
           case .success:
               alertController.view.tintColor = UIColor.systemGreen
               alertController.title = "✅ " + title
           case .error:
               alertController.view.tintColor = UIColor.systemRed
               alertController.title = "❌ " + title
           case .warning:
               alertController.view.tintColor = UIColor.systemYellow
               alertController.title = "⚠️ " + title
           case .info:
               alertController.view.tintColor = UIColor.systemBlue
               alertController.title = "ℹ️ " + title
           }
    alertController.addAction(action)
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: presentationCompletion)
    }
    }
}
