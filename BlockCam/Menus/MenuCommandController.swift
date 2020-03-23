//
//  MenuCommandController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: ContextMenuProtocol
{
    /// Handle commands from the various context menus.
    /// - Parameter Command: The command issued by the user.
    func HandleContextMenu(Command: ContextMenuCommands)
    {
        switch Command
        {
            case .Cancelled:
                break
            
            case .CurrentImageSettings:
                ShowCurrentSettings()
            
            case .ProgramSettings:
                ChangeSettingsFromMenu()
            
            case .SetImageOptions:
                RunShapeSettingsFromMenu()
            
            case .ShowAbout:
                ShowAboutFromMenu()
            
            case .LightingOptions:
                RunLightingSettingsFromMenu()
            
            case .PerformanceOptions:
                RunPerformanceSettingsFromMenu()
            
            case .LoadScene:
                LoadSavedScene()
            
            case .RecordScene:
                ShowRecordSceneBar()
            
            case .SaveScene:
                SaveScene()
            
            case .ShareImage:
                RunExportProcessedImageFromMenu()
            
            case .ShowHelp:
                RunHelpViewer()
            
            case .SelectedNewShape:
                break
            
            case .ShowFavoriteShapes:
                break
        }
    }
    
    func HandleContextMenu(Command: ContextMenuCommands, Parameter: Any?)
    {
        switch Command
        {
            case .SelectedNewShape:
                if let SentParameter = Parameter
                {
                    if let Shape = SentParameter as? NodeShapes
                    {
                        //HaveNewShape
                    }
            }
            
            default:
                break
        }
    }
}
