//
//  SettingsController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ShapeOptionsProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeContainer.layer.borderColor = UIColor.black.cgColor
        ShapeContainer.layer.backgroundColor = UIColor.clear.cgColor
        HeightContainer.layer.borderColor = UIColor.black.cgColor
        HeightContainer.layer.backgroundColor = UIColor.clear.cgColor
        var ShapeSize = Settings.GetInteger(ForKey: .BlockSize)
        if ShapeSize == 0
        {
            ShapeSize = 48
            Settings.SetInteger(48, ForKey: .BlockSize)
        }
        BlockSizeSegment.selectedSegmentIndex = SizeMap[ShapeSize]!
        var ShapeType = Settings.GetString(ForKey: .ShapeType)
        if ShapeType == nil
        {
            ShapeType = NodeShapes.Blocks.rawValue
        }
        if OptionsList.contains(ShapeType!)
        {
            ShapeOptionsButton.isEnabled = true
        }
        else
        {
            ShapeOptionsButton.isEnabled = false
        }
        CurrentShape = NodeShapes(rawValue: ShapeType!)
        var PickerIndex = ShapeIndex(NodeShapes(rawValue: ShapeType!)!.rawValue)
        if PickerIndex == nil
        {
            PickerIndex = 0
        }
        ShapePicker.selectRow(PickerIndex!, inComponent: 0, animated: true)
        InvertHeightSwitch.isOn = Settings.GetBoolean(ForKey: .InvertHeight)
        if let HeightSource = Settings.GetString(ForKey: .HeightSource)
        {
            if HeightSources.contains(HeightSource)
            {
                HeightPicker.selectRow(HeightSources.firstIndex(of: HeightSource)!, inComponent: 0, animated: true)
            }
            else
            {
                HeightPicker.selectRow(2, inComponent: 0, animated: true)
                Settings.SetString("Brightness", ForKey: .HeightSource)
            }
        }
        else
        {
            HeightPicker.selectRow(2, inComponent: 0, animated: true)
            Settings.SetString("Brightness", ForKey: .HeightSource)
        }
        
        var VEx = Settings.GetString(ForKey: .VerticalExaggeration)
        if VEx == nil
        {
            VEx = "Medium"
        }
        var VExIndex = 1
        switch VEx!
        {
            case "None":
                VExIndex = 0
            
            case "Low":
                VExIndex = 1
            
            case "Medium":
                VExIndex = 2
            
            case "High":
                VExIndex = 3
            
            default:
                break
        }
        VerticalExaggerationSegment.selectedSegmentIndex = VExIndex
    }
    
    let OptionsList = [NodeShapes.Letters.rawValue, NodeShapes.Meshes.rawValue, NodeShapes.Stars.rawValue, NodeShapes.CappedLines.rawValue]
    
    func ShapeIndex(_ Raw: String) -> Int?
    {
        var Index = 0
        for Shape in NodeShapes.allCases
        {
            if Shape.rawValue == Raw
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    @IBAction func HandleShapeOptionsButton(_ sender: Any)
    {
        switch CurrentShape!
        {
            case .Meshes:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "MeshOptionsUI") as? MeshOptionsCode
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Stars:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "StarOptionsUI") as? StarOptionsCode
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Letters:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "LetterOptionsUI") as? LetterOptionsCode2
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .CappedLines:
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "CappedLineOptions") as? CappedLineOptionsCode
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            default:
                break
        }
    }
    
    let SizeMap = [16: 0, 32: 1, 48: 2, 64: 3, 96: 4]
    
    @IBAction func HandleBlockSizeChanged(_ sender: Any)
    {
        let index = BlockSizeSegment.selectedSegmentIndex
        for (Size, Index) in SizeMap
        {
            if Index == index
            {
                Settings.SetInteger(Size, ForKey: .BlockSize)
                return
            }
        }
    }
    
    let HeightSources = ["Hue", "Saturation", "Brightness", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Black"]
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case 100:
                let Shape = NodeShapes.allCases[row]
                Settings.SetString(Shape.rawValue, ForKey: .ShapeType)
                if OptionsList.contains(Shape.rawValue)
                {
                    CurrentShape = Shape
                    ShapeOptionsButton.isEnabled = true
                }
                else
                {
                    CurrentShape = nil
                    ShapeOptionsButton.isEnabled = false
            }
            
            case 200:
                let HeightSource = HeightSources[row]
                Settings.SetString(HeightSource, ForKey: .HeightSource)
            
            default:
                break
        }
    }
    
    var CurrentShape: NodeShapes? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case 100:
                return NodeShapes.allCases.count
            
            case 200:
                return HeightSources.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case 100:
                let ShapeName = NodeShapes.allCases[row].rawValue
                return ShapeName
            
            case 200:
                return HeightSources[row]
            
            default:
                return nil
        }
    }
    
    @IBAction func HandleInvertHeightChanged(_ sender: Any)
    {
        Settings.SetBoolean(InvertHeightSwitch.isOn, ForKey: .InvertHeight)
    }
    
    @IBAction func HandleVerticalExaggerationChanged(_ sender: Any)
    {
        let Index = VerticalExaggerationSegment.selectedSegmentIndex
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
                break
        }
    }
    
    func GetShape() -> NodeShapes
    {
        let Index = ShapePicker.selectedRow(inComponent: 0)
        return NodeShapes.allCases[Index]
    }
    
    @IBOutlet weak var ShapeOptionsButton: UIButton!
    @IBOutlet weak var HeightContainer: UIView!
    @IBOutlet weak var ShapeContainer: UIView!
    @IBOutlet weak var HeightPicker: UIPickerView!
    @IBOutlet weak var VerticalExaggerationSegment: UISegmentedControl!
    @IBOutlet weak var ShapePicker: UIPickerView!
    @IBOutlet weak var InvertHeightSwitch: UISwitch!
    @IBOutlet weak var BlockSizeSegment: UISegmentedControl!
}
