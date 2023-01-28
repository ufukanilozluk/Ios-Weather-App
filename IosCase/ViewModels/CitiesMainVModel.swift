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
    
    private let dateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "d MMMM EEEE"
      return dateFormatter
    }()
    
    let temperature = Box("")
    let bigIcon: Box<UIImage?> = Box(nil) // no image initially
    let description = Box("")
    let visibility = Box("")
    let wind = Box("")
    let humidity = Box("")
    let pressure = Box("")
    let date = Box("")

    override init() {
        super.init()
        getWeather()
    }

    func getWeather() {
        let endPoint = Endpoint.daily(city: "Bursa", appId: "54bfbfe4aa755c3b005fded2b0741fa5")

        APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
            switch result {
            case let .success(forecast):
                let data = forecast.list[0]
                self.temperature.value = data.main.degree
                self.bigIcon.value = UIImage(named: data.weather[0].icon)
                self.description.value = data.weather[0].description.capitalized
                self.visibility.value = data.visibilityTxt
                self.wind.value = data.windTxt
                self.humidity.value = data.main.humidityTxt
                self.pressure.value = data.main.pressureTxt
                self.date.value =  self.dateFormatter.string(from: data.dt)

            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
    }

    //    func getWeatherForecastWeekly(completion: @escaping (HavaDurum) -> Void) {
    //        let endPoint = Endpoint.weeklyForecast(exclude: "current,minutely,hourly,alerts", lan: , lot: )
    //
    //        APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
    //            switch result {
    //            case let .success(forecast):
    //                completion(forecast)
    //            case let .failure(error):
    //                switch error {
    //                case let .error(errorString):
    //                    print(errorString)
    //                }
    //            }
    //        }
    //    }
}
