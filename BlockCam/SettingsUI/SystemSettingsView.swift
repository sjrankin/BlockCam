//
//  SystemSettingsView.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SystemSettingsView: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PowerEventSwitch.isOn = Settings.GetBoolean(ForKey: .HaltOnLowPower)
        ThermalEventSwitch.isOn = Settings.GetBoolean(ForKey: .HaltWhenCriticalThermal)
    }
    
    @IBAction func HandleThermalEventChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .HaltWhenCriticalThermal)
        }
    }
    
    @IBAction func HandlePowerEventChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .HaltOnLowPower)
        }
    }
    
    @IBOutlet weak var PowerEventSwitch: UISwitch!
    @IBOutlet weak var ThermalEventSwitch: UISwitch!
}
