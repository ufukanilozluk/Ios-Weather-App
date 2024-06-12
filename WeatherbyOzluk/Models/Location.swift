import Foundation

// Karşılaştırmada (contains kısmı) kullanmak için equatable gerekir

struct Location : Codable {

    var LocalizedName: String
    var Country: Country
    var GeoPosition : GeoPosition?
}

extension Location{
  struct Country : Codable {
    var LocalizedName : String
  }
  
  struct GeoPosition : Codable {
    var Latitude  : Double
    var Longitude : Double
  }
}

