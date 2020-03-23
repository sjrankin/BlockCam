//
//  StatusLayerView2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a simple status view layer with a main label, percent complete indicator, and minor label.
/// - Note: All accesses to the user interface are done on the main, UI queue meaning background threads can call these functions
///         without worrying about which thread is which.
extension ViewController
{
    /// Initialize controls and set up visuals.
    func InitializeControls()
    {
    }
    
    /// Create an attributed text string to display.
    /// - Parameter Message: The text to apply visual attributes to.
    /// - Parameter TextColor: The text foreground color. Defaults to black.
    /// - Parameter StrokeColor: The text stroke color. Defaults to white.
    /// - Returns: `NSAttributedString` with the passed `Message` value.
    private func MakeAttributedText(Message: String, TextColor: UIColor = UIColor.black,
                                    StrokeColor: UIColor = UIColor.white) -> NSAttributedString
    {
        let Font = UIFont.boldSystemFont(ofSize: 54.0)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: Font as Any,
                .foregroundColor: TextColor as Any,
                .strokeColor: StrokeColor as Any,
                .strokeWidth: -3 as Any
        ]
        return NSAttributedString(string: Message, attributes: Attributes)
    }
}
