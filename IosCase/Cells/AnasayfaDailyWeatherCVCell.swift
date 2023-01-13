//
//  AnasayfaDailyWeatherCVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 18.12.2020.
//

import UIKit

class AnasayfaDailyWeatherCVCell: UICollectionViewCell {
    @IBOutlet var frameCV: CardView!
    @IBOutlet var imgWeather: UIImageView!
    @IBOutlet var hour: UILabel!

    static let reuseIdentifier: String = "DailyWeatherCVCell"

    func set(data: HavaDurum.Hava, indexPath: IndexPath) {
        if indexPath.row == 0 {
            hour.text = "Now"
        } else {
            hour.text = try? Utility.dateFormatter(to: .strToStr, value: data.dt_txt!, outputFormat: "HH:mm") as? String ?? "-"
        }

        imgWeather.image = UIImage(named: data.weather[0].icon!)
        configImg()
    }

    func configImg() {
        imgWeather.layer.masksToBounds = true
        imgWeather.layer.cornerRadius = 12
    }
}
