//
//  Alerts.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 21.06.2022.
//

import Foundation


enum AlertType {
    case warning
    case err
    case succ
    case info
}


struct Alerts {
    var alertType: AlertType
    var alertTitle: String
}

enum CustomAlerts {
    static let sameCity = Alerts(alertType: .info, alertTitle: "Already Added")
    static let added = Alerts(alertType: .succ, alertTitle: "Added")
    static let internetNotConnected = Alerts(alertType: .err, alertTitle: "Internet Not Connected")
    static let internetConnected = Alerts(alertType: .succ, alertTitle: "Internet Reconnected")
}

