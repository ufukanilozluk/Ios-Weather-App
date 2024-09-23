import Combine
import Foundation

final class CityViewModel {
  // Observable properties to hold location data
  let locationSearchData = CurrentValueSubject<[Location], Never>([])
  let location = CurrentValueSubject<[Location], Never>([])
  let cityNames = CurrentValueSubject<[String], Never>([])

  private let service: CityServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  // Initializer to inject the service dependency
  init(service: CityServiceProtocol) {
    self.service = service
  }

  // Function to find city based on query string
  func findCity(query: String) {
    service.findCity(query: query)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            ErrorHandling.handleError(error)
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] locations in
          guard let self = self else { return }
          self.locationSearchData.send(locations)
          self.cityNames.send(locations.map { "\($0.localizedName), \($0.country.localizedName)" })
        }
      )
      .store(in: &cancellables)
  }

  // Function to find coordinates based on query string
  func findCoordinate(query: String) {
    service.findCoordinate(query: query)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            ErrorHandling.handleError(error)
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] locations in
          guard let self = self else { return }
          self.location.send(locations)
        }
      )
      .store(in: &cancellables)
  }
}
