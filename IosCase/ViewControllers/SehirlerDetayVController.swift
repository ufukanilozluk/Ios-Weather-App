//
//  SehirlerDetayVController.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import UIKit

class SehirlerDetayVController: BaseVController {
    struct Section {
        let letter: String
        let names: [String]
    }

    var sections = [Section]()
    var turkeyCities: [String] = []
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
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    // Searchbar Search icon sağa almak için

    override func viewDidLayoutSubviews() {
        let searchTextField: UITextField = searchController.searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
        searchTextField.layer.cornerRadius = 15
        searchTextField.textAlignment = .left
        let image: UIImage = UIImage(named: "ara")!
        let imageView: UIImageView = UIImageView(image: image)
        searchTextField.leftView = nil
        searchTextField.placeholder = "Şehir Ara"
        searchTextField.rightView = imageView
        searchTextField.rightViewMode = UITextField.ViewMode.always
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

//        searchController.searchBar.setImage(image, for: .search, state: .normal)
//        searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: searchController.searchBar.frame.width ,vertical: 0), for:.search )

        // navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.setValue("Vazgeç", forKey: "cancelButtonText")
        // Yanda çıkan rehber gibi şeyin rengi
        sehirlerTableview.sectionIndexColor = Colors.iosCasePurple
    }

    @IBOutlet var sehirlerTableview: UITableView!

    // UserDefaultsa struct array kaydetmek için
    class func saveCities(arrayCity: [Location]) {
        let cityData = arrayCity.map { $0.encode() }
        UserDefaults.standard.set(cityData, forKey: "cities")
    }

    func filterContentForSearchText(_ searchText: String) {
//        let filtered = cities.filter {
//            $0.name!.lowercased().contains(searchText.lowercased())
//        }
//        filteredCities = createAlphabetSectionsFrom(data: filtered)
//        sehirlerTableview.reloadData()
        if searchText.count > 2 {
            sehirlerVModel.findCity(query: searchText)
        }
    }

//    fileprivate func createAlphabetSectionsFrom(data cities: [City]) -> [Section] {
//        turkeyCities = cities.map { $0.name! }
//        // Array Gruplama ilk harfe göre
//        let groupedDictionary = Dictionary(grouping: turkeyCities, by: { String($0.prefix(1)) })
//        // get the keys and sort them
//
//        let keys = groupedDictionary.keys.sorted(by: {
//            let locale = NSLocale(localeIdentifier: "tr")
//            let firstLetter = String($0) as NSString
//            let secondLetter = String($1) as NSString
//            return firstLetter.compare(secondLetter as String, options: .caseInsensitive, range: NSMakeRange(0, 1), locale: locale) == ComparisonResult.orderedAscending
//        })
//        // map the sorted keys to a struct
//        let sections = keys.map { Section(letter: $0, names: groupedDictionary[$0]!.sorted(by: {
//            let locale = NSLocale(localeIdentifier: "tr")
//            let firstCity = String($0) as NSString
//            let secondCity = String($1) as NSString
//            return firstCity.compare(secondCity as String, options: .caseInsensitive, range: NSMakeRange(0, firstCity.length), locale: locale) == ComparisonResult.orderedAscending
//        })) }
//        return sections
//    }
}

// MARK: TableView Functions

extension SehirlerDetayVController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering {
//            return filteredCities[section].names.count
//        }

        return cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData: Section
//        if isFiltering {
//            rowData = filteredCities[indexPath.section]
//        } else {
//            rowData = sections[indexPath.section]
//        }

//        rowData = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SehirlerDetayCell", for: indexPath) as! SehirlerDetayTVCell
//        cell.sehirName.text = rowData.names[indexPath.row]
        cell.sehirName.text = cities[indexPath.row].cityName! + "," + cities[indexPath.row].countryName!
        
        cell.ekleAction = {
            var citiesArray = SehirlerVController.getCities()
//            let cityName = rowData.names[indexPath.row]
            
//            let cityName = rowData.names[indexPath.row]
            let cityName = self.cities[indexPath.row].cityName!
            let city = self.cities.first(where: { $0.cityName == cityName })

            guard !citiesArray.contains(city!) else {
                throw WeatherAppErrors.SehirEkleError.sameSelection
            }
            citiesArray.append(city!)
            SehirlerDetayVController.saveCities(arrayCity: citiesArray)
            alert(msg: "Başarıyla eklendi", type: .succ)
            SehirlerVController.shouldUpdateSegments = true
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
//        if isFiltering {
//            if filteredCities.count == 0 {
//                tableView.setEmptyView(title: "Sonuç bulunamadı", message: "Farklı bir arama kriteri deneyiniz", animation: "not-found")
//            } else {
//                tableView.restoreToFullTableView()
//            }
//            return filteredCities.count
//        }
//        return sections.count
        return 1
    }

    // Yanda çıkan title rehberdeki gibi
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        if isFiltering {
//            return filteredCities.map { $0.letter }
//        }
//        return sections.map { $0.letter }
//    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if isFiltering {
//            return filteredCities[section].letter
//        }
//        return sections[section].letter
//    }
}

// MARK: ViewModel Delegate Functions

extension SehirlerDetayVController: SehirEkleVModelDelegate {
    func getCityListCompleted(data: [Location]) {
        cities = data
        //       sections = createAlphabetSectionsFrom(data: data)
        sehirlerTableview.reloadData()
    }
}

extension SehirlerDetayVController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
