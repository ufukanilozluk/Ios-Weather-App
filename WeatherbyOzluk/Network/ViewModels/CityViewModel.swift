import Foundation
import UIKit

final class CityViewModel {
  // Observable properties to hold location data
  let locationSearchData: ObservableValue<[Location]> = ObservableValue([])
  let location: ObservableValue<[Location]> = ObservableValue([])
  let cityNames: ObservableValue<[String]> = ObservableValue([])
  private let service: CityServiceProtocol
  // Initializer to inject the service dependency
  init(service: CityServiceProtocol) {
    self.service = service
  }
  // Function to find city based on query string
  func findCity(query: String, completion: @escaping () -> Void) {
    service.findCity(query: query) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let locations):
        self.locationSearchData.value = locations
        self.cityNames.value = locations.map { "\($0.localizedName), \($0.country.localizedName)" }
        completion()
      case .failure(let error):
        self.handleError(error)
      }
    }
  }
  // Function to find coordinates based on query string
  func findCoordinate(query: String, completion: @escaping (Result<Void, Error>) -> Void) {
    service.findCoordinate(query: query) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let locations):
        self.location.value = locations
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  // Private function to handle errors
  private func handleError(_ error: APIManager.APIError) {
    print("Error: \(error.localizedDescription)")
      // Optionally, you could show an alert to the user or perform other UI-related error handling here.
  }
}
