//
//  Menu_SphereSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_SphereSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let Behavior = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self,
                                        Default: .Size)
        switch Behavior
        {
            case .Size:
                BehaviorSegment.selectedSegmentIndex = 0
            
            case .Location:
                BehaviorSegment.selectedSegmentIndex = 1
            
            case .Both:
                BehaviorSegment.selectedSegmentIndex = 2
        }
    }
    
    @IBAction func HandleBehaviorChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetEnum(.Size, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
                
                case 1:
                    Settings.SetEnum(.Location, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
                
                case 2:
                    Settings.SetEnum(.Both, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
                
                default:
                    Settings.SetEnum(.Size, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
            }
        }
    }
    
    @IBOutlet weak var BehaviorSegment: UISegmentedControl!
}
