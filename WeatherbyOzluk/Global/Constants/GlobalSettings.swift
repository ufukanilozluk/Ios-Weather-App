import Foundation
import Security


enum GlobalSettings{
  static var selectedCities: [Location] = UserDefaultsHelper.getCities()
  static var shouldUpdateSegments = false
  static var formerConnectivityStatus = true
  
  
      enum KeychainHelper {
          
          static func saveApiKey(_ apiKey: String, forKey key: String){
              // Önceki API anahtarını kontrol et
            guard getApiKey(forKey: key) == nil else {
                  print("\(key) zaten kayıtlı.")
                  return
              }

              // API anahtarını kaydet
              let keychainQuery: [String: Any] = [
                  kSecClass as String: kSecClassGenericPassword,
                  kSecAttrAccount as String: key,
                  kSecValueData as String: apiKey.data(using: .utf8)!
              ]
              let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)

              if status == errSecSuccess {
                  print("\(key) başarıyla kaydedildi.")
              } else {
                  print("\(key) kaydedilemedi. Hata kodu: \(status)")
              }
          }

          static func getApiKey(forKey key: String) -> String? {
              let keychainQuery: [String: Any] = [
                  kSecClass as String: kSecClassGenericPassword,
                  kSecAttrAccount as String: key,
                  kSecMatchLimit as String: kSecMatchLimitOne,
                  kSecReturnData as String: kCFBooleanTrue!
              ]

              var dataTypeRef: AnyObject? = nil
              let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
            if status == errSecSuccess {
                    if let retrievedData = dataTypeRef as? Data {
                      return String(data: retrievedData, encoding: .utf8)
                    } else {
                      print("Veri tipi dönüşümünde hata.")
                    }
                  } else {
                    print("SecItemCopyMatching hata kodu: \(status)")
                  }
                  return nil
          }
      }
  }

