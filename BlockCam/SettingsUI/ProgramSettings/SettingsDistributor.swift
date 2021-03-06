//
//  SettingsDistributor.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit


class SettingsDistributor: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AnimateUISwitch.isOn = !Settings.GetBoolean(ForKey: .StaticUI)
        EnableLoggingSwitch.isOn = Settings.GetBoolean(ForKey: .LoggingEnabled)
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleEnableLoggingChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .LoggingEnabled)
        }
    }
    
    @IBAction func HandleAnimateUIChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(!Switch.isOn, ForKey: .StaticUI)
        }
    }
    
    @IBOutlet weak var AnimateUISwitch: UISwitch!
    @IBOutlet weak var EnableLoggingSwitch: UISwitch!
}

