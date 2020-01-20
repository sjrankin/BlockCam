//
//  Main_HeightSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_HeightSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    weak var Delegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DeterminantPicker.layer.borderColor = UIColor.black.cgColor
        Menu_ChangeManager.Clear()
        DeterminantLabel.text = ""
        var Index = -1
        var Count = 0
        for SomeCase in HeightSources.allCases
        {
            Sources.append(SomeCase.rawValue)
            if SomeCase.rawValue == Settings.GetString(ForKey: .HeightSource)
            {
                Index = Count
            }
            Count = Count + 1
        }
        DeterminantPicker.reloadAllComponents()
        DeterminantPicker.selectRow(Index, inComponent: 0, animated: true)
        InvertHeightSwitch.isOn = Settings.GetBoolean(ForKey: .InvertHeight)
        if let VEx = Settings.GetString(ForKey: .VerticalExaggeration)
        {
            switch VEx
            {
                case "None":
                    HeightModifierSegment.selectedSegmentIndex = 0
                
                case "Low":
                    HeightModifierSegment.selectedSegmentIndex = 1
                
                case "Medium":
                    HeightModifierSegment.selectedSegmentIndex = 2
                
                case "High":
                    HeightModifierSegment.selectedSegmentIndex = 3
                
                default:
                    HeightModifierSegment.selectedSegmentIndex = 2
            }
        }
        else
        {
            HeightModifierSegment.selectedSegmentIndex = 2
            Settings.SetString("Medium", ForKey: .VerticalExaggeration)
        }
    }
    
    var Sources: [String] = []
    
    @IBAction func HandleHeightModifierChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.VerticalExaggeration)
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString("None", ForKey: .VerticalExaggeration)
                
                case 1:
                    Settings.SetString("Low", ForKey: .VerticalExaggeration)
                
                case 2:
                    Settings.SetString("Medium", ForKey: .VerticalExaggeration)
                
                case 3:
                    Settings.SetString("High", ForKey: .VerticalExaggeration)
                
                default:
                    Settings.SetString("Medium", ForKey: .VerticalExaggeration)
            }
        }
    }
    
    @IBAction func HandleInvertHeightChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.InvertHeight)
            Settings.SetBoolean(Switch.isOn, ForKey: .InvertHeight)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return Sources[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Sources.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Raw = Sources[row]
        Menu_ChangeManager.AddChanged(.HeightSource)
        Settings.SetString(Raw, ForKey: .HeightSource)
    }
    
    let ChangeList: [SettingKeys] =
        [
            .InvertHeight, .VerticalExaggeration, .HeightSource
    ]
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            if Menu_ChangeManager.Contains(self.ChangeList)
            {
                self.Delegate?.Redraw3D(Menu_ChangeManager.AsArray)
            }
        }
    }
    
    @IBOutlet weak var InvertHeightSwitch: UISwitch!
    @IBOutlet weak var HeightModifierSegment: UISegmentedControl!
    @IBOutlet weak var DeterminantLabel: UILabel!
    @IBOutlet weak var DeterminantPicker: UIPickerView!
}
