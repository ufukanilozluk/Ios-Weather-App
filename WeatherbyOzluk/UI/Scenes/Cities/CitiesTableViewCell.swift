import UIKit

class CitiesTableViewCell: UITableViewCell {
  @IBOutlet var degreeLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var cityNameLabel: UILabel!
  @IBOutlet var weatherPicImageView: UIImageView!

  static let reuseIdentifier: String = "CitiesTableViewCell"

  func setWeather(weatherPic: UIImage, cityName: String, degree: String, date: String) {
    cityNameLabel.text = cityName
    degreeLabel.text = degree
    weatherPicImageView.image = weatherPic
    dateLabel.text = date
  }
}
