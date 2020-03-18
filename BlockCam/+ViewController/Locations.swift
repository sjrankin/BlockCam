//
//  Locations.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension ViewController: CLLocationManagerDelegate
{
    func InitializeLocation()
    {
        self.LocationManager = CLLocationManager()
        LocationManager?.requestWhenInUseAuthorization()
        LocationManager?.delegate = self
        LocationManager?.distanceFilter = kCLDistanceFilterNone
        LocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        LocationManager?.headingFilter = 1.0
        LocationManager?.startUpdatingLocation()
        LocationManager?.startUpdatingHeading()
        UpdateLocation()
        StartLocationGathering()
    }
    
    func StartLocationGathering()
    {
        LocationTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(UpdateLocation),
                                             userInfo: nil,
                                             repeats: true)
    }
    
    @objc func UpdateLocation()
    {
        LocationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        if Settings.GetBoolean(ForKey: .ShowCompass)
        {
            UpdateHUDView(.Compass, With: Double(newHeading.trueHeading))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let Current = locations.first
        {
            let Altitude = Current.altitude
            if Settings.GetBoolean(ForKey: .ShowAltitude)
            {
                UpdateHUDView(.Altitude, With: Altitude)
            }
            PreviousAltitude = Altitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        fatalError("Location manager failed: \(error.localizedDescription)")
    }
}
