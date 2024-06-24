import Foundation

enum UserDefaultsHelper {
  static func getCities() -> [Location] {
      guard let cityList = UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] else { return [] }
      var cities: [Location] = []
      
      for city in cityList {
          if let cityName = city["city"] as? String,
             let countryDict = city["country"] as? [String: Any],
             let countryName = countryDict["LocalizedName"] as? String,
             let latitude = city["latitude"] as? Double,
             let longitude = city["longitude"] as? Double {
              
              let country = Location.Country(localizedName: countryName)
            let geoPosition = Location.GeoPosition(latitude: latitude, longitude: longitude)
              let location = Location(localizedName: cityName, country: country, geoPosition: geoPosition)
              cities.append(location)
          }
      }
      return cities
  }
  
  static func saveCity(city: Location) {
      var cities: [[String: Any]] = UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] ?? []
      
      guard let latitude = city.geoPosition?.latitude,
            let longitude = city.geoPosition?.longitude else {
          // Handle the case where any of the values are nil
          return
      }
      
      // Convert Location.Country to Dictionary
      let countryDict: [String: Any] = [
          "LocalizedName": city.country.localizedName
      ]
      
      let newCity: [String: Any] = [
          "city": city.localizedName,
          "country": countryDict,
          "latitude": latitude,
          "longitude": longitude,
      ]
      
      cities.append(newCity)
      UserDefaults.standard.set(cities, forKey: "cities")
  }
  
  static func moveCity(_ i : Int, _ j : Int) {
    
    guard var cities = UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] else {
        return
    }
    cities.swapAt(i, j)
    UserDefaults.standard.set(cities, forKey: "cities")
  }
  
  static func removeCity(at : Int ) {
    
    guard var cities = UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] else {
        return
    }
    cities.remove(at: at)
    UserDefaults.standard.set(cities, forKey: "cities")
  }
}
