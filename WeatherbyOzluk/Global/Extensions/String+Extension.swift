//
//  String+Extension.swift
//  WeatherbyOzluk
//
//  Created by Ufuk Anıl Özlük on 24.06.2024.
//

import Foundation

extension String {
    func firstCharLowercased() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
