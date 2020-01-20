//
//  CappedLineOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CappedLineOptionsCode: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let RawLocation = Settings.GetString(ForKey: .CappedLineBallLocation)
        {
            if let Location = BallLocations(rawValue: RawLocation)
            {
                switch Location
                {
                    case .Bottom:
                        LocationSegment.selectedSegmentIndex = 0
                    
                    case .Middle:
                        LocationSegment.selectedSegmentIndex = 1
                    
                    case .Top:
                        LocationSegment.selectedSegmentIndex = 2
                }
            }
            else
            {
                LocationSegment.selectedSegmentIndex = 2
                Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
            }
        }
        else
        {
            LocationSegment.selectedSegmentIndex = 2
            Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
        }
    }
    
    @IBAction func HandleLocationChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetString(BallLocations.Bottom.rawValue, ForKey: .CappedLineBallLocation)
                
                case 1:
                    Settings.SetString(BallLocations.Middle.rawValue, ForKey: .CappedLineBallLocation)
                
                case 2:
                    Settings.SetString(BallLocations.Top.rawValue, ForKey: .CappedLineBallLocation)
                
                default:
                    Crash.ShowCrashAlert(WithController: self, "Error", "Received out-of-range segment value. BlockCam will close.")
                    Log.AbortMessage("Received out-of-range segment value: \(Segment.selectedSegmentIndex)", FileName: #file,
                                     FunctionName: #function)
                    {
                        Message in
                        fatalError(Message)
                }
            }
        }
    }
    
    @IBOutlet weak var LocationSegment: UISegmentedControl!
}
