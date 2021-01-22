//
//  Hava.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 4.12.2020.
//

import Foundation

struct HavaDurum: Codable {
    var list: [Hava] = []
    var cnt: Int?
    var message: Int?
    var cod: String?
    var city: City

    init(json: [String: Any]) {
        if let weatherList = json["list"] as? [[String: Any]] {
            for dic in weatherList {
                list.append(Hava(json: dic))
            }
        }

        cnt = json["cnt"] as? Int ?? -1
        message = json["message"] as? Int ?? -1
        cod = json["cod"] as? String ?? "-"
        city = City(json: json["city"] as? [String: Any] ?? [:])
    }
}

struct HavaDurumWeekly: Codable {
    var list: [Daily] = []
    var uv : String?
    
    init(json: [String: Any]) {
        if let weatherList = json["daily"] as? [[String: Any]] {
            uv = String(weatherList[0]["uvi"] as! Double) 
            for dic in weatherList {
                list.append(Daily(json: dic))
            }
        }
    }
}

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

struct Hava: Codable {
    var main: HavaMain = HavaMain(json: [:])
    var weather: [Weather] = []
    var wind: Wind = Wind(json: [:])
    var visibility: Double?
    var dt_text: String?

    init(json: [String: Any]) {
        if let mainList = json["main"] as? [String: Any] {
            main = HavaMain(json: mainList)
        }

        if let weatherList = json["weather"] as? [[String: Any]] {
            for dic in weatherList {
                weather.append(Weather(json: dic))
            }
        }

        if let windJson = json["wind"] as? [String: Any] {
            wind = Wind(json: windJson)
        }

        visibility = json["visibility"] as? Double ?? -100
        dt_text = json["dt_txt"] as? String ?? "-"
    }
}

struct HavaMain: Codable {
    var temp: String?
    var feels_like: Double?
    var temp_min: String?
    var temp_max: String?
    var pressure: Double?
    var sea_level: Double?
    var grnd_level: Double?
    var humidity: Double?
    var temp_kf: Double?

    init(json: [String: Any]) {
        var tmp = json["temp"] as? Double ?? -100.0
        // yuvarlama
        temp = String(Int(tmp.rounded()))
        feels_like = json["feels_like"] as? Double ?? -100.0
        tmp = json["temp_min"] as? Double ?? -100.0
        temp_min = String(Int(tmp.rounded()))
        tmp = json["temp_max"] as? Double ?? -100.0
        temp_max = String(Int(tmp.rounded()))
        pressure = json["pressure"] as? Double ?? -100.0
        sea_level = json["sea_level"] as? Double ?? -100.0
        grnd_level = json["grnd_level"] as? Double ?? -100.0
        humidity = json["humidity"] as? Double ?? -100.0
        temp_kf = json["temp_kf"] as? Double ?? -100.0
    }
}

struct Weather: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
    // var icon:  computed value

    init(json: [String: Any]) {
        id = json["id"] as? Int ?? -1
        main = json["main"] as? String ?? "-"
        description = json["description"] as? String ?? "-"
        icon = json["icon"] as? String ?? "-"
    }
}

struct Wind: Codable {
    var speed: Double?
    var deg: Int?

    init(json: [String: Any]) {
        speed = json["speed"] as? Double ?? -100
        deg = json["deg"] as? Int ?? -100
    }
}
