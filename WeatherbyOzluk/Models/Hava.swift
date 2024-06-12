import Foundation

struct City: Codable {
    var name: String
    var country: String
    var coord: Coordinate
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
        var dt: Date
    }
}

extension HavaDurum.Hava {
    struct HavaMain: Codable {
        var temp: Double
        var temp_min: Double
        var temp_max: Double
        var humidity: Int
        var pressure: Int
    }

    struct Weather: Codable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }

    struct Wind: Codable {
        var speed: Double
        var deg: Int
    }
}

struct HavaDurumWeekly: Codable {
    var lat: Double
    var daily: [Daily]
}

extension HavaDurumWeekly {
    struct Daily: Codable {
        var dt: Date
        var temp: Temp
        var weather: [Weather]
    }
}

extension HavaDurumWeekly.Daily {
    struct Temp: Codable {
        var min: Double
        var max: Double
    }

    struct Weather: Codable {
        var icon: String
    }
}
