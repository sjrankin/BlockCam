//
//  MeshOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MeshOptionsCode: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let MeshThickness = Settings.GetString(ForKey: .MeshLineThickness)
        {
            switch MeshThickness
            {
                case MeshLineThicknesses.Thin.rawValue:
                    ThicknessSelector.selectedSegmentIndex = 0
                
                case MeshLineThicknesses.Medium.rawValue:
                    ThicknessSelector.selectedSegmentIndex = 1
                
                case MeshLineThicknesses.Thick.rawValue:
                    ThicknessSelector.selectedSegmentIndex = 2
                
                default:
                    Settings.SetString(MeshLineThicknesses.Medium.rawValue, ForKey: .MeshLineThickness)
                    ThicknessSelector.selectedSegmentIndex = 1
            }
        }
        else
        {
            Settings.SetString(MeshLineThicknesses.Medium.rawValue, ForKey: .MeshLineThickness)
            ThicknessSelector.selectedSegmentIndex = 1
        }
        if let BallRadius = Settings.GetString(ForKey: .MeshDotSize)
        {
            switch BallRadius
            {
                case MeshDotSizes.None.rawValue:
                    DotSizeSelector.selectedSegmentIndex = 0
                
                case MeshDotSizes.Small.rawValue:
                    DotSizeSelector.selectedSegmentIndex = 1
                
                case MeshDotSizes.Medium.rawValue:
                    DotSizeSelector.selectedSegmentIndex = 2
                
                case MeshDotSizes.Large.rawValue:
                    DotSizeSelector.selectedSegmentIndex = 3
                
                default:
                    Settings.SetString(MeshDotSizes.Medium.rawValue, ForKey: .MeshDotSize)
                    DotSizeSelector.selectedSegmentIndex = 2
            }
        }
        else
        {
            Settings.SetString(MeshDotSizes.Medium.rawValue, ForKey: .MeshDotSize)
            DotSizeSelector.selectedSegmentIndex = 2
        }
    }
    
    @IBAction func HandleThicknessChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString(MeshLineThicknesses.Thin.rawValue, ForKey: .MeshLineThickness)
                
                case 1:
                    Settings.SetString(MeshLineThicknesses.Medium.rawValue, ForKey: .MeshLineThickness)
                
                case 2:
                    Settings.SetString(MeshLineThicknesses.Thick.rawValue, ForKey: .MeshLineThickness)
                
                default:
                    Settings.SetString(MeshLineThicknesses.Medium.rawValue, ForKey: .MeshLineThickness)
            }
        }
    }
    
    @IBAction func HandleDotSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString(MeshDotSizes.None.rawValue, ForKey: .MeshDotSize)
                
                case 1:
                    Settings.SetString(MeshDotSizes.Small.rawValue, ForKey: .MeshDotSize)
                
                case 2:
                    Settings.SetString(MeshDotSizes.Medium.rawValue, ForKey: .MeshDotSize)
                
                case 3:
                    Settings.SetString(MeshDotSizes.Large.rawValue, ForKey: .MeshDotSize)
                
                default:
                    Settings.SetString(MeshDotSizes.Medium.rawValue, ForKey: .MeshDotSize)
            }
        }
    }
    
    @IBOutlet weak var DotSizeSelector: UISegmentedControl!
    @IBOutlet weak var ThicknessSelector: UISegmentedControl!
}
