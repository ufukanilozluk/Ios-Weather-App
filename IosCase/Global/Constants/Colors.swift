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
    static let alpha = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

    static var tint: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return Colors.weatherPurpleDark
                } else {
                    /// Return the color for Light Mode
                    return Colors.weatherPurpleLight
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return Colors.weatherPurpleLight
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
}
