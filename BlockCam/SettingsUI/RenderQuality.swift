//
//  RenderQuality.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RenderQuality: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var QLevel = Settings.GetInteger(ForKey: .AntialiasingMode)
        if QLevel > 2
        {
            QLevel = 2
            Settings.SetInteger(2, ForKey: .AntialiasingMode)
        }
        QualitySegment.selectedSegmentIndex = QLevel
        let APIIndex = Settings.GetBoolean(ForKey: .UseMetal) ? 1 : 0
        APISegment.selectedSegmentIndex = APIIndex
    }
    
    @IBAction func HandleQualityChanged(_ sender: Any)
    {
        Settings.SetInteger(QualitySegment.selectedSegmentIndex, ForKey: .AntialiasingMode)
    }
    
    @IBAction func HandleAPISegmentChanged(_ sender: Any)
    {
        let UseMetal = APISegment.selectedSegmentIndex == 1 ? true : false
        Settings.SetBoolean(UseMetal, ForKey: .UseMetal)
    }
    
    @IBOutlet weak var APISegment: UISegmentedControl!
    @IBOutlet weak var QualitySegment: UISegmentedControl!
}
