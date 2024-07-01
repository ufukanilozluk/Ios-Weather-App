import Foundation

extension Endpoint {
  static func daily(
    city: String,
    cnt: String = "7",
    lang: String = "en",
    units: String = "metric"
  ) -> Self {
    guard let appId = GlobalSettings.KeychainHelper.getApiKey(forKey: "openweather") else {
      fatalError("API key not found in Keychain")
    }
    return Endpoint(
      host: "api.openweathermap.org",
      path: "data/2.5/forecast",
      queryItems: [
        URLQueryItem(name: "appid", value: appId),
        URLQueryItem(name: "cnt", value: cnt),
        URLQueryItem(name: "lang", value: lang),
        URLQueryItem(name: "units", value: units),
        URLQueryItem(name: "q", value: city)
      ]
    )
  }

  static func weeklyForecast(
    exclude: String = "current,minutely,hourly,alerts",
    units: String = "metric",
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
        URLQueryItem(name: "units", value: units)
      ]
    )
  }
}
