//
//  TabbarController.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 5.01.2021.
//

import UIKit
import Network

class TabbarController: UITabBarController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Colors.iosCasePurple], for: .selected)
        tabBar.tintColor = Colors.iosCasePurple
        
      
    }
    
 
    
    
}