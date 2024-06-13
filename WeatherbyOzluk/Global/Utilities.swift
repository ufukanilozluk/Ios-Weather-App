import Foundation
import Lottie
import Network
import UIKit

class Utility {
    
    
    
   
    static func showToast(controller: UIViewController? = nil, message: String, seconds: Double, alertType: AlertType = .info) {
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

        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        } else if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        // ...
        rootViewController?.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

    static func netWorkConnectivityCheck() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in

            if path.status == .satisfied {
              if !GlobalSettings.formerConnectivityStatus {
                    DispatchQueue.main.async {
                        showToast(message: CustomAlerts.internetConnected.alertTitle, seconds: 5, alertType: CustomAlerts.internetConnected.alertType)
                    }
                }
              GlobalSettings.formerConnectivityStatus = true

            } else {
              GlobalSettings.formerConnectivityStatus = false
                DispatchQueue.main.async {
                    showToast(message: CustomAlerts.internetNotConnected.alertTitle, seconds: 5, alertType: CustomAlerts.internetNotConnected.alertType)
                }
            }

            //        print(path.isExpensive)
        }

        monitor.start(queue: DispatchQueue(label: "Network"))
    }


    static func startAnimation(jsonFile: String, view: UIView) {
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

