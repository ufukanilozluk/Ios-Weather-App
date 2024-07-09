protocol CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void)
}
class CityService: CityServiceProtocol {
  func findCity(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void ) {
    let endPoint = Endpoint.findCity(query: query)
    APIManager.shared.getJSON(url: endPoint.url, keyDecodingStrategy: .convertFromPascalCase, completion: completion)
  }
  func findCoordinate(query: String, completion: @escaping (Result<[Location], APIManager.APIError>) -> Void) {
    let searchText = query.replacingOccurrences(of: " ", with: "%20")
    let endPoint = Endpoint.findCoordinate(query: searchText)
    APIManager.shared.getJSON(
      url: endPoint.url,
      keyDecodingStrategy: .convertFromPascalCase,
      completion: completion
    )
  }
}
