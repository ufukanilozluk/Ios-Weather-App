//
//  SehirlerTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 7.12.2020.
//

import UIKit

class SehirlerTVCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var derece: UILabel!
    @IBOutlet weak var tarih: UILabel!
    @IBOutlet weak var sehirIsim: UILabel!
    @IBOutlet weak var weatherPic: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
