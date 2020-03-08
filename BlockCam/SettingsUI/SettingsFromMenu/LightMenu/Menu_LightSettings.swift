//
//  Menu_LightSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_LightSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,
    SomethingChangedProtocol
{
    weak var Delegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Menu_ChangeManager.Clear()
        let LightColor = Settings.GetString(ForKey: .LightColor)
        var Index = 0
        var Found = false
        for SomeColor in ColorTable
        {
            if SomeColor.Name == LightColor
            {
                Found = true
                break
            }
            Index = Index + 1
        }
        if !Found
        {
            Index = 0
        }
        ColorListUI.reloadAllComponents()
        ColorListUI.selectRow(Index, inComponent: 0, animated: true)
        ColorListUI.layer.borderColor = UIColor.black.cgColor
        
        let LightType = Settings.GetEnum(ForKey: .LightType, EnumType: LightTypes.self, Default: .Omni)
        switch LightType
        {
            case .Ambient:
                LightTypeSegment.selectedSegmentIndex = 3
            
            case .Directional:
                LightTypeSegment.selectedSegmentIndex = 2
            
            case .Omni:
                LightTypeSegment.selectedSegmentIndex = 0
            
            case .Spot:
                LightTypeSegment.selectedSegmentIndex = 1
        }
        
        let LightIntensity = Settings.GetEnum(ForKey: .LightIntensity, EnumType: LightIntensities.self, Default: .Normal)
        switch LightIntensity
        {
            case .Darkest:
                LightIntensitySegment.selectedSegmentIndex = 0
            
            case .Dim:
                LightIntensitySegment.selectedSegmentIndex = 1
            
            case .Normal:
                LightIntensitySegment.selectedSegmentIndex = 2
            
            case .Bright:
                LightIntensitySegment.selectedSegmentIndex = 3
            
            case .Brightest:
                LightIntensitySegment.selectedSegmentIndex = 4
        }
        
        let Model = Settings.GetEnum(ForKey: .LightingModel, EnumType: MaterialLightingTypes.self,
                                     Default: .Lambert)
        switch Model
        {
            case .Blinn:
                ModelSegment.selectedSegmentIndex = 0
            
            case .Constant:
                ModelSegment.selectedSegmentIndex = 1
            
            case .Lambert:
                ModelSegment.selectedSegmentIndex = 2
            
            case .Phong:
                ModelSegment.selectedSegmentIndex = 3
            
            case .PhysicallyBased:
                ModelSegment.selectedSegmentIndex = 4
        }
        
        UpdateSample()
    }
    
    let LightTypeMap =
        [
            "Omni": 0,
            "Spot": 1,
            "Directional": 2,
            "Ambient": 3
    ]
    
    let LightIntensityMap =
        [
            "Darkest": 0,
            "Dim": 1,
            "Normal": 2,
            "Bright": 3,
            "Brightest": 4
    ]
    
    func DoShowLightTypeDescription(ForType: LightTypes)
    {
        switch ForType
        {
            case .Omni:
                LightTypeDescription.text = "Point light that shines in all directions."
            
            case .Ambient:
                LightTypeDescription.text = "Light that illuminates all sides of an object equally."
            
            case .Directional:
                LightTypeDescription.text = "Light that is aimed in one direction."
            
            case .Spot:
                LightTypeDescription.text = "Light that shines with a cone of illumination."
        }
    }
    
    @IBAction func HandleLightTypeChange(_ sender: Any)
    {
        let Index = LightTypeSegment.selectedSegmentIndex
        switch Index
        {
            case 0:
                Settings.SetEnum(.Omni, EnumType: LightTypes.self, ForKey: .LightType)
                DoShowLightTypeDescription(ForType: .Omni)
            
            case 1:
                Settings.SetEnum(.Spot, EnumType: LightTypes.self, ForKey: .LightType)
                DoShowLightTypeDescription(ForType: .Spot)
            
            case 2:
                Settings.SetEnum(.Directional, EnumType: LightTypes.self, ForKey: .LightType)
                DoShowLightTypeDescription(ForType: .Directional)
            
            case 3:
                Settings.SetEnum(.Ambient, EnumType: LightTypes.self, ForKey: .LightType)
                DoShowLightTypeDescription(ForType: .Ambient)
            
            default:
                Settings.SetEnum(.Omni, EnumType: LightTypes.self, ForKey: .LightType)
                DoShowLightTypeDescription(ForType: .Omni)
        }
        Menu_ChangeManager.AddChanged(.LightType)
        
        UpdateSample()
    }
    
    @IBAction func HandleLightIntensityChange(_ sender: Any)
    {
        let Index = LightIntensitySegment.selectedSegmentIndex
        switch Index
        {
            case 0:
                Settings.SetEnum(.Darkest, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 1:
                Settings.SetEnum(.Dim, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 2:
                Settings.SetEnum(.Normal, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 3:
                Settings.SetEnum(.Bright, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            case 4:
                Settings.SetEnum(.Brightest, EnumType: LightIntensities.self, ForKey: .LightIntensity)
            
            default:
                Settings.SetEnum(.Normal, EnumType: LightIntensities.self, ForKey: .LightIntensity)
        }
        
        Menu_ChangeManager.AddChanged(.LightIntensity)
        UpdateSample()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ColorTable.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        Menu_ChangeManager.AddChanged(.LightColor)
        let Color = ColorTable[row].Name
        Settings.SetString(Color, ForKey: .LightColor)
        UpdateSample()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ColorTable[row].Name
    }
    
    let ColorTable: [ColorDataM] =
        [
            ColorDataM("Black", UIColor.black),
            ColorDataM("White", UIColor.white),
            ColorDataM("Red", UIColor.red),
            ColorDataM("Green", UIColor.green),
            ColorDataM("Blue", UIColor.blue),
            ColorDataM("Cyan", UIColor.cyan),
            ColorDataM("Magenta", UIColor.magenta),
            ColorDataM("Yellow", UIColor.yellow),
            ColorDataM("Gray", UIColor.gray)
    ]
    
    let ChangeList: [SettingKeys] =
        [
            .LightingModel, .LightType, .LightColor, .LightIntensity, .EnableShadows
    ]
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            if Menu_ChangeManager.Contains(self.ChangeList)
            {
                self.Delegate?.Redraw3D(Menu_ChangeManager.AsArray)
            }
        }
    }
    
    /// Update the sample view that shows the user the effects of changing various lighting options.
    func UpdateSample()
    {
        if !UpdateInitialized
        {
            UpdateInitialized = true
            SampleView.scene = SCNScene()
            SampleView.scene?.background.contents = UIColor.black
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(0.0, 0.0, 8.0)
            SampleView.scene?.rootNode.addChildNode(CameraNode)
            SampleView.allowsCameraControl = true
            SampleView.showsStatistics = false
        }
        
        let Light = SCNLight()
        if let RawColor = Settings.GetString(ForKey: .LightColor)
        {
            var FoundColor = false
            for CData in ColorTable
            {
                if CData.Name == RawColor
                {
                    print("Found color: \(CData.Name)")
                    FoundColor = true
                    Light.color = CData.Color
                    break
                }
            }
            if !FoundColor
            {
                Light.color = UIColor.white
                Settings.SetString("White", ForKey: .LightColor)
            }
        }
        else
        {
            Light.color = UIColor.white
            Settings.SetString("White", ForKey: .LightColor)
        }
        if Settings.GetBoolean(ForKey: .EnableShadows)
        {
            Light.castsShadow = true
            Light.shadowColor = UIColor.black.withAlphaComponent(0.8)
            Light.shadowMode = .forward
            Light.shadowRadius = 10.0
        }
        else
        {
            Light.castsShadow = false
        }
        
        let Intensity = Settings.GetEnum(ForKey: .LightIntensity, EnumType: LightIntensities.self, Default: .Normal)
        switch Intensity
        {
            case .Darkest:
                Light.intensity = 500
            
            case .Dim:
                Light.intensity = 750
            
            case .Normal:
                Light.intensity = 1000
            
            case .Bright:
                Light.intensity = 1500
            
            case .Brightest:
                Light.intensity = 2000
        }
        
        let LightType = Settings.GetEnum(ForKey: .LightType, EnumType: LightTypes.self, Default: .Omni)
        switch LightType
        {
            case .Omni:
                Light.type = .omni
            
            case .Ambient:
                Light.type = .ambient
            
            case .Directional:
                Light.type = .directional
            
            case .Spot:
                Light.type = .spot
        }
        
        var LightModel = SCNMaterial.LightingModel.phong
        let Model = Settings.GetEnum(ForKey: .LightingModel, EnumType: MaterialLightingTypes.self,
                                     Default: .Lambert)
        switch Model
        {
            case .Blinn:
                LightModel = .blinn
            
            case .Constant:
                LightModel = .constant
            
            case .Lambert:
                LightModel = .lambert
            
            case .Phong:
                LightModel = .phong
            
            case .PhysicallyBased:
                LightModel = .physicallyBased
        }
        
        SampleView.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node.name == "DisplayNode" || Node.name == "LightNode"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
        }
        
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.name = "LightNode"
        LightNode.position = SCNVector3(-4.0, 3.0, 10.0)
        SampleView.scene?.rootNode.addChildNode(LightNode)
        
        var Rough: Double = 0.0
        var Metal: Double = 0.0
        if LightModel == .physicallyBased
        {
            switch Settings.GetEnum(ForKey: .Metalness, EnumType: Metalnesses.self, Default: .Medium)
            {
                case .Least:
                    Metal = 0.0
                
                case .NotMuch:
                    Metal = 0.25
                
                case .Medium:
                    Metal = 0.5
                
                case .ALot:
                    Metal = 0.75
                
                case .Most:
                    Metal = 1.0
            }
            switch Settings.GetEnum(ForKey: .MaterialRoughness, EnumType: MaterialRoughnesses.self, Default: .Medium)
            {
                case .Roughest:
                    Rough = 0.0
                
                case .Rough:
                    Rough = 0.25
                
                case .Medium:
                    Rough = 0.5
                
                case .Smooth:
                    Rough = 0.75
                
                case .Smoothest:
                    Rough = 1.0
            }
        }
        
        let Shape1 = SCNCylinder(radius: 1.0, height: 5.0)
        Shape1.firstMaterial?.lightingModel = LightModel
        Shape1.firstMaterial?.diffuse.contents = UIColor.systemOrange
        Shape1.firstMaterial?.specular.contents = UIColor.white
        if LightModel == .physicallyBased
        {
            Shape1.firstMaterial?.roughness.contents = NSNumber(value: Rough)
            Shape1.firstMaterial?.metalness.contents = NSNumber(value: Metal)
        }
        let Node1 = SCNNode(geometry: Shape1)
        Node1.castsShadow = Settings.GetBoolean(ForKey: .EnableShadows)
        Node1.name = "DisplayNode"
        let Shape2 = SCNSphere(radius: 1.5)
        Shape2.firstMaterial?.lightingModel = LightModel
        Shape2.firstMaterial?.diffuse.contents = UIColor.systemYellow
        Shape2.firstMaterial?.specular.contents = UIColor.white
        if LightModel == .physicallyBased
        {
            Shape2.firstMaterial?.roughness.contents = NSNumber(value: Rough)
            Shape2.firstMaterial?.metalness.contents = NSNumber(value: Metal)
        }
        let Node2 = SCNNode(geometry: Shape2)
        Node2.castsShadow = Settings.GetBoolean(ForKey: .EnableShadows)
        Node2.name = "DisplayNode"
        let Shape3 = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.05)
        Shape3.firstMaterial?.lightingModel = LightModel
        Shape3.firstMaterial?.diffuse.contents = UIColor.systemGreen
        Shape3.firstMaterial?.specular.contents = UIColor.white
        if LightModel == .physicallyBased
        {
            Shape3.firstMaterial?.roughness.contents = NSNumber(value: Rough)
            Shape3.firstMaterial?.metalness.contents = NSNumber(value: Metal)
        }
        let Node3 = SCNNode(geometry: Shape3)
        Node3.castsShadow = Settings.GetBoolean(ForKey: .EnableShadows)
        Node3.name = "DisplayNode"
        Node1.position = SCNVector3(0.0, 0.0, 0.0)
        Node2.position = SCNVector3(0.0, 2.5, 0.0)
        Node3.position = SCNVector3(0.0, -2.5, 0.0)
        let AllNodes = SCNNode()
        AllNodes.name = "DisplayNode"
        AllNodes.addChildNode(Node1)
        AllNodes.addChildNode(Node2)
        AllNodes.addChildNode(Node3)
        AllNodes.position = SCNVector3(0.0, 0.0, 0.0)
        SampleView.scene?.rootNode.addChildNode(AllNodes)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -CGFloat.pi / 180.0, duration: 0.04)
        let Forever = SCNAction.repeatForever(Rotate)
        AllNodes.runAction(Forever)
    }
    
    @IBAction func HandleModelChanged(_ sender: Any)
    {
        switch ModelSegment.selectedSegmentIndex
        {
            case 0:
                Settings.SetEnum(.Blinn, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
            
            case 1:
                Settings.SetEnum(.Constant, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
            
            case 2:
                Settings.SetEnum(.Lambert, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
            
            case 3:
                Settings.SetEnum(.Phong, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
            
            case 4:
                Settings.SetEnum(.PhysicallyBased, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
            
            default:
                Settings.SetEnum(.Lambert, EnumType: MaterialLightingTypes.self, ForKey: .LightingModel)
        }
        Menu_ChangeManager.AddChanged(.LightingModel)
        UpdateSample()
    }
    
    func SomethingChanged()
    {
        UpdateSample()
    }
    
    var UpdateInitialized = false
    
    @IBOutlet weak var ModelSegment: UISegmentedControl!
    @IBOutlet weak var SampleView: SCNView!
    @IBOutlet weak var ColorListUI: UIPickerView!
    @IBOutlet weak var LightTypeDescription: UILabel!
    @IBOutlet weak var LightIntensitySegment: UISegmentedControl!
    @IBOutlet weak var LightTypeSegment: UISegmentedControl!
}

class ColorDataM
{
    init(_ Name: String, _ Color: UIColor)
    {
        self.Name = Name
        self.Color = Color
        self.IsSelected = false
    }
    
    init(_ Name: String, _ Color: UIColor, _ IsSelected: Bool)
    {
        self.Name = Name
        self.Color = Color
        self.IsSelected = IsSelected
    }
    
    var Color: UIColor = UIColor.white
    var Name: String = "White"
    var IsSelected: Bool = false
}
