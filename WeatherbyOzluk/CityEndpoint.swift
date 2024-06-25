import Foundation

extension Endpoint {
  
  static func getSearchResult(
      exclude: String = "current,minutely,hourly,alerts" ,
      units: String = "metric" ,
      lat: String,
      lon: String
  ) -> Self {
    guard let appId = GlobalSettings.KeychainHelper.getApiKey(forKey: "openweather") else {
          fatalError("API key not found in Keychain")
      }
      return Endpoint(
          host: "api.openweathermap.org",
          path: "data/2.5/onecall",
          queryItems: [
              URLQueryItem(name: "appid", value: appId),
              URLQueryItem(name: "exclude", value: exclude),
              URLQueryItem(name: "lat", value: lat),
              URLQueryItem(name: "lon", value: lon),
              URLQueryItem(name: "units", value: units),
          ]
      )
  }
  
static func findCity( q: String) -> Self {
  
  guard let apikey = GlobalSettings.KeychainHelper.getApiKey(forKey: "accuweather") else {
        fatalError("API key not found in Keychain")
    }
    return Endpoint(
        host: "dataservice.accuweather.com",
        path: "locations/v1/cities/autocomplete",
        queryItems: [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "q", value: q),
        ]
    )
}

static func findCoordinate(q: String) -> Self {
  guard let apikey = GlobalSettings.KeychainHelper.getApiKey(forKey: "accuweather") else {
        fatalError("API key not found in Keychain")
    }
    return Endpoint(
        host: "dataservice.accuweather.com",
        path: "locations/v1/search",
        queryItems: [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "q", value: q),
        ]
    )
}    
}
