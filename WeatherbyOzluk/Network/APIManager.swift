import Foundation
import Network
import UIKit

class APIManager {
  /// Shared instance of the APIManager.
  static let shared = APIManager()
  /// Private initializer to enforce singleton pattern.
  private init() {}
  func getJSON<T: Decodable>(
    url: URL,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
    completion: @escaping (Result<T, APIError>) -> Void
  ) {
    let timeoutInterval: TimeInterval = 30
    let urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)

    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      // Handle network errors.
      if let error = error as? URLError {
        switch error.code {
        case .notConnectedToInternet:
          completion(.failure(APIError.noInternetConnection))
        case .timedOut:
          completion(.failure(APIError.timeout))
        default:
          completion(.failure(APIError.networkError(error.localizedDescription)))
        }
        return
      }

      // Check for a valid HTTP response status code.
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
        completion(.failure(APIError.invalidResponse))
        return
      }

      // Ensure that data is present.
      guard let data = data else {
        completion(.failure(APIError.noData))
        return
      }

      // Decode the JSON data.
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = dateDecodingStrategy
      decoder.keyDecodingStrategy = keyDecodingStrategy

      do {
        let decodedData = try decoder.decode(T.self, from: data)
        completion(.success(decodedData))
      } catch let decodingError {
        completion(.failure(APIError.decodingFailed(decodingError.localizedDescription)))
      }
    }
    .resume()
  }
}


extension APIManager {
  func netWorkConnectivityCheck(onViewController viewController: UIViewController) {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        if !GlobalSettings.formerConnectivityStatus {
          DispatchQueue.main.async {
            viewController.showToast(
              message: CustomAlerts.internetConnected.alertTitle,
              seconds: 5,
              alertType: CustomAlerts.internetConnected.alertType
            )
          }
        }
        GlobalSettings.formerConnectivityStatus = true
      } else {
        GlobalSettings.formerConnectivityStatus = false
        DispatchQueue.main.async {
          viewController.showToast(
            message: CustomAlerts.internetNotConnected.alertTitle,
            seconds: 5,
            alertType: CustomAlerts.internetNotConnected.alertType
          )
        }
      }
    }

    monitor.start(queue: DispatchQueue(label: "Network"))
}
}
  // MARK: - Response Decoding

  /// Decodes a response of the specified type from the provided data.
  /// - Parameters:
  ///   - type: The type to decode.
  ///   - data: The data to decode.
  /// - Returns: An instance of the decoded type or nil if decoding fails.
  private func decodeResponse<T: Decodable>(type: T.Type, from data: Data) -> T? {
    let decoder = JSONDecoder()
    do {
      let decodedData = try decoder.decode(T.self, from: data)
      return decodedData
    } catch {
      return nil
    }
  }

// MARK: - API Error Enum

extension APIManager {
  /// Enum representing various API-related errors.
  enum APIError: Error {
    case networkError(String)
    case invalidResponse
    case requestFailed(Int)
    case noData
    case decodingFailed(String)
    case noInternetConnection
    case timeout
    case invalidURL

    /// A localized description for each error case.
    var localizedDescription: String {
      switch self {
      case .networkError(let errorString):
        return "Network Error: \(errorString)"
      case .invalidResponse:
        return "Invalid Response Error"
      case .requestFailed(let statusCode):
        return "Request Failed Error: \(statusCode)"
      case .noData:
        return "No Data Error"
      case .decodingFailed(let errorString):
        return "Decoding Error: \(errorString)"
      case .noInternetConnection:
        return "No Internet Connection"
      case .timeout:
        return "Request Timeout"
      case .invalidURL:
        return "Invalid URL"
      }
    }
  }
}
