import UIKit

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
