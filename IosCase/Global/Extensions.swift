//

//  isortagim
//
//  Created by Ufuk on 7.10.2019.
//  Copyright © 2019 Hasan Karaman. All rights reserved.
//
import UIKit

// MARK: UITableView

extension UITableView {
    func setEmptyView(title: String, message: String, image: UIImage? = nil, animation: String? = nil) {
        let emptyView = UIView(frame: CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height))
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

        if let _ = image {
            let imageView = UIImageView()
            imageView.image = image
            stackView.addArrangedSubview(imageView)
//            imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
//            imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else if let _ = animation {
            let animationView = UIView()
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalToConstant: 100),
                animationView.heightAnchor.constraint(equalToConstant: 100),
            ])

            startAnimation(jsonFile: animation!, view: animationView)
            stackView.addArrangedSubview(animationView)
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

        // The only tricky part is here:
        backgroundView = emptyView
        separatorStyle = .none
    }

    func restoreToFullTableView() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}

// MARK: UITextfield

extension UITextField {
    func setIcon(_ image: UIImage, to direction: String, y: Int = 5, width: Int = 20, height: Int = 20) {
        let xIcon = (direction == "left") ? 10 : -10

        let xContainer = (direction == "left") ? 20 : -20

        let iconView = UIImageView(frame:
            CGRect(x: xIcon, y: y, width: width, height: height))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: xContainer, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)

        if direction == "left" {
            leftView = iconContainerView
            leftViewMode = .always
        } else {
            rightView = iconContainerView
            rightViewMode = .always
        }
    }

    func setButtonwithTitle(title: String, space: CGFloat = 0) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
//      button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)

        return button
    }
}

// MARK: UIButton

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0

        layer.add(pulse, forKey: "pulse")
    }

    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3

        layer.add(flash, forKey: nil)
    }

    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true

        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)

        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)

        shake.fromValue = fromValue
        shake.toValue = toValue

        layer.add(shake, forKey: "position")
    }
}

// MARK: Dictionary

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

// MARK: UIView

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder {
            return self
        }

        for view in subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }

        return nil
    }

    var width: CGFloat {
        return frame.size.width
    }

    var height: CGFloat {
        return frame.size.width
    }

    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }

    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func addBorder(borderWidth borderwidth: CGFloat, color colour: CGColor, radius cornerRadius: CGFloat) {
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderwidth
        layer.borderColor = colour
    }

    func addShadow(cooordinate shadowOffset: CGSize = .zero, color shadowColor: CGColor = UIColor.gray.cgColor, opacity shadowOpacity: Float = 1, radius shadowRadius: CGFloat = 5) {
        layer.shadowColor = shadowColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }

    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    // Gradyan Oluşturma
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)

        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: UIViewController

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setEmptyView(title: String, message: String, image: UIImage? = nil) {
        let emptyView = UIView(frame: CGRect(x: view.center.x, y: view.center.y, width: view.bounds.size.width, height: view.bounds.size.height))
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
        if let _ = image {
            imageView.image = image
            stackView.addArrangedSubview(imageView)
            //            imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            //            imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
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

// MARK: UITextView

extension UITextView {
    func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: frame.origin.x - 22, y: frame.origin.y + frame.height - height, width: frame.width + 22, height: height)
        border.backgroundColor = color
        superview!.insertSubview(border, aboveSubview: self)
    }
}

// MARK: NSAttributedString

extension NSAttributedString {
    convenience init(htmlString html: String) throws {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ], documentAttributes: nil)
    }
}

// MARK: String

extension String {
    init(htmlString: String) {
        self.init()
        guard let encodedData = htmlString.data(using: .utf8) else {
            self = htmlString
            return
        }

        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        do {
            let attributedString = try NSAttributedString(data: encodedData,
                                                          options: attributedOptions,
                                                          documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error.localizedDescription)")
            self = htmlString
        }
    }
}

// MARK: SegmentedControl

extension UISegmentedControl {
    // Segment atamak için

    func replaceSegments(segments: Array<String>) {
        removeAllSegments()
        for segment in segments {
            insertSegment(withTitle: segment, at: numberOfSegments, animated: false)
        }
    }

    func removeBorders() {
        setBackgroundImage(imageWithColor(color: .clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: .gray), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

// MARK: UIImageView

extension UIImageView {
    convenience init?(named name: String, contentMode: UIView.ContentMode = .scaleToFill) {
        guard let image = UIImage(named: name) else {
            return nil
        }

        self.init(image: image)
        self.contentMode = contentMode
        translatesAutoresizingMaskIntoConstraints = false
    }
}
