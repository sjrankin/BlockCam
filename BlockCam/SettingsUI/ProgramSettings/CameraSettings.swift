//
//  CameraSettings2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/21/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CameraSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let InQual = Settings.GetInteger(ForKey: .InputQuality)
        DoHandleQualityChanged(InQual)
        QualitySegment.selectedSegmentIndex = InQual
        var Constraints = Settings.GetString(ForKey: .ImageSizeConstraints)
        if Constraints == nil
        {
            Constraints = "Medium"
        }
        switch Constraints!
        {
            case SizeConstraints.None.rawValue:
                ConstraintSegment.selectedSegmentIndex = 3
                DoHandleConstraintsChanged(0)
            
            case SizeConstraints.Small.rawValue:
                ConstraintSegment.selectedSegmentIndex = 0
                DoHandleConstraintsChanged(1)
            
            case SizeConstraints.Medium.rawValue:
                ConstraintSegment.selectedSegmentIndex = 1
                DoHandleConstraintsChanged(2)
            
            case SizeConstraints.Large.rawValue:
                ConstraintSegment.selectedSegmentIndex = 2
                DoHandleConstraintsChanged(3)
            
            default:
                ConstraintSegment.selectedSegmentIndex = 2
                DoHandleConstraintsChanged(2)
        }
        if let FOV = Settings.GetString(ForKey: .FieldOfView)
        {
            if let FOVIndex = FOVMap[FOV]
            {
                FOVSegment.selectedSegmentIndex = FOVIndex
                DoShowFOVDescription(ForFOV: FOV)
            }
            else
            {
                Settings.SetString("Normal", ForKey: .FieldOfView)
                DoShowFOVDescription(ForFOV: "Normal")
            }
        }
    }
    
    func DoHandleQualityChanged(_ NewIndex: Int)
    {
        switch NewIndex
        {
            case 0:
                QualityDetails.text = "Low quality input from the camera. Increases performance."
            
            case 1:
                QualityDetails.text = "Moderate quality input from the camera."
            
            case 2:
                QualityDetails.text = "High quality input from the camera. Decreases performance."
            
            case 3:
                QualityDetails.text = "High resolution input from the camera. Decreases performance."
            
            default:
                return
        }
    }
    
    func DoHandleConstraintsChanged(_ NewIndex: Int)
    {
        switch NewIndex
        {
            case 3:
                ConstraintDescription.text = "No image size constraints. May be very slow."
            
            case 0:
                ConstraintDescription.text = "Input image reduced to no larger than 800 pixels in the largest dimension."
            
            case 1:
                ConstraintDescription.text = "Input image reduced to no larger than 1600 pixes in the longest dimension."
            
            case 2:
                ConstraintDescription.text = "Input image reduced to no larger than 2000 pixes in the longest dimension."
            
            default:
                return
        }
    }
    
    @IBAction func HandleConstraintsChanged(_ sender: Any)
    {
        let Index = ConstraintSegment.selectedSegmentIndex
        DoHandleConstraintsChanged(Index)
        switch Index
        {
            case 0:
                Settings.SetString(SizeConstraints.None.rawValue, ForKey: .ImageSizeConstraints)
            
            case 1:
                Settings.SetString(SizeConstraints.Small.rawValue, ForKey: .ImageSizeConstraints)
            
            case 2:
                Settings.SetString(SizeConstraints.Medium.rawValue, ForKey: .ImageSizeConstraints)
            
            case 3:
                Settings.SetString(SizeConstraints.Large.rawValue, ForKey: .ImageSizeConstraints)
            
            default:
                return
        }
    }
    
    @IBAction func HandleQualityChanged(_ sender: Any)
    {
        let NewQuality = QualitySegment.selectedSegmentIndex
        DoHandleQualityChanged(NewQuality)
        Settings.SetInteger(NewQuality, ForKey: .InputQuality)
    }
    
    func DoShowFOVDescription(ForFOV: String)
    {
        switch ForFOV
        {
            case "Narrowest":
                FOVDescription.text = "Very narrow view. Sets the field of view to 60°."
            
            case "Narrow":
                FOVDescription.text = "Narrow view. Sets the field of view to 90°."
            
            case "Normal":
                FOVDescription.text = "Normal view. Sets the field of view to 120°."
            
            case "Wide":
                FOVDescription.text = "Wide view. Sets the field of view to 160°."
            
            case "Widest":
                FOVDescription.text = "Very wide view. Sets the field of view to 180°."
            
            default:
                FOVDescription.text = ""
        }
    }
    
    let FOVMap =
        [
            "Narrowest": 0,
            "Narrow": 1,
            "Normal": 2,
            "Wide": 3,
            "Widest": 4
    ]
    
    @IBAction func HandleFOVChanged(_ sender: Any)
    {
        let Index = FOVSegment.selectedSegmentIndex
        for (Name, index) in FOVMap
        {
            if index == Index
            {
                Settings.SetString(Name, ForKey: .FieldOfView)
                DoShowFOVDescription(ForFOV: Name)
                return
            }
        }
    }
    
    @IBOutlet weak var FOVSegment: UISegmentedControl!
    @IBOutlet weak var FOVDescription: UILabel!
    @IBOutlet weak var ConstraintDescription: UILabel!
    @IBOutlet weak var QualitySegment: UISegmentedControl!
    @IBOutlet weak var QualityDetails: UILabel!
    @IBOutlet weak var ConstraintSegment: UISegmentedControl!
}
