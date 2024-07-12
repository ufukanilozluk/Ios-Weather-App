import UIKit

class CitiesToAddTableViewCell: UITableViewCell {
  var ekleAction: (() -> Void)?
  weak var parentViewController: AddCityViewController?
  static let reuseIdentifier: String = "SehirlerDetayTVCell"
  @IBOutlet var sehirName: UILabel!

  @IBAction func sehirEkle(_ sender: Any) {
    ekleAction?()
  }
  func set(city: String, parentVC: AddCityViewController) {
    sehirName.text = city
    parentViewController = parentVC
  }
}
