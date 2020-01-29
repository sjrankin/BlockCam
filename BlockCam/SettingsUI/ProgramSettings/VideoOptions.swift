//
//  VideoOptions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class VideoOptions: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var BlockSize = Settings.GetInteger(ForKey: .VideoBlockSize)
        if BlockSize == 0
        {
            BlockSize = 48
            Settings.SetInteger(48, ForKey: .VideoBlockSize)
        }
        if let BlockIndex = BlockSizeMap[BlockSize]
        {
            VideoBlockSegment.selectedSegmentIndex = BlockIndex
        }
        else
        {
            VideoBlockSegment.selectedSegmentIndex = 2
            Settings.SetInteger(48, ForKey: .VideoBlockSize)
        }
        var FPS = Settings.GetInteger(ForKey: .VideoFPS)
        if FPS == 0
        {
            FPS = 1
            Settings.SetInteger(FPS, ForKey: .VideoFPS)
        }
        if let FPSIndex = FPSMap[FPS]
        {
            FPSSegment.selectedSegmentIndex = FPSIndex
        }
        else
        {
            FPSSegment.selectedSegmentIndex = 0
            Settings.SetInteger(1, ForKey: .VideoFPS)
        }
        var VideoSizeS = Settings.GetString(ForKey: .VideoDimensions)
        if VideoSizeS == nil
        {
            VideoSizeS = "Smallest"
            Settings.SetString("Smallest", ForKey: .VideoDimensions)
        }
        var FinalQuality: VideoQuality = .Smallest
        if let VideoSize = VideoQuality(rawValue: VideoSizeS!)
        {
            if let Quality = QualityMap[VideoSize]
            {
                VideoDimSegment.selectedSegmentIndex = Quality
                FinalQuality = VideoSize
            }
            else
            {
                VideoDimSegment.selectedSegmentIndex = 0
                Settings.SetString(VideoQuality.Smallest.rawValue, ForKey: .VideoDimensions)
            }
        }
        else
        {
            VideoDimSegment.selectedSegmentIndex = 0
            Settings.SetString(VideoQuality.Smallest.rawValue, ForKey: .VideoDimensions)
        }
        ShowQualityDescriptionFor(FinalQuality)
    }
    
    let QualityMap =
        [
            VideoQuality.Smallest: 0,
            VideoQuality.Small: 1,
            VideoQuality.Medium: 2,
            VideoQuality.Large: 3,
            VideoQuality.Original: 4
    ]
    
    let FPSMap =
        [
            1: 0,
            5: 1,
            10: 2,
            15: 3,
            20: 4,
            30: 5
    ]
    
    let BlockSizeMap =
        [
            16: 0,
            32: 1,
            48: 2,
            64: 3,
            96: 4
    ]
    
    @IBAction func HandleFPSChanged(_ sender: Any)
    {
        let SelIndex = FPSSegment.selectedSegmentIndex
        for (Value, Index) in FPSMap
        {
            if Index == SelIndex
            {
                Settings.SetInteger(Value, ForKey: .VideoFPS)
                return
            }
        }
    }
    
    @IBAction func HandleVideoDimensionsChanged(_ sender: Any)
    {
        let SelIndex = VideoDimSegment.selectedSegmentIndex
        for (Value, Index) in QualityMap
        {
            if Index == SelIndex
            {
                let NewQuality = Value
                ShowQualityDescriptionFor(NewQuality)
                Settings.SetString(NewQuality.rawValue, ForKey: .VideoDimensions)
                return
            }
        }
    }
    
    func ShowQualityDescriptionFor(_ Quality: VideoQuality)
    {
        switch Quality
        {
            case .Smallest:
                VideoDimDescription.text = "Video's longest dimension is 600 pixels or less. Fastest processing and lowest quality."
            
            case .Small:
                VideoDimDescription.text = "Video's longest dimension is 800 pixels or less. Fast processing and low quality."
            
            case .Medium:
                VideoDimDescription.text = "Video's longest dimension is 1000 pixels or less. Moderate processing and quality."
            
            case .Large:
                VideoDimDescription.text = "Video's longest dimension is 1600 pixels or less. Slow processing and high quality."
            
            case .Original:
                VideoDimDescription.text = "Video's dimensions are unchanged. Very slow processing and original quality."
        }
    }
    
    @IBAction func HandleVideoBlockSizeChanged(_ sender: Any)
    {
        let SelIndex = VideoBlockSegment.selectedSegmentIndex
        for (Value, Index) in BlockSizeMap
        {
            if Index == SelIndex
            {
                Settings.SetInteger(Value, ForKey: .VideoBlockSize)
                return
            }
        }
    }
    
    @IBOutlet weak var VideoBlockSegment: UISegmentedControl!
    @IBOutlet weak var FPSSegment: UISegmentedControl!
    @IBOutlet weak var VideoDimDescription: UILabel!
    @IBOutlet weak var VideoDimSegment: UISegmentedControl!
}

