//
//  Menu_Materials.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_Materials: UITableViewController
{
    public weak var Delegate: SomethingChangedProtocol? = nil
    
    var SomethingChanged = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch Settings.GetEnum(ForKey: .Metalness, EnumType: Metalnesses.self, Default: .Medium)
        {
            case .Least:
                MetalSegment.selectedSegmentIndex = 0
            
            case .NotMuch:
                MetalSegment.selectedSegmentIndex = 1
            
            case .Medium:
                MetalSegment.selectedSegmentIndex = 2
            
            case .ALot:
                MetalSegment.selectedSegmentIndex = 3
            
            case .Most:
                MetalSegment.selectedSegmentIndex = 4
        }
        switch Settings.GetEnum(ForKey: .MaterialRoughness, EnumType: MaterialRoughnesses.self,
                                Default: .Medium)
        {
            case .Roughest:
                RoughSegment.selectedSegmentIndex = 0
            
            case .Rough:
                RoughSegment.selectedSegmentIndex = 1
            
            case .Medium:
                RoughSegment.selectedSegmentIndex = 2
            
            case .Smooth:
                RoughSegment.selectedSegmentIndex = 3
            
            case .Smoothest:
                RoughSegment.selectedSegmentIndex = 4
        }
        EnableMaterialsSwitch.isOn = Settings.GetBoolean(ForKey: .EnableMaterials)
    }
    
    @IBAction func HandleEnableMaterialsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableMaterials)
            Menu_ChangeManager.AddChanged(.EnableMaterials)
            SomethingChanged = true
        }
    }
    
    @IBAction func HandleRoughChanged(_ sender: Any)
    {
        switch RoughSegment.selectedSegmentIndex
        {
            case 0:
                Settings.SetEnum(.Roughest, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 1:
                Settings.SetEnum(.Rough, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 2:
                Settings.SetEnum(.Medium, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 3:
                Settings.SetEnum(.Smooth, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            case 4:
                Settings.SetEnum(.Smoothest, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
            
            default:
                Settings.SetEnum(.Medium, EnumType: MaterialRoughnesses.self, ForKey: .MaterialRoughness)
        }
        Menu_ChangeManager.AddChanged(.MaterialRoughness)
        SomethingChanged = true
    }
    
    @IBAction func HandleMetalChanged(_ sender: Any)
    {
        switch MetalSegment.selectedSegmentIndex
        {
            case 0:
                Settings.SetEnum(.Least, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 1:
                Settings.SetEnum(.NotMuch, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 2:
                Settings.SetEnum(.Medium, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 3:
                Settings.SetEnum(.ALot, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            case 4:
                Settings.SetEnum(.Most, EnumType: Metalnesses.self, ForKey: .Metalness)
            
            default:
                Settings.SetEnum(.Medium, EnumType: Metalnesses.self, ForKey: .Metalness)
        }
        Menu_ChangeManager.AddChanged(.Metalness)
        SomethingChanged = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if SomethingChanged
        {
            Delegate?.SomethingChanged()
        }
        super.viewWillDisappear(true)
    }
    
    @IBOutlet weak var RoughSegment: UISegmentedControl!
    @IBOutlet weak var MetalSegment: UISegmentedControl!
    @IBOutlet weak var EnableMaterialsSwitch: UISwitch!
}
