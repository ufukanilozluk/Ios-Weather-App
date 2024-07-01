import Foundation

struct Endpoint {
  var host: String
  var path: String
  var queryItems: [URLQueryItem] = []
}

extension Endpoint {
  var url: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = "/" + path
    components.queryItems = queryItems

    guard let url = components.url else {
      preconditionFailure(
        "Invalid URL components: \(components)"
      )
    }
    return url
  }
}
