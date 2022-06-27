//
//  SehirlerDetayTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import UIKit



class SehirlerDetayTVCell: UITableViewCell {
    var ekleAction: (() throws -> Void)?
    static let reuseIdentifier : String = "SehirlerDetayTVCell"
    
    @IBOutlet weak var sehirName: UILabel!
    
    @IBAction func sehirEkle(_ sender: Any) {
        do {
            try ekleAction?()
        } catch WeatherAppErrors.SehirEkleError.sameSelection {
            alert(msg: CustomAlerts.sameCity.alertTitle, type: CustomAlerts.sameCity.alertType)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
}
