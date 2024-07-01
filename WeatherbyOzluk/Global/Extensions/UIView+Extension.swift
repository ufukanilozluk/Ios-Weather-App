import UIKit
import Lottie

extension UIView {
  var width: CGFloat {
    return frame.size.width
  }

  var height: CGFloat {
    return frame.size.height
  }

  func addSubviews(_ views: UIView...) {
    for view in views {
      addSubview(view)
    }
  }

  func showSpinner() {
    // Dim view oluştur ve ayarla
    let dimView = UIView(frame: self.bounds)
    dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
    dimView.translatesAutoresizingMaskIntoConstraints = false
    dimView.tag = 999 // Dim view için benzersiz bir tag

    // Spinner'ı oluştur ve ayarla
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()

    // Dim view'a spinner'ı ekle
    dimView.addSubview(spinner)

    // Spinner'ı dim view'ın ortasına yerleştir
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: dimView.centerYAnchor)
    ])

    // Dim view'ı ana view'a ekle
    self.addSubview(dimView)

    // Dim view'ı ana view'ın boyutlarına göre ayarla
    NSLayoutConstraint.activate([
      dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      dimView.topAnchor.constraint(equalTo: self.topAnchor),
      dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }

  func removeSpinner() {
    // Dim view'ı tag'ine göre bul ve kaldır
    if let dimView = self.viewWithTag(999) {
      dimView.removeFromSuperview()
    }
  }

  func startAnimation(jsonFile: String, view: UIView) {
    var animationView = LottieAnimationView()
    animationView = .init(name: jsonFile)
    animationView.contentMode = .scaleToFill
    animationView.loopMode = .loop
    animationView.animationSpeed = 0.5
    animationView.layer.cornerRadius = 15
    view.layer.cornerRadius = 15
    view.addSubview(animationView)
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    animationView.play()
  }
}
