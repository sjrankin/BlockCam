//
//  ViewSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ViewSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
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
        let InitialS = Settings.GetString(ForKey: .InitialView)
        if let Initial = InitialS == nil ? ProgramModes.LiveView : ProgramModes(rawValue: InitialS!)
        {
            ModeSegements.selectedSegmentIndex = ModeMap[Initial]!
        }
        else
        {
            ModeSegements.selectedSegmentIndex = 0
        }
        ShowCurrentOrientationSwitch.isOn = Settings.GetBoolean(ForKey: .ShowActualOrientation)
        if let RawGridType = Settings.GetString(ForKey: .LiveViewGridType)
        {
            if let ActualType = GridTypes(rawValue: RawGridType)
            {
                let Index = GridMap[ActualType]!
                GridPicker.selectRow(Index, inComponent: 0, animated: true)
            }
            else
            {
                Settings.SetString(GridTypes.None.rawValue, ForKey: .LiveViewGridType)
                GridPicker.selectRow(0, inComponent: 0, animated: true)
            }
        }
        else
        {
            Settings.SetString(GridTypes.None.rawValue, ForKey: .LiveViewGridType)
            GridPicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    let ModeMap =
        [
            ProgramModes.LiveView: 0,
            ProgramModes.PhotoLibrary: 1,
            ProgramModes.ProcessedView: 2
    ]
    
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
    
    let GridTypeList = ["None", "Simple", "Cross Hairs", "Rule of Three", "Exotic", "Tight"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return GridTypeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return GridTypeList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        for (GridType, GridIndex) in GridMap
        {
            if GridIndex == row
            {
                Settings.SetString(GridType.rawValue, ForKey: .LiveViewGridType)
            }
        }
    }
    
    let GridMap =
        [
            GridTypes.None: 0,
            GridTypes.Simple: 1,
            GridTypes.CrossHairs: 2,
            GridTypes.RuleOfThree: 3,
            GridTypes.Exotic: 4,
            GridTypes.Tight: 5,
    ]
    
    @IBAction func HandleCurrentOrientationChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowActualOrientation)
        }
    }
    
    @IBOutlet weak var GridPicker: UIPickerView!
    @IBOutlet weak var ShowCurrentOrientationSwitch: UISwitch!
    @IBOutlet weak var BestFitOffsetSegment: UISegmentedControl!
    @IBOutlet weak var BestFitSwitch: UISwitch!
    @IBOutlet weak var ModeSegements: UISegmentedControl!
}
