

import Foundation
import Lottie
import Network
import NVActivityIndicatorView
import SCLAlertView
import UIKit

class Utility {
    
    
    private static var formerConnectivityStatus = true
    private static let spinner = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 50, height: 50),
        type: .ballRotateChase,
        color: UIColor(red: 0.26, green: 0.41, blue: 0.62, alpha: 1.00)
    )

    static func showToast(controller: UIViewController? = nil, message: String, seconds: Double, alertType: AlertType = .info) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        switch alertType {
        case .warning:
            alert.view.backgroundColor = .yellow
        case .err:
            alert.view.backgroundColor = .red
        case .succ:
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
                if !formerConnectivityStatus {
                    DispatchQueue.main.async {
                        showToast(message: CustomAlerts.internetConnected.alertTitle, seconds: 5, alertType: CustomAlerts.internetConnected.alertType)
                    }
                }
                formerConnectivityStatus = true

            } else {
                formerConnectivityStatus = false
                DispatchQueue.main.async {
                    showToast(message: CustomAlerts.internetNotConnected.alertTitle, seconds: 5, alertType: CustomAlerts.internetNotConnected.alertType)
                }
            }

            //        print(path.isExpensive)
        }

        monitor.start(queue: DispatchQueue(label: "Network"))
    }

    static func stopLoader(uiView: UIView) {
        Utility.spinner.stopAnimating()
    }

    static func startAnimation(jsonFile: String, view: UIView) {
        var animationView = AnimationView()
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

    static func alert(msg: String!, type: AlertType = .err, title: String = "", completion: (() -> Void)? = nil) {
        let alertOptions = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: true,
            shouldAutoDismiss: true
        )
        var color: UIColor?
        let alertView = SCLAlertView(appearance: alertOptions)

        switch type {
        case .err:
            color = UIColor(red: 0.79, green: 0.11, blue: 0.18, alpha: 1.0)
            alertView.showError(title.isEmpty ? "Error!" : title, subTitle: msg!)

            break
        case .succ:
            color = UIColor(red: 0.00, green: 0.71, blue: 0.47, alpha: 1.0)
            alertView.showSuccess(title.isEmpty ? "Success" : title, subTitle: msg!)
            break
        case .warning:
            color = UIColor(red: 1.00, green: 0.81, blue: 0.25, alpha: 1.0)
            alertView.showWarning(title.isEmpty ? "Warning!" : title, subTitle: msg!)
            break
        case .info:
            color = UIColor(red: 0.00, green: 0.41, blue: 0.73, alpha: 1.0)
            alertView.showInfo(title.isEmpty ? "Info" : title, subTitle: msg!)
            break
        }

        let close = alertView.addButton("Close") {
            if completion != nil {
                completion!()
            }
        }
        close.backgroundColor = color
    }

    static func dateFormatter(to date: DateConvertType, value: Any, inputFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String = "dd.MM.yyyy HH:mm") throws -> Any {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = inputFormat
        let rv: Any

        switch date {
        case .toDate:
            rv = formatter.date(from: value as! String)!
            break
        case .toStr:
            formatter.dateFormat = outputFormat
            rv = formatter.string(from: value as! Date)
            break
        case .strToStr:
            let date = try dateFormatter(to: .toDate, value: value, inputFormat: inputFormat) as! Date
            formatter.dateFormat = outputFormat
            rv = formatter.string(from: date)

            //        Yada yukarısı olmadan aşağıdaki gibi recursive de yapabilirsin ilk stringi date çevirdikten sonra
            //        rv = try dateFormatter(to: .toStr, value: date, inputFormat: inputFormat, outputFormat: outputFormat) as! String
            break
        }

        return rv
    }
}

extension Utility {
    
    enum DateConvertType: Int {
         case toStr
         case toDate
         case strToStr
     }
    
}
