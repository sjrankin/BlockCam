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
        switch Settings.GetEnum(ForKey: .Metalness, EnumType: Metalnesses.self, Default: .Medium)
        {
            case .Least:
                MetalSegment.selectedSegmentIndex = 0
            
            case .NotMuch:
                MetalSegment.selectedSegmentIndex = 1
            
            case .Medium:
                MetalSegment.selectedSegmentIndex = 2
            
            case .ALot:
                MetalSegment.selectedSegmentIndex = 3
            
            case .Most:
                MetalSegment.selectedSegmentIndex = 4
        }
        switch Settings.GetEnum(ForKey: .MaterialRoughness, EnumType: MaterialRoughnesses.self,
                                Default: .Medium)
        {
            case .Roughest:
                RoughSegment.selectedSegmentIndex = 0
            
            case .Rough:
                RoughSegment.selectedSegmentIndex = 1
            
            case .Medium:
                RoughSegment.selectedSegmentIndex = 2
            
            case .Smooth:
                RoughSegment.selectedSegmentIndex = 3
            
            case .Smoothest:
                RoughSegment.selectedSegmentIndex = 4
        }
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
    
    @IBAction func HandleRoughChanged(_ sender: Any)
    {
        switch RoughSegment.selectedSegmentIndex
        {
            case 0:
                Settings.SetEnum(.Roughest, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 1:
                Settings.SetEnum(.Rough, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 2:
                Settings.SetEnum(.Medium, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 3:
                Settings.SetEnum(.Smooth, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 4:
                Settings.SetEnum(.Smoothest, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            default:
                Settings.SetEnum(.Medium, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
        }
        Menu_ChangeManager.AddChanged(.MaterialRoughness)
    }
    
    @IBAction func HandleMetalChanged(_ sender: Any)
    {
        switch MetalSegment.selectedSegmentIndex
        {
            case 0:
                Settings.SetEnum(.Least, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 1:
                Settings.SetEnum(.NotMuch, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 2:
                Settings.SetEnum(.Medium, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 3:
                Settings.SetEnum(.ALot, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 4:
                Settings.SetEnum(.Most, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            default:
                Settings.SetEnum(.Medium, EnumType: Metalnesses.self, ForKey: .Metalness)
        }
        Menu_ChangeManager.AddChanged(.Metalness)
    }
    
    @IBOutlet weak var RoughSegment: UISegmentedControl!
    @IBOutlet weak var MetalSegment: UISegmentedControl!
    @IBOutlet weak var ConditionLabel: UILabel!
    @IBOutlet weak var ConditionalColorLabel: UILabel!
    @IBOutlet weak var ConditionalColorSelection: UISegmentedControl!
    @IBOutlet weak var ConditionalColorAction: UISegmentedControl!
    @IBOutlet weak var ConditionalColorThreshold: UISegmentedControl!
    @IBOutlet weak var InvertConditionalColorSwitch: UISwitch!
}
