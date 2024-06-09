import Network
import SkeletonView
import UIKit

class AnasayfaVController: BaseVController {
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
//    var city: Location = Location()
    var dataWeather: [HavaDurum.Hava]?
    var weeklyWeather: HavaDurumWeekly?
    private let spacing: CGFloat = 4.0
    static var selectedCities: [Location] = UserDefaultsHelper.getCities()
    var selectedCity: Location?
    var viewModel: CitiesMainVModel = CitiesMainVModel()

    override func viewDidLoad() {
        Utility.netWorkConnectivityCheck()
        configUI()
    }

    func updateHome() {
      AnasayfaVController.selectedCities = UserDefaultsHelper.getCities()
      guard  !AnasayfaVController.selectedCities.isEmpty else {
            view.addSubview(emptyView)
            Utility.startAnimation(jsonFile: "welcome-page", view: welcomeAnimationView)
            emptyView.center = view.center
            scrollViewAnasayfa.isHidden = true
            return
        }

        emptyView.removeFromSuperview()
        scrollViewAnasayfa.isHidden = false

        if let _ = segmentedControl {
            if SehirlerVController.shouldUpdateSegments {
                let items = AnasayfaVController.selectedCities.map({ $0.cityTxt })
                segmentedControl?.replaceSegments(segments: items)
                segmentedControl?.selectedSegmentIndex = 0
                SehirlerVController.shouldUpdateSegments = false
            }
        } else {
            createSegmentedControl()
        }
        selectedCity = AnasayfaVController.selectedCities[segmentedControl!.selectedSegmentIndex]
        fetchData(for: selectedCity!)
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHome()
        
    }

    func addSkeleton() {
        scrollViewAnasayfa.showAnimatedGradientSkeleton()
    }

    func removeSkeleton() {
        scrollViewAnasayfa.hideSkeleton()
    }
  
  func calculateTotalContentWidth() -> CGFloat {
      var totalWidth: CGFloat = 0.0
    
      if let collectionViewFlowLayout =  dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
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
        weeklyWeatherTV.dataSource = self
        weeklyWeatherTV.delegate = self
        dailyWeatherCV.delegate = self
        dailyWeatherCV.dataSource = self
    
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      dailyWeatherCV.collectionViewLayout = layout
        refreshControl.attributedTitle = NSAttributedString(string: "Updating")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        scrollViewAnasayfa.addSubview(refreshControl)
        // for skeletonview
        weeklyWeatherTV.estimatedRowHeight = 50
      if let layout = dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
          layout.scrollDirection = .horizontal
      }

      
      
      self.setBindings()
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
      
        viewModel.weatherData.bind { [weak self] weatherData in
            self?.dataWeather = weatherData
        }

        viewModel.weeklyWeatherData.bind { [weak self] weeklyWeatherData in
            self?.weeklyWeather = weeklyWeatherData
        }
    }

    func updateUI() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        let items = AnasayfaVController.selectedCities.map({ $0.cityTxt })
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
        selectedCity = AnasayfaVController.selectedCities[segmentedControl.selectedSegmentIndex]
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
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: 75, height: 100)
  }
}


