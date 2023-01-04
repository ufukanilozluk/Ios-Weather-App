//
//  SehirlerDetayVController.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük

import SkeletonView
import UIKit

class SehirlerDetayVController: BaseVController {
    struct Section {
        let letter: String
        let names: [String]
    }

    @IBOutlet var sehirlerTableview: UITableView!

    var once: Bool = false
    var sections = [Section]()
    var cities: [Location] = []
    let searchController = UISearchController(searchResultsController: nil)
    lazy var sehirlerVModel: SehirlerVModel = {
        let vm = SehirlerVModel(view: self.view)
        vm.delegate = self
        return vm
    }()

    lazy var searchBar = UISearchBar()
    var segueIdentifier = "goToSehir"
    var filteredCities: [Section] = []

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    // Searchbar Search icon sağa almak için

    override func viewDidLayoutSubviews() {
        let image: UIImage = UIImage(named: "ara")!
        let imageView: UIImageView = UIImageView(image: image)

        let searchTextField: UITextField = searchController.searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
        searchTextField.layer.cornerRadius = 15
        searchTextField.textAlignment = .left
        searchTextField.leftView = nil
        searchTextField.placeholder = " Search for a location"
        searchTextField.rightView = imageView
        searchTextField.rightViewMode = UITextField.ViewMode.always
        searchTextField.leftViewMode = UITextField.ViewMode.always
    }

    @IBAction func getLocationIBA(_ sender: Any) {
        getLocation()
    }

    func getLocation() {
        let getLocation = GetLocation()

        getLocation.run { location, error in

            if error == nil {
                if let location = location {
                    getLocation.retreiveCityName(lattitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionHandler: { placeMark in

                        var citiesArray = SehirlerVController.getCities()
                        let cityName = placeMark.administrativeArea
                        if !self.once {
                            if let _ = citiesArray.first(where: { $0.cityName! == cityName! }) {
                                Utility.alert(msg: CustomAlerts.sameCity.alertTitle, type: CustomAlerts.sameCity.alertType)

                            } else {
                                var city = Location(json: [:])
                                city.cityName = cityName
                                city.countryName = placeMark.country
                                city.lon = location.coordinate.longitude as Double
                                city.lat = location.coordinate.latitude as Double
                                citiesArray.append(city)
                                SehirlerDetayVController.saveCities(arrayCity: citiesArray)
                                Utility.alert(msg: CustomAlerts.added.alertTitle, type: CustomAlerts.added.alertType)
                                self.searchController.searchBar.text = ""
                                self.cities = []
                                self.sehirlerTableview.reloadData()
                                self.searchController.searchBar.endEditing(true)
                                SehirlerVController.shouldUpdateSegments = true
                            }
                            self.once = true
                        }
                    }
                    )
                }
            } else {
                Utility.alert(msg: error, type: .err)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
    }

    override func setConfig() {
        super.setConfig()
        sehirlerTableview.delegate = self
        sehirlerTableview.dataSource = self
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        navigationController?.navigationBar.backItem?.title = ""
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.setValue("Cancel", forKey: "cancelButtonText")
        sehirlerTableview.estimatedRowHeight = 50
    }

    // UserDefaultsa struct array kaydetmek için
    class func saveCities(arrayCity: [Location]) {
        let cityData = arrayCity.map { $0.encode() }
        UserDefaults.standard.set(cityData, forKey: "cities")
    }

    func filterContentForSearchText(_ searchText: String) {
        addSkeleton()
        let searchTxt = searchText.replacingOccurrences(of: " ", with: "%20")
        sehirlerVModel.findCity(query: searchTxt)
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
        return cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SehirlerDetayTVCell.reuseIdentifier, for: indexPath) as! SehirlerDetayTVCell
        let city = cities[indexPath.row].locationName

        cell.set(city: city!)

//Refactor ?
        cell.ekleAction = {
            var citiesArray = SehirlerVController.getCities()
            let cityName = self.cities[indexPath.row].cityName!
            var city = self.cities.first(where: { $0.cityName == cityName })
            if let _ = citiesArray.first(where: { $0.cityName! == city?.cityName! }) {
                throw SehirEkleError.sameSelection
            }

            self.sehirlerVModel.findCoordinate(query: cityName) { data in
                city?.lat = data?["Latitude"] as? Double
                city?.lon = data?["Longitude"] as? Double

                citiesArray.append(city!)
                SehirlerDetayVController.saveCities(arrayCity: citiesArray)
                Utility.alert(msg: CustomAlerts.added.alertTitle, type: CustomAlerts.added.alertType)
                SehirlerVController.shouldUpdateSegments = true
                self.searchController.searchBar.text = ""
                self.cities = []
                self.sehirlerTableview.reloadData()
                self.searchController.searchBar.endEditing(true)
                SehirlerVController.shouldUpdateSegments = true
            }
        }
        return cell
    }
}

// MARK: ViewModel Delegate Functions

extension SehirlerDetayVController: SehirEkleVModelDelegate {
    func getCityListCompleted(data: [Location]) {
        cities = data
        removeSkeleton()
        sehirlerTableview.reloadData()
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
