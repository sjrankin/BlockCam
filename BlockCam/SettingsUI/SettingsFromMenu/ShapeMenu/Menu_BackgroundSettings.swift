//
//  Menu_BackgroundSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_BackgroundSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        BackgroundSelector.selectedSegmentIndex = Settings.GetBoolean(ForKey: .SourceAsBackground) ? 1 : 0
        ColorPicker.layer.borderColor = UIColor.black.cgColor
        for ColorName in BasicColors.allCases
        {
            ColorList.append(ColorName.rawValue)
        }
        ColorPicker.reloadAllComponents()
        ColorTitle.isEnabled = !Settings.GetBoolean(ForKey: .SourceAsBackground)
        ColorPicker.isUserInteractionEnabled = !Settings.GetBoolean(ForKey: .SourceAsBackground)
        let ColorIndex = GetColorIndex(FromRaw: Settings.GetString(ForKey: .SceneBackgroundColor)!)
        ColorPicker.selectRow(ColorIndex, inComponent: 0, animated: true)
    }
    
    var ColorList = [String]()
    
    func GetColorIndex(FromRaw: String) -> Int
    {
        var Index = 0
        for ColorName in ColorList
        {
            if ColorName == FromRaw
            {
                return Index
            }
            Index = Index + 1
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ColorList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        Menu_ChangeManager.AddChanged(.SceneBackgroundColor)
        Settings.SetString(ColorList[row], ForKey: .SceneBackgroundColor)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ColorList[row]
    }
    
    @IBAction func HandleBackgroundTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            var SelectColorsOK = false
            switch Index
            {
                case 0:
                    SelectColorsOK = true
                
                case 1:
                    SelectColorsOK = false
                
                default:
                    SelectColorsOK = false
            }
            ColorTitle.isEnabled = SelectColorsOK
            ColorPicker.isUserInteractionEnabled = SelectColorsOK
            Settings.SetBoolean(!SelectColorsOK, ForKey: .SourceAsBackground)
            Menu_ChangeManager.AddChanged(.SourceAsBackground)
        }
    }
    
    @IBOutlet weak var ColorTitle: UILabel!
    @IBOutlet weak var BackgroundSelector: UISegmentedControl!
    @IBOutlet weak var ColorPicker: UIPickerView!
}
