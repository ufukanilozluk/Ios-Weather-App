//
//  Cities.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import Foundation

// Karşılaştırmada (contains kısmı) kullanmak için equatable gerekir

struct City: Codable, Equatable {
    var id: Int?
    var name: String?
    var lat: Double?
    var lon: Double?

    init(json: [String: Any]) {
        id = json["id"] as? Int ?? -1
        name = json["name"] as? String ?? ""
        name = name?.replacingOccurrences(of: " Province", with: "")
        if let data = json["coord"] as? [String: Any] {
            lat = data["lat"] as? Double ?? -1000.0
            lon = data["lon"] as? Double ?? -1000.0
        }
    }
}

// UserDefaultsa Struct kaydetmek için
extension City {
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)

        archiver.encode(name, forKey: "name")
        archiver.encode(id, forKey: "id")
        archiver.encode(lat, forKey: "lat")
        archiver.encode(lon, forKey: "lon")

        return archiver.encodedData
    }

    init?(data: Data) {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

            defer {
                unarchiver.finishDecoding()
            }
            guard let name = unarchiver.decodeObject(forKey: "name") as? String else { return nil }
            guard let id = unarchiver.decodeObject(forKey: "id") as? Int else { return nil }
            guard let lat = unarchiver.decodeObject(forKey: "lat") as? Double else { return nil }
            guard let lon = unarchiver.decodeObject(forKey: "lon") as? Double else { return nil }
            
            self.name = name
            self.id = id
            self.lat = lat
            self.lon = lon
        } catch {
            name = ""
            id = -1
            lat = -1000.0
            lon = -1000.0
        }
    }
}
