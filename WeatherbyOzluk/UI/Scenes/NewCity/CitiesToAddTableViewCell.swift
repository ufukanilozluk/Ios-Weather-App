import UIKit

class CitiesToAddTableViewCell: UITableViewCell {
  var ekleAction: (() throws -> Void)?
  weak var parentViewController: AddCityViewController?

  static let reuseIdentifier: String = "SehirlerDetayTVCell"

  @IBOutlet var sehirName: UILabel!

  @IBAction func sehirEkle(_ sender: Any) {
    do {
      try ekleAction?()
    } catch AddNewCityError.sameSelection {
      parentViewController?.showAlert(title: CustomAlerts.sameCity.alertTitle)
    } catch let error {
      print("Unexpected error: \(error).")
    }
  }

  func set(city: String, parentVC: AddCityViewController) {
    sehirName.text = city
    parentViewController = parentVC
  }
}
