import UIKit

class SehirlerVController: BaseVController {
  @IBOutlet var sehirlerTableView: UITableView!
  
  var weather: [HavaDurum]?
  var selectedCities: [Location] = UserDefaultsHelper.getCities()
  var newCityAdded = false
  static var shouldUpdateSegments = false
  var viewModel: CitiesMainVModel = CitiesMainVModel()
  var degrees : [String] = []
  var dates : [String] = []
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
  
  fileprivate func getWeatherInfo() {
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
    guard !selectedCities.isEmpty else {
      sehirlerTableView.setEmptyView(title: "No location Found", message: "Start by adding a location", animation: "location")
      return
    }
    getWeatherInfo()
  }

  
  override func setConfig() {
    super.setConfig()
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

extension SehirlerVController: UITableViewDelegate,UITableViewDataSource {
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard !selectedCities.isEmpty else {
            tableView.setEmptyView(title: "No location found", message: "Start by adding a location", animation: "location")
            return 0
        }
        tableView.restoreToFullTableView()
        return weather?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hava = weather![indexPath.row].list[0]
        let cell = tableView.dequeueReusableCell(withIdentifier: SehirlerTVCell.reuseIdentifier, for: indexPath) as! SehirlerTVCell
      
      let row = indexPath.row
      cell.setWeather(
        weatherPic: UIImage(named: hava.weather[0].icon)!,
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
        let mover = weather!.remove(at: sourceIndexPath.row) // sildiğini dönüyor. Yani mover bir Location
        weather!.insert(mover, at: destinationIndexPath.row)
        selectedCities.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        UserDefaultsHelper.moveCity(sourceIndexPath.row, destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weather!.remove(at: indexPath.row)
            selectedCities.remove(at: indexPath.row)
            sehirlerTableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaultsHelper.removeCity(at: indexPath.row)
            SehirlerVController.shouldUpdateSegments = true
        }
    }
}

extension SehirlerVController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        SehirlerVController.shouldUpdateSegments = true
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = weather![indexPath.row]
        return [dragItem]
    }
}
