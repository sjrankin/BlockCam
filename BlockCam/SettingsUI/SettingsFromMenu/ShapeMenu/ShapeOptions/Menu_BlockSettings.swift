//
//  Menu_BlockSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_BlockSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let ChamferValue = Settings.GetString(ForKey: .BlockChamferSize)
        {
            if let TheChamfer = BlockEdgeSmoothings(rawValue: ChamferValue)
            {
                switch TheChamfer
                {
                    case .None:
                        EdgeSmoothingSelector.selectedSegmentIndex = 0
                    
                    case .Small:
                        EdgeSmoothingSelector.selectedSegmentIndex = 1
                    
                    case .Medium:
                        EdgeSmoothingSelector.selectedSegmentIndex = 2
                    
                    case .Large:
                        EdgeSmoothingSelector.selectedSegmentIndex = 3
                }
            }
            else
            {
                Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
                EdgeSmoothingSelector.selectedSegmentIndex = 0
            }
        }
        else
        {
            Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
            EdgeSmoothingSelector.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func HandleEdgeSmoothingChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.BlockChamferSize)
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
                
                case 1:
                    Settings.SetString(BlockEdgeSmoothings.Small.rawValue, ForKey: .BlockChamferSize)
                
                case 2:
                    Settings.SetString(BlockEdgeSmoothings.Medium.rawValue, ForKey: .BlockChamferSize)
                
                case 3:
                    Settings.SetString(BlockEdgeSmoothings.Large.rawValue, ForKey: .BlockChamferSize)
                
                default:
                    Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
            }
        }
    }
    
    @IBOutlet weak var EdgeSmoothingSelector: UISegmentedControl!
}
