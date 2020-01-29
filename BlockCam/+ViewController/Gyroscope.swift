//
//  Gyroscope.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

extension ViewController
{
    func StartGyroscopeUpdates()
    {
        MotionManager = CMMotionManager()
        if MotionManager!.isGyroAvailable
        {
            MotionManager?.gyroUpdateInterval = 1.0 / 60.0
        MotionManager?.startGyroUpdates()
            let GyroTimer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true)
            {
                (timer) in
                if let GyroData = self.MotionManager?.gyroData
                {
                    print("RotationRate.z=\(GyroData.rotationRate.z)")
                }
            }
            RunLoop.current.add(GyroTimer, forMode: .default)
        }
        else
        {
            MotionManager = nil
        }
    }
    
    func StopGyrocopeUpdates()
    {
        if MotionManager != nil
        {
            MotionManager?.stopGyroUpdates()
        }
    }
}
