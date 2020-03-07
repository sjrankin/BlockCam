//
//  Menu_RegularSolidSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_RegularSolidSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let Behavior = Settings.GetEnum(ForKey: .RegularSolidBehavior, EnumType: RegularSolidBehaviors.self,
                                        Default: .Size)
        switch Behavior
        {
            case .Size:
                BehaviorSegment.selectedSegmentIndex = 0
            
            case .Location:
                BehaviorSegment.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func HandleBehaviorChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetEnum(.Size, EnumType: RegularSolidBehaviors.self, ForKey: .RegularSolidBehavior)
                
                case 1:
                    Settings.SetEnum(.Location, EnumType: RegularSolidBehaviors.self, ForKey: .RegularSolidBehavior)
                
                default:
                    Settings.SetEnum(.Size, EnumType: RegularSolidBehaviors.self, ForKey: .RegularSolidBehavior)
            }
            Menu_ChangeManager.AddChanged(.RegularSolidBehavior)
        }
    }
    
    @IBOutlet weak var BehaviorSegment: UISegmentedControl!
}
