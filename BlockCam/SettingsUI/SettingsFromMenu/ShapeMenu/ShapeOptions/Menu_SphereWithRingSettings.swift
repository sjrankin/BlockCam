//
//  Menu_SphereWithRingSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_SphereWithRingSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let ColorPickerTag = 100
    let OrientationTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let RelativeColor = Settings.GetEnum(ForKey: .SphereRingColor, EnumType: RelativeColors.self,
                                             Default: .Darker)
        ColorList.removeAll()
        for RColor in RelativeColors.allCases
        {
            ColorList.append(RColor.rawValue)
        }
        ColorPicker.reloadAllComponents()
        if let Index = ColorList.firstIndex(of: RelativeColor.rawValue)
        {
            ColorPicker.selectRow(Index, inComponent: 0, animated: true)
        }
        
     let Orientation = Settings.GetEnum(ForKey: .SphereRingOrientation, EnumType: RingOrientations.self,
                                        Default: .Flat)
        OrientationList.removeAll()
        for Ori in RingOrientations.allCases
        {
            OrientationList.append(Ori.rawValue)
        }
        OrientationPicker.reloadAllComponents()
        if let Index = OrientationList.firstIndex(of: Orientation.rawValue)
        {
            OrientationPicker.selectRow(Index, inComponent: 0, animated: true)
        }
    }
    
    var ColorList = [String]()
    var OrientationList = [String]()
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case ColorPickerTag:
                return ColorList[row]
            
            case OrientationTag:
            return OrientationList[row]
            
            default:
                return nil
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        switch pickerView.tag
        {
            case ColorPickerTag:
                return 1
            
            case OrientationTag:
            return 1
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case ColorPickerTag:
                return ColorList.count
            
            case OrientationTag:
            return OrientationList.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case ColorPickerTag:
                let Raw = ColorList[row]
                if let RColor = RelativeColors(rawValue: Raw)
                {
                    Settings.SetEnum(RColor, EnumType: RelativeColors.self, ForKey: .SphereRingColor)
                    Menu_ChangeManager.AddChanged(.SphereRingColor)
            }
            
            case OrientationTag:
            let Raw = OrientationList[row]
            if let ROri = RingOrientations(rawValue: Raw)
            {
                Settings.SetEnum(ROri, EnumType: RingOrientations.self, ForKey: .SphereRingOrientation)
                Menu_ChangeManager.AddChanged(.SphereRingOrientation)
            }
            
            default:
                break
        }
    }
    
    @IBOutlet weak var OrientationPicker: UIPickerView!
    @IBOutlet weak var ColorPicker: UIPickerView!
}
