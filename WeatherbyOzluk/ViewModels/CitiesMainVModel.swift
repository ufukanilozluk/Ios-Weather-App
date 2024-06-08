import UIKit

class CitiesMainVModel {
    let temperature = ObservableValue("")
    let bigIcon: ObservableValue<UIImage?> = ObservableValue(nil)
    let description = ObservableValue("")
    let visibility = ObservableValue("")
    let wind = ObservableValue("")
    let humidity = ObservableValue("")
    let pressure = ObservableValue("")
    let date = ObservableValue("")
    let weatherData: ObservableValue<[HavaDurum.Hava]> = ObservableValue([])
    let weeklyWeatherData: ObservableValue<HavaDurumWeekly?> = ObservableValue(nil)
    let allCitiesWeatherData: ObservableValue<[HavaDurum]> = ObservableValue([])

    let dispatchGroup = DispatchGroup()

  
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
        dispatchGroup.leave()
    }

    func getWeatherForecastWeekly(lat: String, lon: String) {
        let endPoint = Endpoint.weeklyForecast(lat: lat, lon: lon)
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
        dispatchGroup.leave()
    }

    func getForecast(city: Location, completion: @escaping () -> Void) {
      guard let lat = city.GeoPosition?.Latitude, let lon = city.GeoPosition?.Longitude else {return}
        dispatchGroup.enter()
      getWeather(city: city.LocalizedName)
        dispatchGroup.enter()
      getWeatherForecastWeekly(lat: String(lat), lon: String(lon))
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func getForecastForAllCities(completion: @escaping () -> Void) {
        var weather: [HavaDurum] = []
        let selectedCities: [Location] = AnasayfaVController.selectedCities
        for city in selectedCities {
            dispatchGroup.enter()
          let endPoint = Endpoint.daily(city: city.LocalizedName, cnt: "1")
            APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
                switch result {
                case let .success(forecast):
                    weather.append(forecast)
                case let .failure(error):
                    switch error {
                    case let .error(errorString):
                        print(errorString)
                    }
                }
                self.dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            // Şehirler sırasındakine göre tüm verileri çektikten sonra sırala

            weather.sort(by: { n1, n2 in
                let index1 = selectedCities.firstIndex(where: {
                    $0.cityTxt == n1.city!.nameTxt
                })
                let index2 = selectedCities.firstIndex(where: {
                    $0.cityTxt == n2.city!.nameTxt
                })
                return index1! < index2!
            })
            completion()
            self.allCitiesWeatherData.value = weather
        }
    }
}
