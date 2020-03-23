//
//  UIGuide.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class UIGuide: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBSegueAction func InstantiateHUDHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "Live View Overlays"
        Controller?.HTML = HelpText.GetHelpText(For: .HUDUI)
        return Controller
    }
    
    @IBSegueAction func InstantiateGeneralUIHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "User Interface Help"
        Controller?.HTML = HelpText.GetHelpText(For: .OverallUI)
        return Controller
    }
    
    @IBSegueAction func InstantiateToolbarHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "Toolbar Help"
        Controller?.HTML = HelpText.GetHelpText(For: .ToolbarUI)
        return Controller
    }
}
