import UIKit

class HomeWeeklyWeatherTableviewCell: UITableViewCell {
  @IBOutlet var imgWeatherTV: UIImageView!
  @IBOutlet var lblDay: UILabel!
  @IBOutlet var lblMaxWeatherTV: UILabel!
  @IBOutlet var lblMinWeatherTV: UILabel!
  static let reuseIdentifier = "WeeklyWeatherTVCell"

  func set(image: UIImage, maxTemp: String, minTemp: String, day: String) {
    imgWeatherTV.image = image
    lblMaxWeatherTV.text = maxTemp
    lblMinWeatherTV.text = minTemp
    lblDay.text = day
  }
}
