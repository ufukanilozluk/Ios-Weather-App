//
//  SehirlerDetayTVCell.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük
//

import UIKit

class SehirlerDetayTVCell: UITableViewCell {
    var ekleAction: (() throws -> Void)?
    static let reuseIdentifier: String = "SehirlerDetayTVCell"

    @IBOutlet var sehirName: UILabel!

    @IBAction func sehirEkle(_ sender: Any) {
        do {
            try ekleAction?()
        } catch SehirEkleError.sameSelection {
            Utility.alert(msg: CustomAlerts.sameCity.alertTitle, type: CustomAlerts.sameCity.alertType)
        } catch let error {
            print("Unexpected error: \(error).")
        }
    }
    
    func set(city : String ){
        sehirName.text = city
    }
    
    
    
    
}
