import Combine
import UIKit

final class ForecastViewModel {
  // Observable properties
  let temperature = CurrentValueSubject<String, Never>("")
  let bigIcon = CurrentValueSubject<UIImage?, Never>(nil)
  let description = CurrentValueSubject<String, Never>("")
  let visibility = CurrentValueSubject<String, Never>("")
  let wind = CurrentValueSubject<String, Never>("")
  let humidity = CurrentValueSubject<String, Never>("")
  let pressure = CurrentValueSubject<String, Never>("")
  let date = CurrentValueSubject<String, Never>("")
  let weatherData = CurrentValueSubject<[Forecast.Weather], Never>([])
  let weeklyWeatherData = CurrentValueSubject<ForecastWeekly?, Never>(nil)
  let allCitiesWeatherData = CurrentValueSubject<[Forecast], Never>([])
  let degree = CurrentValueSubject<[String], Never>([])
  let dates = CurrentValueSubject<[String], Never>([])
  let times = CurrentValueSubject<[String], Never>([])
  let mins = CurrentValueSubject<[String], Never>([])
  let maxs = CurrentValueSubject<[String], Never>([])
  let days = CurrentValueSubject<[String], Never>([])
  let cityNames = CurrentValueSubject<[String], Never>([])

  private let service: ForecastServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  // Init
  init(service: ForecastServiceProtocol) {
    self.service = service
  }

  // Get weather for a specific city
  func getWeather(city: String) {
    service.getWeather(city: city, cnt: "7")
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          ErrorHandling.handleError(error)
        }
      }, receiveValue: { [weak self] forecast in
        self?.processWeather(forecast)
      })
      .store(in: &cancellables)
  }

  // Get weekly weather forecast based on latitude and longitude
  func getWeatherForecastWeekly(lat: String, lon: String) {
    service.getWeatherForecastWeekly(lat: lat, lon: lon)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          ErrorHandling.handleError(error)
        }
      }, receiveValue: { [weak self] weeklyForecast in
        self?.processWeeklyWeather(weeklyForecast)
      })
      .store(in: &cancellables)
  }

  // Fetch weather and weekly forecast for a specific city
  func getForecast(city: Location, completion: @escaping () -> Void) {
    guard let lat = city.geoPosition?.latitude, let lon = city.geoPosition?.longitude else { return }

    let weatherPublisher = service.getWeather(city: city.localizedName, cnt: "7")
    let weeklyWeatherPublisher = service.getWeatherForecastWeekly(lat: String(lat), lon: String(lon))

    Publishers.Zip(weatherPublisher, weeklyWeatherPublisher)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          ErrorHandling.handleError(error)
        }
      }, receiveValue: { [weak self] weather, weeklyForecast in
        self?.processWeather(weather)
        self?.processWeeklyWeather(weeklyForecast)
        completion()
      })
      .store(in: &cancellables)
  }

  // Fetch forecast for all selected cities
  func getForecastForAllCities(completion: @escaping () -> Void) {
    let selectedCities: [Location] = UserDefaultsHelper.getCities()

    let weatherPublishers = selectedCities.map { city in
      service.getWeather(city: city.localizedName, cnt: "1").eraseToAnyPublisher()
    }

    Publishers.MergeMany(weatherPublishers)
      .collect()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        if case let .failure(error) = completion {
          ErrorHandling.handleError(error)
        }
      }, receiveValue: { [weak self] weather in
        self?.processAllCitiesWeather(weather, selectedCities: selectedCities)
        completion()
      })
      .store(in: &cancellables)
  }

  // Process weather data for a specific city
  private func processWeather(_ forecast: Forecast) {
    let data = forecast.list[0]
    temperature.send("\(Int(data.main.temp))°C")
    bigIcon.send(UIImage(named: data.weather[0].icon))
    description.send(data.weather[0].description.capitalized)
    visibility.send("\(Int(data.visibility / 1000)) km")
    wind.send("\(data.wind.deg)m/s")
    humidity.send("%\(data.main.humidity)")
    pressure.send("%\(data.main.pressure) mbar")
    date.send(data.date.dateAndTimeLong())
    weatherData.send(forecast.list)
    times.send(forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.date.timeIn24Hour() })
  }

  // Process weekly weather data
  private func processWeeklyWeather(_ weeklyForecast: ForecastWeekly) {
    weeklyWeatherData.send(weeklyForecast)
    maxs.send(weeklyForecast.daily.map { "\(Int($0.temp.max))°C" })
    mins.send(weeklyForecast.daily.map { "\(Int($0.temp.min))°C" })
    days.send(weeklyForecast.daily.map { $0.date.dayLong() })
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
    allCitiesWeatherData.send(sortedWeather)
    let temp = sortedWeather.compactMap { $0.list.first }
    degree.send(temp.map { "\(Int($0.main.temp))°C" })
    dates.send(temp.map { $0.date.dateAndTimeLong() })
    cityNames.send(sortedWeather.compactMap { $0.city?.name.replacingOccurrences(of: " Province", with: "") })
  }
}
