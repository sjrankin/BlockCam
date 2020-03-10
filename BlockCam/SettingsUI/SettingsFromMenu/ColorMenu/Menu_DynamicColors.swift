//
//  Menu_DynamicColors.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_DynamicColors: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
      
        InvertConditionalColorSwitch.isOn = Settings.GetBoolean(ForKey: .InvertDynamicColorProcess)
        UpdateConditionalSigns(IsInverted: InvertConditionalColorSwitch.isOn)
        if let RawType = Settings.GetString(ForKey: .DynamicColorType)
        {
            if let Index = ConditionalColorMap[RawType]
            {
                ConditionalColorSelection.selectedSegmentIndex = Index
            }
            else
            {
                ConditionalColorSelection.selectedSegmentIndex = 0
                Settings.SetString(DynamicColorTypes.None.rawValue, ForKey: .DynamicColorType)
            }
        }
        else
        {
            ConditionalColorSelection.selectedSegmentIndex = 0
            Settings.SetString(DynamicColorTypes.None.rawValue, ForKey: .DynamicColorType)
        }
        UpdateConditionalColorLabel(WithIndex: ConditionalColorAction.selectedSegmentIndex)
        if let RawType = Settings.GetString(ForKey: .DynamicColorAction)
        {
            if let Index = ColorActionsMap[RawType]
            {
                ConditionalColorAction.selectedSegmentIndex = Index
            }
            else
            {
                ConditionalColorAction.selectedSegmentIndex = 0
                Settings.SetString(DynamicColorActions.Grayscale.rawValue, ForKey: .DynamicColorAction)
            }
        }
        else
        {
            ConditionalColorAction.selectedSegmentIndex = 0
            Settings.SetString(DynamicColorActions.Grayscale.rawValue, ForKey: .DynamicColorAction)
        }
        if let RawType = Settings.GetString(ForKey: .DynamicColorCondition)
        {
            if let Index = ChannelEnableMap[RawType]
            {
                ConditionalColorThreshold.selectedSegmentIndex = Index
            }
            else
            {
                ConditionalColorThreshold.selectedSegmentIndex = 2
                Settings.SetString(DynamicColorConditions.LessThan50.rawValue, ForKey: .DynamicColorCondition)
            }
        }
        else
        {
            ConditionalColorThreshold.selectedSegmentIndex = 2
            Settings.SetString(DynamicColorConditions.LessThan50.rawValue, ForKey: .DynamicColorCondition)
        }
    }
    
    let ConditionalColorMap =
        [
            DynamicColorTypes.None.rawValue: 0,
            DynamicColorTypes.Hue.rawValue: 1,
            DynamicColorTypes.Saturation.rawValue: 2,
            DynamicColorTypes.Brightness.rawValue: 3
    ]
    
    let ChannelEnableMap =
        [
            DynamicColorConditions.LessThan10.rawValue: 0,
            DynamicColorConditions.LessThan25.rawValue: 1,
            DynamicColorConditions.LessThan50.rawValue: 2,
            DynamicColorConditions.LessThan75.rawValue: 3,
            DynamicColorConditions.LessThan90.rawValue: 4
    ]
    
    let ColorActionsMap =
        [
            DynamicColorActions.Grayscale.rawValue: 0,
            DynamicColorActions.IncreaseSaturation.rawValue: 1,
            DynamicColorActions.DecreaseSaturation.rawValue: 2
    ]
    
    @IBAction func HandleInvertConditionalColor(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.InvertDynamicColorProcess)
            Settings.SetBoolean(Switch.isOn, ForKey: .InvertDynamicColorProcess)
            UpdateConditionalSigns(IsInverted: Switch.isOn)
        }
    }
    
    func UpdateConditionalSigns(IsInverted: Bool)
    {
        if IsInverted
        {
            ConditionalColorThreshold.setTitle("> 0.10", forSegmentAt: 0)
            ConditionalColorThreshold.setTitle("> 0.25", forSegmentAt: 1)
            ConditionalColorThreshold.setTitle("> 0.5", forSegmentAt: 2)
            ConditionalColorThreshold.setTitle("> 0.75", forSegmentAt: 3)
            ConditionalColorThreshold.setTitle("> 0.9", forSegmentAt: 4)
        }
        else
        {
            ConditionalColorThreshold.setTitle("< 0.10", forSegmentAt: 0)
            ConditionalColorThreshold.setTitle("< 0.25", forSegmentAt: 1)
            ConditionalColorThreshold.setTitle("< 0.5", forSegmentAt: 2)
            ConditionalColorThreshold.setTitle("< 0.75", forSegmentAt: 3)
            ConditionalColorThreshold.setTitle("< 0.9", forSegmentAt: 4)
        }
    }
    
    func GetValueFor(_ Index: Int, From: [String: Int]) -> String?
    {
        for (Key, Value) in From
        {
            if Value == Index
            {
                return Key
            }
        }
        return nil
    }
    
    @IBAction func HandleConditionalColorThresholdChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            if let Raw = GetValueFor(Index, From: ChannelEnableMap)
            {
                Menu_ChangeManager.AddChanged(.DynamicColorCondition)
                Settings.SetString(Raw, ForKey: .DynamicColorCondition)
            }
        }
    }
    
    @IBAction func HandleConditionalColorActionChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            if let Raw = GetValueFor(Index, From: ColorActionsMap)
            {
                Menu_ChangeManager.AddChanged(.DynamicColorAction)
                Settings.SetString(Raw, ForKey: .DynamicColorAction)
            }
        }
    }
    
    @IBAction func HandleConditionalColorTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            if let Raw = GetValueFor(Index, From: ConditionalColorMap)
            {
                Menu_ChangeManager.AddChanged(.DynamicColorType)
                Settings.SetString(Raw, ForKey: .DynamicColorType)
                UpdateConditionalColorLabel(WithIndex: Index)
            }
        }
    }
    
    func UpdateConditionalColorLabel(WithIndex: Int)
    {
        switch WithIndex
        {
            case 0:
                ConditionalColorLabel.text = "Conditional colors disabled."
            
            case 1:
                ConditionalColorLabel.text = "Conditional colors are based on the hue of each pixellated color."
                ConditionLabel.text = "Hue"
            
            case 2:
                ConditionalColorLabel.text = "Conditional colors are based on the saturation of each pixellated color."
                ConditionLabel.text = "Saturation"
            
            case 3:
                ConditionalColorLabel.text = "Conditional colors are based on the brightness of each pixellated color."
                ConditionLabel.text = "Brightness"
            
            default:
                ConditionalColorLabel.text = ""
        }
    }
    
    @IBOutlet weak var ConditionLabel: UILabel!
    @IBOutlet weak var ConditionalColorLabel: UILabel!
    @IBOutlet weak var ConditionalColorSelection: UISegmentedControl!
    @IBOutlet weak var ConditionalColorAction: UISegmentedControl!
    @IBOutlet weak var ConditionalColorThreshold: UISegmentedControl!
    @IBOutlet weak var InvertConditionalColorSwitch: UISwitch!
}
