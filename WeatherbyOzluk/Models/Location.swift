import Foundation

struct Location: Codable {
  var localizedName: String
  var country: Country
  var geoPosition: GeoPosition?
}

// Location struct'ına extension eklemesi
extension Location {
  // Location içindeki Country struct'ı tanımlaması
  struct Country: Codable {
    var localizedName: String
  }
  // Location içindeki GeoPosition struct'ı tanımlaması
  struct GeoPosition: Codable {
    var latitude: Double
    var longitude: Double
  }
}
