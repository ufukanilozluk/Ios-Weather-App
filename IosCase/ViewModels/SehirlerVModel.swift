import Alamofire
import Foundation
import UIKit

class SehirlerVModel: MainVModel {
//    var delegate: SehirEkleVModelDelegate?
    let selfView: UIView
    typealias FindCooordinateCompletion = ((_ data: [String:Any]?) -> Void)

    init(view: UIView) {
        selfView = view
    }

    func findCity(query: String) {
        var data: [Location] = []
        let url = "https://dataservice.accuweather.com/locations/v1/cities/autocomplete?apikey=ViMALGnwtd6ZwguzkrnCM7phryDuVKY3&q=" + query
        startLoader(uiView: selfView)
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { [self] response in

            switch response.result {
            case let .success(JSON):

                if let response = JSON as? [[String: Any]] {
                    for el in response {
                        data.append(Location(json: el))
                    }
//                    self.delegate?.getCityListCompleted(data: data)

                } else {
                    print("Cast olamadı")
                }

            case let .failure(error):
                // TODO: moobil_log // type error olarak loglanıcak
                print(error.localizedDescription)
            }
            stopLoader(uiView: self.selfView)
        }
    }

    func findCoordinate(query: String,completion: @escaping FindCooordinateCompletion){
      
        let searchText = query.replacingOccurrences(of: " ", with: "%20")
        let url = "https://dataservice.accuweather.com/locations/v1/search?apikey=ViMALGnwtd6ZwguzkrnCM7phryDuVKY3&q=" + searchText
        startLoader(uiView: selfView)
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { [self] response in

            switch response.result {
            case let .success(JSON):

                if let response = JSON as? [[String: Any]] {
                    if response.count > 0 {
                        let json = response[0]["GeoPosition"]
                        completion(json as? [String : Any])
                    }

                } else {
                    print("Cast olamadı")
                }

            case let .failure(error):
                // TODO: moobil_log // type error olarak loglanıcak
                print(error.localizedDescription)
            }
            stopLoader(uiView: self.selfView)
        }
     
    }
}
