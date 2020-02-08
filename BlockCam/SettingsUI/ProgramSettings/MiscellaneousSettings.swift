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
       InitializeRotation()
    }
    
    @IBAction func HandleSplashScreenChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowSplashScreen)
        }
    }
    
    func InitializeRotation()
    {
        let RotateHow = Settings.GetEnum(ForKey: .UIRotationStyle,
                                         EnumType: UIRotationTypes.self,
                                         Default: UIRotationTypes.None)
        switch RotateHow
        {
            case .None:
                RotationSegment.selectedSegmentIndex = 0
            
            case .CardinalDirections:
                RotationSegment.selectedSegmentIndex = 1
            
            case .Continuous:
                RotationSegment.selectedSegmentIndex = 2
        }
        ShowRotationCaption(RotateHow)
    }
    
    func ShowRotationCaption(_ How: UIRotationTypes)
    {
        switch How
        {
            case .None:
                RotationCaption.text = "Camera controls do not rotate."
            
            case .CardinalDirections:
                RotationCaption.text = "Camera controls rotate to nearest cardinal direction when your device is rotated."
            
            case .Continuous:
                RotationCaption.text = "Camera controls rotate continuously in response to how your device is rotated."
        }
    }
    
    @IBAction func HandleRotationSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(UIRotationTypes.None,
                                     EnumType: UIRotationTypes.self,
                                     ForKey: .UIRotationStyle)
                    ShowRotationCaption(.None)
                
                case 1:
                    Settings.SetEnum(UIRotationTypes.CardinalDirections,
                                     EnumType: UIRotationTypes.self,
                                     ForKey: .UIRotationStyle)
                    ShowRotationCaption(.CardinalDirections)
                
                case 2:
                    Settings.SetEnum(UIRotationTypes.Continuous,
                                     EnumType: UIRotationTypes.self,
                                     ForKey: .UIRotationStyle)
                    ShowRotationCaption(.Continuous)
                
                default:
                break
            }
        }
    }
    
    @IBOutlet weak var RotationCaption: UILabel!
    @IBOutlet weak var RotationSegment: UISegmentedControl!
    @IBOutlet weak var ShowSplashScreenSwitch: UISwitch!
}
