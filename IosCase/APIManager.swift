import Alamofire
import Foundation

struct ReturnValue {
    var durum: Bool
    var mesaj: String
    var obj: Any?
    var extr: Any?
    
    init(json: [String: Any]) {
        durum = json["durum"] as? Bool ?? false
        mesaj = json["mesaj"] as? String ?? ""
        obj = json["obj"]
        
    }
}

class APIManager {
    
    class func runApi(feed: String, parameters: Parameters? = nil, selfView: UIView? = nil, method: HTTPMethod = .post, onCompletion: @escaping (_
        data: ReturnValue, _ error: String?) -> Void) {
        
        AF.request(feed, method: method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in switch response.result {
        case let .success(JSON):

            if let response = JSON as? [String: Any] {
                let rv: ReturnValue = ReturnValue(json: response)
                onCompletion(rv, nil)

            } else {
                onCompletion(ReturnValue(json: ["durum": false, "mesaj": "RESPONSE AS? NSDictionary tipine cast olamadı!"]), "RESPONSE AS? NSDictionary tipine cast olamadı!")

                //                self.util.stopLoader(uiView: self.view)
            }

        case let .failure(error):
            //todo : moobil_log // type error olarak loglanıcak
            onCompletion(ReturnValue(json: ["durum": false, "mesaj": error.localizedDescription]), error.localizedDescription)
        }
        }
    }
}
