//
//  Colours.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 29.12.2020.
//

import Foundation
import UIKit

struct Colors {
    // Sayıları 255 e böl rgb verirken

    static let weatherPurpleLight = UIColor(red: 120 / 255, green: 6 / 255, blue: 245 / 255, alpha: 1)
    static let weatherPurpleDark = UIColor(red: 174 / 255, green: 13 / 255, blue: 255 / 255, alpha: 1)
    static let iosCaseLightGray = UIColor(red: 247 / 255, green: 247 / 255, blue: 250 / 255, alpha: 1)
    static let grayDarkMode = UIColor(red: 205 / 255, green: 202 / 255, blue: 205 / 255, alpha: 1)
    static let grayLightMode = UIColor(red: 76 / 255, green: 82 / 255, blue: 100 / 255, alpha: 1)
    static let lightGrayDarkMode = UIColor(red: 227 / 255, green: 225 / 255, blue: 220 / 255, alpha: 1)
    static let lightGrayLightMode = UIColor(red: 50 / 255, green: 53 / 255, blue: 64 / 255, alpha: 1)
    static let alpha = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    static var tint: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                UITraitCollection.userInterfaceStyle == .dark ? weatherPurpleDark : weatherPurpleLight
            }
        } else {
            return weatherPurpleLight
        }
    }()

    static var segmentedControlSelectedState: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                UITraitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
            }
        } else {
            return UIColor.black
        }
    }()
    
    static var segmentedControlNormalState: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                UITraitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
            }
        } else {
            return UIColor.white
        }
    }()
    
    static var customLightGray: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                UITraitCollection.userInterfaceStyle == .dark ? lightGrayDarkMode : lightGrayLightMode
            }
        } else {
            return UIColor.lightGray
        }
    }()
    
    static var customGray: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                UITraitCollection.userInterfaceStyle == .dark ? grayDarkMode : grayLightMode
            }
        } else {
            return UIColor.gray
        }
    }()
}
