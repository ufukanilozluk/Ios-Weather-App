import UIKit

class AnasayfaWeeklyWeatherTVCell: UITableViewCell {
    @IBOutlet var imgWeatherTV: UIImageView!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblMaxWeatherTV: UILabel!
    @IBOutlet var lblMinWeatherTV: UILabel!

    static let reuseIdentifier: String = "WeeklyWeatherTVCell"

    var data: HavaDurumWeekly.Daily? {
        didSet {
            if let data = data {
                imgWeatherTV.image = UIImage(named: data.weather[0].icon)
                lblMaxWeatherTV.text = data.temp.maxTxt
                lblMinWeatherTV.text = data.temp.minTxt
                lblDay.text = data.dtTxt
            }
        }
    }
}
