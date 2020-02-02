//
//  ContextMenuProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for handling context menu commands.
protocol ContextMenuProtocol: class
{
    /// Command sent from a context menu.
    /// - Parameter Command: The actual command.
    func HandleContextMenu(Command: ContextMenuCommands)
    
    /// Command and data sent from a context menu.
    /// - Parameter Command: The actual command.
    /// - Parameter Parameter: Command parameter.
    func HandleContextMenu(Command: ContextMenuCommands, Parameter: Any?)
}

/// Valid context menu commands.
enum ContextMenuCommands: String, CaseIterable
{
    /// Context menu closed or cancelled without a command being issued.
    case Cancelled = "Cancelled"
    /// Show the About dialog.
    case ShowAbout = "ShowAbout"
    /// Show program settings.
    case ProgramSettings = "ProgramSettings"
    /// Show current image settings (eg, the settings in effect at the time).
    case CurrentImageSettings = "CurrentImageSettings"
    /// Run the image options dialog (mainly for shapes).
    case SetImageOptions = "SetImageOptions"
    /// Run the lighting options dialog.
    case LightingOptions = "SetLightingOptions"
    /// Run the performance options dialog.
    case PerformanceOptions = "SetPerformanceOptions"
    /// Load a saved scene.
    case LoadScene = "LoadScene"
    /// Save current processed view as a scene.
    case SaveScene = "SaveScene"
    /// Record scene motion as a video.
    case RecordScene = "RecordScene"
    /// Share the image via the share API.
    case ShareImage = "ShareImage"
    /// Show help.
    case ShowHelp = "ShowHelp"
    /// User selected a new shape.
    case SelectedNewShape = "SelectedNewShape"
    /// Show favorite shapes the user has selected.
    case ShowFavoriteShapes = "ShowFavoriteShapes"
}
