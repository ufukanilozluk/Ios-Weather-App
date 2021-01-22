//
//  AppDelegate.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import Network
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
   
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let board: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let VC = board.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        window?.rootViewController = VC
     

        return true

        // MARK: UISceneSession Lifecycle
    }
}
