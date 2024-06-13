import Foundation

extension Endpoint {
  
  static func getSearchResult(
      exclude: String = "current,minutely,hourly,alerts" ,
      units: String = "metric" ,
      lat: String,
      lon: String,
      appId: String = "54bfbfe4aa755c3b005fded2b0741fa5"
  ) -> Self {
      Endpoint(
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
  
static func findCity(
    q: String,
    apikey: String = "ViMALGnwtd6ZwguzkrnCM7phryDuVKY3"
) -> Self {
    Endpoint(
        host: "dataservice.accuweather.com",
        path: "locations/v1/cities/autocomplete",
        queryItems: [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "q", value: q),
        ]
    )
}

static func findCoordinate(
    q: String,
    apikey: String = "ViMALGnwtd6ZwguzkrnCM7phryDuVKY3"
) -> Self {
    Endpoint(
        host: "dataservice.accuweather.com",
        path: "locations/v1/search",
        queryItems: [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "q", value: q),
        ]
    )
}
    
}
