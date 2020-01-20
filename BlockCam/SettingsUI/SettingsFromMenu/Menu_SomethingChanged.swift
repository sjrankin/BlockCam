//
//  Menu_SomethingChanged.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol to notify delegates that some setting changed. It is the responsibility of the delegate to
/// determine the changed setting and take action as appropriate.
protocol SomethingChangedProtocol: class
{
    /// Notify the delegate that something changed.
    func SomethingChanged()
}
