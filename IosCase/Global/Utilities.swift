

import Foundation
import Lottie
import Network
import NVActivityIndicatorView
import SCLAlertView
import UIKit

let alertOptions = SCLAlertView.SCLAppearance(
    kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
    kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
    kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
    showCloseButton: false,
    showCircularIcon: true,
    shouldAutoDismiss: true
)

var animationView = AnimationView()
public var formerConnectivityStatus = true

let spinner = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .ballRotateChase, color: UIColor(red: 0.26, green: 0.41, blue: 0.62, alpha: 1.00))

func startLoader(uiView: UIView) {
    spinner.center = uiView.center
    uiView.addSubview(spinner)
    spinner.startAnimating()
}

func showToast(controller: UIViewController? = nil, message: String, seconds: Double, alertType: Alert = .info) {
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

func netWorkConnectivityCheck() {
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

func stopLoader(uiView: UIView) {
    spinner.stopAnimating()
}

func startAnimation(jsonFile: String, view: UIView) {
    animationView = .init(name: jsonFile)

    // 3. Set animation content mode

    animationView.contentMode = .scaleToFill

    // 4. Set animation loop mode

    animationView.loopMode = .loop

    // 5. Adjust animation speed

    animationView.animationSpeed = 0.5
    animationView.layer.cornerRadius = 15
    view.layer.cornerRadius = 15

    view.addSubview(animationView)
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    // 6. Play animation

    animationView.play { _ in
        //  animationView.removeFromSuperview()
    }
}

func getYesterday() -> Date {
    var dateComponents = DateComponents()
    dateComponents.setValue(-1, for: .day) // -1 day

    let now = Date() // Current date
    let yesterday = Calendar.current.date(byAdding: dateComponents, to: now) // Add the DateComponents
    return yesterday!
}

func getTomorrow() -> Date {
    var dateComponents = DateComponents()
    dateComponents.setValue(1, for: .day) // +1 day

    let now = Date() // Current date
    let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now) // Add the DateComponents

    return tomorrow!
}

func nowDateStr(format str: String = "dd.MM.yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "tr")
    dateFormatter.dateFormat = str
    return dateFormatter.string(from: Date())
}

public func daysBetween(start: Date, end: Date) -> Int {
    Calendar.current.dateComponents([.day], from: start, to: end).day!
}

func alert(msg: String!, type: Alert = .err, completion: (() -> Void)? = nil, title: String = "") {
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

public func questionConfirm(msg: String, btnTxt: String? = "Sil", success: @escaping () -> Void, cancel: (() -> Void)?) {
    let alertViewIcon = UIImage(named: "iconplus.png")
    let alertView = SCLAlertView(appearance: alertOptions)

    alertView.addButton(btnTxt!) {
        success()
    }

    alertView.addButton("Vazgeç") {
        cancel?()
    }
    alertView.showNotice("Onaylıyor musunuz?", subTitle: msg, circleIconImage: alertViewIcon)
}

func dateFormatter(to date: DateConvertType, value: Any, inputFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String = "dd.MM.yyyy HH:mm") throws -> Any {
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

func callNumber(phoneNumber: String) {
    if let url = URL(string: "telprompt://\(phoneNumber)") {
        let application = UIApplication.shared
        guard application.canOpenURL(url) else {
            return
        }
        application.open(url, options: [:], completionHandler: nil)
    }
}

func dismissPopoverViewController(_ selfViewController: UIViewController, completion: (() -> Void)?) {
    selfViewController.dismiss(animated: true, completion: { () -> Void in

        if completion != nil {
            completion!()
        }

    })
}

func downloadImage(from url: URL, postImg: UIImageView) {
    getDataImg(from: url) { data, _, error in

        guard let data = data, error == nil else {
            alert(msg: error?.localizedDescription, type: .err)
            return
        }
        DispatchQueue.main.async {
            postImg.image = UIImage(data: data)
        }
    }
}

func getDataImg(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func isNull(data: Any) -> Bool {
    var bool: Bool = false

    if let data = data as? String {
        bool = data.isEmpty
    } else if let data = data as? Array<Any> {
        bool = data.count <= 0
    } else if let data = data as? NSDictionary {
        bool = data.count <= 0
    } else if let data = data as? [String: Any] {
        bool = data.count <= 0
    } else if let data = data as? [[String: Any]] {
        bool = data.count <= 0
    }
    return bool
}

func openThis(webPage url: String) {
    guard let url = URL(string: url) else { return }
    UIApplication.shared.open(url)
}

func dismissKeyboardGestureTap(view: UIView) {
    let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0 ..< length).map { _ in letters.randomElement()! })
}
