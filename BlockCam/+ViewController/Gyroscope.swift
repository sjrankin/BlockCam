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
    /// Start monitoring orientation updates. Updates to the rotation of the device trigger orientation
    /// changes in some UI elements.
    /// - Note: See [CMDeviceMotion](https://nshipster.com/cmdevicemotion/)
    /// - Parameter UpdateFrequency. How often to check for changes. Defaults to 1/60th of a second.
    func StartOrientationUpdates(_ UpdateFrequency: Double = 1.0 / 60.0)
    {
        MotionManager = CMMotionManager()
        if MotionManager!.isDeviceMotionAvailable
        {
            MotionManager?.deviceMotionUpdateInterval = UpdateFrequency
            MotionManager?.startDeviceMotionUpdates(to: .main)
            {
                [weak self] (data, error) in
                guard let MotionData = data, error == nil else
                {
                    return
                }
                var Rotation = atan2(MotionData.gravity.x, MotionData.gravity.y) - .pi
                Rotation = Rotation * 180.0 / .pi
                Rotation = abs(round(Rotation))
                if self!.PreviousRotation == Rotation
                {
                    return
                }
                self!.PreviousRotation = Rotation
                let GridType = Settings.GetEnum(ForKey: .LiveViewGridType, EnumType: GridTypes.self, Default: GridTypes.None)
                if GridType != .None
                {
                    self!.GridView.DrawGrid(CGFloat(360.0 - Rotation))
                }
                //If the rotation is close to a cardinal direction, force it to the exact
                //cardinal direction.
                switch Rotation
                {
                    case 0.0 ... 15.0,
                         345.0 ... 359.999:
                        self!.UpdateButtonAngle(360.0 - 0.0)
                    
                    case 75.0 ... 105.0:
                        self!.UpdateButtonAngle(360.0 - 90.0)
                    
                    case 165.0 ... 195.0:
                        self!.UpdateButtonAngle(360.0 - 180.0)
                    
                    case 255.0 ... 285.0:
                        self!.UpdateButtonAngle(360.0 - 270.0)
                    
                    default:
                        self!.UpdateButtonAngle(360.0 - Rotation)
                }
            }
        }
    }
    
    /// Stops the motion manager from updating rotational changes.
    func StopOrientationUpdates()
    {
        MotionManager?.stopDeviceMotionUpdates()
    }
}
