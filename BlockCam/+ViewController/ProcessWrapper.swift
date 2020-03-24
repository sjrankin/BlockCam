//
//  ProcessWrapper.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    /// Handles the expiration of the processing for too long timer.
    /// Shows a message on the screen.
    @objc func TooLongTimerHandler()
    {
        DispatchQueue.main.async
            {
                self.ShowTextLayerMessage(.TooLong)
        }
    }

    /// Common function for processing all still images.
    /// - Parameter Image: The image to process.
    func ProcessImageWrapper(_ Image: UIImage)
    {
        if Settings.GetBoolean(ForKey: .ShowPerformanceStatus)
        {
            let Duration = Settings.GetDouble(ForKey: .TooLongDuration, IfZero: 10.0)
            TooLongTimer = Timer.scheduledTimer(timeInterval: Duration,
                                                target: self,
                                                selector: #selector(TooLongTimerHandler),
                                                userInfo: nil,
                                                repeats: false)
        }
        ShowTextLayerMessage(.PleaseWait)
        BackgroundThread.async
            {
                self.OutputView.ProcessImage(self.ImageToProcess!, CalledFrom: "ProcessImageWrapper")
        }
    }
    
    /// Common function for processing all still images.
    /// - Parameter Colors: Pre-processed colors.
    func ProcessImageWrapper(_ Colors: [[UIColor]])
    {
        if Settings.GetBoolean(ForKey: .ShowPerformanceStatus)
        {
            let Duration = Settings.GetDouble(ForKey: .TooLongDuration, IfZero: 10.0)
            TooLongTimer = Timer.scheduledTimer(timeInterval: Duration,
                                                target: self,
                                                selector: #selector(TooLongTimerHandler),
                                                userInfo: nil,
                                                repeats: false)
        }
        ShowTextLayerMessage(.PleaseWait)
        BackgroundThread.async
            {
                self.OutputView.ProcessImage(Colors, CalledFrom: "ProcessImageWrapper")
        }
    }
}
