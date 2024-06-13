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
    let degree: ObservableValue<[String]> = ObservableValue([])
    let dates: ObservableValue<[String]> = ObservableValue([])
    let times: ObservableValue<[String]> = ObservableValue([])
    let mins: ObservableValue<[String]> = ObservableValue([])
    let maxs: ObservableValue<[String]> = ObservableValue([])
    let days: ObservableValue<[String]> = ObservableValue([])
    let cityNames: ObservableValue<[String]> = ObservableValue([])


  
  
    func getWeather(city: String) {
        let endPoint = Endpoint.daily(city: city)

        APIManager.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
            switch result {
            case let .success(forecast):
                let data = forecast.list[0]
                self.temperature.value = "\(Int(data.main.temp))°C"
                self.bigIcon.value = UIImage(named: data.weather[0].icon)
                self.description.value = data.weather[0].description.capitalized
                self.visibility.value = "\(Int(data.visibility / 1000)) km"
                self.wind.value = "\(data.wind.deg)m/s"
                self.humidity.value = "%\(data.main.humidity)"
                self.pressure.value = "%\(data.main.pressure) mbar"
                self.date.value =  data.dt.dateAndTimeLong()
                self.weatherData.value = forecast.list
                self.times.value = forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.dt.timeIn24Hour() }
              
              
              
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
                self.maxs.value = weeklyForecast.daily.map({ "\(Int($0.temp.max))°C"})
              self.mins.value = weeklyForecast.daily.map({ "\(Int($0.temp.min))°C"})
              self.days.value = weeklyForecast.daily.map({ $0.dt.dayLong()})
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
      let selectedCities: [Location] = UserDefaultsHelper.getCities()
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
                  $0.LocalizedName.replacingOccurrences(of: " Province", with: "") == n1.city!.name.replacingOccurrences(of: " Province", with: "")
                })
                let index2 = selectedCities.firstIndex(where: {
                  $0.LocalizedName.replacingOccurrences(of: " Province", with: "") == n2.city!.name.replacingOccurrences(of: " Province", with: "")
                })
                return index1! < index2!
            })
            completion()
            self.allCitiesWeatherData.value = weather
          let temp = weather.map({$0.list})
          let temp2 = temp.map({$0[0]})
          self.degree.value = temp2.map({ "\(Int($0.main.temp))°C" })
          self.dates.value = temp2.map({ $0.dt.dateAndTimeLong() })
          self.cityNames.value = weather.map({$0.city!.name.replacingOccurrences(of: " Province", with: "")})
        }
    }
}
