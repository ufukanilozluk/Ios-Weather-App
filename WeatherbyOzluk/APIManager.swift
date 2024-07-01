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
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
    completion: @escaping (Result<T, APIError>) -> Void
  ) {
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
        completion(.failure(APIError.error("Error: \(String(describing: decodingError))")))
        return
      }
    }
    .resume()
  }


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

extension APIManager {
  enum APIError: Error {
    case error(_ errorString: String)
  }
}
