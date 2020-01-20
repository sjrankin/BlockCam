//
//  Menu_ImageSizeProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for communicating changes from the image size to its parent.
protocol Menu_ImageSizeProtocol: class
{
    /// Settings changed in the child.
    /// - Parameter Changed: Array of changed settings.
    func ChangesFromChild(_ Changed: [SettingKeys])
}
