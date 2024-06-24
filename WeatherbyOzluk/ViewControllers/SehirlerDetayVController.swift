import UIKit

class SehirlerDetayVController: BaseVController {
    @IBOutlet var sehirlerTableview: UITableView!

    var cities: [Location] = []
    let searchController = UISearchController(searchResultsController: nil)
    let sehirlerVModel = SehirlerVModel()
    lazy var searchBar = UISearchBar()
    var segueIdentifier = "goToSehir"
    var locationToAdd : [Location]?
    var cityNames : [String] = []
 
    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    // Searchbar Search icon sağa almak için
    fileprivate func setSearchTextField() {
        let imageView = UIImageView(image: UIImage(named:"ara"))
        let searchTextField: UITextField = searchController.searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
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

      locationService.requestLocation { location, error in
          guard error == nil else {
              self.showAlert(title: "Error", message: error!)
              return
          }
          
          guard let location = location else {
              self.showAlert(title: "Error", message: "Unable to retrieve location.")
              return
          }
          
          locationService.retrieveCityName(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { placeMark in
              guard let placeMark = placeMark,
                    let cityName = placeMark.administrativeArea,
                    let countryName = placeMark.country else {
                  self.showAlert(title: "Error", message: "Unable to retrieve city information.")
                  return
              }
              
            let citiesArray = UserDefaultsHelper.getCities()
              if citiesArray.contains(where: { $0.LocalizedName == cityName }) {
                  self.showAlert(title: CustomAlerts.sameCity.alertTitle, alertType: CustomAlerts.sameCity.alertType)
              } else {
                  let geoPosition = Location.GeoPosition(Latitude: location.coordinate.latitude, Longitude: location.coordinate.longitude)
                  let city = Location(LocalizedName: cityName, Country: Location.Country(LocalizedName: countryName), GeoPosition: geoPosition)
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
        DispatchQueue.main.async{
          self?.view.removeSpinner()
          self?.sehirlerTableview.reloadData()
        }
      }
    }
  
}

// MARK: TableView Functions

extension SehirlerDetayVController: UITableViewDelegate, UITableViewDataSource {
 
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if cities.count == 0 && isFiltering {
      let searchText: String = searchController.searchBar.text!
      if searchText.count > 2 {
        tableView.setEmptyView(title: "Location Not Found", message: "Try something different", animation: "not-found")
      }
      
    } else {
      tableView.restoreToFullTableView()
    }
    
    return cities.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SehirlerDetayTVCell.reuseIdentifier, for: indexPath) as! SehirlerDetayTVCell
    let city = cityNames[indexPath.row]
    cell.set(city: city, parentVC: self)
    
    // Refactor ?
    cell.ekleAction = {
      
      let citiesArray = UserDefaultsHelper.getCities()
      let cityName = self.cities[indexPath.row].LocalizedName
      let city = self.cities.first(where: { $0.LocalizedName == cityName })
      guard  !citiesArray.contains(where: { $0.LocalizedName == city?.LocalizedName }) else {
        throw SehirEkleError.sameSelection
      }
      
      self.sehirlerVModel.findCoordinate(query: cityName) { [weak self] result in
        
        switch result {
        case .success:
          DispatchQueue.main.async {
            self?.showAlert(title: CustomAlerts.added.alertTitle , alertType: CustomAlerts.added.alertType)
            GlobalSettings.shouldUpdateSegments = true
            self?.searchController.searchBar.text = ""
            self?.cities = []
            self?.sehirlerTableview.reloadData()
            self?.searchController.searchBar.endEditing(true)
            UserDefaultsHelper.saveCity(city: (self?.locationToAdd![0])!)
          }
        case let .failure(error):
          self?.showAlert(title: "Error", message: error.localizedDescription)
        }
      
      }
    }
    return cell
  }
}
  
  
  
  extension SehirlerDetayVController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
      let searchText: String = searchController.searchBar.text!
      if searchText.count > 2 {
        filterContentForSearchText(searchText)
      } else {
        cities = []
        sehirlerTableview.reloadData()
      }
    }
  }
