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
    var locationName:String? {
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
            self.countryName = country
            self.cityName = city
        } catch {
            countryName = ""
            cityName = ""
        }
    }
}
