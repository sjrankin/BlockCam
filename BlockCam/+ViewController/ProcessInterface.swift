//
//  ProcessInterface.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    /// Process the passed image in a background thread (to keep the UI responsive).
    /// - Parameter Image: The image to process.
    /// - Parameter ShowWait: If true, a "Please Wait" message is shown. Otherwise, nothing is shown.
    func ProcessImageInBackground(_ Image: UIImage, ShowWait: Bool = true)
    {
        OutputView.Clear()
        #if true
        //        CompositeStatus.ShowIndefiniteIndicator = true
        //CompositeStatus.ShowTaskPercentage = false
        CompositeStatus.AddText("Please Wait")
        ShowStatusLayer()
        ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
        DispatchQueue.global().async
            {
            [weak self] in
            self!.OutputView.ProcessImage(Image)
        }
        #else
        if ShowWait
        {
            ShowStatusLayer()
            ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
        }
        BackgroundThread.async
            {
                [weak self] in
                self!.OutputView.ProcessImage(Image)
        }
        #endif
    }
    
    /// Process the passed image pixel data in a background thread (to keep the UI responsive).
    /// - Parameter Colors: Pixel data from a previous processing run.
    /// - Parameter ShowWait: If true, a "Please Wait" message is shown. Otherwise, nothing is shown.
    func ProcessImageInBackground(_ Colors: [[UIColor]], ShowWait: Bool = true)
    {
        OutputView.Clear()
        #if true
        CompositeStatus.AddText("Please Wait")
        ShowStatusLayer()
        ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
        DispatchQueue.global().async
            {
                [weak self] in
                self!.OutputView.ProcessImage(Colors)
        }
        #else
        if ShowWait
        {
            ShowStatusLayer()
            ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
        }
        BackgroundThread.async
            {
                [weak self] in
                self!.OutputView.ProcessImage(Colors)
        }
        #endif
    }
}
