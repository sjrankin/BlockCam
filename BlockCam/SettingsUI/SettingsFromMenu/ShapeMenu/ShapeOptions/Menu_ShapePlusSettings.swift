//
//  Menu_ShapePlusSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_ShapePlusSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource 
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeList.layer.borderColor = UIColor.black.cgColor
        if let Shape = PlusShape
        {
            self.title = "\(Shape.rawValue) Options"
            var CurrentExtrudedShape = NodeShapes.Cones
            switch Shape
            {
                case .SpherePlus:
                    ExtraShapes = ShapeManager.GetValidSpherePlusShapes()
                    CurrentExtrudedShape = Settings.GetEnum(ForKey: .SpherePlusShape, EnumType: NodeShapes.self,
                                                            Default: .Blocks)
                
                case .BoxPlus:
                    ExtraShapes = ShapeManager.GetValidBoxPlusShapes()
                    CurrentExtrudedShape = Settings.GetEnum(ForKey: .BoxPlusShape, EnumType: NodeShapes.self,
                                                            Default: .SpherePlus)
                
                default:
                    fatalError("Invalid shape (\(Shape.rawValue)) in Menu_ShapePlusSettings")
            }
            ShapeList.reloadAllComponents()
            if let Index = ExtraShapes.firstIndex(of: CurrentExtrudedShape)
            {
                ShapeList.selectRow(Index, inComponent: 0, animated: true)
            }
        }
    }
    
    var ExtraShapes = [NodeShapes]()
    var PlusShape: NodeShapes? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ExtraShapes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ExtraShapes[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Shape = ExtraShapes[row]
        print("Selected extruded shape \(Shape.rawValue)")
        switch PlusShape!
        {
            case .SpherePlus:
                Settings.SetEnum(Shape, EnumType: NodeShapes.self, ForKey: .SpherePlusShape)
                Menu_ChangeManager.AddChanged(.SpherePlusShape)
            
            case .BoxPlus:
                Settings.SetEnum(Shape, EnumType: NodeShapes.self, ForKey: .BoxPlusShape)
                Menu_ChangeManager.AddChanged(.BoxPlusShape)
            
            default:
            return
        }
    }

    @IBOutlet weak var ShapeList: UIPickerView!
}
