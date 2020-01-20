//
//  MiscellaneousSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MiscellaneousSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowSplashScreenSwitch.isOn = Settings.GetBoolean(ForKey: .ShowSplashScreen)
        ShowUIPromptsSwitch.isOn = Settings.GetBoolean(ForKey: .ShowUIHelpPrompts)
    }
    
    @IBAction func HandleUIPromptsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowUIHelpPrompts)
        }
    }
    
    @IBAction func HandleSplashScreenChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowSplashScreen)
        }
    }
    
    @IBOutlet weak var ShowSplashScreenSwitch: UISwitch!
    @IBOutlet weak var ShowUIPromptsSwitch: UISwitch!
}
