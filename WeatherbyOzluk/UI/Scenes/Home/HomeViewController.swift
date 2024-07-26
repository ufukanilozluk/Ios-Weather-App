import UIKit
import OSLog

final class HomeViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet private var mainStackView: UIStackView!
  @IBOutlet private var emptyView: UIView!
  @IBOutlet private var scrollViewAnasayfa: UIScrollView!
  @IBOutlet private var dailyWeatherCV: UICollectionView!
  @IBOutlet private var weeklyWeatherTV: UITableView!
  @IBOutlet private var lblTemperature: UILabel!
  @IBOutlet private var imgWeatherMain: UIImageView!
  @IBOutlet private var lblDescription: UILabel!
  @IBOutlet private var lblDate: UILabel!
  @IBOutlet private var lblVisibility: UILabel!
  @IBOutlet private var lblWind: UILabel!
  @IBOutlet private var lblHumidity: UILabel!
  @IBOutlet private var lblPressure: UILabel!
  @IBOutlet private var welcomeAnimationView: UIView!
  // MARK: - Properties
  private lazy var refreshControl = UIRefreshControl()
  private var segmentedControl: UISegmentedControl?
  private var dataWeather: [Forecast.Weather]?
  private var weeklyWeather: ForecastWeekly?
  private let spacing: CGFloat = 4.0
  private var selectedCity: Location?
  private var viewModel = ForecastViewModel(service: ForecastService())
  private var times: [String] = []
  private var mins: [String] = []
  private var maxs: [String] = []
  private var days: [String] = []

  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    if #available(iOS 14.0, *) {
      Logger.api.notice("Sample Comment")
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateHome()
  }

  // MARK: - UI Configuration
  private func configureUI() {
    configureTableView()
    configureCollectionView()
    configureRefreshControl()
    configureSegmentedControl()
    setBindings()
  }

  private func configureTableView() {
    weeklyWeatherTV.dataSource = self
    weeklyWeatherTV.delegate = self
    weeklyWeatherTV.estimatedRowHeight = 50
  }

  private func configureCollectionView() {
    dailyWeatherCV.delegate = self
    dailyWeatherCV.dataSource = self
    if let layout = dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.scrollDirection = .horizontal
    }
  }

  private func configureRefreshControl() {
    refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    scrollViewAnasayfa.addSubview(refreshControl)
  }

  private func configureSegmentedControl() {
    let items = GlobalSettings.selectedCities.map { $0.localizedName.replacingOccurrences(of: " Province", with: "") }
    let segmentedControl = UISegmentedControl(items: items)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.backgroundColor = Colors.iosCaseLightGray
    segmentedControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
    mainStackView.insertArrangedSubview(segmentedControl, at: 0)
    let attributes = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlNormalState]
    let attributesSelected = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlSelectedState]
    segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    segmentedControl.setTitleTextAttributes(attributesSelected, for: .selected)
    segmentedControl.backgroundColor = Colors.segmentedControlSelectedState
    segmentedControl.selectedSegmentTintColor = Colors.tint
    self.segmentedControl = segmentedControl
  }

  // MARK: - Data Binding
  private func setBindings() {
    bindLabels()
    bindCollectionsData()
  }

  private func bindLabels() {
    viewModel.bigIcon.bind { [weak self] bigIcon in
      DispatchQueue.main.async {
        self?.imgWeatherMain.image = bigIcon
      }
    }
    viewModel.description.bind { [weak self] description in
      DispatchQueue.main.async {
        self?.lblDescription.text = description
      }
    }
    viewModel.humidity.bind { [weak self] humidity in
      DispatchQueue.main.async {
        self?.lblHumidity.text = humidity
      }
    }
    viewModel.wind.bind { [weak self] wind in
      DispatchQueue.main.async {
        self?.lblWind.text = wind
      }
    }
    viewModel.temperature.bind { [weak self] temperature in
      DispatchQueue.main.async {
        self?.lblTemperature.text = temperature
      }
    }
    viewModel.visibility.bind { [weak self] visibility in
      DispatchQueue.main.async {
        self?.lblVisibility.text = visibility
      }
    }
    viewModel.pressure.bind { [weak self] pressure in
      DispatchQueue.main.async {
        self?.lblPressure.text = pressure
      }
    }
    viewModel.date.bind { [weak self] date in
      DispatchQueue.main.async {
        self?.lblDate.text = date
      }
    }
  }

  private func bindCollectionsData() {
    viewModel.weatherData.bind { [weak self] weatherData in
      DispatchQueue.main.async {
        self?.dataWeather = weatherData
        self?.reloadCollectionViewData()
      }
    }
    viewModel.weeklyWeatherData.bind { [weak self] weeklyWeatherData in
      DispatchQueue.main.async {
        self?.weeklyWeather = weeklyWeatherData
        self?.reloadTableViewData()
      }
    }
    viewModel.times.bind { [weak self] times in
      DispatchQueue.main.async {
        self?.times = times
        self?.reloadCollectionViewData()
      }
    }
    viewModel.days.bind { [weak self] days in
      DispatchQueue.main.async {
        self?.days = days
        self?.reloadTableViewData()
      }
    }
    viewModel.mins.bind { [weak self] mins in
      DispatchQueue.main.async {
        self?.mins = mins
        self?.reloadTableViewData()
      }
    }
    viewModel.maxs.bind { [weak self] maxs in
      DispatchQueue.main.async {
        self?.maxs = maxs
        self?.reloadTableViewData()
      }
    }
  }

  // MARK: - UI Updates
  private func updateHome() {
    GlobalSettings.selectedCities = UserDefaultsHelper.getCities()
    guard !GlobalSettings.selectedCities.isEmpty else {
      showEmptyView()
      return
    }
    emptyView.removeFromSuperview()
    scrollViewAnasayfa.isHidden = false
    if segmentedControl != nil {
      updateSegmentedControlItems()
    } else {
      configureSegmentedControl()
    }
    fetchDataForSelectedCity()
  }

  private func showEmptyView() {
    view.addSubview(emptyView)
    view.startAnimation(jsonFile: "welcome-page", onView: welcomeAnimationView)
    emptyView.center = view.center
    scrollViewAnasayfa.isHidden = true
  }

  private func updateSegmentedControlItems() {
    if GlobalSettings.shouldUpdateSegments {
      let items = GlobalSettings.selectedCities.map {
        $0.localizedName.replacingOccurrences(of: " Province", with: "")
      }
      segmentedControl?.replaceSegments(with: items)
      segmentedControl?.selectedSegmentIndex = 0
      GlobalSettings.shouldUpdateSegments = false
    }
  }

  private func fetchDataForSelectedCity() {
    if let selectedSegmentIndex = segmentedControl?.selectedSegmentIndex {
      let selectedCity = GlobalSettings.selectedCities[selectedSegmentIndex]
      self.selectedCity = selectedCity
      fetchData(for: selectedCity)
    }
  }

  private func reloadCollectionViewData() {
    guard dataWeather?.count == times.count else {
      print("Mismatch in dataWeather and times count")
      return
    }
    self.dailyWeatherCV.reloadData()
  }

  private func reloadTableViewData() {
    guard let weeklyWeather = weeklyWeather,
      weeklyWeather.daily.count == mins.count,
      mins.count == maxs.count,
      maxs.count == days.count else {
        print("Mismatch in weeklyWeather, mins, maxs, or days count")
        return
    }
    self.weeklyWeatherTV.reloadData()
  }

  private func updateUI() {
    DispatchQueue.main.async {
      self.dailyWeatherCV.reloadData()
      self.weeklyWeatherTV.reloadData()
      self.refreshControl.endRefreshing()
      self.view.removeSpinner()
    }
  }

  private func fetchData(for city: Location) {
    self.view.showSpinner()
    viewModel.getForecast(city: city) {
      self.updateUI()
    }
  }

  // MARK: - Actions
  @objc private func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
    let selectedCity = GlobalSettings.selectedCities[segmentedControl.selectedSegmentIndex]
    self.selectedCity = selectedCity
    fetchData(for: selectedCity)
  }

  @objc private func didPullToRefresh() {
    guard let selectedCity = selectedCity else { return }
    fetchData(for: selectedCity)
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return weeklyWeather?.daily.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: HomeWeeklyWeatherTableviewCell.reuseIdentifier,
      for: indexPath
    )
    if let cell = cell as? HomeWeeklyWeatherTableviewCell,
      let rowData = weeklyWeather?.daily[indexPath.row],
      let imageName = rowData.weather.first?.icon,
      let image = UIImage(named: imageName) {
        cell.set(image: image, maxTemp: maxs[indexPath.row], minTemp: mins[indexPath.row], day: days[indexPath.row])
        return cell
    }
    // Return default cell if configuration fails
    return cell
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataWeather?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: HomeDailyWeatherCollectionViewCell.reuseIdentifier,
      for: indexPath
    )
    if let cell = cell as? HomeDailyWeatherCollectionViewCell {
      if let rowData = dataWeather?[indexPath.row],
        let image = UIImage(named: rowData.weather[0].icon) {
        cell.set(time: times[indexPath.row], image: image)
      }
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 75, height: 100)
  }
}
