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

  func showToast(message: String, seconds: Double, alertType: AlertType = .info) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    switch alertType {
    case .warning:
      alert.view.backgroundColor = .yellow
    case .error:
      alert.view.backgroundColor = .red
    case .success:
      alert.view.backgroundColor = .green
    case .info:
      alert.view.backgroundColor = .blue
    }
    alert.view.layer.cornerRadius = 15
    self.present(alert, animated: true, completion: nil)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
      alert.dismiss(animated: true)
    }
  }

  func setEmptyView(title: String, message: String, image: UIImage? = nil) {
    let emptyView = UIView(
      frame: CGRect(
        x: view.center.x,
        y: view.center.y,
        width: view.bounds.size.width,
        height: view.bounds.size.height
      )
    )
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.spacing = 10

    let titleLabel = UILabel()
    let messageLabel = UILabel()
    titleLabel.textColor = UIColor.black
    titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
    messageLabel.textColor = UIColor.lightGray
    messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)

    let imageView = UIImageView()
    if let image = image {
      imageView.image = image
      stackView.addArrangedSubview(imageView)
      // imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
      // imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(messageLabel)
    emptyView.addSubview(stackView)

    stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
    stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true

    //        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 20).isActive = true
    //        titleLabel.leftAnchor.constraint(equalTo: messageLabel.leftAnchor, constant: 0).isActive = true
    //        titleLabel.rightAnchor.constraint(equalTo: messageLabel.rightAnchor, constant: 0).isActive = true
    //
    //        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
    //        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
    //        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true

    titleLabel.text = title
    messageLabel.text = message
    messageLabel.textAlignment = .center
    view = emptyView
  }
}
