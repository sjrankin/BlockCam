//
//  AutoBlockSize.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AutoBlockSize
{
    /// Returns the next highest multiple of `Value`.
    /// - Note: Returns the value calculated as: `Value + (Multiple - (Value % Multiple))`.
    /// - Parameter Value: The value used to determine the next highest multiple.
    /// - Parameter Multiple: The multiple used to determine the final value.
    /// - Returns: The next highest multiple of `Value`. If `Value` is already an even multiple
    ///            value, it is returned unchanged.
    public static func NextHighestMultiple(_ Value: Int, Multiple: Int) -> Int
    {
        if Value.isMultiple(of: Multiple)
        {
            return Value
        }
        let Remainder = Value % Multiple
        return Value + (Multiple - Remainder)
    }
    
    /// Depending on the value of `.AutomaticallyDetermineBlockSize`, either the user-selected
    /// block size of a block size determined by current conditions will be returned.
    /// - Note: When determined automatically, block size is calculated by:
    ///   - **Processor** Older, slower processors have larger block sizes.
    ///   - **Battery level** If the battery level is less than a certain percent, the block size
    ///     is increased.
    ///   - **System pressure** System pressure (eg, thermal stress) increases the block size.
    /// - Parameter Always: If true, the automatic block size is *always* returned regardless of
    ///                     user settings. Defaults to `false`.
    /// - Returns: Size of the square region used to pixellate the image. This indirectly determines
    ///            the number of shapes generated for the final 3D scene. The user can select the
    ///            block size manually, in which case that will be used regardless of the hardware
    ///            the program is running on.
    public static func GetBlockSize(_ Always: Bool = false) -> Int
    {
        if Settings.GetBoolean(ForKey: .AutomaticallyDetermineBlockSize) || Always
        {
            var AutoBlock = 0
            let BatteryLevel = Platform.BatteryLevel()
            let (CPU, _) = Platform.GetProcessorInfo()
            //Base block size determined by the CPU.
            switch CPU
            {
                case "A8":
                    AutoBlock = 16
                
                case "A9":
                    AutoBlock = 16
                
                case "A10":
                    AutoBlock = 10
                
                case "A11 Bionic":
                    AutoBlock = 10
                
                case "A12 Bionic":
                    AutoBlock = 10
                
                case "A13 Bionic":
                    AutoBlock = 10
                
                default:
                    AutoBlock = 32
            }
            //Low power levels increase the block size.
            if BatteryLevel! < 0.2
            {
                AutoBlock = NextHighestMultiple(AutoBlock + 8, Multiple: 8)
            }
            //High thermal levels increase the block size.
            switch Platform.GetSystemPressure()
            {
                case "Nominal", "Fair":
                    break
                
                case "Serious":
                    AutoBlock = NextHighestMultiple(AutoBlock + 8, Multiple: 8)
                
                case "Critical":
                    AutoBlock = NextHighestMultiple(AutoBlock + 12, Multiple: 8)
                
                case "Catastrophic":
                    AutoBlock = NextHighestMultiple(AutoBlock + 32, Multiple: 8)
                
                default:
                    break
            }
            return AutoBlock
        }
        else
        {
            return Settings.GetInteger(ForKey: .BlockSize)
        }
    }
}
