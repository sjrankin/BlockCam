//
//  Menu_EmbeddedBoxesSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_EmbeddedBoxesSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
       let RelativeColor = Settings.GetEnum(ForKey: .EmbeddedBoxColor, EnumType: RelativeColors.self,
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
    }
    
    var ColorList = [String]()
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ColorList[row]
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
        let Raw = ColorList[row]
        if let RColor = RelativeColors(rawValue: Raw)
        {
            Settings.SetEnum(RColor, EnumType: RelativeColors.self, ForKey: .EmbeddedBoxColor)
            Menu_ChangeManager.AddChanged(.EmbeddedBoxColor)
        }
    }
    
    @IBOutlet weak var ColorPicker: UIPickerView!
}
