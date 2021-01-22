//
//  CitiesVModel.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import Alamofire
import Foundation
import UIKit

class SehirlerVModel : MainVModel {
    var delegate: SehirEkleVModelDelegate?
    let selfView: UIView

    init(view: UIView) {
        selfView = view
    }

    func getCityList() {
        var data: [City] = []
        let url = "https://weathercase-99549.firebaseio.com/.json"
        self.startLoader(uiView: self.selfView)
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { [self] response in
            
        
            switch response.result {
        case let .success(JSON):

            if let response = JSON as? [[String: Any]] {
                
                for el in response{
                    data.append(City(json: el))
                }
                self.delegate?.getCityListCompleted(data: data)

            } else {
              print("Cast olamadı")
            }

        case let .failure(error):
            //todo : moobil_log // type error olarak loglanıcak
            print( error.localizedDescription)
    
        }
            stopLoader(uiView: self.selfView)
        }

    }
        
    }
