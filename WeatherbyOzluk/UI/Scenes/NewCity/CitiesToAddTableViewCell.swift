import UIKit

class CitiesToAddTableViewCell: UITableViewCell {
  var addCityAction: (() -> Void)?
  weak var parentViewController: AddCityViewController?
  static let reuseIdentifier: String = "AddNewCity"
  @IBOutlet var cityNameLabel: UILabel!

  @IBAction func addCity(_ sender: Any) {
    addCityAction?()
  }
  func set(city: String, parentVC: AddCityViewController) {
    cityNameLabel.text = city
    parentViewController = parentVC
  }
}
