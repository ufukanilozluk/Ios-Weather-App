//
//  Hava.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 4.12.2020.
//

import Foundation

struct City: Codable {
    var name: String
    var country: String
    var coord: Coordinate

    var locationName: String {
        "\(name),\(country)"
    }
}

extension City {
    struct Coordinate: Codable {
        var lat: Double
        var lon: Double
    }
}

struct HavaDurum: Codable {
    var list: [Hava] = []
    var city: City?
}

extension HavaDurum {
    struct Hava: Codable {
        var main: HavaMain
        var weather: [Weather]
        var wind: Wind
        var visibility: Double
        var dt_txt: String
    }
}

extension HavaDurum.Hava {
    struct HavaMain: Codable {
        var temp: Double
        var temp_min: Double
        var temp_max: Double
        var humidity: Int?
        
        var degree : String{
            "\( Int(temp) )°C"
        }
    }

    struct Weather: Codable {
        var id: Int?
        var main: String?
        var description: String?
        var icon: String?
    }

    struct Wind: Codable {
        var speed: Double?
        var deg: Int?
    }
}

struct HavaDurumWeekly: Codable {
    var list: [Daily] = []
    var uv: String?

    init(json: [String: Any]) {
        if let weatherList = json["daily"] as? [[String: Any]] {
            uv = String(weatherList[0]["uvi"] as! Double)
            for dic in weatherList {
                list.append(Daily(json: dic))
            }
        }
    }
}

extension HavaDurumWeekly {
    struct Daily: Codable {
        var icon: String?
        var min: String = ""
        var max: String = ""
        var dt: Date

        init(json: [String: Any]) {
            if let data = json["temp"] as? [String: Any] {
                var tmp = data["min"] as? Double ?? -100.0
                min = String(Int(tmp.rounded())) + "°" + "C"
                tmp = data["max"] as? Double ?? -100.0
                max = String(Int(tmp.rounded())) + "°" + "C"
            }
            if let temp = json["weather"] as? [[String: Any]] {
                icon = temp[0]["icon"] as? String ?? ""
            }
            dt = Date(timeIntervalSince1970: json["dt"] as! Double)
        }
    }
}
