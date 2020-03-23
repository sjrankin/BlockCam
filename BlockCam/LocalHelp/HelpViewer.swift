//
//  HelpViewer.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import QuickLook

class HelpViewer: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBSegueAction func InstantiateConstraintsHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "BlockCam Constraints"
        Controller?.HTML = HelpText.GetHelpText(For: .Constraints)
        return Controller
    }
    
    @IBSegueAction func InstantiateFAQ(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "BlockCam FAQs"
        Controller?.HTML = HelpText.GetHelpText(For: .FAQs)
        return Controller
    }
    
    @IBSegueAction func InstanstiateWorkFlowHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "BlockCam Workflow"
        Controller?.HTML = HelpText.GetHelpText(For: .WorkFlow)
        return Controller
    }
    
    @IBSegueAction func InstantiateGlossary(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "Glossary"
        Controller?.HTML = HelpText.GetHelpText(For: .Glossary)
        return Controller
    }
    
    @IBSegueAction func InstantiateOverviewHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "BlockCam Overview"
        Controller?.HTML = HelpText.GetHelpText(For: .Overview)
        return Controller
    }
    @IBSegueAction func InstantiateSettingTypeHelp(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "Setting Types"
        Controller?.HTML = HelpText.GetHelpText(For: .SettingTypes)
        return Controller
    }
    
    @IBSegueAction func InstantiateSettingsDictionary(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "Settings Dictionary"
        Controller?.HTML = HelpText.GetHelpText(For: .SettingsDictionary)
        return Controller
    }
    @IBSegueAction func InstantiateBehindTheScenes(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.ControllerTitle = "BlockCam Internals"
        Controller?.HTML = HelpText.GetHelpText(For: .BehindTheScenes)
        return Controller
    }
    
    @IBSegueAction func InstantiateHelpRightsTextViewer(_ coder: NSCoder) -> HelpViewController2?
    {
        let Controller = HelpViewController2(coder: coder)
        Controller?.HTML = HelpText.GetHelpText(For: .Rights)
        Controller?.ControllerTitle = "Rights and Privacy"
        return Controller
    }
    
    @IBSegueAction func InstantiateSettingSearch(_ coder: NSCoder) -> SettingsSearcherUI?
    {
        return SettingsSearcherUI(coder: coder)
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
