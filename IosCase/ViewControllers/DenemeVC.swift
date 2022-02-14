//
//  DenemeVC.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 13.02.2022.
//

import UIKit

class DenemeVC: UIViewController {
    
    @IBOutlet var allTheButtons: [UIButton]!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func bntAnimate(_ sender: UIButton) {
        switch sender {
        case btn1:
            sender.flash()
        case btn2:
            sender.shake()
        case btn3:
            sender.pulsate()
            
        default: break
        }
        btn1.setTitle("Evet", for:.normal) 
    }
    
    

}
