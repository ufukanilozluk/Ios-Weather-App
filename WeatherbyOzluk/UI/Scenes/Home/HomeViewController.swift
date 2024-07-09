import UIKit

class HomeViewController: UIViewController {
  @IBOutlet var mainStackView: UIStackView!
  @IBOutlet var emptyView: UIView!
  @IBOutlet var scrollViewAnasayfa: UIScrollView!
  @IBOutlet var dailyWeatherCV: UICollectionView!
  @IBOutlet var weeklyWeatherTV: UITableView!
  @IBOutlet var lblTemperature: UILabel!
  @IBOutlet var imgWeatherMain: UIImageView!
  @IBOutlet var lblDescription: UILabel!
  @IBOutlet var lblDate: UILabel!
  @IBOutlet var lblVisibility: UILabel!
  @IBOutlet var lblWind: UILabel!
  @IBOutlet var lblHumidity: UILabel!
  @IBOutlet var lblPressure: UILabel!
  @IBOutlet var welcomeAnimationView: UIView!
  lazy var refreshControl = UIRefreshControl()
  var segmentedControl: UISegmentedControl?
  var dataWeather: [Forecast.Weather]?
  var weeklyWeather: ForecastWeekly?
  private let spacing: CGFloat = 4.0
  var selectedCity: Location?
  var viewModel = ForecastViewModel(service: ForecastService())
  var times: [String] = []
  var mins: [String] = []
  var maxs: [String] = []
  var days: [String] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    configUI()
  }
  func updateHome() {
    GlobalSettings.selectedCities = UserDefaultsHelper.getCities()
    guard !GlobalSettings.selectedCities.isEmpty else {
      view.addSubview(emptyView)
      view.startAnimation(jsonFile: "welcome-page", onView: welcomeAnimationView)
      emptyView.center = view.center
      scrollViewAnasayfa.isHidden = true
      return
    }
    emptyView.removeFromSuperview()
    scrollViewAnasayfa.isHidden = false
    if let segmentedControl = segmentedControl {
      if GlobalSettings.shouldUpdateSegments {
        let items = GlobalSettings.selectedCities.map {
          $0.localizedName.replacingOccurrences(of: " Province", with: "")
        }
        segmentedControl.replaceSegments(with: items)
        segmentedControl.selectedSegmentIndex = 0
        GlobalSettings.shouldUpdateSegments = false
      }
    } else {
      createSegmentedControl()
    }
    if let selectedSegmentIndex = segmentedControl?.selectedSegmentIndex {
      let selectedCity = GlobalSettings.selectedCities[selectedSegmentIndex]
      self.selectedCity = selectedCity
      fetchData(for: selectedCity)
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateHome()
  }
  func calculateTotalContentWidth() -> CGFloat {
    var totalWidth: CGFloat = 0.0
    if let collectionViewFlowLayout = dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
      let numberOfItems = dailyWeatherCV.numberOfItems(inSection: 0)
      let interitemSpacing = collectionViewFlowLayout.minimumInteritemSpacing
      for itemIndex in 0..<numberOfItems {
        let cellWidth = collectionViewFlowLayout.itemSize.width // Her hücrenin genişliği
        totalWidth += cellWidth
        // İlk hücre hariç her hücrenin arasına interitemSpacing kadar boşluk ekle
        if itemIndex > 0 {
          totalWidth += interitemSpacing
        }
      }
    }
    return totalWidth
  }
  func configUI() {
    viewModel = ForecastViewModel(service: ForecastService())
    weeklyWeatherTV.dataSource = self
    weeklyWeatherTV.delegate = self
    dailyWeatherCV.delegate = self
    dailyWeatherCV.dataSource = self
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    dailyWeatherCV.collectionViewLayout = layout
    refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    scrollViewAnasayfa.addSubview(refreshControl)
    // for skeletonview
    weeklyWeatherTV.estimatedRowHeight = 50
    if let layout = dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.scrollDirection = .horizontal
    }
    setBindings()
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
//        days.forEach({print($0)})
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
  func setBindings() {
    bindLabels()
    bindCollectionsData()
  }
  func reloadCollectionViewData() {
    guard dataWeather?.count == times.count else {
      print("Mismatch in dataWeather and times count")
      return
    }
    self.dailyWeatherCV.reloadData()
  }
  func reloadTableViewData() {
    guard let weeklyWeather = weeklyWeather,
      weeklyWeather.daily.count == mins.count,
      mins.count == maxs.count,
      maxs.count == days.count else {
        print("Mismatch in weeklyWeather, mins, maxs, or days count")
        return
    }
    self.weeklyWeatherTV.reloadData()
  }
  func updateUI() {
    DispatchQueue.main.async {
      self.dailyWeatherCV.reloadData()
      self.weeklyWeatherTV.reloadData()
      self.refreshControl.endRefreshing()
      self.view.removeSpinner()
    }
  }
  func fetchData(for city: Location) {
    self.view.showSpinner()
    viewModel.getForecast(city: city) {
      self.updateUI()
    }
  }
  func createSegmentedControl() {
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
    if #available(iOS 13.0, *) {
      segmentedControl.selectedSegmentTintColor = Colors.tint
    }
    // Assign segmentedControl to your property if needed
    self.segmentedControl = segmentedControl
  }
  @objc func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
    let selectedCity = GlobalSettings.selectedCities[segmentedControl.selectedSegmentIndex]
    self.selectedCity = selectedCity
    fetchData(for: selectedCity)
  }
  @objc func didPullToRefresh() {
    guard let selectedCity = selectedCity else { return }
    fetchData(for: selectedCity)
  }
}

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
    
    // Hücre yapılandırması başarısız olduğunda varsayılan bir hücre döndür
    return cell
  }

}

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

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 75, height: 100)
  }
}
