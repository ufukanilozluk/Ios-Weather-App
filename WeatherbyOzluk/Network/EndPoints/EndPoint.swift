import Foundation

struct Endpoint {
  let host: String
  let path: String
  let queryItems: [URLQueryItem]
  init(host: String, path: String, queryItems: [URLQueryItem] = []) {
    self.host = host
    self.path = path
    self.queryItems = queryItems
  }
}
extension Endpoint {
  var url: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = "/\(path)"
    components.queryItems = queryItems.isEmpty ? nil : queryItems
    guard let url = components.url else {
      fatalError("Invalid URL components: \(components)")
    }
    return url
  }
}
