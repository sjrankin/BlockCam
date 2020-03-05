//
//  Menu_CappedLineSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_CappedLineSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let ShapePickerTag = 100
    let ColorPickerTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapePicker.layer.borderColor = UIColor.black.cgColor
        LineColorPicker.layer.borderColor = UIColor.black.cgColor
        #if true
        let Location = Settings.GetEnum(ForKey: .CappedLineBallLocation, EnumType: BallLocations.self,
                                        Default: .Bottom)
        switch Location
        {
            case .Bottom:
                BallLocationSelector.selectedSegmentIndex = 0
            
            case .Middle:
                BallLocationSelector.selectedSegmentIndex = 1
            
            case .Top:
                BallLocationSelector.selectedSegmentIndex = 2
        }
        #else
        if let Where = Settings.GetString(ForKey: .CappedLineBallLocation)
        {
            if let Actual = BallLocations(rawValue: Where)
            {
                switch Actual
                {
                    case .Bottom:
                        BallLocationSelector.selectedSegmentIndex = 0
                    
                    case .Middle:
                        BallLocationSelector.selectedSegmentIndex = 1
                    
                    case .Top:
                        BallLocationSelector.selectedSegmentIndex = 2
                }
            }
            else
            {
                Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
                BallLocationSelector.selectedSegmentIndex = 2
            }
        }
        else
        {
            Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
            BallLocationSelector.selectedSegmentIndex = 2
        }
        #endif
        ShapePicker.reloadAllComponents()
        #if true
        let CapShape = Settings.GetEnum(ForKey: .CappedLineCapShape, EnumType: CappedLineCapShapes.self,
                                        Default: .Sphere)
        if let Index = ShapeMap[CapShape.rawValue]
        {
            ShapePicker.selectRow(Index, inComponent: 0, animated: true)
        }
        else
        {
            ShapePicker.selectRow(0, inComponent: 0, animated: true)
            Settings.SetEnum(.Sphere, EnumType: CappedLineCapShapes.self, ForKey: .CappedLineCapShape)
        }
        #else
        if let RawShape = Settings.GetString(ForKey: .CappedLineCapShape)
        {
            if let Index = ShapeMap[RawShape]
            {
                ShapePicker.selectRow(Index, inComponent: 0, animated: true)
            }
            else
            {
                ShapePicker.selectRow(0, inComponent: 0, animated: true)
                Settings.SetString(CappedLineCapShapes.Sphere.rawValue, ForKey: .CappedLineCapShape)
            }
        }
        else
        {
            ShapePicker.selectRow(0, inComponent: 0, animated: true)
            Settings.SetString(CappedLineCapShapes.Sphere.rawValue, ForKey: .CappedLineCapShape)
        }
        #endif
        LineColorPicker.reloadAllComponents()
        #if true
        let Color = Settings.GetEnum(ForKey: .CappedLineLineColor, EnumType: CappedLineLineColors.self,
                                     Default: .Same)
        if let Index = ColorMap[Color.rawValue]
        {
            LineColorPicker.selectRow(Index, inComponent: 0, animated: true)
        }
        else
        {
            LineColorPicker.selectRow(0, inComponent: 0, animated: true)
            Settings.SetEnum(.Same, EnumType: CappedLineLineColors.self, ForKey: .CappedLineLineColor)
        }
        #else
        if let RawColor = Settings.GetString(ForKey: .CappedLineLineColor)
        {
            if let Index = ColorMap[RawColor]
            {
                LineColorPicker.selectRow(Index, inComponent: 0, animated: true)
            }
            else
            {
                LineColorPicker.selectRow(0, inComponent: 0, animated: true)
                Settings.SetString(CappedLineLineColors.Same.rawValue, ForKey: .CappedLineLineColor)
            }
        }
        else
        {
            LineColorPicker.selectRow(0, inComponent: 0, animated: true)
            Settings.SetString(CappedLineLineColors.Same.rawValue, ForKey: .CappedLineLineColor)
        }
        #endif
    }
    
    let ShapeMap =
        [
            CappedLineCapShapes.Sphere.rawValue: 0,
            CappedLineCapShapes.Box.rawValue: 1,
            CappedLineCapShapes.Cone.rawValue: 2,
            CappedLineCapShapes.Square.rawValue: 3,
            CappedLineCapShapes.Circle.rawValue: 4
    ]
    
    let ColorMap =
        [
            CappedLineLineColors.Same.rawValue: 0,
            CappedLineLineColors.Darker.rawValue: 1,
            CappedLineLineColors.Lighter.rawValue: 2,
            CappedLineLineColors.Black.rawValue: 3,
            CappedLineLineColors.White.rawValue: 4
    ]
    
    @IBAction func HandleBallLocationChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            Menu_ChangeManager.AddChanged(.CappedLineBallLocation)
            switch Index
            {
                case 0:
                    Settings.SetEnum(.Bottom, EnumType: BallLocations.self, ForKey: .CappedLineBallLocation)
//                    Settings.SetString(BallLocations.Bottom.rawValue, ForKey: .CappedLineBallLocation)
                
                case 1:
                                        Settings.SetEnum(.Middle, EnumType: BallLocations.self, ForKey: .CappedLineBallLocation)
                    //Settings.SetString(BallLocations.Middle.rawValue, ForKey: .CappedLineBallLocation)
                
                case 2:
                                        Settings.SetEnum(.Top, EnumType: BallLocations.self, ForKey: .CappedLineBallLocation)
                   // Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
                
                default:
                                        Settings.SetEnum(.Top, EnumType: BallLocations.self, ForKey: .CappedLineBallLocation)
                   // Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case ShapePickerTag:
                return ShapeMap.count
            
            case ColorPickerTag:
                return ColorMap.count
            
            default:
                return 0
        }
    }
    
    func ShapeForIndex(_ Index: Int) -> String?
    {
        for (Name, ShapeIndex) in ShapeMap
        {
            if ShapeIndex == Index
            {
                return Name
            }
        }
        return nil
    }
    
    func ColorForIndex(_ Index: Int) -> String?
    {
        for (Name, ColorIndex) in ColorMap
        {
            if ColorIndex == Index
            {
                return Name
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case ShapePickerTag:
                if let ShapeName = ShapeForIndex(row)
                {
                    Menu_ChangeManager.AddChanged(.CappedLineCapShape)
                    Settings.SetString(ShapeName, ForKey: .CappedLineCapShape)
            }
            
            case ColorPickerTag:
                if let ColorType = ColorForIndex(row)
                {
                    Menu_ChangeManager.AddChanged(.CappedLineLineColor)
                    Settings.SetString(ColorType, ForKey: .CappedLineLineColor)
            }
            
            default:
                break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case ShapePickerTag:
                return ShapeForIndex(row)
            
            case ColorPickerTag:
                return ColorForIndex(row)
            
            default:
                return nil
        }
    }
    
    @IBOutlet weak var LineColorPicker: UIPickerView!
    @IBOutlet weak var ShapePicker: UIPickerView!
    @IBOutlet weak var BallLocationSelector: UISegmentedControl!
}
