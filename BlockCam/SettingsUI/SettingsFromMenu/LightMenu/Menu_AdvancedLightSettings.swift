//
//  Menu_AdvancedLightSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_AdvancedLightSettings: UITableViewController
{
    #if false
    weak var Delegate: SomethingChangedProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SampleView.layer.borderColor = UIColor.black.cgColor
        if let ModelType = Settings.GetString(ForKey: .LightingModel)
        {
            var Index = 3
            OriginalModel = ModelType
            switch ModelType
            {
                case MaterialLightingTypes.Blinn.rawValue:
                    Index = 0
                
                case MaterialLightingTypes.Constant.rawValue:
                    Index = 1
                
                case MaterialLightingTypes.Lambert.rawValue:
                    Index = 2
                
                case MaterialLightingTypes.Phong.rawValue:
                    Index = 3
                
                case MaterialLightingTypes.PhysicallyBased.rawValue:
                    Index = 4
                
                default:
                    break
            }
            ColorModel.selectedSegmentIndex = Index
        }
        else
        {
            ColorModel.selectedSegmentIndex = 3
            Settings.SetString(MaterialLightingTypes.Phong.rawValue, ForKey: .LightingModel)
        }
        UpdateSample()
    }
    
    var OriginalModel: String = ""
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if SomeSettingChanged
        {
            Delegate?.SomethingChanged()
        }
        super.viewWillAppear(animated)
    }
    
    var SomeSettingChanged = false
    
    let ColorTable: [ColorData] =
        [
            ColorData("Black", UIColor.black),
            ColorData("White", UIColor.white),
            ColorData("Red", UIColor.red),
            ColorData("Green", UIColor.green),
            ColorData("Blue", UIColor.blue),
            ColorData("Cyan", UIColor.cyan),
            ColorData("Magenta", UIColor.magenta),
            ColorData("Yellow", UIColor.yellow),
            ColorData("Gray", UIColor.gray)
    ]

    @IBAction func HandleHandleModelChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.LightingModel)
            var Model = "Phong"
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Model = MaterialLightingTypes.Blinn.rawValue
                
                case 1:
                    Model = MaterialLightingTypes.Constant.rawValue
                
                case 2:
                    Model = MaterialLightingTypes.Lambert.rawValue
                
                case 3:
                    Model = MaterialLightingTypes.Phong.rawValue
                
                case 4:
                    Model = MaterialLightingTypes.PhysicallyBased.rawValue
                
                default:
                    break
            }
            SomeSettingChanged = OriginalModel != Model
            Settings.SetString(Model, ForKey: SettingKeys.LightingModel)
            UpdateSample()
        }
    }
    
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
        
        if let RawIntensity = Settings.GetString(ForKey: .LightIntensity)
        {
            switch RawIntensity
            {
                case "Darkest":
                    Light.intensity = 500
                
                case "Dim":
                    Light.intensity = 750
                
                case "Normal":
                    Light.intensity = 1000
                
                case "Bright":
                    Light.intensity = 1500
                
                case "Brightest":
                    Light.intensity = 2000
                
                default:
                    Light.intensity = 1000
                    Settings.SetString("Normal", ForKey: .LightIntensity)
            }
        }
        else
        {
            Light.intensity = 1000
            Settings.SetString("Normal", ForKey: .LightIntensity)
        }
        
        if let RawType = Settings.GetString(ForKey: .LightType)
        {
            switch RawType
            {
                case "Omni":
                    Light.type = .omni
                
                case "Ambient":
                    Light.type = .ambient
                
                case "Directional":
                    Light.type = .directional
                
                case "Spot":
                    Light.type = .spot
                
                default:
                    Light.type = .omni
                    Settings.SetString("Omni", ForKey: .LightType)
            }
        }
        else
        {
            Light.type = .omni
            Settings.SetString("Omni", ForKey: .LightType)
        }
        
        var LightModel = SCNMaterial.LightingModel.phong
        if let RawModel = Settings.GetString(ForKey: .LightingModel)
        {
            switch RawModel
            {
                case "Blinn":
                    LightModel = .blinn
                
                case "Constant":
                    LightModel = .constant
                
                case "Lambert":
                    LightModel = .lambert
                
                case "Phong":
                    LightModel = .phong
                
                case "PhysicallyBased":
                    LightModel = .physicallyBased
                
                default:
                    LightModel = .phong
                    Settings.SetString("Phong", ForKey: .LightingModel)
            }
        }
        else
        {
            LightModel = .phong
            Settings.SetString("Phong", ForKey: .LightingModel)
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
        
        let Shape1 = SCNCylinder(radius: 1.0, height: 5.0)
        Shape1.firstMaterial?.lightingModel = LightModel
        Shape1.firstMaterial?.diffuse.contents = UIColor.systemOrange
        Shape1.firstMaterial?.specular.contents = UIColor.white
        let Node1 = SCNNode(geometry: Shape1)
        Node1.name = "DisplayNode"
        let Shape2 = SCNSphere(radius: 1.5)
        Shape2.firstMaterial?.lightingModel = LightModel
        Shape2.firstMaterial?.diffuse.contents = UIColor.systemYellow
        Shape2.firstMaterial?.specular.contents = UIColor.white
        let Node2 = SCNNode(geometry: Shape2)
        Node2.name = "DisplayNode"
        let Shape3 = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.05)
        Shape3.firstMaterial?.lightingModel = LightModel
        Shape3.firstMaterial?.diffuse.contents = UIColor.systemGreen
        Shape3.firstMaterial?.specular.contents = UIColor.white
        let Node3 = SCNNode(geometry: Shape3)
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
    
    var UpdateInitialized = false
    
        @IBOutlet weak var SampleView: SCNView!
        @IBOutlet weak var ColorModel: UISegmentedControl!
#endif
}
