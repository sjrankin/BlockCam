//
//  Depth.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension ViewController
{
    /// Determines if depth data is supported on the current device.
    func SupportsDepthData() -> Bool
    {
        if CaptureSession == nil
        {
            fatalError("Cannot check for depth data with nil CaptureSession.")
        }
       let DepthDataOutput = AVCaptureDepthDataOutput()
            CaptureSession.addOutput(DepthDataOutput)
            if let _ = DepthDataOutput.connection(with: .depthData)
            {
                return true
            }
        return false
    }
}
