//
//  AnasayfaVController.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import Network
import SkeletonView
import UIKit
import XLPagerTabStrip

class AnasayfaVController: BaseVController {
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var scrollViewAnasayfa: UIScrollView!
    @IBOutlet var dailyWeatherCV: UICollectionView!
    @IBOutlet var weeklyWeatherTV: UITableView!
    @IBOutlet var lblTemperature: UILabel!
    @IBOutlet var imgWeatherMain: UIImageView!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblLowestTemperature: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblHighestTemperature: UILabel!
    @IBOutlet var lblVisibility: UILabel!
    @IBOutlet var lblWind: UILabel!
    @IBOutlet var lblHumidity: UILabel!
    @IBOutlet var lblUV: UILabel!
    @IBOutlet var welcomeAnimationView: UIView!

    let refreshControl = UIRefreshControl()
    var segmentedControl: UISegmentedControl?
    var city: Location = Location(json: [:])
    var dataWeather: HavaDurum = HavaDurum(json: [:])
    var weeklyWeather: HavaDurumWeekly = HavaDurumWeekly(json: [:])
    private let spacing: CGFloat = 4.0
    var selectedCities = SehirlerVController.getCities()

    lazy var sehirlerVModel: CitiesMainVModel = {
        let vm = CitiesMainVModel(view: self.view)
        vm.delegate = self
        return vm
    }()

    override func viewDidLoad() {
        Utility.netWorkConnectivityCheck()
        config()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedCities = SehirlerVController.getCities()
        if !selectedCities.isEmpty {
            emptyView.removeFromSuperview()
            scrollViewAnasayfa.isHidden = false
            fetchData()
            if let _ = segmentedControl {
                if SehirlerVController.shouldUpdateSegments {
                    let items = SehirlerVController.getCities().map({ $0.cityName! })
                    segmentedControl?.replaceSegments(segments: items)
                    segmentedControl?.selectedSegmentIndex = 0
                    SehirlerVController.shouldUpdateSegments = false
                }
            } else {
                createSegmentedControl()
            }
            
            addSkeleton()
            
        } else {
            view.addSubview(emptyView)
            Utility.startAnimation(jsonFile: "welcome-page", view: welcomeAnimationView)
            emptyView.center = view.center
            scrollViewAnasayfa.isHidden = true
        }
    }

    func switchSegmentControlSkeletonable() {
        if let _ = segmentedControl {
            let state = !segmentedControl!.isSkeletonable
            segmentedControl!.isSkeletonable = state
            state ? segmentedControl!.showAnimatedGradientSkeleton() : segmentedControl!.hideSkeleton()
            
            if #available(iOS 13.0, *) {
                segmentedControl!.selectedSegmentTintColor = state ? Colors.alpha : Colors.tint
            }
            
            let attributes = [NSAttributedString.Key.foregroundColor: state ? Colors.alpha : Colors.segmentedControlNormalState]
            let attributesSelected = [NSAttributedString.Key.foregroundColor: state ? Colors.alpha : Colors.segmentedControlSelectedState]
            segmentedControl!.setTitleTextAttributes(attributes, for: .normal)
            segmentedControl!.setTitleTextAttributes(attributesSelected, for: .selected)
            segmentedControl!.backgroundColor = Colors.segmentedControlSelectedState
        }
    }

    func addSkeleton(){
        scrollViewAnasayfa.showAnimatedGradientSkeleton()
        switchSegmentControlSkeletonable()
    }
    
    func removeSkeleton() {
        scrollViewAnasayfa.hideSkeleton()
        switchSegmentControlSkeletonable()
    }

    func config() {
        weeklyWeatherTV.dataSource = self
        weeklyWeatherTV.delegate = self
        scrollViewAnasayfa.delegate = self
        dailyWeatherCV.delegate = self
        dailyWeatherCV.dataSource = self

//         Collection view cell equaled size config
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        dailyWeatherCV?.collectionViewLayout = layout
    
        refreshControl.attributedTitle = NSAttributedString(string: "Updating")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        scrollViewAnasayfa.addSubview(refreshControl)

        // for skeletonview
        weeklyWeatherTV.estimatedRowHeight = 50
        

    }

    func setData() {
        let data = dataWeather.list[0]
        lblTemperature.text = data.main.temp! + "°C"
        imgWeatherMain.image = UIImage(named: data.weather[0].icon!)
        lblDescription.text = data.weather[0].description?.capitalized
        lblVisibility.text = String(Int(data.visibility! / 1000)) + " km"
        lblWind.text = String(data.wind.deg!) + "m/s"
        lblHumidity.text = "%" + String(data.main.humidity!)

        do {
            lblDate.text = try? Utility.dateFormatter(to: .strToStr, value: data.dt_text!, outputFormat: "dd/MM/yyyy") as? String
        }
    }

    func fetchData(selectedCityIndex: Int = 0) {
        
        city = selectedCities[selectedCityIndex]
        let parametersWeekly: [String: Any] = ["lon": String(city.lon!), "lat": String(city.lat!), "exclude": "current,minutely,hourly,alerts"]
        let parametersDaily: [String: Any] = ["q": city.cityName!, "cnt": 5]
//        let parametersWeekly: [String: Any] = ["q": city.cityName!, "cnt": 7]
        sehirlerVModel.getWeatherForecast(parameters: parametersDaily)
        sehirlerVModel.getWeatherForecastWeekly(parameters: parametersWeekly)
    }

    func createSegmentedControl() {
        let items = selectedCities.map({ $0.cityName! })
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl!.selectedSegmentIndex = 0
        segmentedControl!.backgroundColor = Colors.iosCaseLightGray
        segmentedControl!.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        mainStackView.insertArrangedSubview(segmentedControl!, at: 0)
    }

    @objc func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
        fetchData(selectedCityIndex: segmentedControl.selectedSegmentIndex)
        addSkeleton()
    }

    @objc func didPullToRefresh() {
        fetchData()
        addSkeleton()
    }
}

extension AnasayfaVController: SehirlerMainVModelDelegate {
    func getWeatherCastWeeklyCompleted(data: HavaDurumWeekly) {
        weeklyWeather = data
        lblUV.text = data.uv!
        weeklyWeatherTV.reloadData()
        if weeklyWeather.list.count > 0 && dataWeather.list.count > 0 {
            // Refreshle eklenen viewi kaldırmak için
            refreshControl.endRefreshing()
            removeSkeleton()
        }
    }

    func getWeatherCastCompleted(data: HavaDurum) {
        dataWeather = data
        setData()
        dailyWeatherCV.reloadData()
    }
}

extension AnasayfaVController: UITableViewDelegate, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeather.list.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AnasayfaWeeklyWeatherTVCell.reuseIdentifier
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnasayfaWeeklyWeatherTVCell.reuseIdentifier, for: indexPath) as! AnasayfaWeeklyWeatherTVCell
        let rowData = weeklyWeather.list[indexPath.row]

        cell.imgWeatherTV.image = UIImage(named: rowData.icon!)
        cell.lblMaxWeatherTV.text = rowData.max
        cell.lblMinWeatherTV.text = rowData.min
        do {
            // EEEE direk gün ismi
            cell.lblDay.text = try? Utility.dateFormatter(to: .toStr, value: rowData.dt, outputFormat: "EEEE") as? String
        }
        return cell
    }
}

extension AnasayfaVController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 && scrollView == scrollViewAnasayfa {
            scrollView.contentOffset.x = 0
        }

    }
}

extension AnasayfaVController: UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AnasayfaDailyWeatherCVCell.reuseIdentifier
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataWeather.list.count
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnasayfaDailyWeatherCVCell.reuseIdentifier, for: indexPath) as! AnasayfaDailyWeatherCVCell

        let rowData = dataWeather.list[indexPath.row]

        cell.hour.text = indexPath.row == 0 ? "Now" :
        try? Utility.dateFormatter(to: .strToStr, value: rowData.dt_text!, outputFormat: "HH:mm") as? String

//        cell.imgWeather.image = UIImage(named: rowData.weather[0].icon!)?.withRenderingMode(.alwaysTemplate)
        cell.imgWeather.image = UIImage(named: rowData.weather[0].icon!)
        cell.imgWeather.layer.masksToBounds = true
        cell.imgWeather.layer.cornerRadius = 12

        return cell
    }
}

// Collection view cell equaled size delegate method

extension AnasayfaVController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 5
        let spacingBetweenCells: CGFloat = 15

        let totalSpacing = (2 * spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) // Amount of total spacing in a row

        if let collection = dailyWeatherCV {
            let width = (collection.bounds.width - totalSpacing) / numberOfItemsPerRow
            return CGSize(width: width, height: collectionView.bounds.height-10)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
