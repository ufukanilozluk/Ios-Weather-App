import Foundation
import UIKit

class SehirlerVModel{

    typealias FindCooordinateCompletion = (_ data: [String: Any]?) -> Void
    let locationSearchData: Box<[Location]> = Box([])
    let location: Box<[Location]> = Box([])
    

  
    func findCity(query: String,completion: @escaping () -> Void) {
      let endPoint = Endpoint.findCity(q: query)
      APIManager.getJSON(url: endPoint.url) { (result: Result<[Location], APIManager.APIError>) in
            switch result {
            case let .success(locations):
                self.locationSearchData.value = locations
                completion()
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
    }

  
    func findCoordinate(query: String, closure: @escaping (Result<(), Error>) -> Void) {
     let searchText = query.replacingOccurrences(of: " ", with: "%20")
     let endPoint = Endpoint.findCoordinate(q: searchText)
      print(endPoint.url)
     APIManager.getJSON(url: endPoint.url) { (result: Result<[Location], APIManager.APIError>) in
       switch result {
       case let .success(location):
         self.location.value = location
         closure(.success(()))
       case let .failure(error):
         closure(.failure(error))
       }
     }
   }
 }

