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
    
    @IBOutlet weak var BestFitOffsetSegment: UISegmentedControl!
    @IBOutlet weak var BestFitSwitch: UISwitch!
    @IBOutlet weak var HistogramLabel: UILabel!
    @IBOutlet weak var ModeSegements: UISegmentedControl!
    @IBOutlet weak var ShowHistogramSwitch: UISwitch!
}
