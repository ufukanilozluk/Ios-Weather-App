import UIKit

final class ForecastViewModel {
  // Observable properties
  let temperature = ObservableValue("")
  let bigIcon: ObservableValue<UIImage?> = ObservableValue(nil)
  let description = ObservableValue("")
  let visibility = ObservableValue("")
  let wind = ObservableValue("")
  let humidity = ObservableValue("")
  let pressure = ObservableValue("")
  let date = ObservableValue("")
  let weatherData: ObservableValue<[Forecast.Weather]> = ObservableValue([])
  let weeklyWeatherData: ObservableValue<ForecastWeekly?> = ObservableValue(nil)
  let allCitiesWeatherData: ObservableValue<[Forecast]> = ObservableValue([])
  let degree: ObservableValue<[String]> = ObservableValue([])
  let dates: ObservableValue<[String]> = ObservableValue([])
  let times: ObservableValue<[String]> = ObservableValue([])
  let mins: ObservableValue<[String]> = ObservableValue([])
  let maxs: ObservableValue<[String]> = ObservableValue([])
  let days: ObservableValue<[String]> = ObservableValue([])
  let cityNames: ObservableValue<[String]> = ObservableValue([])
  private let service: ForecastServiceProtocol
  private let dispatchGroup = DispatchGroup()
  // Init
  init(service: ForecastServiceProtocol) {
    self.service = service
  }
  // Get weather for a specific city
  func getWeather(city: String) {
    dispatchGroup.enter()
    service.getWeather(city: city, cnt: "7" ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(forecast):
        self.processWeather(forecast)
      case let .failure(error):
        ErrorHandling.handleError(error)
      }
      self.dispatchGroup.leave()
    }
  }
  // Get weekly weather forecast based on latitude and longitude
  func getWeatherForecastWeekly(lat: String, lon: String) {
    dispatchGroup.enter()
    service.getWeatherForecastWeekly(lat: lat, lon: lon) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(weeklyForecast):
        self.processWeeklyWeather(weeklyForecast)
      case let .failure(error):
        ErrorHandling.handleError(error)
      }
      self.dispatchGroup.leave()
    }
  }

  // Fetch weather and weekly forecast for a specific city
  func getForecast(city: Location, completion: @escaping () -> Void) {
    guard let lat = city.geoPosition?.latitude, let lon = city.geoPosition?.longitude else { return }
    getWeather(city: city.localizedName)
    getWeatherForecastWeekly(lat: String(lat), lon: String(lon))
    dispatchGroup.notify(queue: .main) {
      completion()
    }
  }

  // Fetch forecast for all selected cities
  func getForecastForAllCities(completion: @escaping () -> Void) {
    var weather: [Forecast] = []
    let selectedCities: [Location] = UserDefaultsHelper.getCities()

    for city in selectedCities {
      dispatchGroup.enter()
      service.getWeather(city: city.localizedName, cnt: "1") { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(forecast):
          weather.append(forecast)
        case let .failure(error):
          ErrorHandling.handleError(error)
        }
        self.dispatchGroup.leave()
      }
    }
    dispatchGroup.notify(queue: .main) {
      self.processAllCitiesWeather(weather, selectedCities: selectedCities)
      completion()
    }
  }

  // Process weather data for a specific city
  private func processWeather(_ forecast: Forecast) {
    let data = forecast.list[0]
    temperature.value = "\(Int(data.main.temp))°C"
    bigIcon.value = UIImage(named: data.weather[0].icon)
    description.value = data.weather[0].description.capitalized
    visibility.value = "\(Int(data.visibility / 1000)) km"
    wind.value = "\(data.wind.deg)m/s"
    humidity.value = "%\(data.main.humidity)"
    pressure.value = "%\(data.main.pressure) mbar"
    date.value = data.date.dateAndTimeLong()
    weatherData.value = forecast.list
    times.value = forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.date.timeIn24Hour() }
  }

  // Process weekly weather data
  private func processWeeklyWeather(_ weeklyForecast: ForecastWeekly) {
    weeklyWeatherData.value = weeklyForecast
    maxs.value = weeklyForecast.daily.map { "\(Int($0.temp.max))°C" }
    mins.value = weeklyForecast.daily.map { "\(Int($0.temp.min))°C" }
    days.value = weeklyForecast.daily.map { $0.date.dayLong() }
  }

  // Process weather data for all selected cities
  private func processAllCitiesWeather(_ weather: [Forecast], selectedCities: [Location]) {
    let sortedWeather = weather.sorted { weather1, weather2 in
      guard let cityName1 = weather1.city?.name.replacingOccurrences(of: " Province", with: ""),
      let cityName2 = weather2.city?.name.replacingOccurrences(of: " Province", with: ""),
      let index1 = selectedCities.firstIndex(where: { $0.localizedName == cityName1 }),
      let index2 = selectedCities.firstIndex(where: { $0.localizedName == cityName2 }) else {
        return false
      }
      return index1 < index2
    }

    allCitiesWeatherData.value = sortedWeather
    let temp = sortedWeather.compactMap { $0.list.first }
    degree.value = temp.map { "\(Int($0.main.temp))°C" }
    dates.value = temp.map { $0.date.dateAndTimeLong() }
    cityNames.value = sortedWeather.compactMap { $0.city?.name.replacingOccurrences(of: " Province", with: "") }
  }
}
