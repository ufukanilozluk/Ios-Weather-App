//
//  AnasayfaWeeklyWeatherTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 18.12.2020.
//

import UIKit

class AnasayfaWeeklyWeatherTVCell: UITableViewCell {
    @IBOutlet var imgWeatherTV: UIImageView!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblMaxWeatherTV: UILabel!
    @IBOutlet var lblMinWeatherTV: UILabel!

    static let reuseIdentifier: String = "WeeklyWeatherTVCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func set(data: Daily) {
        imgWeatherTV.image = UIImage(named: data.icon!)
        lblMaxWeatherTV.text = data.max
        lblMinWeatherTV.text = data.min
        // EEEE direk gün ismi
        lblDay.text = try? Utility.dateFormatter(to: .toStr, value: data.dt, outputFormat: "EEEE") as? String ?? "-"
    }
}
