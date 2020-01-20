//
//  Menu_RadiatingLinesSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_RadiatingLinesSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var Count = Settings.GetInteger(ForKey: .RadiatingLineCount)
        if Count < 4
        {
            Count = 4
        }
        switch Count
        {
            case 4:
                LineCountSelection.selectedSegmentIndex = 0
            
            case 8:
                LineCountSelection.selectedSegmentIndex = 1
            
            case 16:
                LineCountSelection.selectedSegmentIndex = 2
            
            default:
                LineCountSelection.selectedSegmentIndex = 1
        }
        if let RawThickness = Settings.GetString(ForKey: .RadiatingLineThickness)
        {
            if let Thick = RadiatingLineThicknesses(rawValue: RawThickness)
            {
                switch Thick
                {
                    case .Thin:
                        ThicknessSelection.selectedSegmentIndex = 0
                    
                    case .Medium:
                        ThicknessSelection.selectedSegmentIndex = 1
                    
                    case .Thick:
                        ThicknessSelection.selectedSegmentIndex = 2
                }
            }
            else
            {
                Settings.SetString(RadiatingLineThicknesses.Medium.rawValue, ForKey: .RadiatingLineThickness)
                ThicknessSelection.selectedSegmentIndex = 1
            }
        }
        else
        {
            Settings.SetString(RadiatingLineThicknesses.Medium.rawValue, ForKey: .RadiatingLineThickness)
            ThicknessSelection.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func HandleThicknessChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.RadiatingLineThickness)
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString(RadiatingLineThicknesses.Thin.rawValue, ForKey: .RadiatingLineThickness)
                
                case 1:
                    Settings.SetString(RadiatingLineThicknesses.Medium.rawValue, ForKey: .RadiatingLineThickness)
                
                case 2:
                    Settings.SetString(RadiatingLineThicknesses.Thick.rawValue, ForKey: .RadiatingLineThickness)
                
                default:
                    Settings.SetString(RadiatingLineThicknesses.Medium.rawValue, ForKey: .RadiatingLineThickness)
            }
        }
    }
    
    @IBAction func HandleLineCountChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.RadiatingLineCount)
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetInteger(4, ForKey: .RadiatingLineCount)
                
                case 1:
                    Settings.SetInteger(8, ForKey: .RadiatingLineCount)
                
                case 2:
                    Settings.SetInteger(16, ForKey: .RadiatingLineCount)
                
                default:
                    Settings.SetInteger(8, ForKey: .RadiatingLineCount)
            }
        }
    }
    
    @IBOutlet weak var ThicknessSelection: UISegmentedControl!
    @IBOutlet weak var LineCountSelection: UISegmentedControl!
    
}
