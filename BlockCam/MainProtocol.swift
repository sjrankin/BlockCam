//
//  MainProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol MainProtocol: class
{
    /// Sends a status to the main view to be displayed to the user.
    /// - Parameter Percent: The percent complete for some operation. Values must range
    ///                      between 0.0 and 1.0.
    /// - Parameter Color: The color of the percent indicator.
    /// - Parameter Message: The activity message to display.
    func Status(_ Percent: Double, _ Color: UIColor, _ Message: String)
    
    /// Updates the status sub-percent value.
    /// - Parameter SubPercent: The sub-percent for some operation. Values must range
    ///                         between 0.0 and 1.0.
    /// - Parameter Color: The color of the percent indicator.
    func SubStatus(_ SubPercent: Double, _ Color: UIColor)
    
    /// Called upon the completion of a long-running operation. How things are handled
    /// depends on the operation.
    /// - Parameter Success: Success flag for the operation.
    func Completed(_ Success: Bool)
    
    /// Returns the `UIView` for the main view controller.
    func MainView() -> UIView
    
    /// Called when settings change that require a redraw of a 3D view.
    /// - Parameter With: Array of changed setting keys.
    func Redraw3D(_ With: [SettingKeys])
    
    /// Called when settings changed in a context menu that do not require a redraw of a 3D view.
    /// - Parameter Updated: Array of changed setting keys.
    func ContextMenuSettingsChanged(_ Updated: [SettingKeys])
    
    /// Call to show the indefinite indicator.
    func ShowIndefiniteIndicator()
    
    /// Hides the indefinite indicator.
    func HideIndefiniteIndicator()
    
    /// Returns the source image.
    /// - Returns: Source image being processed. Nil if it does not exist.
    func GetSourceImage() -> UIImage?
    
    /// Shows the processed image menu.
    /// - Parameter From: The source object the menu will point to.
    func ShowProcessedImageMenu(From SourceObject: UIView)
}
