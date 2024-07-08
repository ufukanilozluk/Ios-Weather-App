import UIKit

class CitiesViewController: UIViewController {
  @IBOutlet var sehirlerTableView: UITableView!
  var weather: [Forecast]?
  var selectedCities: [Location] = UserDefaultsHelper.getCities()
  var newCityAdded = false
  var viewModel = ForecastViewModel(service: ForecastService())
  var degrees: [String] = []
  var dates: [String] = []
  var cityNames: [String] = []
  func setBindings() {
    viewModel.allCitiesWeatherData.bind { [weak self] weatherData in
      self?.weather = weatherData
    }
    viewModel.degree.bind { [weak self] degrees in
      self?.degrees = degrees
    }
    viewModel.dates.bind { [weak self] dates in
      self?.dates = dates
    }
    viewModel.cityNames.bind { [weak self] cityNames in
      self?.cityNames = cityNames
    }
  }
  func updateUI() {
    view.removeSpinner()
    sehirlerTableView.reloadData()
  }
  private func getWeatherInfo() {
    self.view.showSpinner()
    viewModel.getForecastForAllCities { [weak self] in
      DispatchQueue.main.async {
        self?.updateUI()
      }
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setConfig()
    setBindings()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectedCities = UserDefaultsHelper.getCities()
    guard !selectedCities.isEmpty else {
      sehirlerTableView.setEmptyView(
        title: "No location Found",
        message: "Start by adding a location",
        animation: "location"
      )
      return
    }
    getWeatherInfo()
  }
  func setConfig() {
    sehirlerTableView.delegate = self
    sehirlerTableView.dataSource = self
    sehirlerTableView.dragDelegate = self
    sehirlerTableView.dropDelegate = self
    sehirlerTableView.dragInteractionEnabled = false
    // Bir sonraki sayfadaki geri butonunun texti burada ayarlanır.
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "", style: .plain, target: nil, action: nil)
    // Use the edit button provided by the view controller.
    editButtonItem.title = "Edit"
    navigationItem.leftBarButtonItem = editButtonItem // editbutton swiftten geliyor
    sehirlerTableView.allowsSelection = false
    sehirlerTableView.estimatedRowHeight = 60
  }
  // Edit state function
  override func setEditing(_ editing: Bool, animated: Bool) {
    // Takes care of toggling the button's title.
    super.setEditing(editing, animated: true)
    // Toggle table view editing.
    sehirlerTableView.setEditing(editing, animated: true)
    sehirlerTableView.dragInteractionEnabled = editing
    // Edit button text ayarlama
    // Swiftten geliyor isEditing
    editButtonItem.title = isEditing ? "Done" : "Edit"
  }
  @IBAction func sehirEkle(_ sender: Any) {
    performSegue(withIdentifier: "goToSehirlerDetay", sender: nil)
  }
}

extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard !selectedCities.isEmpty else {
      tableView.setEmptyView(title: "No location found", message: "Start by adding a location", animation: "location")
      return 0
    }
    tableView.restoreToFullTableView()
    return weather?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let weatherList = weather?[indexPath.row].list, !weatherList.isEmpty else {
      // Handle the case where weather is nil or the list is empty
      return UITableViewCell()
    }
    let hava = weatherList[0]
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: CitiesTableViewCell.reuseIdentifier,
      for: indexPath
    ) as? CitiesTableViewCell else {
      // Handle the case where the cell cannot be dequeued as SehirlerTVCell
      return UITableViewCell()
    }
    let row = indexPath.row
    guard let icon = hava.weather.first?.icon,
      let weatherPic = UIImage(named: icon) else {
      // Handle the case where the icon or image is nil
        return UITableViewCell()
    }
    cell.setWeather(
      weatherPic: weatherPic,
      cityName: cityNames[row],
      degree: degrees[row],
      date: dates[row]
    )
    return cell
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return isEditing
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // Update the model
    guard var weather = weather else {
      // Handle the case where weather is nil
      return
    }

    let mover = weather.remove(at: sourceIndexPath.row) // sildiğini dönüyor. Yani mover bir Location
    weather.insert(mover, at: destinationIndexPath.row)
    self.weather = weather
    selectedCities.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    UserDefaultsHelper.moveCity(sourceIndexPath.row, destinationIndexPath.row)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard var weather = weather else {
        // Handle the case where weather is nil
        return
      }
      weather.remove(at: indexPath.row)
      self.weather = weather
      selectedCities.remove(at: indexPath.row)
      sehirlerTableView.deleteRows(at: [indexPath], with: .automatic)
      UserDefaultsHelper.removeCity(index: indexPath.row)
      GlobalSettings.shouldUpdateSegments = true
    }
  }
}

extension CitiesViewController: UITableViewDragDelegate, UITableViewDropDelegate {
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    // Implementation for drop functionality if needed
  }
  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    GlobalSettings.shouldUpdateSegments = true
    guard let weather = weather else {
      // Handle the case where weather is nil
      return []
    }
    let dragItem = UIDragItem(itemProvider: NSItemProvider())
    dragItem.localObject = weather[indexPath.row]
    return [dragItem]
  }
}
