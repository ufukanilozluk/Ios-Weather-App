//
//  City.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 25.03.2021.
//

import Foundation

struct City: Codable, Equatable {
    var id: Int?
    var name: String?
    var lat: Double?
    var lon: Double?

    init(json: [String: Any]) {
        id = json["id"] as? Int ?? -1
        name = json["name"] as? String ?? ""
        name = name?.replacingOccurrences(of: " Province", with: "")
    }

}
