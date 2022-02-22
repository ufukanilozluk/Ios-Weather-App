//
//  Cities.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import Foundation

// Karşılaştırmada (contains kısmı) kullanmak için equatable gerekir

struct Location: Codable, Equatable {
    var cityName: String?
    var countryName: String?
    var lat: Double?
    var lon: Double?

    var locationName: String? {
//        return city! + "," + country!
        return "\(cityName!), \(countryName!)"
    }

    init(json: [String: Any]) {
        cityName = json["LocalizedName"] as? String ?? ""
        if let data = json["Country"] as? [String: Any] {
            countryName = data["LocalizedName"] as? String ?? ""
        }
    }
}

// UserDefaultsa Struct kaydetmek için
extension Location {
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)

        archiver.encode(cityName, forKey: "LocalizedName")
        archiver.encode(countryName, forKey: "Country")
        archiver.encode(lon, forKey: "Longitude")
        archiver.encode(lat, forKey: "Latitude")

        return archiver.encodedData
    }

    init?(data: Data) {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

            defer {
                unarchiver.finishDecoding()
            }
            guard let country = unarchiver.decodeObject(forKey: "Country") as? String? else { return nil }
            guard let city = unarchiver.decodeObject(forKey: "LocalizedName") as? String? else { return nil }
            guard let lat = unarchiver.decodeObject(forKey: "Longitude") as? Double? else { return nil }
            guard let lon = unarchiver.decodeObject(forKey: "Latitude") as? Double? else { return nil }

            countryName = country
            cityName = city
            self.lat = lat
            self.lon = lon
        } catch {
            return nil
        }
    }
}
