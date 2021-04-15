//
//  ViewController.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 19.11.2020.
//

import UIKit

class SehirlerVController: BaseVController {
    @IBOutlet var sehirlerTableView: UITableView!

    lazy var sehirlerVModel: CitiesMainVModel = {
        let vm = CitiesMainVModel(view: self.view)
        vm.delegate = self
        return vm
    }()

    var weather: [HavaDurum] = []
    var selectedCities: [Location] = []
    var newCityAdded = false
    static var shouldUpdateSegments = false

    fileprivate func getWeatherInfo() {
        weather = []
        selectedCities = SehirlerVController.getCities()
        for item in selectedCities {
            let parameters: [String: Any] = ["q": item.cityName!, "cnt": 1]
            sehirlerVModel.getWeatherForecast(parameters: parameters)
        }
    }

    override func viewDidLoad() {
        // Drag-drop da delegatelar ataman lazım

        super.viewDidLoad()
        setConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        getWeatherInfo()
        if weather.count == 0 {
            sehirlerTableView.setEmptyView(title: "Henüz bir şehir seçmediniz", message: "Ekle butonuyla bir şehir ekleyebilirsiniz.", animation: "location")
        }
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
        editButtonItem.title = "Düzenle"
        navigationItem.leftBarButtonItem = editButtonItem
        sehirlerTableView.allowsSelection = false
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)
        // Toggle table view editing.
        sehirlerTableView.setEditing(editing, animated: true)
        sehirlerTableView.dragInteractionEnabled = editing
        // Edit button text ayarlama
        if !isEditing {
            editButtonItem.title = "Düzenle"
        } else {
            editButtonItem.title = "Bitti"
        }
    }

    @IBAction func sehirEkle(_ sender: Any) {
        performSegue(withIdentifier: "goToSehirlerDetay", sender: nil)
    }

    // UserDefaultsa kaydedilen structları almak için
    class func getCities() -> [Location] {
        guard let cityData = UserDefaults.standard.object(forKey: "cities") as? [Data] else { return [] }
//        Finally, there’s compactMap, which lets us discard any nil values that our transform might produce
        return cityData.compactMap { return Location(data: $0) }
    }
}

extension SehirlerVController: SehirlerMainVModelDelegate {
    func getWeatherCastWeeklyCompleted(data: HavaDurumWeekly) {
    }

    func getWeatherCastCompleted(data: HavaDurum) {
        weather.append(data)
        if weather.count == selectedCities.count {
            // Şehirler sırasındakine göre tüm verileri çektikten sonra sırala
            weather.sort(by: { n1, n2 in
                let index1 = selectedCities.firstIndex(where: {
                    $0.cityName == n1.city.cityName
                })
                let index2 = selectedCities.firstIndex(where: {
                    $0.cityName == n2.city.cityName
                })
                return index1! < index2!
            })

            sehirlerTableView.reloadData()
        }
    }
}

extension SehirlerVController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weather.count == 0 {
            tableView.setEmptyView(title: "Henüz bir şehir seçmediniz", message: "Ekle butonuyla bir şehir ekleyebilirsiniz.", animation: "location")
        } else {
            tableView.restoreToFullTableView()
        }
        return weather.count
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = weather.remove(at: sourceIndexPath.row)
        weather.insert(mover, at: destinationIndexPath.row)
        SehirlerDetayVController.saveCities(arrayCity: weather.map({ $0.city }))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = weather[indexPath.row].list[0]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SehirlerCell", for: indexPath) as! SehirlerTVCell
        cell.sehirIsim.text = weather[indexPath.row].city.cityName
        cell.derece.text = String(rowData.main.temp!) + "°C"
        cell.weatherPic.image = UIImage(named: rowData.weather[0].icon!)

//        cell.weatherPic.image =

        do {
            cell.tarih.text = try? dateFormatter(to: .strToStr, value: rowData.dt_text!, outputFormat: "dd/MM/yyyy") as? String
        }

        // TO-DO : Aynı şehir ekleme ve UserDefaultsa bittiğinde kaydetme?

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isEditing { return true } else { return false }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weather.remove(at: indexPath.row)
            sehirlerTableView.deleteRows(at: [indexPath], with: .automatic)
            SehirlerDetayVController.saveCities(arrayCity: weather.map({ $0.city }))
            alert(msg: "Başarıyla silindi", type: .succ)
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
        dragItem.localObject = weather[indexPath.row]
        return [dragItem]
    }
}