//
//  ViewSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ViewSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        BestFitSwitch.isOn = Settings.GetBoolean(ForKey: .InitialBestFit)
        let Offset = Settings.GetDouble(ForKey: .BestFitOffset)
        if let Index = BestFitMap[Offset]
        {
            BestFitOffsetSegment.selectedSegmentIndex = Index
        }
        else
        {
            BestFitOffsetSegment.selectedSegmentIndex = 0
            Settings.SetDouble(0.0, ForKey: .BestFitOffset)
        }
        ShowHistogramSwitch.isOn = Settings.GetBoolean(ForKey: .ShowHistogram)
        let InitialS = Settings.GetString(ForKey: .InitialView)
        if let Initial = InitialS == nil ? ProgramModes.LiveView : ProgramModes(rawValue: InitialS!)
        {
            ModeSegements.selectedSegmentIndex = ModeMap[Initial]!
        }
        else
        {
            ModeSegements.selectedSegmentIndex = 0
        }
        if let RawOrder = Settings.GetString(ForKey: .HistogramOrder)
        {
            InitializeHistogramOrder(RawOrder)
        }
        else
        {
            Settings.SetString(HistogramOrders.RGB.rawValue, ForKey: .HistogramOrder)
            InitializeHistogramOrder(HistogramOrders.RGB.rawValue)
        }
        if let RawSpeed = Settings.GetString(ForKey: .HistogramCreationSpeed)
        {
            InitializeHistogramSpeed(RawSpeed)
        }
        else
        {
            Settings.SetString(HistogramCreationSpeeds.Medium.rawValue, ForKey: .HistogramCreationSpeed)
            InitializeHistogramSpeed(HistogramCreationSpeeds.Medium.rawValue)
        }
        ProcessedHistogramSwitch.isOn = Settings.GetBoolean(ForKey: .ShowProcessedHistogram)
    }
    
    let ModeMap =
        [
            ProgramModes.LiveView: 0,
            ProgramModes.PhotoLibrary: 1,
            ProgramModes.ProcessedView: 2
    ]
    
    @IBAction func HandleHistogramChanged(_ sender: Any)
    {
        Settings.SetBoolean(ShowHistogramSwitch.isOn, ForKey: .ShowHistogram)
    }
    
    @IBAction func HandleModeChanged(_ sender: Any)
    {
        let NewIndex = ModeSegements.selectedSegmentIndex
        for (Mode, Index) in ModeMap
        {
            if Index == NewIndex
            {
                Settings.SetString(Mode.rawValue, ForKey: .InitialView)
                return
            }
        }
        Settings.SetString(ProgramModes.LiveView.rawValue, ForKey: .InitialView)
    }
    
    @IBAction func HandleBestFitChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .InitialBestFit)
        }
    }
    
    @IBAction func HandleBestFitOffsetChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            for (Value, MapIndex) in BestFitMap
            {
                if MapIndex == Index
                {
                    Settings.SetDouble(Value, ForKey: .BestFitOffset)
                    return
                }
            }
            Settings.SetDouble(0.0, ForKey: .BestFitOffset)
            Segment.selectedSegmentIndex = 0
        }
    }
    
    let BestFitMap =
    [
        0.0: 0,
        1.0: 1,
        2.0: 2,
        4.0: 3,
        8.0: 4
    ]
    
    @IBAction func HandleHistogramOrderChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let NewIndex = Segment.selectedSegmentIndex
            for (Order, Index) in OrderMap
            {
                if Index == NewIndex
                {
                    Settings.SetString(Order.rawValue, ForKey: .HistogramOrder)
                }
            }
        }
    }
    
    func InitializeHistogramOrder(_ Raw: String)
    {
        if Raw.isEmpty
        {
            Log.AbortMessage("Unexpectedly empty string passed to InitializeHistogramOrder")
            {
                Message in
                fatalError(Message)
            }
        }
        if let Order = HistogramOrders(rawValue: Raw)
        {
            if let OrderIndex = OrderMap[Order]
            {
                HistogramOrder.selectedSegmentIndex = OrderIndex
                return
            }
        }
        HistogramOrder.selectedSegmentIndex = 0
        Settings.SetString(HistogramOrders.RGB.rawValue, ForKey: .HistogramOrder)
    }
    
    let OrderMap =
    [
        HistogramOrders.RGB: 0,
        HistogramOrders.RBG: 1,
        HistogramOrders.GRB: 2,
        HistogramOrders.GBR: 3,
        HistogramOrders.BRG: 4,
        HistogramOrders.BGR: 5,
        HistogramOrders.Gray: 6
    ]
    
    @IBAction func HandleProcessedHistogramChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowProcessedHistogram)
        }
    }
    
    @IBAction func HandleHistogramSpeedChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let NewIndex = Segment.selectedSegmentIndex
            for (Speed, Index) in SpeedMap
            {
                if Index == NewIndex
                {
                    Settings.SetString(Speed.rawValue, ForKey: .HistogramCreationSpeed)
                }
            }
        }
    }
    
    func InitializeHistogramSpeed(_ Raw: String)
    {
        if let Speed = HistogramCreationSpeeds(rawValue: Raw)
        {
            HistogramSpeedSegment.selectedSegmentIndex = SpeedMap[Speed]!
        }
        else
        {
            HistogramSpeedSegment.selectedSegmentIndex = 2
        }
    }
    
    let SpeedMap =
    [
        HistogramCreationSpeeds.Fastest: 0,
        HistogramCreationSpeeds.Fast: 1,
        HistogramCreationSpeeds.Medium: 2,
        HistogramCreationSpeeds.Slow: 3,
        HistogramCreationSpeeds.Slowest: 4
    ]
    
    @IBOutlet weak var HistogramSpeedSegment: UISegmentedControl!
    @IBOutlet weak var ProcessedHistogramSwitch: UISwitch!
    @IBOutlet weak var HistogramOrder: UISegmentedControl!
    @IBOutlet weak var BestFitOffsetSegment: UISegmentedControl!
    @IBOutlet weak var BestFitSwitch: UISwitch!
    @IBOutlet weak var HistogramLabel: UILabel!
    @IBOutlet weak var ModeSegements: UISegmentedControl!
    @IBOutlet weak var ShowHistogramSwitch: UISwitch!
}
