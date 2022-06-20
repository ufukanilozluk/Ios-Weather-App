//
//  SehirlerDetayTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import UIKit



class SehirlerDetayTVCell: UITableViewCell {
    var ekleAction: (() throws -> Void)?

    @IBOutlet weak var sehirName: UILabel!
    
    @IBAction func sehirEkle(_ sender: Any) {
        do {
            try ekleAction?()
        } catch WeatherAppErrors.SehirEkleError.sameSelection {
            alert(msg: "This city has been added already", type: .info)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
}
