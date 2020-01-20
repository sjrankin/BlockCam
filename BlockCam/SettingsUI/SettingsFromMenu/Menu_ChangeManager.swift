//
//  Menu_ChangeManager.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages changes to settings from various UI settings. This class does not track changed values - only which settings were
/// changed.
class Menu_ChangeManager
{
    /// Holds the list of changed settings.
    private static var _Changed: Set<SettingKeys> = Set<SettingKeys>()
    
    /// Add a changed setting.
    /// - Parameter ChangedSetting: The setting that was changed. If a setting is already in the set of changed settings, it
    ///                             is not added again.
    public static func AddChanged(_ ChangedSetting: SettingKeys)
    {
        _Changed.insert(ChangedSetting)
    }
    
    /// Remove the specified setting from the set of changed settings.
    /// - Parameter ChangedSetting: The setting to remove. If this setting does not exist, no action is taken.
    public static func Remove(_ ChangedSetting: SettingKeys)
    {
        _Changed.remove(ChangedSetting)
    }
    
    /// Clear all changed settings.
    public static func Clear()
    {
        _Changed.removeAll()
    }
    
    /// Determines if any value in the passed array exists in the set of settings.
    /// - Parameter List: List of settings to check against the set of changed settings.
    /// - Returns: True if any setting in `List` exists in the set of changed settings, false if not.
    public static func Contains(_ List: [SettingKeys]) -> Bool
    {
        if List.count < 1
        {
            return false
        }
        for Key in List
        {
            if _Changed.contains(Key)
            {
                return true
            }
        }
        return false
    }
    
    /// Returns the set of changed setting keys as an array.
    public static var AsArray: [SettingKeys]
    {
        get
        {
            return Array(_Changed)
        }
    }
}
