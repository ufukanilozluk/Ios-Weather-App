//
//  City.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 25.03.2021.
//

import Foundation

struct GeoLocation: Codable, Equatable {
 
    var lat: Double?
    var lon: Double?

    init(json: [String: Any]) {
        lat = json["Latitude"] as? Double ?? 0.0
        lon = json["Longitude"] as? Double ?? 0.0
    }

}
