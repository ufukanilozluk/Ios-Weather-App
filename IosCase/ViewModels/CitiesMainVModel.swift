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
    let temperature = Box("")
    let bigIcon: Box<UIImage?> = Box(nil) // no image initially
    let description = Box("")
    let visibility = Box("")
    let wind = Box("")
    let humidity = Box("")
    let pressure = Box("")
    let date = Box("")
    let weatherData: Box<[HavaDurum.Hava]> = Box([])
    let weeklyWeatherData: Box<HavaDurumWeekly?> = Box(nil)

    let dispatchGroup = DispatchGroup()

    override init() {
        super.init()
    }

    func getWeather(city: String) {
        let endPoint = Endpoint.daily(city: city)

        APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
            switch result {
            case let .success(forecast):
                let data = forecast.list[0]
                self.temperature.value = data.main.degree
                self.bigIcon.value = UIImage(named: data.weather[0].icon)
                self.description.value = data.weather[0].descriptionTxt
                self.visibility.value = data.visibilityTxt
                self.wind.value = data.windTxt
                self.humidity.value = data.main.humidityTxt
                self.pressure.value = data.main.pressureTxt
                self.date.value = data.dateTxtLong
                self.weatherData.value = forecast.list
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
        self.dispatchGroup.leave()
    }

    func getWeatherForecastWeekly(lat: String, lon: String) {
        let endPoint = Endpoint.weeklyForecast(lat: lat, lon: lon)
        print(endPoint.url)
        APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurumWeekly, APIManager.APIError>) in
            switch result {
            case let .success(weeklyForecast):
                self.weeklyWeatherData.value = weeklyForecast
            case let .failure(error):
                switch error {
                case let .error(errorString):
                    print(errorString)
                }
            }
        }
        self.dispatchGroup.leave()
    }

    func getForecast(city: Location, completion: @escaping () -> Void) {
        dispatchGroup.enter()
        getWeather(city: city.cityName!)
        dispatchGroup.enter()
        getWeatherForecastWeekly(lat: String(city.lat!), lon: String(city.lon!))
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
