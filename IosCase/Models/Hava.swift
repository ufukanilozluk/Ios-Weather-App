import Foundation

struct City: Codable {
    var name: String
    var country: String
    var coord: Coordinate

    var locationName: String {
        "\(name),\(country)"
    }

    var nameTxt: String {
        name.replacingOccurrences(of: " Province", with: "")
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
        var dt: Date

        var visibilityTxt: String {
            "\(Int(visibility / 1000)) km"
        }

        var windTxt: String {
            "\(wind.deg)m/s"
        }

        var dateTxtLong: String {
            dt.dateAndTimeLong()
        }

        var time: String {
            dt.timeIn24Hour()
        }
    }
}

extension HavaDurum.Hava {
    struct HavaMain: Codable {
        var temp: Double
        var temp_min: Double
        var temp_max: Double
        var humidity: Int
        var pressure: Int

        var degree: String {
            "\(Int(temp))°C"
        }

        var humidityTxt: String {
            "%\(humidity)"
        }

        var pressureTxt: String {
            "%\(pressure) mbar"
        }
    }

    struct Weather: Codable {
        var id: Int
        var main: String
        var description: String
        var icon: String

        var descriptionTxt: String {
            description.capitalized
        }
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

        var dtTxt: String {
            dt.dayLong()
        }
    }
}

extension HavaDurumWeekly.Daily {
    struct Temp: Codable {
        var min: Double
        var max: Double

        var minTxt: String {
            "\(Int(min))°C"
        }

        var maxTxt: String {
            "\(Int(max))°C"
        }
    }

    struct Weather: Codable {
        var icon: String
    }
}
