//
//  Menu_Hardware.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_Hardware: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let (CPU, Freq) = Platform.GetProcessorInfo()
        CPULabel.text = "\(CPU), \(Freq)"
        let (Used, FreeMem) = Platform.RAMSize()
        AvailableRAMLabel.text = "\(Utilities.PrettyBigNumber(FreeMem))"
        UsedRAMLabel.text = "\(Utilities.PrettyBigNumber(Used))"
        let TotalRAM = Used + FreeMem
        let UsedPercent = Double(Used) / Double(TotalRAM)
        let UnusedPercent = 1.0 - UsedPercent
        let UsedSegment = PieChartSegment(UIColor.systemRed, CGFloat(UsedPercent))
        let UnusedSegment = PieChartSegment(UIColor.systemGreen, CGFloat(UnusedPercent))
        RAMUsage.Segments = [UsedSegment, UnusedSegment]
        GPULabel.text = Platform.MetalGPU()
        ModelNameLabel.text = Platform.NiceModelName()
        ModelIdentifierLabel.text = Platform.GetDeviceModelIdentifier()
    }
    

    
    @IBOutlet weak var RAMUsage: PieChart!
    @IBOutlet weak var AvailableRAMLabel: UILabel!
    @IBOutlet weak var UsedRAMLabel: UILabel!
    @IBOutlet weak var GPULabel: UILabel!
    @IBOutlet weak var CPULabel: UILabel!
    @IBOutlet weak var ModelIdentifierLabel: UILabel!
    @IBOutlet weak var ModelNameLabel: UILabel!
}
