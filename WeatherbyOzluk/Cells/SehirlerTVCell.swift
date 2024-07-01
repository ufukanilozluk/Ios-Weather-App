import UIKit

class SehirlerTVCell: UITableViewCell {
  @IBOutlet var derece: UILabel!
  @IBOutlet var tarih: UILabel!
  @IBOutlet var sehirIsim: UILabel!
  @IBOutlet var weatherPicImageView: UIImageView!

  static let reuseIdentifier: String = "SehirlerTVCell"

  func setWeather(weatherPic: UIImage, cityName: String, degree: String, date: String) {
    sehirIsim.text = cityName
    derece.text = degree
    weatherPicImageView.image = weatherPic
    tarih.text = date
  }
}
