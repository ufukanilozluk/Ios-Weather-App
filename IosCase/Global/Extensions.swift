//

//  isortagim
//
//  Created by Ufuk on 7.10.2019.
//  Copyright © 2019 Ufuk Anıl Özlük. All rights reserved.
//
import UIKit

// MARK: UITableView

extension UITableView {
    func setEmptyView(title: String, message: String, image: UIImage? = nil, animation: String? = nil) {
        let emptyView = UIView()
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10

        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.textColor = Colors.customGray
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = Colors.customLightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)

        if let _ = image {
            let imageView = UIImageView()
            imageView.image = image
            stackView.addArrangedSubview(imageView)

        } else if let _ = animation {
            let animationView = UIView()
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalToConstant: 100),
                animationView.heightAnchor.constraint(equalToConstant: 100),
            ])
            
            Utility.startAnimation(jsonFile: animation!, view: animationView)
            stackView.addArrangedSubview(animationView)
            
        }

        
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        emptyView.addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true

        titleLabel.text = title
        messageLabel.text = message
        messageLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        // The only tricky part is here:
        backgroundView = emptyView
        separatorStyle = .none
    }

    func restoreToFullTableView() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}


// MARK: Dictionary

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)   // k varsa v yi güncelliyor yoksa k,v ekliyor bu func
        }
    }
}

// MARK: UIView

extension UIView {

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

}

// MARK: UIViewController

extension UIViewController {
    
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


// MARK: SegmentedControl

extension UISegmentedControl {
    // Segment atamak için

    func replaceSegments(segments: Array<String>) {
        removeAllSegments()
        for segment in segments {
            insertSegment(withTitle: segment, at: numberOfSegments, animated: false)
        }
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
