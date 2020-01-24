//
//  MainProtocolFunctions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: MainProtocol
{
    /// Update the status on the status layer.
    /// - Paremeter Percent: The percent complete value.
    /// - Parameter Color: Color of the percent complete indicator.
    /// - Parameter Message: Text for the action message.
    func Status(_ Percent: Double, _ Color: UIColor, _ Message: String)
    {
        ShowStatusLayer()
        DispatchQueue.main.async
            {
                self.CompositeStatus.AddText(Message)
                self.CompositeStatus.TotalPercentValue = Percent
        }
    }
    
    /// Show a status sub-percent value.
    /// - Parameter SubPercent: The sub-percent value to show.
    /// - Parameter Color: The color of the indicator.
    func SubStatus(_ SubPercent: Double, _ Color: UIColor)
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.TaskPercentColor = Color
                self.CompositeStatus.ShowTaskPercentage = true
                self.CompositeStatus.TaskPercentValue = SubPercent
        }
    }
    
    /// Call to show the indefinite indicator.
    func ShowIndefiniteIndicator()
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.ShowIndefiniteIndicator = true
        }
    }
    
    /// Hides the indefinite indicator.
    func HideIndefiniteIndicator()
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.ShowIndefiniteIndicator = false
        }
    }
    
    /// Handle completed events.
    /// - Parameter Success: The event successfully completed flag.
    func Completed(_ Success: Bool)
    {
        DispatchQueue.main.async
            {
                let RandomDuration = Utilities.GetMeanRandomCharacterDurations()
                if RandomDuration > 0
                {
                    print("Mean random character generation duration: \(RandomDuration), Cache count: \(Utilities.CharSetCache.count)")
                }
                self.HideStatusLayer()
                self.CompositeStatus.AnimatePercent(To: 0.0, Duration: 1.0)
                self.CompositeStatus.TaskPercentValue = 0.0
                if self.InitialProcessedImage
                {
                    self.InitialProcessedImage = false
                    if Settings.GetBoolean(ForKey: .AutoSaveProcessedImage)
                    {
                        let SourceSize = "\(Generator.OriginalImageSize)"
                        let ReducedSize = "\(Generator.ReducedImageSize)"
                        let UserData = CurrentSettings.KVPs(AppendWith: [("Original size", SourceSize), ("Reduced size", ReducedSize)])
                        FileIO.SaveImageWithMetaData(self.OutputView.snapshot(), KeyValueString: UserData, SaveInCameraRoll: true)
                        {
                            Successful in
                            if Successful
                            {
                                self.CompositeStatus.AddText("Image automatically saved.", HideAfter: 5.0)
                            }
                        }
                    }
                }
                if Settings.DoShowUIPrompt()
                {
                    if UIDevice.current.userInterfaceIdiom == .pad
                    {
                        self.CompositeStatus.AddText("Long press image for image settings.")
                    }
                    else
                    {
                        self.CompositeStatus.AddText("Press image for settings")
                    }
                }
                self.CompositeStatus.ShowHelp()
        }
    }
    
    /// Return the main view.
    func MainView() -> UIView
    {
        return self.view
    }
}
