//
//  AnasayfaDailyWeatherCVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 18.12.2020.
//

import UIKit

class AnasayfaDailyWeatherCVCell: UICollectionViewCell {
    @IBOutlet weak var frameCV: DesingTableCell!
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var hour: UILabel!
    
    static let reuseIdentifier : String = "DailyWeatherCVCell"
}
