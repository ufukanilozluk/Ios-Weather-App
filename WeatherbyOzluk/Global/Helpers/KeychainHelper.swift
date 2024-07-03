import Foundation

enum KeychainHelper {
  static func saveApiKey(_ apiKey: String, forKey key: String) {
    // Önceki API anahtarını kontrol et
    guard getApiKey(forKey: key) == nil else {
      print("\(key) zaten kayıtlı.")
      return
    }

    // API anahtarını kaydet
    guard let apiKeyData = apiKey.data(using: .utf8) else {
      print("API anahtarı veriye dönüştürülemedi.")
      return
    }
    let keychainQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: apiKeyData
    ]

    let status = SecItemAdd(keychainQuery as CFDictionary, nil)

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
      kSecReturnData as String: kCFBooleanTrue as Any
    ]

    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)

    guard status == errSecSuccess else {
      print("SecItemCopyMatching hata kodu: \(status)")
      return nil
    }

    guard let retrievedData = dataTypeRef as? Data else {
      print("Veri tipi dönüşümünde hata.")
      return nil
    }

    return String(data: retrievedData, encoding: .utf8)
  }
}
