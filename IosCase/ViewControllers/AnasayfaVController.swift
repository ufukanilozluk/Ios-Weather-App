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
    @IBOutlet var lblPressure: UILabel!
    @IBOutlet var welcomeAnimationView: UIView!

    lazy var refreshControl = UIRefreshControl()
    var segmentedControl: UISegmentedControl?
    var city: Location = Location(json: [:])
    var dataWeather: [HavaDurum.Hava]?

    var weeklyWeather: HavaDurumWeekly = HavaDurumWeekly(json: [:])
    private let spacing: CGFloat = 4.0
    var selectedCities = SehirlerVController.getCities()

    let dispatchGroup = DispatchGroup()
    var viewModel: CitiesMainVModel = CitiesMainVModel()

    override func viewDidLoad() {
        Utility.netWorkConnectivityCheck()
        config()
        fetchData()
    }

    func updateHome() {
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

    override func viewWillAppear(_ animated: Bool) {
        updateHome()
    }

    func addSkeleton() {
        scrollViewAnasayfa.showAnimatedGradientSkeleton()
    }

    func removeSkeleton() {
        scrollViewAnasayfa.hideSkeleton()
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

    func setBindings() {
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

        viewModel.date.bind { [weak self] date in

            DispatchQueue.main.async {
                self?.lblDate.text = date
            }
        }

        viewModel.weatherData.bind { [weak self] weatherData in
            self?.dataWeather = weatherData
        }
    }

    func updateUI() {
        setBindings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dailyWeatherCV.reloadData()
            self.refreshControl.endRefreshing()
            self.removeSkeleton()
        }
    }

    func fetchData(selectedCityIndex: Int = 0) {
        city = selectedCities[selectedCityIndex]
        viewModel.getWeather(city: city.cityName!) {
            self.updateUI()
        }

//        let parametersWeekly: [String: Any] = ["lon": String(city.lon!), "lat": String(city.lat!), "exclude": "current,minutely,hourly,alerts"]

//        let parametersWeekly: [String: Any] = ["q": city.cityName!, "cnt": 7]

//        dispatchGroup.enter()
        ////        sehirlerVModel.getWeather { [self] forecast in
        ////            self.dataWeather = forecast
        ////            self.dispatchGroup.leave()
        ////        }
        ////        dispatchGroup.enter()
        ////        sehirlerVModel.getWeatherForecastWeekly(parameters: parametersWeekly)
//        dispatchGroup.notify(queue: .main) {

//        }
    }

    func createSegmentedControl() {
        let items = selectedCities.map({ $0.cityName! })
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl!.selectedSegmentIndex = 0
        segmentedControl!.backgroundColor = Colors.iosCaseLightGray
        segmentedControl!.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        mainStackView.insertArrangedSubview(segmentedControl!, at: 0)

        let attributes = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlNormalState]
        let attributesSelected = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlSelectedState]
        segmentedControl!.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl!.setTitleTextAttributes(attributesSelected, for: .selected)
        segmentedControl!.backgroundColor = Colors.segmentedControlSelectedState
        if #available(iOS 13.0, *) {
            segmentedControl!.selectedSegmentTintColor = Colors.tint
        }
    }

    @objc func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
        fetchData(selectedCityIndex: segmentedControl.selectedSegmentIndex)
        addSkeleton()
    }

    @objc func didPullToRefresh() {
        fetchData(selectedCityIndex: segmentedControl!.selectedSegmentIndex)
        addSkeleton()
    }
}

extension AnasayfaVController: UITableViewDelegate, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeather.list.count
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AnasayfaWeeklyWeatherTVCell.reuseIdentifier
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnasayfaWeeklyWeatherTVCell.reuseIdentifier, for: indexPath) as! AnasayfaWeeklyWeatherTVCell
        cell.data = weeklyWeather.list[indexPath.row]
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
        AnasayfaDailyWeatherCVCell.reuseIdentifier
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataWeather?.count ?? 0
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataWeather?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnasayfaDailyWeatherCVCell.reuseIdentifier, for: indexPath)

        if let cell = cell as? AnasayfaDailyWeatherCVCell {
            if let rowData = dataWeather?[indexPath.row] {
                cell.set(data: rowData, indexPath: indexPath)
            }
        }

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
            return CGSize(width: width, height: collectionView.bounds.height - 10)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
