//
//  CrashView.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Provides a common alert for crash events.
class Crash
{
    /// Show an alert view with crash text.
    /// - Parameter WithController: The controller that will actually do the display.
    /// - Parameter Title: The title of the alert.
    /// - Parameter Message: The message for the crash.
    public static func ShowCrashAlert(WithController: UIViewController, _ Title: String, _ Message: String)
    {
        if Settings.GetBoolean(ForKey: .EnableCrashSounds)
        {
            Sounds.PlaySound(.Alarm)
        }
        WasClosed = false
        OperationQueue.main.addOperation
            {
                let Alert = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
                Alert.addAction(UIAlertAction(title: "Close", style: .default, handler: self.HandleCrashAlertClosed))
                WithController.present(Alert, animated: true)
        }
    }
    
    /// Handle the close button pressed on the crash alert viewer.
    @objc private static func HandleCrashAlertClosed(Action: UIAlertAction)
    {
        WasClosed = true
    }
    
    /// Get the alert viewer was closed flag.
    public static var WasClosed = false
}
