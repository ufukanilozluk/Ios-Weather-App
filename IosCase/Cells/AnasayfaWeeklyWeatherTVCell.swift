//
//  AnasayfaWeeklyWeatherTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 18.12.2020.
//

import UIKit

class AnasayfaWeeklyWeatherTVCell: UITableViewCell {

    @IBOutlet weak var imgWeatherTV: UIImageView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblMaxWeatherTV: UILabel!
    @IBOutlet weak var lblMinWeatherTV: UILabel!
    
    static let reuseIdentifier : String = "WeeklyWeatherTVCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
