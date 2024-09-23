import Combine

protocol CityServiceProtocol {
  func findCity(query: String) -> AnyPublisher<[Location], APIManager.APIError>
  func findCoordinate(query: String) -> AnyPublisher<[Location], APIManager.APIError>
}

final class CityService: CityServiceProtocol {
  func findCity(query: String) -> AnyPublisher<[Location], APIManager.APIError> {
    do {
      let endPoint = try Endpoint.findCity(query: query)
      guard let url = endPoint.url else {
        return Fail(error: APIManager.APIError.invalidURL).eraseToAnyPublisher()
      }
      return APIManager.shared.getJSONPublisher(url: url, keyDecodingStrategy: .convertFromPascalCase)
    } catch {
      return Fail(error: APIManager.APIError.missingAPIKey).eraseToAnyPublisher()
    }
  }

  func findCoordinate(query: String) -> AnyPublisher<[Location], APIManager.APIError> {
    let searchText = query.replacingOccurrences(of: " ", with: "%20")
    do {
      let endPoint = try Endpoint.findCoordinate(query: searchText)
      guard let url = endPoint.url else {
        return Fail(error: APIManager.APIError.invalidURL).eraseToAnyPublisher()
      }
      return APIManager.shared.getJSONPublisher(url: url, keyDecodingStrategy: .convertFromPascalCase)
    } catch {
      return Fail(error: APIManager.APIError.missingAPIKey).eraseToAnyPublisher()
    }
  }
}
