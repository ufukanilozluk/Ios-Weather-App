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

 

    func getWeatherForecast(parameters: Parameters? = nil) {
        var merge_parameters: [String: Any] = parameters ?? [:]
        merge_parameters.merge(dict: defaultParams)

        startLoader(uiView: selfView)
        let url = baseUrl + "forecast"
        AF.request(url, method: .get, parameters: merge_parameters, encoding: URLEncoding.default).responseJSON { response in

            switch response.result {
            case let .success(JSON):

                if let response = JSON as? [String: Any] {
                    self.delegate?.getWeatherCastCompleted(data: HavaDurum(json: response))

                } else {
                    print("Cast olamadı")
                }

            case let .failure(error):
                print(error.localizedDescription)
            }
            self.stopLoader(uiView: self.selfView)
        }
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
}
