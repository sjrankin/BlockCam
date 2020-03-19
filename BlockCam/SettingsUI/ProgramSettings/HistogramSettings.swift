//
//  HistogramSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class HistogramSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let ChannelPickerTag = 100
    let CreationSpeedPickerTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ChannelOrderPicker.layer.cornerRadius = 5.0
        ChannelOrderPicker.layer.borderWidth = 0.5
        ChannelOrderPicker.layer.borderColor = UIColor.black.cgColor
        CreationSpeedPicker.layer.cornerRadius = 5.0
        CreationSpeedPicker.layer.borderWidth = 0.5
        CreationSpeedPicker.layer.borderColor = UIColor.black.cgColor
        ChannelOrderPicker.reloadAllComponents()
        CreationSpeedPicker.reloadAllComponents()
        let OldOrder = Settings.GetEnum(ForKey: .HistogramOrder, EnumType: HistogramOrders.self, Default: .RGB)
        let OldSpeed = Settings.GetEnum(ForKey: .HistogramCreationSpeed, EnumType: HistogramCreationSpeeds.self, Default: .Fastest)
        let OldOrderIndex = OrderMap[OldOrder]!
        let OldSpeedIndex = SpeedMap[OldSpeed]!
        ChannelOrderPicker.selectRow(OldOrderIndex, inComponent: 0, animated: true)
        CreationSpeedPicker.selectRow(OldSpeedIndex, inComponent: 0, animated: true)
        CombineChannelSwitch.isOn = Settings.GetBoolean(ForKey: .CombinedHistogram)
        ProcessedImageHistogramSwitch.isOn = Settings.GetBoolean(ForKey: .ShowProcessedHistogram)
    }
    
    let OrderMap =
        [
            HistogramOrders.RGB: 0,
            HistogramOrders.RBG: 1,
            HistogramOrders.GRB: 2,
            HistogramOrders.GBR: 3,
            HistogramOrders.BRG: 4,
            HistogramOrders.BGR: 5,
            HistogramOrders.Gray: 6
    ]
    
    let SpeedMap =
        [
            HistogramCreationSpeeds.Fastest: 0,
            HistogramCreationSpeeds.Fast: 1,
            HistogramCreationSpeeds.Medium: 2,
            HistogramCreationSpeeds.Slow: 3,
            HistogramCreationSpeeds.Slowest: 4
    ]
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case ChannelPickerTag:
                for (Channel, Index) in OrderMap
                {
                    if Index == row
                    {
                        return Channel.rawValue
                    }
            }
            
            case CreationSpeedPickerTag:
                for (Speed, Index) in SpeedMap
                {
                    if Index == row
                    {
                        return Speed.rawValue
                    }
            }
            
            default:
                return nil
        }
        
        return nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case ChannelPickerTag:
                return OrderMap.count
            
            case CreationSpeedPickerTag:
                return SpeedMap.count
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case ChannelPickerTag:
                let Index = row
                for (Order, OrderIndex) in OrderMap
                {
                    if OrderIndex == Index
                    {
                        Settings.SetEnum(Order, EnumType: HistogramOrders.self, ForKey: .HistogramOrder)
                        return
                    }
            }
            
            case CreationSpeedPickerTag:
                let Index = row
                for (Speed, SpeedIndex) in SpeedMap
                {
                    if SpeedIndex == Index
                    {
                        Settings.SetEnum(Speed, EnumType: HistogramCreationSpeeds.self, ForKey: .HistogramCreationSpeed)
                        return
                    }
            }
            
            default:
                break
        }
    }
    
    @IBAction func HandleCombinedChannelsSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .CombinedHistogram)
        }
    }
    
    @IBAction func HandleProcessedImageHistogramChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowProcessedHistogram)
        }
    }
    
    @IBOutlet weak var CreationSpeedPicker: UIPickerView!
    @IBOutlet weak var ChannelOrderPicker: UIPickerView!
    @IBOutlet weak var ProcessedImageHistogramSwitch: UISwitch!
    @IBOutlet weak var CombineChannelSwitch: UISwitch!
}
