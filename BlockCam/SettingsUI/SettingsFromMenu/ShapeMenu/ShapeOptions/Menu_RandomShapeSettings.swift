//
//  Menu_RandomShapeSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_RandomShapeSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let BasePickerTag = 100
    let RadiusPickerTag = 200
    let IntensityPickerTag = 300
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        BaseShapePicker.layer.borderColor = UIColor.black.cgColor
        BaseShapePicker.layer.borderWidth = 0.5
        BaseShapePicker.layer.cornerRadius = 5.0
        RadiusPicker.layer.borderColor = UIColor.black.cgColor
        RadiusPicker.layer.borderWidth = 0.5
        RadiusPicker.layer.cornerRadius = 5.0
        IntensityPicker.layer.borderColor = UIColor.black.cgColor
        IntensityPicker.layer.cornerRadius = 5.0
        IntensityPicker.layer.borderWidth = 0.5
        
        ShowBaseSwitch.isOn = Settings.GetBoolean(ForKey: .RandomShapeShowsBase)
        BaseShapes = ShapeManager.GetValidRandomShapes()
        Radiuses = RandomRadiuses.allCases
        Intensities = RandomIntensities.allCases
        BaseShapePicker.reloadAllComponents()
        RadiusPicker.reloadAllComponents()
        IntensityPicker.reloadAllComponents()
        let CurrentShape = Settings.GetEnum(ForKey: .RandomBaseShape, EnumType: NodeShapes.self,
                                            Default: .Spheres)
        let ShapeIndex = BaseShapes.firstIndex(of: CurrentShape)!
        BaseShapePicker.selectRow(ShapeIndex, inComponent: 0, animated: true)
        let CurrentRadius = Settings.GetEnum(ForKey: .RandomRadius, EnumType: RandomRadiuses.self,
                                             Default: .Medium)
        let RadiusIndex = Radiuses.firstIndex(of: CurrentRadius)!
        RadiusPicker.selectRow(RadiusIndex, inComponent: 0, animated: true)
        let CurrentIntensity = Settings.GetEnum(ForKey: .RandomIntensity, EnumType: RandomIntensities.self,
                                                Default: .Moderate)
        let IntensityIndex = Intensities.firstIndex(of: CurrentIntensity)!
        IntensityPicker.selectRow(IntensityIndex, inComponent: 0, animated: true)
    }

    var BaseShapes = [NodeShapes]()
    var Radiuses = [RandomRadiuses]()
    var Intensities = [RandomIntensities]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case BasePickerTag:
                return BaseShapes.count
            
            case RadiusPickerTag:
                return Radiuses.count
            
            case IntensityPickerTag:
                return Intensities.count
            
            default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case BasePickerTag:
                return BaseShapes[row].rawValue
            
            case RadiusPickerTag:
                return Radiuses[row].rawValue
            
            case IntensityPickerTag:
                return Intensities[row].rawValue
            
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case BasePickerTag:
            let Shape = BaseShapes[row]
            Settings.SetEnum(Shape, EnumType: NodeShapes.self, ForKey: .RandomBaseShape)
            Menu_ChangeManager.AddChanged(.RandomBaseShape)
            
            case RadiusPickerTag:
            let Radius = Radiuses[row]
            Settings.SetEnum(Radius, EnumType: RandomRadiuses.self, ForKey: .RandomRadius)
            Menu_ChangeManager.AddChanged(.RandomRadius)
            
            case IntensityPickerTag:
            let Intensity = Intensities[row]
            Settings.SetEnum(Intensity, EnumType: RandomIntensities.self, ForKey: .RandomIntensity)
            Menu_ChangeManager.AddChanged(.RandomIntensity)
            
            default:
            return
        }
    }
    
    @IBAction func HandleShowBaseChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .RandomShapeShowsBase)
            Menu_ChangeManager.AddChanged(.RandomShapeShowsBase)
        }
    }
    
    @IBOutlet weak var ShowBaseSwitch: UISwitch!
    @IBOutlet weak var IntensityPicker: UIPickerView!
    @IBOutlet weak var RadiusPicker: UIPickerView!
    @IBOutlet weak var BaseShapePicker: UIPickerView!
}
