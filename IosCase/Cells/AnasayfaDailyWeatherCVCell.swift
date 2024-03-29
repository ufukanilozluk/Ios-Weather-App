import UIKit

class AnasayfaDailyWeatherCVCell: UICollectionViewCell {
    @IBOutlet var frameCV: CardView!
    @IBOutlet var imgWeather: UIImageView!
    @IBOutlet var hour: UILabel!

    static let reuseIdentifier: String = "DailyWeatherCVCell"

    func set(data: HavaDurum.Hava, indexPath: IndexPath) {
        hour.text = indexPath.row == 0 ? "Now" : data.time
        imgWeather.image = UIImage(named: data.weather[0].icon)
        configImg()
    }

    func configImg() {
        imgWeather.layer.masksToBounds = true
        imgWeather.layer.cornerRadius = 12
    }
}
