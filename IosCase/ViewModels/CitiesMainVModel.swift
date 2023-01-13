//
//  CitiesMainVModel.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 30.11.2020.
//

import Alamofire
import Foundation
import UIKit

class CitiesMainVModel: MainVModel {
    var delegate: SehirlerMainVModelDelegate? // Delegator Class
    let selfView: UIView

    init(view: UIView) {
        selfView = view
    }



    func getWeatherForecastWeekly(parameters: Parameters? = nil) {
        var params: [String: Any] = parameters ?? [:]
        params.merge(dict: defaultParams)

        startLoader(uiView: selfView)
        let url = baseUrl + "onecall"
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default).responseJSON { response in

            switch response.result {
            case let .success(JSON):

                if let response = JSON as? [String: Any] {
                    self.delegate?.getWeatherCastWeeklyCompleted(data: HavaDurumWeekly(json: response))

                } else {
                    print("Cast olamadı")
                }

            case let .failure(error):
                // TODO: moobil_log // type error olarak loglanıcak
                print(error.localizedDescription)
            }
            self.stopLoader(uiView: self.selfView)
        }
    }

    func getWeather(completion: @escaping(HavaDurum) -> Void) {
        APIManager.getJSON(urlString: "https://api.openweathermap.org/data/2.5/forecast?appid=54bfbfe4aa755c3b005fded2b0741fa5&cnt=1&lang=tr&q=Bursa&units=metric") { (result: Result<HavaDurum, APIManager.APIError>) in
            switch result {
            case let .success(forecast):
                completion(forecast)
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
    }
}
