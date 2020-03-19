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

/// Code to get the altitude and heading of the device for display on the HUD.
extension ViewController: CLLocationManagerDelegate
{
    /// Initialize the system location manager. If `.ShowCompass` and `.ShowAltitude` are both false,
    /// control returns immediately with no initialization. In this case, when the user changes either
    /// setting, this function is called and initialization will cocur.
    func InitializeLocation()
    {
        if Settings.GetBoolean(ForKey: .ShowCompass) || Settings.GetBoolean(ForKey: .ShowAltitude)
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
    }
    
    /// Starts a timer to read the altitude and header periodically.
    func StartLocationGathering()
    {
        LocationTimer = Timer.scheduledTimer(timeInterval: Settings.GetDouble(ForKey: .LocationUpdateFrequency),
                                             target: self,
                                             selector: #selector(UpdateLocation),
                                             userInfo: nil,
                                             repeats: true)
    }
    
    /// Request the current heading and altitude.
    @objc func UpdateLocation()
    {
        LocationManager?.requestLocation()
    }
    
    /// Called by the system location manager when a new header is available.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        if Settings.GetBoolean(ForKey: .ShowCompass)
        {
            UpdateHUDView(.Compass, With: Double(newHeading.trueHeading))
        }
    }
    
    /// Called by the system location manager when a new location is available.
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
    
    /// Called by the system location manager when an error occurs.
    /// When this happens, certain settings are reset to false and updating the heading and location
    /// is turned off.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        Log.Message("Location error: \(error.localizedDescription)")
        Settings.SetBoolean(false, ForKey: .ShowAltitude)
        Settings.SetBoolean(false, ForKey: .ShowCompass)
        LocationManager?.stopUpdatingLocation()
        LocationManager?.stopUpdatingHeading()
    }
}
