import UIKit

class AnasayfaWeeklyWeatherTVCell: UITableViewCell {
    @IBOutlet var imgWeatherTV: UIImageView!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblMaxWeatherTV: UILabel!
    @IBOutlet var lblMinWeatherTV: UILabel!

    static let reuseIdentifier: String = "WeeklyWeatherTVCell"
  
    func set(img : UIImage , maxTemp: String , minTemp : String , day : String){
    imgWeatherTV.image = img
    lblMaxWeatherTV.text = maxTemp
    lblMinWeatherTV.text = minTemp
    lblDay.text = day
  }
}
