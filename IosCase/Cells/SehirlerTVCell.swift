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

    func setWeather(weather: HavaDurum.Hava, cityName: String) {
        sehirIsim.text = cityName
        derece.text = weather.main.degree
        weatherPic.image = UIImage(named: weather.weather[0].icon)
//        tarih.text = try? Utility.dateFormatter(to: .strToStr, value: weather.dateTxt, outputFormat: "dd/MM/yyyy")
//                     as? String ?? "-"
    }
}
