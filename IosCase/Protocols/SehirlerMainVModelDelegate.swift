//
//  SehirlerMainVModelDelegate.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 30.11.2020.
//

import Foundation

protocol SehirlerMainVModelDelegate: MainVModelDelegate {
    func getWeatherCastCompleted(data:HavaDurum)
    func getWeatherCastWeeklyCompleted(data:HavaDurumWeekly)
}
