//
//  SehirlerVModelDelegate.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 25.11.2020.
//

import Foundation

protocol SehirEkleVModelDelegate: MainVModelDelegate {
    func getCityListCompleted(data:[City])
}
