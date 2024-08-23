protocol ForecastServiceProtocol {
  func getWeather(
    city: String,
    cnt: String,
    completion: @escaping (Result<Forecast, APIManager.APIError>) -> Void
  )
  func getWeatherForecastWeekly(
    lat: String,
    lon: String,
    completion: @escaping (Result<ForecastWeekly, APIManager.APIError>) -> Void
  )
}
final class ForecastService: ForecastServiceProtocol {
  func getWeather(
    city: String,
    cnt: String,
    completion: @escaping (Result<Forecast, APIManager.APIError>) -> Void
  ) {
    do {
      let endPoint = try Endpoint.daily(city: city, cnt: cnt)
      guard let url = endPoint.url else {
        completion(.failure(.invalidURL))
        return
      }
      APIManager.shared.getJSON(url: url, completion: completion)
    } catch {
      completion(.failure(.missingAPIKey))
    }
  }
  func getWeatherForecastWeekly(
    lat: String,
    lon: String,
    completion: @escaping (Result<ForecastWeekly, APIManager.APIError>) -> Void
  ) {
    do {
      let endPoint = try Endpoint.weeklyForecast(lat: lat, lon: lon)
      guard let url = endPoint.url else {
        completion(.failure(.invalidURL))
        return
      }
      APIManager.shared.getJSON(url: url, completion: completion)
    } catch {
      completion(.failure(.missingAPIKey))
    }
  }
}
