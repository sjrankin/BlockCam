//
//  Menu_EllipseSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_EllipseSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for ShapeName in EllipticalShapes.allCases
        {
            ShapeList.append(ShapeName.rawValue)
        }
        ShapePicker.reloadAllComponents()
        if let RawShape = Settings.GetString(ForKey: .EllipseShape)
        {
            if ShapeList.contains(RawShape)
            {
                for Index in 0 ..< ShapeList.count
                {
                    if ShapeList[Index] == RawShape
                    {
                        ShapePicker.selectRow(Index, inComponent: 0, animated: true)
                        break
                    }
                }
            }
            else
            {
                Settings.SetString(EllipticalShapes.HorizontalMedium.rawValue, ForKey: .EllipseShape)
                ShapePicker.selectRow(1, inComponent: 0, animated: true)
            }
        }
        else
        {
            Settings.SetString(EllipticalShapes.HorizontalMedium.rawValue, ForKey: .EllipseShape)
            ShapePicker.selectRow(1, inComponent: 0, animated: true)
        }
    }
    
    var ShapeList = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ShapeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        Menu_ChangeManager.AddChanged(.EllipseShape)
        Settings.SetString(ShapeList[row], ForKey: .EllipseShape)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ShapeList[row]
    }
    
    @IBOutlet weak var ShapePicker: UIPickerView!
}
