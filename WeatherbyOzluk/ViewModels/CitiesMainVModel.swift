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

    APIManager.shared.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
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
        self.date.value = data.date.dateAndTimeLong()
        self.weatherData.value = forecast.list
        self.times.value = forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.date.timeIn24Hour() }
      case let .failure(error):
        switch error {
        case let .error(errorString):
          print(errorString)
        }
      }
      self.dispatchGroup.leave()
    }
  }

  func getWeatherForecastWeekly(lat: String, lon: String) {
    let endPoint = Endpoint.weeklyForecast(lat: lat, lon: lon)
    APIManager.shared.getJSON(url: endPoint.url) { (result: Result<HavaDurumWeekly, APIManager.APIError>) in
      switch result {
      case let .success(weeklyForecast):
        self.weeklyWeatherData.value = weeklyForecast
        self.maxs.value = weeklyForecast.daily.map({ "\(Int($0.temp.max))°C" })
        self.mins.value = weeklyForecast.daily.map({ "\(Int($0.temp.min))°C" })
        self.days.value = weeklyForecast.daily.map({ $0.date.dayLong() })
      case let .failure(error):
        switch error {
        case let .error(errorString):
          print(errorString)
        }
      }
      self.dispatchGroup.leave()
    }
  }

  func getForecast(city: Location, completion: @escaping () -> Void) {
    guard let lat = city.geoPosition?.latitude, let lon = city.geoPosition?.longitude else {return}
    self.dispatchGroup.enter()
    self.getWeather(city: city.localizedName)
    self.dispatchGroup.enter()
    self.getWeatherForecastWeekly(lat: String(lat), lon: String(lon))
    self.dispatchGroup.notify(queue: .main) {
      completion()
    }
  }

  func getForecastForAllCities(completion: @escaping () -> Void) {
    var weather: [HavaDurum] = []
    let selectedCities: [Location] = UserDefaultsHelper.getCities()
    for city in selectedCities {
      self.dispatchGroup.enter()
      let endPoint = Endpoint.daily(city: city.localizedName, cnt: "1")
      APIManager.shared.getJSON(url: endPoint.url) { (result: Result<HavaDurum, APIManager.APIError>) in
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
    self.dispatchGroup.notify(queue: .main) {
      // Şehirler sırasına göre tüm verileri çektikten sonra sırala
      weather.sort { weather1, weather2 in
        guard let cityName1 = weather1.city?.name.replacingOccurrences(of: " Province", with: ""),
          let cityName2 = weather2.city?.name.replacingOccurrences(of: " Province", with: ""),
          let index1 = selectedCities.firstIndex(where: { $0.localizedName == cityName1 }),
          let index2 = selectedCities.firstIndex(where: { $0.localizedName == cityName2 }) else {
            return false
        }
        return index1 < index2
      }
      completion()
      self.allCitiesWeatherData.value = weather
      let temp = weather.compactMap { $0.list.first }
      self.degree.value = temp.map { "\((Int($0.main.temp)))°C" }
      self.dates.value = temp.map { $0.date.dateAndTimeLong() }
      self.cityNames.value = weather.compactMap { $0.city?.name.replacingOccurrences(of: " Province", with: "") }
    }
  }
}
