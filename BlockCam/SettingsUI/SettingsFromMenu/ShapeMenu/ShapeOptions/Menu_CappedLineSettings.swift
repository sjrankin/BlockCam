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
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        ShapePicker.reloadAllComponents()
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
    }
    
    let ShapeMap =
    [
        CappedLineCapShapes.Sphere.rawValue: 0,
        CappedLineCapShapes.Box.rawValue: 1,
        CappedLineCapShapes.Cone.rawValue: 2,
        CappedLineCapShapes.Square.rawValue: 3,
        CappedLineCapShapes.Circle.rawValue: 4
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
                    Settings.SetString(BallLocations.Bottom.rawValue, ForKey: .CappedLineBallLocation)
                
                case 1:
                    Settings.SetString(BallLocations.Middle.rawValue, ForKey: .CappedLineBallLocation)
                
                case 2:
                    Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
                
                default:
                    Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ShapeMap.count
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let ShapeName = ShapeForIndex(row)
        {
            Menu_ChangeManager.AddChanged(.CappedLineCapShape)
            Settings.SetString(ShapeName, ForKey: .CappedLineCapShape)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ShapeForIndex(row)
    }
    
    @IBOutlet weak var ShapePicker: UIPickerView!
    @IBOutlet weak var BallLocationSelector: UISegmentedControl!
}
