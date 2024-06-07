
import SkeletonView
import UIKit

class SehirlerDetayVController: BaseVController {
    @IBOutlet var sehirlerTableview: UITableView!

    var cities: [Location] = []
    let searchController = UISearchController(searchResultsController: nil)
    let sehirlerVModel = SehirlerVModel()
    lazy var searchBar = UISearchBar()
    var segueIdentifier = "goToSehir"
  var locationToAdd : Location?

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
//        getLocation()
    }

//    func getLocation() {
//        let getLocation = GetLocation()
//
//        getLocation.run { location, error in
//
//            if error == nil {
//                if let location = location {
//                    getLocation.retreiveCityName(lattitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionHandler: { placeMark in
//
//                        var citiesArray = SehirlerVController.getCities()
//                        let cityName = placeMark.administrativeArea
//
//                      if let _ = citiesArray?.first(where: { $0.LocalizedName == cityName! }) {
//                            Utility.alert(msg: CustomAlerts.sameCity.alertTitle, type: CustomAlerts.sameCity.alertType)
//
//                        } else {
//                            var city = Location()
//                            city.cityName = cityName
//                            city.countryName = placeMark.country
//                            city.lon = location.coordinate.longitude as Double
//                            city.lat = location.coordinate.latitude as Double
//                            citiesArray?.append(city)
//                            SehirlerDetayVController.saveCities(arrayCity: citiesArray!)
//                            Utility.alert(msg: CustomAlerts.added.alertTitle, type: CustomAlerts.added.alertType)
//                            self.searchController.searchBar.text = ""
//                            self.cities = []
//                            self.sehirlerTableview.reloadData()
//                            self.searchController.searchBar.endEditing(true)
//                            SehirlerVController.shouldUpdateSegments = true
//                        }
//                    }
//                    )
//                }
//            } else {
//                Utility.alert(msg: error, type: .err)
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
    }
  
  private func setBindingforCoordinate() {
    sehirlerVModel.location.bind { [weak self] location in
      self?.locationToAdd = location[0]
    }
    sehirlerVModel.locationSearchData.bind { [weak self] searchdata in
      self?.cities = searchdata
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
        addSkeleton()
        let searchTxt = searchText.replacingOccurrences(of: " ", with: "%20")
      sehirlerVModel.findCity(query: searchTxt) { [weak self] in
        DispatchQueue.main.async{
          self?.removeSkeleton()
          self?.sehirlerTableview.reloadData()
        }
      }
    }

    func addSkeleton() {
        view.showSkeleton()
    }

    func removeSkeleton() {
        view.hideSkeleton()
    }
}

// MARK: TableView Functions

extension SehirlerDetayVController: UITableViewDelegate, SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return SehirlerDetayTVCell.reuseIdentifier
  }
  
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
    let city = cities[indexPath.row].locationName
    
    cell.set(city: city!)
    
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
            Utility.alert(msg: CustomAlerts.added.alertTitle, type: CustomAlerts.added.alertType)
            SehirlerVController.shouldUpdateSegments = true
            self?.searchController.searchBar.text = ""
            self?.cities = []
            self?.sehirlerTableview.reloadData()
            self?.searchController.searchBar.endEditing(true)
            SehirlerVController.shouldUpdateSegments = true
            UserDefaultsHelper.saveCity(city: (self?.locationToAdd!)!)
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
