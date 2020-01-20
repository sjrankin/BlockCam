//
//  UnicodeBlock.swift
//  BlockCam
//  Adapted from Characterizer.
//
//  Created by Stuart Rankin on 11/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains information on a block of Unicode characters.
class UnicodeBlock
{
    /// Initializer.
    /// - Parameter Name: Name of the block.
    /// - Parameter Low: The low end of the block.
    /// - Parameter High: The high end of the block.
    /// - Parameter Selected: The block selected flag.
    init(_ Name: String, _ Low: UInt32, _ High: UInt32, _ Range: UnicodeRanges)
    {
        self.Name = Name
        self.LowRange = Low
        self.HighRange = High
        self.UnicodeBlockID = Range
    }
    
    /// Initializer.
    /// - Note: This alternative initializer was added due to how I created the Unicode block structure (copied, literally,
    ///         from Wikipedia - the data were in a different order, hence the need for parameters in a different order).
    /// - Parameter Low: The low end of the block.
    /// - Parameter High: The high end of the block.
    /// - Parameter Name: Name of the block.
    init(_ Low: UInt32, _ High: UInt32, Name: String, _ Range: UnicodeRanges)
    {
        self.Name = Name
        self.LowRange = Low
        self.HighRange = High
        self.UnicodeBlockID = Range
    }
    
    public var UnicodeBlockID: UnicodeRanges = .BasicLatin
    
    /// Name of the block of Unicode characters.
    public var Name: String = ""
    
    /// Starting value of the range of the block.
    public var LowRange: UInt32 = 0x0
    
    /// Ending value of the range of the block.
    public var HighRange: UInt32 = 0x0
}
