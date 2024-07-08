import Foundation

protocol ForecastServiceProtocol {
  func getWeather(
    city: String,
    cnt: String,
    completion: @escaping (Result<Forecast, APIManager.APIError>) -> Void
  )
  func getWeatherForecastWeekly(
    lat: String, lon: String, completion: @escaping (Result<ForecastWeekly, APIManager.APIError>) -> Void
  )
}
class ForecastService: ForecastServiceProtocol {
  func getWeather(
    city: String,
    cnt: String,
    completion: @escaping (Result<Forecast, APIManager.APIError>) -> Void
  ) {
    let endPoint = Endpoint.daily(city: city, cnt: cnt)
    APIManager.shared.getJSON(url: endPoint.url, completion: completion)
  }
  func getWeatherForecastWeekly(
    lat: String,
    lon: String,
    completion: @escaping (Result<ForecastWeekly, APIManager.APIError>) -> Void
  ) {
    let endPoint = Endpoint.weeklyForecast(lat: lat, lon: lon)
    APIManager.shared.getJSON(url: endPoint.url, completion: completion)
  }
}
