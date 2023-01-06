//
//  SehirlerTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 7.12.2020.
//

import UIKit

class SehirlerTVCell: UITableViewCell {
    @IBOutlet var derece: UILabel!
    @IBOutlet var tarih: UILabel!
    @IBOutlet var sehirIsim: UILabel!
    @IBOutlet var weatherPic: UIImageView!

    static let reuseIdentifier: String = "SehirlerTVCell"

    func setWeather(weather: Hava, cityName: String) {
        sehirIsim.text = cityName
        derece.text = String(weather.main.temp!) + "°C"
        weatherPic.image = UIImage(named: weather.weather[0].icon!)
        tarih.text = try? Utility.dateFormatter(to: .strToStr, value: weather.dt_text!, outputFormat: "dd/MM/yyyy")
                     as? String ?? "-"
    }
}
