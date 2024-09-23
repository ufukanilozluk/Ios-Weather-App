import UIKit
import OSLog
import Combine

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
  private var cancellables = Set<AnyCancellable>()

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
    viewModel.bigIcon
      .receive(on: DispatchQueue.main)
      .sink { [weak self] bigIcon in
        self?.imgWeatherMain.image = bigIcon
      }
      .store(in: &cancellables)

    viewModel.description
      .receive(on: DispatchQueue.main)
      .sink { [weak self] description in
        self?.lblDescription.text = description
      }
      .store(in: &cancellables)

    viewModel.humidity
      .receive(on: DispatchQueue.main)
      .sink { [weak self] humidity in
        self?.lblHumidity.text = humidity
      }
      .store(in: &cancellables)

    viewModel.wind
      .receive(on: DispatchQueue.main)
      .sink { [weak self] wind in
        self?.lblWind.text = wind
      }
      .store(in: &cancellables)

    viewModel.temperature
      .receive(on: DispatchQueue.main)
      .sink { [weak self] temperature in
        self?.lblTemperature.text = temperature
      }
      .store(in: &cancellables)

    viewModel.visibility
      .receive(on: DispatchQueue.main)
      .sink { [weak self] visibility in
        self?.lblVisibility.text = visibility
      }
      .store(in: &cancellables)

    viewModel.pressure
      .receive(on: DispatchQueue.main)
      .sink { [weak self] pressure in
        self?.lblPressure.text = pressure
      }
      .store(in: &cancellables)

    viewModel.date
      .receive(on: DispatchQueue.main)
      .sink { [weak self] date in
        self?.lblDate.text = date
      }
      .store(in: &cancellables)
  }

  private func bindCollectionsData() {
    viewModel.weatherData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] weatherData in
        self?.dataWeather = weatherData
        self?.reloadCollectionViewData()
      }
      .store(in: &cancellables)

    viewModel.weeklyWeatherData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] weeklyWeatherData in
        self?.weeklyWeather = weeklyWeatherData
        self?.reloadTableViewData()
      }
      .store(in: &cancellables)

    viewModel.times
      .receive(on: DispatchQueue.main)
      .sink { [weak self] times in
        self?.times = times
        self?.reloadCollectionViewData()
      }
      .store(in: &cancellables)

    viewModel.days
      .receive(on: DispatchQueue.main)
      .sink { [weak self] days in
        self?.days = days
        self?.reloadTableViewData()
      }
      .store(in: &cancellables)

    viewModel.mins
      .receive(on: DispatchQueue.main)
      .sink { [weak self] mins in
        self?.mins = mins
        self?.reloadTableViewData()
      }
      .store(in: &cancellables)

    viewModel.maxs
      .receive(on: DispatchQueue.main)
      .sink { [weak self] maxs in
        self?.maxs = maxs
        self?.reloadTableViewData()
      }
      .store(in: &cancellables)
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
    self.dailyWeatherCV.reloadData()
  }

  private func reloadTableViewData() {
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
      // Default hücre döndür
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
