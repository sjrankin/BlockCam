//
//  SettingChangedProtocol.swift
//  BlockCam
//  Adapted from GPS Log
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for notification of individual setting value changes.
protocol SettingChangedProtocol: class
{
    /// Function called before a setting is changed.
    /// - Note: `Settings` supports multiple delegates. If the last delegate added returns `true`
    ///         in `CancelChange`, no change will be made.
    /// - Parameter ChangedSetting: The key for the setting that will be changed.
    /// - Parameter NewValue: The new value for the setting, cast to `Any`.
    /// - Parameter CancelChange: Set by the receiver. If set to true, the change will be canceled
    ///                           and `DidChangeSetting` will *not* be called. If set to false,
    ///                           the setting will be changed and afterwards, `DidChangeSetting`
    ///                           will be called.
    func WillChangeSetting(_ ChangedSetting: SettingKeys, NewValue: Any, CancelChange: inout Bool)
    
    /// Function called after a setting has been changed.
    /// - Parameter ChangedSetting: The key of the changed setting.
    func DidChangeSetting(_ ChangedSetting: SettingKeys)
}
