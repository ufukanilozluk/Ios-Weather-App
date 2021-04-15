//
//  GetLocation.swift
//  endavet_portal
//
//  Created by Ufuk on 26.08.2020.
//  Copyright © 2020 Hasan Karaman. All rights reserved.
//

import CoreLocation

public class GetLocation: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var locationCallback: ((_ location:CLLocation?,_ error:String?) -> Void)!
    var locationServicesEnabled = false
    var didFailWithError: Error?

    public func run(callback: @escaping (CLLocation?,String?) -> Void) {
        locationCallback = callback
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationServicesEnabled = CLLocationManager.locationServicesEnabled()

        if locationServicesEnabled {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            
            case .restricted, .denied:
                locationCallback(nil,"Location authorization is denied")
            case .authorizedAlways, .authorizedWhenInUse:
                manager.startUpdatingLocation()
           default:
                break
            }
            
        } else {
            locationCallback(nil,"Location service disabled")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
       
        case .restricted, .denied:
            locationCallback(nil,"Location authorization is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
       default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        locationCallback(locations.last!,nil)
        manager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError = error
        locationCallback(nil,error.localizedDescription)
        manager.stopUpdatingLocation()
    }

    deinit {
        manager.stopUpdatingLocation()
    }

    func retreiveCityName(lattitude: Double, longitude: Double, completionHandler: @escaping ((CLPlacemark) -> Void)) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lattitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in

            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            completionHandler(placeMark)

        })
    }
}
