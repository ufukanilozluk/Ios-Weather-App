import UIKit

class SehirlerDetayVController: BaseVController {
  @IBOutlet var sehirlerTableview: UITableView!

  var cities: [Location] = []
  let searchController = UISearchController(searchResultsController: nil)
  let sehirlerVModel = SehirlerVModel()
  lazy var searchBar = UISearchBar()
  var segueIdentifier = "goToSehir"
  var locationToAdd: [Location]?
  var cityNames: [String] = []
  var isSearchBarEmpty: Bool {
    searchController.searchBar.text?.isEmpty ?? true
  }

  var isFiltering: Bool {
    searchController.isActive && !isSearchBarEmpty
  }

  // Searchbar Search icon sağa almak için
  private func setSearchTextField() {
    let imageView = UIImageView(image: UIImage(named: "ara"))
    let searchTextField: UITextField = searchController.searchBar.value(
      forKey: "searchField"
    ) as? UITextField ?? UITextField()
    searchTextField.layer.cornerRadius = 15
    searchTextField.textAlignment = .left
    searchTextField.leftView = nil
    searchTextField.placeholder = " Type minimum 3 characters"
    searchTextField.rightView = imageView
    searchTextField.rightViewMode = UITextField.ViewMode.always
    searchTextField.leftViewMode = UITextField.ViewMode.always
  }

  @IBAction func getLocationIBA(_ sender: Any) {
    getLocation()
  }

  func getLocation() {
    let locationService = LocationService()

    locationService.requestLocation {location, error in
      if let error = error {
        self.showAlert(title: "Error", message: error)
        return
      }
      guard let location = location else {
        self.showAlert(title: "Error", message: "Unable to retrieve location.")
        return
      }
      locationService.retrieveCityName(
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude
      ) { placeMark in
        guard let placeMark = placeMark,
          let cityName = placeMark.administrativeArea,
          let countryName = placeMark.country else {
          self.showAlert(title: "Error", message: "Unable to retrieve city information.")
          return
        }
        let citiesArray = UserDefaultsHelper.getCities()
        if citiesArray.contains(where: { $0.localizedName == cityName }) {
          self.showAlert(title: CustomAlerts.sameCity.alertTitle, alertType: CustomAlerts.sameCity.alertType)
        } else {
          let geoPosition = Location.GeoPosition(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
          )
          let city = Location(
            localizedName: cityName,
            country: Location.Country(
              localizedName: countryName
            ),
            geoPosition: geoPosition
          )
          UserDefaultsHelper.saveCity(city: city)
          self.showAlert(title: CustomAlerts.added.alertTitle, alertType: CustomAlerts.added.alertType)
          self.searchController.searchBar.text = ""
          self.cities.removeAll()
          self.sehirlerTableview.reloadData()
          self.searchController.searchBar.endEditing(true)
          GlobalSettings.shouldUpdateSegments = true
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setConfig()
  }

  private func setBindingforCoordinate() {
    sehirlerVModel.location.bind { [weak self] location in
      self?.locationToAdd = location
    }
    sehirlerVModel.locationSearchData.bind { [weak self] searchData in
      self?.cities = searchData
    }
    sehirlerVModel.cityNames.bind { [weak self] cityNames in
      self?.cityNames = cityNames
    }
  }

  override func setConfig() {
    super.setConfig()
    sehirlerTableview.delegate = self
    sehirlerTableview.dataSource = self
    sehirlerTableview.allowsSelection = false
    navigationItem.titleView = searchController.searchBar
    searchController.hidesNavigationBarDuringPresentation = false
    navigationController?.navigationBar.backItem?.title = ""
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    definesPresentationContext = true
    searchController.searchBar.setValue("Cancel", forKey: "cancelButtonText")
    sehirlerTableview.estimatedRowHeight = 50
    setSearchTextField()
    setBindingforCoordinate()
  }

  override func viewWillLayoutSubviews() {
    setSearchTextField()
  }

  func filterContentForSearchText(_ searchText: String) {
    view.showSpinner()
    let searchTxt = searchText.replacingOccurrences(of: " ", with: "%20")
    sehirlerVModel.findCity(query: searchTxt) { [weak self] in
      DispatchQueue.main.async {
        self?.view.removeSpinner()
        self?.sehirlerTableview.reloadData()
      }
    }
  }
}

// MARK: TableView Functions

extension SehirlerDetayVController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if cities.isEmpty && isFiltering {
      if let searchText = searchController.searchBar.text, searchText.count > 2 {
        tableView.setEmptyView(title: "Location Not Found", message: "Try something different", animation: "not-found")
      }
    } else {
      tableView.restoreToFullTableView()
    }
    return cities.count
  }


  // Inside your cellForRowAt method
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: SehirlerDetayTVCell.reuseIdentifier,
      for: indexPath
    ) as? SehirlerDetayTVCell else {
      fatalError("Failed to dequeue SehirlerDetayTVCell")
    }
    let city = cityNames[indexPath.row] // cityNames dizisi kullanılıyor
    cell.set(city: city, parentVC: self)
    // Configure cell action
    cell.ekleAction = { [weak self] in
      guard let self = self else { return }
      let citiesArray = UserDefaultsHelper.getCities()
      let cityName = city // cityNames dizisinden alınan şehir ismi kullanılıyor
      // Check if city already exists in UserDefaults
      guard !citiesArray.contains(where: { $0.localizedName == cityName }) else {
        // Handle case where city is already selected
        self.showAlert(title: "Error", message: "City already selected.")
        return
      }
      // Find coordinates for the city
      self.sehirlerVModel.findCoordinate(query: cityName) { result in
        switch result {
        case .success:
          DispatchQueue.main.async {
            guard let locationToAdd = self.locationToAdd else { return }
            guard let location = locationToAdd.first else { return }
            self.handleCityAdded(location: location)
          }
        case .failure(let error):
          // Handle coordinate retrieval failure
          DispatchQueue.main.async {
            self.showAlert(title: "Error", message: error.localizedDescription)
          }
        }
      }
    }
    return cell
  }

  // Helper method to handle city added to UserDefaults
  private func handleCityAdded(location: Location) {
    showAlert(title: CustomAlerts.added.alertTitle, alertType: CustomAlerts.added.alertType)
    GlobalSettings.shouldUpdateSegments = true
    searchController.searchBar.text = ""
    cities = []
    sehirlerTableview.reloadData()
    searchController.searchBar.endEditing(true)
    UserDefaultsHelper.saveCity(city: location)
  }
}

extension SehirlerDetayVController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text, searchText.count > 2 else {
      cities = []
      sehirlerTableview.reloadData()
      return
    }
    filterContentForSearchText(searchText)
  }
}
