//
//  ContextMenuProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol ContextMenuProtocol: class
{
    func HandleContextMenu(Command: ContextMenuCommands)
}

enum ContextMenuCommands: String, CaseIterable
{
    case Cancelled = "Cancelled"
    case ShowAbout = "ShowAbout"
    case ProgramSettings = "ProgramSettings"
    case CurrentImageSettings = "CurrentImageSettings"
    case SetImageOptions = "SetImageOptions"
    case LightingOptions = "SetLightingOptions"
    case PerformanceOptions = "SetPerformanceOptions"
    case LoadScene = "LoadScene"
    case SaveScene = "SaveScene"
    case RecordScene = "RecordScene"
    case ShareImage = "ShareImage"
}
