import UIKit

class BaseVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setConfig(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:Colors.tint]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
//        navigationController?.navigationBar.barTintColor = Colors.iosCasePurple
        navigationController?.navigationBar.tintColor = Colors.tint
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
