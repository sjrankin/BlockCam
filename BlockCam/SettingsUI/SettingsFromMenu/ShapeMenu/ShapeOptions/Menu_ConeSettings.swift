//
//  Menu_ConeSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_ConeSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let TopPicker = 100
    let BottomPicker = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InvertConeSwitch.isOn = Settings.GetBoolean(ForKey: .ConeIsInverted)
        AdjustedTopSizeMap = TopSizeMap.map{$0.0}
        AdjustedBottomSizeMap = BottomSizeMap.map{$0.0}
        ConeTopPicker.reloadAllComponents()
        ConeBottomPicker.reloadAllComponents()
        if let TopRaw = Settings.GetString(ForKey: .ConeTopOptions)
        {
            if let TopValue = ConeTopOptions(rawValue: TopRaw)
            {
                if let TopIndex = GetTopIndex(For: TopValue)
                {
                    ConeTopPicker.selectRow(TopIndex, inComponent: 0, animated: true)
                }
                else
                {
                    ConeTopPicker.selectRow(3, inComponent: 0, animated: true)
                    Settings.SetString(ConeTopOptions.TopIsZero.rawValue, ForKey: .ConeTopOptions)
                }
            }
            else
            {
                ConeTopPicker.selectRow(3, inComponent: 0, animated: true)
                Settings.SetString(ConeTopOptions.TopIsZero.rawValue, ForKey: .ConeTopOptions)
            }
        }
        if let BottomRaw = Settings.GetString(ForKey: .ConeBottomOptions)
        {
            if let BottomValue = ConeBaseOptions(rawValue: BottomRaw)
            {
                if let BottomIndex = GetBottomIndex(For: BottomValue)
                {
                    ConeBottomPicker.selectRow(BottomIndex, inComponent: 0, animated: true)
                }
                else
                {
                    ConeBottomPicker.selectRow(0, inComponent: 0, animated: true)
                    Settings.SetString(ConeBaseOptions.BaseIsSide.rawValue, ForKey: .ConeBottomOptions)
                }
            }
            else
            {
                ConeTopPicker.selectRow(0, inComponent: 0, animated: true)
                Settings.SetString(ConeBaseOptions.BaseIsSide.rawValue, ForKey: .ConeBottomOptions)
            }
        }
    }
    
    func RemoveTopOptions()
    {
        AdjustedTopSizeMap.removeAll()
        for Index in 0 ..< 5
        {
            AdjustedTopSizeMap.append(TopSizeMap[Index].0)
        }
        ConeTopPicker.reloadAllComponents()
    }
    
    func RestoreTopOptions()
    {
        AdjustedTopSizeMap = TopSizeMap.map{$0.0}
        ConeTopPicker.reloadAllComponents()
    }
    
    func RemoveBottomOptions()
    {
        AdjustedBottomSizeMap.removeAll()
        for Index in 0 ..< 5
        {
            AdjustedBottomSizeMap.append(BottomSizeMap[Index].0)
        }
        ConeBottomPicker.reloadAllComponents()
    }
    
    func RestoreBottomOptions()
    {
        AdjustedBottomSizeMap = BottomSizeMap.map{$0.0}
        ConeBottomPicker.reloadAllComponents()
    }
    
    func GetTopIndex(For: ConeTopOptions) -> Int?
    {
        var Index = 0
        for (_, Computer) in TopSizeMap
        {
            if Computer == For.rawValue
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    func GetBottomIndex(For: ConeBaseOptions) -> Int?
    {
        var Index = 0
        for (_, Computer) in BottomSizeMap
        {
            if Computer == For.rawValue
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    let TopSizeMap: [(String, String)] =
        [
            ("Side value", ConeTopOptions.TopIsSide.rawValue),
            ("Saturation", ConeTopOptions.TopIsSaturation.rawValue),
            ("Hue", ConeTopOptions.TopIsHue.rawValue),
            ("10% of Side", ConeTopOptions.TenPercentSide.rawValue),
            ("50% of Side", ConeTopOptions.FiftyPercentSide.rawValue),
            ("Zero", ConeTopOptions.TopIsZero.rawValue),
            ("10%", ConeTopOptions.TenPercent.rawValue),
            ("50%", ConeTopOptions.FiftyPercent.rawValue)
    ]
    
    let BottomSizeMap: [(String, String)] =
        [
            ("Side value", ConeBaseOptions.BaseIsSide.rawValue),
            ("Saturation", ConeBaseOptions.BaseIsSaturation.rawValue),
            ("Hue", ConeBaseOptions.BaseIsHue.rawValue),
            ("10% of Side", ConeBaseOptions.TenPercentSide.rawValue),
            ("50% of Side", ConeBaseOptions.FiftyPercentSide.rawValue),
            ("Zero", ConeBaseOptions.BaseIsZero.rawValue),
            ("10%", ConeBaseOptions.TenPercent.rawValue),
            ("50%", ConeBaseOptions.FiftyPercent.rawValue)
    ]
    
    var AdjustedTopSizeMap: [String] = [String]()
    var AdjustedBottomSizeMap: [String] = [String]()
    
    let TopExclusions = [5, 6, 7]
    let BaseExclusions = [5, 6, 7]
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case TopPicker:
            return AdjustedTopSizeMap[row]
            
            case BottomPicker:
            return AdjustedBottomSizeMap[row]
            
            default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case TopPicker:
                let BottomSelection = ConeBottomPicker.selectedRow(inComponent: 0)
                if TopExclusions.contains(BottomSelection)
                {
                    ConeTopPicker.selectRow(0, inComponent: 0, animated: true)
                    Settings.SetString(TopSizeMap[row].1, ForKey: .ConeTopOptions)
                }
                else
                {
                    let TopSelection = ConeTopPicker.selectedRow(inComponent: 0)
                    if TopSelection > 2
                    {
                        RemoveBottomOptions()
                    }
                    else
                    {
                        if AdjustedBottomSizeMap.count != BottomSizeMap.count
                        {
                            RestoreBottomOptions()
                        }
                    }
                    Settings.SetString(TopSizeMap[row].1, ForKey: .ConeTopOptions)
                }
                Menu_ChangeManager.AddChanged(.ConeTopOptions)
            
            case BottomPicker:
                let TopSelection = ConeTopPicker.selectedRow(inComponent: 0)
                if BaseExclusions.contains(TopSelection)
                {
                    ConeBottomPicker.selectRow(0, inComponent: 0, animated: true)
                    Settings.SetString(BottomSizeMap[row].1, ForKey: .ConeBottomOptions)
                }
                else
                {
                    let BottomSelection = ConeBottomPicker.selectedRow(inComponent: 0)
                    if BottomSelection > 0
                    {
                        RemoveTopOptions()
                    }
                    else
                    {
                        if AdjustedTopSizeMap.count != TopSizeMap.count
                        {
                            RestoreTopOptions()
                        }
                    }
                    Settings.SetString(BottomSizeMap[row].1, ForKey: .ConeBottomOptions)
                }
                Menu_ChangeManager.AddChanged(.ConeBottomOptions)
            
            default:
                break
        }
    }
    
    func ValidateChanges()
    {
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case TopPicker:
                return AdjustedTopSizeMap.count
            
            case BottomPicker:
                return AdjustedBottomSizeMap.count
            
            default:
                return 0
        }
    }
    
    @IBAction func HandleConeInverted(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.ConeIsInverted)
            Settings.SetBoolean(Switch.isOn, ForKey: .ConeIsInverted)
        }
    }
    
    @IBOutlet weak var ConeTopPicker: UIPickerView!
    @IBOutlet weak var ConeBottomPicker: UIPickerView!
    @IBOutlet weak var InvertConeSwitch: UISwitch!
}
