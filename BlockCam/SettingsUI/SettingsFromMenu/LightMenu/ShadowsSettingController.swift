//
//  ShadowsSettingController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ShadowsSettingController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EnableShadowsSwitch.isOn = Settings.GetBoolean(ForKey: .EnableShadows)
    }
    
    @IBAction func HandleEnableShadowsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableShadows)
            Menu_ChangeManager.AddChanged(.EnableShadows)
        }
    }
    
    @IBOutlet weak var EnableShadowsSwitch: UISwitch!
}
