//
//  Menu_ShapeSize.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_ShapeSize: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    public weak var Delegate: SomethingChangedProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SizePicker.reloadAllComponents()
        let OldSize = Settings.GetInteger(ForKey: .BlockSize)
        let Index = ClosestIndex(To: OldSize)
        SizePicker.selectRow(Index, inComponent: 0, animated: true)
    }
    
    let Sizes = [10, 16, 20, 24, 32, 40, 48, 56, 64, 72, 80, 86, 90, 96, 100]
    
    func ClosestIndex(To: Int) -> Int
    {
        var Distance = Int.max
        var Index = 0
        for i in 0 ..< Sizes.count
        {
            let D = abs(To - Sizes[i])
            if D < Distance
            {
                Index = i
                Distance = D
            }
        }
        return Index
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Sizes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return "\(Sizes[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let NewSize = Sizes[row]
        Settings.SetInteger(NewSize, ForKey: .BlockSize)
        Menu_ChangeManager.AddChanged(.BlockSize)
        Delegate?.SomethingChanged()
    }
    
    @IBOutlet weak var SizePicker: UIPickerView!
}
