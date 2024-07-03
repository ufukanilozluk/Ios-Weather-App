import UIKit

class HomeDailyWeatherCollectionViewCell: UICollectionViewCell {
  @IBOutlet var frameCV: CardView!
  @IBOutlet var imgWeather: UIImageView!
  @IBOutlet var hour: UILabel!
  static let reuseIdentifier: String = "DailyWeatherCVCell"

  func set(time: String, image: UIImage) {
    hour.text = time
    imgWeather.image = image
    configImg()
  }

  func configImg() {
    imgWeather.layer.masksToBounds = true
    imgWeather.layer.cornerRadius = 12
  }
}
