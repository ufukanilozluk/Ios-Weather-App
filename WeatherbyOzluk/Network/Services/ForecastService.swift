import Combine

protocol ForecastServiceProtocol {
  func getWeather(city: String, cnt: String) -> AnyPublisher<Forecast, APIManager.APIError>
  func getWeatherForecastWeekly(lat: String, lon: String) -> AnyPublisher<ForecastWeekly, APIManager.APIError>
}

final class ForecastService: ForecastServiceProtocol {
  func getWeather(city: String, cnt: String) -> AnyPublisher<Forecast, APIManager.APIError> {
    do {
      let endPoint = try Endpoint.daily(city: city, cnt: cnt)
      guard let url = endPoint.url else {
        return Fail(error: .invalidURL).eraseToAnyPublisher()
      }
      return APIManager.shared.getJSONPublisher(url: url)
    } catch {
      return Fail(error: .missingAPIKey).eraseToAnyPublisher()
    }
  }

  func getWeatherForecastWeekly(lat: String, lon: String) -> AnyPublisher<ForecastWeekly, APIManager.APIError> {
    do {
      let endPoint = try Endpoint.weeklyForecast(lat: lat, lon: lon)
      guard let url = endPoint.url else {
        return Fail(error: .invalidURL).eraseToAnyPublisher()
      }
      return APIManager.shared.getJSONPublisher(url: url)
    } catch {
      return Fail(error: .missingAPIKey).eraseToAnyPublisher()
    }
  }
}
