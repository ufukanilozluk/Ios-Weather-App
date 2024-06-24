//
//  JSONDecoder.KeyDecodingStrategy+Extension.swift
//  WeatherbyOzluk
//
//  Created by Ufuk Anıl Özlük on 24.06.2024.
//

import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { keys -> CodingKey in
            // keys array is never empty
            let key = keys.last!
            // Do not change the key for an array
            guard key.intValue == nil else {
                return key
            }
            let codingKeyType = type(of: key)
            let newStringValue = key.stringValue.firstCharLowercased()
            return codingKeyType.init(stringValue: newStringValue)!
        }
    }
}
