
import SkeletonView
import UIKit

class SehirlerVController: BaseVController {
    @IBOutlet var sehirlerTableView: UITableView!

    var weather: [HavaDurum]?
    var selectedCities: [Location]?
    var newCityAdded = false
    static var shouldUpdateSegments = false
    var viewModel: CitiesMainVModel = CitiesMainVModel()

    func setBindings() {
        viewModel.allCitiesWeatherData.bind { [weak self] weatherData in
            self?.weather = weatherData
        }
    }

    func updateUI() {
        setBindings()
        sehirlerTableView.reloadData()
        removeSkeleton()
    }

    fileprivate func getWeatherInfo() {
        viewModel.getForecastForAllCities {
            self.updateUI()
        }
    }

    override func viewDidLoad() {
        // Drag-drop da delegatelar ataman lazım

        //    super.viewDidLoad()
        setConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let cities = SehirlerVController.getCities() else {
            sehirlerTableView.setEmptyView(title: "No location Found", message: "Start by adding a location", animation: "location")
            return
        }
        selectedCities = cities
        getWeatherInfo()
        addSkeleton()
    }

    func addSkeleton() {
        sehirlerTableView.showAnimatedGradientSkeleton()
    }

    func removeSkeleton() {
        sehirlerTableView.hideSkeleton()
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

    // UserDefaultsa kaydedilen structları almak için
    class func getCities() -> [Location]? {
        guard let cityData = UserDefaults.standard.object(forKey: "cities") as? [Data] else { return nil }
//        Finally, there’s compactMap, which lets us discard any nil values that our transform might produce
        return cityData.compactMap { return Location(data: $0) }
    }
}

extension SehirlerVController: UITableViewDelegate, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SehirlerTVCell.reuseIdentifier
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = selectedCities else {
            tableView.setEmptyView(title: "No location found", message: "Start by adding a location", animation: "location")
            return 0
        }
        tableView.restoreToFullTableView()
        return weather?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hava = weather![indexPath.row].list[0]
        let cityName = weather![indexPath.row].city?.name
        let cell = tableView.dequeueReusableCell(withIdentifier: SehirlerTVCell.reuseIdentifier, for: indexPath) as! SehirlerTVCell
        cell.setWeather(weather: hava, cityName: cityName!)
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
        selectedCities!.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        SehirlerDetayVController.saveCities(arrayCity: selectedCities!)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weather!.remove(at: indexPath.row)
            selectedCities!.remove(at: indexPath.row)
            sehirlerTableView.deleteRows(at: [indexPath], with: .automatic)
            SehirlerDetayVController.saveCities(arrayCity: selectedCities!)
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
