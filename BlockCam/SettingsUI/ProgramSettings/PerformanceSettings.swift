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
    
    @IBOutlet weak var QualitySegment: UISegmentedControl!
    @IBOutlet weak var ResizeSelector: UISegmentedControl!
    @IBOutlet weak var ResizeDescription: UILabel!
}

