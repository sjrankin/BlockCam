//
//  PerformanceSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PerformanceSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var QLevel = Settings.GetInteger(ForKey: .AntialiasingMode)
        if QLevel > 2
        {
            QLevel = 2
            Settings.SetInteger(2, ForKey: .AntialiasingMode)
        }
        QualitySegment.selectedSegmentIndex = QLevel
        ShowDescription()
        let Size = Settings.GetInteger(ForKey: .MaxImageDimension)
        if let Index = SizeMap[Size]
        {
            ResizeSelector.selectedSegmentIndex = Index
        }
        else
        {
            ResizeSelector.selectedSegmentIndex = 0
            Settings.SetInteger(512, ForKey: .MaxImageDimension)
        }
        WatchPerformanceSwitch.isOn = Settings.GetBoolean(ForKey: .ShowPerformanceStatus)
        let TooLong = Settings.GetDouble(ForKey: .TooLongDuration, IfZero: 10.0)
        switch Int(TooLong)
        {
            case 5:
                TooLongDurationSegment.selectedSegmentIndex = 0
            
            case 10:
                TooLongDurationSegment.selectedSegmentIndex = 1
            
            case 15:
                TooLongDurationSegment.selectedSegmentIndex = 2
            
            case 20:
                TooLongDurationSegment.selectedSegmentIndex = 3
            
            default:
                TooLongDurationSegment.selectedSegmentIndex = 1
        }
    }
    
    let SizeMap =
        [
            512: 0,
            1024: 1,
            1600: 2,
            2000: 3,
            10000: 4
    ]
    
    func ShowDescription()
    {
        let Size = Settings.GetInteger(ForKey: .MaxImageDimension)
        var Text = ""
        switch Size
        {
            case 512:
                Text = "Input images resized to 512 pixels on the longest dimension."
            
            case 1024:
                Text = "Input images resized to 1024 pixels on the longest dimension."
            
            case 1600:
                Text = "Input images resized to 1600 pixels on the longest dimension."
            
            case 2000:
                Text = "Input images resized to 2000 pixels on the longest dimension. Will heavily impact performance."
            
            case 10000:
                Text = "Input images are not resized. Will impact performance severely."
            
            default:
                Settings.SetInteger(512, ForKey: .MaxImageDimension)
                Text = "Input images resized to 512 pixels on the longest dimension."
        }
        ResizeDescription.text = Text
    }
    
    @IBAction func HandleResizeSelectorChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            for (Size, MapIndex) in SizeMap
            {
                if MapIndex == Index
                {
                    Settings.SetInteger(Size, ForKey: .MaxImageDimension)
                    ShowDescription()
                    return
                }
            }
        }
    }
    
    @IBAction func HandleQualityChanged(_ sender: Any)
    {
        Settings.SetInteger(QualitySegment.selectedSegmentIndex, ForKey: .AntialiasingMode)
    }
    
    @IBAction func HandleWatchPerformanceChanged(_ sender: Any)
    {
        Settings.SetBoolean(WatchPerformanceSwitch.isOn, ForKey: .ShowPerformanceStatus)
    }
    
    @IBAction func HandleTooLongDurationChanged(_ sender: Any)
    {
        let Index = TooLongDurationSegment.selectedSegmentIndex
        switch Index
        {
            case 0:
                Settings.SetDouble(5.0, ForKey: .TooLongDuration)
            
            case 1:
                Settings.SetDouble(10.0, ForKey: .TooLongDuration)
            
            case 2:
                Settings.SetDouble(15.0, ForKey: .TooLongDuration)
            
            case 3:
                Settings.SetDouble(20.0, ForKey: .TooLongDuration)
            
            default:
                Settings.SetDouble(10.0, ForKey: .TooLongDuration)
        }
    }
    
    @IBOutlet weak var TooLongDurationSegment: UISegmentedControl!
    @IBOutlet weak var WatchPerformanceSwitch: UISwitch!
    @IBOutlet weak var QualitySegment: UISegmentedControl!
    @IBOutlet weak var ResizeSelector: UISegmentedControl!
    @IBOutlet weak var ResizeDescription: UILabel!
}

