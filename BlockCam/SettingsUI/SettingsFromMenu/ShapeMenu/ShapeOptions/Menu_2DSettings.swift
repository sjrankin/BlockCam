//
//  Menu_2DSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_2DSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let Shape = TwoDShape
        {
            ShapeName2D.text = Shape.rawValue
            let Key = GetAxisKey(Shape)
            let Axis = Settings.GetEnum(ForKey: Key, EnumType: Axes.self, Default: .X)
            switch Axis
            {
                case .X:
                    AxisSegment.selectedSegmentIndex = 0
                
                case .Y:
                    AxisSegment.selectedSegmentIndex = 1
                
                case .Z:
                    AxisSegment.selectedSegmentIndex = 2
            }
        }
    }
    
    func GetAxisKey(_ Shape: NodeShapes) -> SettingKeys
    {
        var Key = SettingKeys.Polygon2DAxis
        switch Shape
        {
            case .Polygon2D:
                Key = .Polygon2DAxis
            
            case .Rectangle2D:
                Key = .Rectangle2DAxis
            
            case .Circle2D:
                Key = .Circle2DAxis
            
            case .Oval2D:
                Key = .Oval2DAxis
            
            case .Star2D:
                Key = .Star2DAxis
            
            case .Diamond2D:
                Key = .Diamond2DAxis
            
            default:
                fatalError("Found unexpected shape: \(Shape.rawValue)")
        }
        return Key
    }
    
    var TwoDShape: NodeShapes? = nil
    
    @IBAction func HandleBehaviorChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            if let Shape = TwoDShape
            {
                let Key = GetAxisKey(Shape)
                switch Segment.selectedSegmentIndex
                {
                    case 0:
                        Settings.SetEnum(.X, EnumType: Axes.self, ForKey: Key)
                    
                    case 1:
                        Settings.SetEnum(.Y, EnumType: Axes.self, ForKey: Key)
                    
                    case 2:
                        Settings.SetEnum(.Z, EnumType: Axes.self, ForKey: Key)
                    
                    default:
                        Settings.SetEnum(.X, EnumType: Axes.self, ForKey: Key)
                }
            }
        }
    }
    
    @IBOutlet weak var ShapeName2D: UILabel!
    @IBOutlet weak var AxisSegment: UISegmentedControl!
}
