import UIKit

class SehirlerDetayTVCell: UITableViewCell {
  var ekleAction: (() throws -> Void)?
  weak var parentViewController: SehirlerDetayVController?

  static let reuseIdentifier: String = "SehirlerDetayTVCell"

  @IBOutlet var sehirName: UILabel!

  @IBAction func sehirEkle(_ sender: Any) {
    do {
      try ekleAction?()
    } catch SehirEkleError.sameSelection {
      parentViewController?.showAlert(title: CustomAlerts.sameCity.alertTitle)
    } catch let error {
      print("Unexpected error: \(error).")
    }
  }

  func set(city: String, parentVC: SehirlerDetayVController) {
    sehirName.text = city
    parentViewController = parentVC
  }
}
