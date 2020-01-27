//
//  SettingsInvocation.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    func SetImageToolViewEnable(To: Bool)
    {
        let ButtonColor = To ? UIColor.white : UIColor.gray
        DoneButton.tintColor = ButtonColor
        DoneButton.setTitleColor(ButtonColor, for: UIControl.State.normal)
        DoneButton.isUserInteractionEnabled = To
        SaveButton.tintColor = ButtonColor
        SaveButton.setTitleColor(ButtonColor, for: UIControl.State.normal)
        SaveButton.isUserInteractionEnabled = To
    }
    
    /// Handle changes from the image view editor.
    func EditorSettings(Changed: Bool)
    {
        if ImageToProcess == nil
        {
            Log.Message("No image to process in EditorSettings.")
            return
        }
        if Changed
        {
            OutputView.Clear()
            ShowStatusLayer()
            ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
            BackgroundThread.async
                {
                    self.OutputView.ProcessImage(self.ImageToProcess!, CalledFrom: "EditorSettings")
            }
        }
    }
}
