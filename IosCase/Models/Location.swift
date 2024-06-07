import Foundation

// Karşılaştırmada (contains kısmı) kullanmak için equatable gerekir

struct Location : Codable {

    var LocalizedName: String
    var Country: Country
    var GeoPosition : GeoPosition?
  
    var locationName: String? {
      "\(LocalizedName),\(self.Country.LocalizedName)"
    }
    
    var cityTxt : String {
         LocalizedName.replacingOccurrences(of: " Province", with: "")
    }
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

