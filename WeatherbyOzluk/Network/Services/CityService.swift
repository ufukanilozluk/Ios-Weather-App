protocol CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
}

final class CityService: CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void) {
    do {
      let endPoint = try Endpoint.findCity(query: query)
      guard let url = endPoint.url else {
        completion(.failure(.invalidURL))
        return
      }
      APIManager.shared.getJSON(url: url, keyDecodingStrategy: .convertFromPascalCase, completion: completion)
    } catch {
      completion(.failure(.missingAPIKey))
    }
  }

  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void) {
    let searchText = query.replacingOccurrences(of: " ", with: "%20")
    do {
      let endPoint = try Endpoint.findCoordinate(query: searchText)
      guard let url = endPoint.url else {
        completion(.failure(.invalidURL))
        return
      }
      APIManager.shared.getJSON(
        url: url,
        keyDecodingStrategy: .convertFromPascalCase,
        completion: completion
      )
    } catch {
      completion(.failure(.missingAPIKey))
    }
  }
}
