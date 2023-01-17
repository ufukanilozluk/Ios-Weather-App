import Alamofire
import Foundation

class APIManager {
    static func getJSON<T: Decodable>(url: URL,
                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                      keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                      completion: @escaping (Result<T, APIError>) -> Void) {
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.error("Error: \(error.localizedDescription)")))
                return
            }

            guard let data = data else {
                completion(.failure(.error(NSLocalizedString("Error: Data is corrupt.", comment: ""))))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
                return
            } catch let decodingError {
                completion(.failure(APIError.error("Error: \(decodingError.localizedDescription)")))
                return
            }

        }.resume()
    }
}

extension APIManager {
    enum APIError: Error {
        case error(_ errorString: String)
    }

    struct Endpoint {
        var host: String
        var path: String
        var queryItems: [URLQueryItem] = []

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

        static func daily(city: String,
                          cnt: String = "8", lang: String = "en", appId: String, units: String = "metric") -> Self {
            Endpoint(
                host: "api.openweathermap.org",
                path: "data/2.5/forecast",
                queryItems: [
                    URLQueryItem(name: "appid", value: appId),
                    URLQueryItem(name: "cnt", value: cnt),
                    URLQueryItem(name: "lang", value: lang),
                    URLQueryItem(name: "units", value: units),
                    URLQueryItem(name: "q", value: city),
                ]
            )
        }
        
    
        
        
        
    }
}
