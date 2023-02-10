import Alamofire
import Foundation
import UIKit

class SehirlerVModel: MainVModel {
//    var delegate: SehirEkleVModelDelegate?

    typealias FindCooordinateCompletion = (_ data: [String: Any]?) -> Void

    let locationSearchData: Box<[Location]> = Box([])

//    func findCity(query: String) {
//        var data: [Location] = []
//        let url = "https://dataservice.accuweather.com/locations/v1/cities/autocomplete?apikey=ViMALGnwtd6ZwguzkrnCM7phryDuVKY3&q=" + query
//    }
//
//    func findCoordinate(query: String, completion: @escaping FindCooordinateCompletion) {
//        let searchText = query.replacingOccurrences(of: " ", with: "%20")
//        let url = "https://dataservice.accuweather.com/locations/v1/search?apikey=ViMALGnwtd6ZwguzkrnCM7phryDuVKY3&q=" + searchText
//    }

    override init() {
        super.init()
    }

    func findCity(query: String) {
        let endPoint = Endpoint.daily(city: city)

        APIManager.getJSON(url: endPoint.url) { (result: Result<[Location], APIManager.APIError>) in
            switch result {
            case let .success(locations):
                self.locationSearchData.value = locations
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
    }

    func findCoordinate(query: String, completion: @escaping FindCooordinateCompletion) {
        let endPoint = Endpoint.daily(city: city)

        APIManager.getJSON(url: endPoint.url) { (result: Result<[Location], APIManager.APIError>) in
            switch result {
            case let .success(locations):
                self.locationSearchData.value = locations
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
    }
}
