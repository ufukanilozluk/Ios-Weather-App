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
    var weeklyWeather: HavaDurumWeekly?
    private let spacing: CGFloat = 4.0
    static var selectedCities: [Location]?
    var selectedCity: Location?
    var viewModel: CitiesMainVModel = CitiesMainVModel()

    override func viewDidLoad() {
        Utility.netWorkConnectivityCheck()
        configUI()
    }

    func updateHome() {
        guard let cities = SehirlerVController.getCities() else {
            view.addSubview(emptyView)
            Utility.startAnimation(jsonFile: "welcome-page", view: welcomeAnimationView)
            emptyView.center = view.center
            scrollViewAnasayfa.isHidden = true
            return
        }
        AnasayfaVController.selectedCities = cities
        emptyView.removeFromSuperview()
        scrollViewAnasayfa.isHidden = false

        if let _ = segmentedControl {
            if SehirlerVController.shouldUpdateSegments {
                let items = AnasayfaVController.selectedCities!.map({ $0.cityTxt })
                segmentedControl?.replaceSegments(segments: items)
                segmentedControl?.selectedSegmentIndex = 0
                SehirlerVController.shouldUpdateSegments = false
            }
        } else {
            createSegmentedControl()
        }
        selectedCity = AnasayfaVController.selectedCities![segmentedControl!.selectedSegmentIndex]
        fetchData(for: selectedCity!)
        addSkeleton()
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

    func configUI() {
        weeklyWeatherTV.dataSource = self
        weeklyWeatherTV.delegate = self
        scrollViewAnasayfa.delegate = self
        dailyWeatherCV.delegate = self
        dailyWeatherCV.dataSource = self

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

        viewModel.weeklyWeatherData.bind { [weak self] weeklyWeatherData in
            self?.weeklyWeather = weeklyWeatherData
        }
    }

    func updateUI() {
        setBindings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dailyWeatherCV.reloadData()
            self.weeklyWeatherTV.reloadData()
            self.refreshControl.endRefreshing()
            self.removeSkeleton()
        }
    }

    func fetchData(for city: Location) {
        viewModel.getForecast(city: city) {
            self.updateUI()
        }
    }

    func createSegmentedControl() {
        let items = AnasayfaVController.selectedCities!.map({ $0.cityTxt })
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
        selectedCity = AnasayfaVController.selectedCities![segmentedControl.selectedSegmentIndex]
        fetchData(for: selectedCity!)
        addSkeleton()
    }

    @objc func didPullToRefresh() {
        fetchData(for: selectedCity!)
        addSkeleton()
    }
}

extension AnasayfaVController: UITableViewDelegate, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeather?.daily.count ?? 0
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AnasayfaWeeklyWeatherTVCell.reuseIdentifier
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnasayfaWeeklyWeatherTVCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? AnasayfaWeeklyWeatherTVCell {
            cell.data = weeklyWeather!.daily[indexPath.row]
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

extension AnasayfaVController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
