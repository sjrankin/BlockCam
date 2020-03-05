//
//  AsynchronousEventHandling.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    // MARK: - Asynchronous device event handling
    
    /// Setup notifications for us to listen to. We are mostly concerned about BlockCam stressing the system due to
    /// memory or thermal issues.
    func SetupNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ThermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PowerStateChanged),
                                               name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    /// Handle power state changes. Displays a dialog when the power is too low.
    /// - Parameter notification: The notification that contains new power state information.
    @objc func PowerStateChanged(notification: NSNotification)
    {
        if let PI = notification.object as? ProcessInfo
        {
            if PI.isLowPowerModeEnabled && Settings.GetBoolean(ForKey: .HaltOnLowPower)
            {
                if Settings.GetBoolean(ForKey: .EnableCrashSounds)
                {
                    Sounds.PlaySound(.Alarm)
                }
                let AlertMessage = UIAlertController(title: "Low Power", message: "Your device is low on power. Please quit as soon as possible.",
                                                     preferredStyle: .alert)
                AlertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(AlertMessage, animated: true)
            }
        }
    }
    
    /// Handles thermal state changes. Displays a dialog when the device gets too hot.
    /// - Parameter notification: The notification that contains new thermal state information.
    @objc func ThermalStateChanged(notification: NSNotification)
    {
        if let PI = notification.object as? ProcessInfo
        {
            if PI.thermalState == .critical && Settings.GetBoolean(ForKey: .HaltWhenCriticalThermal)
            {
                if Settings.GetBoolean(ForKey: .EnableCrashSounds)
                {
                    Sounds.PlaySound(.Alarm)
                }
                let AlertMessage = UIAlertController(title: "Too Hot!", message: "Your device is overheated! Please quit as soon as possible.",
                                                     preferredStyle: .alert)
                AlertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(AlertMessage, animated: true)
            }
            var ThermalMessage = ""
            if let Mapped = ThermalMap[PI.thermalState]
            {
                ThermalMessage = Mapped
            }
            else
            {
                ThermalMessage = "Unknown"
            }
            Log.Message("Thermal state changed to \(ThermalMessage)")
        }
    }
    
    /// Memory warning. Log and continue. Current image processing settings are saved to the log (if
    /// the log is enabled).
    override func didReceiveMemoryWarning()
    {
        Log.Message("Received memory warning.")
    }
}
