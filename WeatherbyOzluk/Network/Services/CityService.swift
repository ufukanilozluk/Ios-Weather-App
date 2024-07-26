import Foundation

protocol CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
}
final class CityService: CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void) {
    let endPoint = Endpoint.findCity(query: query)
    guard let url = endPoint.url else {
      completion(.failure(.invalidURL))
      return
    }
    APIManager.shared.getJSON(url: url, keyDecodingStrategy: .convertFromPascalCase, completion: completion)
  }
  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void) {
    let searchText = query.replacingOccurrences(of: " ", with: "%20")
    let endPoint = Endpoint.findCoordinate(query: searchText)
    guard let url = endPoint.url else {
      completion(.failure(.invalidURL))
      return
    }
    APIManager.shared.getJSON(
      url: url,
      keyDecodingStrategy: .convertFromPascalCase,
      completion: completion
    )
  }
}
