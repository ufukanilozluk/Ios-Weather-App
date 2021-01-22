//
//  WeatherAppErrors.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 20.01.2021.
//

import Foundation


enum WeatherAppErrors : Error{
    
    enum SehirEkleError: Error {
        case sameSelection
    }
}
