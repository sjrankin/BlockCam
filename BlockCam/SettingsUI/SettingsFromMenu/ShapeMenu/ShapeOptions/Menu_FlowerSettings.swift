//
//  Menu_FlowerSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_FlowerSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var PetalCount = Settings.GetInteger(ForKey: .FlowerPetalCount)
        if PetalCount < 4
        {
            PetalCount = 4
        }
        if PetalCount > 8
        {
            PetalCount = 8
        }
        Settings.SetInteger(PetalCount, ForKey: .FlowerPetalCount)
        PetalCountSelector.selectedSegmentIndex = PetalCount - 4
        PetalCountVariesSwitch.isOn = Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence)
        IntensitySlider.value = 50.0
        IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence)
        UpdateSample(WithIntensity: 1.0)
    }
    
    var SampleInitialized = false
    
    func UpdateSample(WithIntensity: Float)
    {
        if !SampleInitialized
        {
            FlowerSample.layer.borderColor = UIColor.black.cgColor
            FlowerSample.scene = SCNScene()
            FlowerSample.scene?.background.contents = UIColor.black
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            Camera.zFar = 1000
            Camera.zNear = 0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(0.0, 0.0, 5.0)
            let Light = SCNLight()
            Light.type = .omni
            Light.color = UIColor.white
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-3.0, 3.0, 6.0)
            FlowerSample.scene?.rootNode.addChildNode(CameraNode)
            FlowerSample.scene?.rootNode.addChildNode(LightNode)
            #if false
            FlowerSample.allowsCameraControl = true
            FlowerSample.debugOptions = [.showBoundingBoxes]
            #endif
            SampleInitialized = true
        }
        FlowerSample.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node.name == "Flower"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
        }
        var PetalCount = Settings.GetInteger(ForKey: .FlowerPetalCount)
        IntensityLabel.text = ""
        if Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence)
        {
            PetalCount = PetalCount + Int(WithIntensity * 1.3)
            IntensityLabel.text = Utilities.RoundedString(Value: Double(WithIntensity), Precision: 2)
        }
        let SmallExtent = min(FlowerSample.frame.width, FlowerSample.frame.height)
        let FlowerGeometry = SCNFlower2.Geometry(InteriorRadius: 2.0, PetalRadius: 1.2,
                                                 PetalCount: PetalCount, Extrusion: 0.5)
        FlowerGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
        FlowerGeometry.firstMaterial?.specular.contents = UIColor.blue
        Flower = SCNNode(geometry: FlowerGeometry)
        Flower.scale = SCNFlower2.ReciprocalScale()
        Flower.name = "Flower"
        Flower.position = SCNVector3(0.0, 0.0, 0.0)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -CGFloat.pi / 180.0, duration: 0.1)
        let Forever = SCNAction.repeatForever(Rotate)
        Flower.runAction(Forever)
        FlowerSample.scene?.rootNode.addChildNode(Flower)
    }
    
    var Flower: SCNNode!
    
    @IBAction func HandlePetalCountChanged(_ sender: Any)
    {
        if let Segments = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.FlowerPetalCount)
            Settings.SetInteger(Segments.selectedSegmentIndex + 4, ForKey: .FlowerPetalCount)
            UpdateSample(WithIntensity: IntensitySlider.value / 100.0)
        }
    }
    
    @IBAction func HandleIntensityValueChanged(_ sender: Any)
    {
        if let Slider = sender as? UISlider
        {
            let Intensity = Slider.value / 100.0
            UpdateSample(WithIntensity: Intensity)
        }
    }
    
    @IBAction func HandlePetalCountIntensitySwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.IncreasePetalCountWithProminence)
            Settings.SetBoolean(Switch.isOn, ForKey: .IncreasePetalCountWithProminence)
            IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence)
            UpdateSample(WithIntensity: IntensitySlider.value / 100.0)
        }
    }
    
    @IBOutlet weak var IntensityLabel: UILabel!
    @IBOutlet weak var PetalCountSelector: UISegmentedControl!
    @IBOutlet weak var IntensitySlider: UISlider!
    @IBOutlet weak var PetalCountVariesSwitch: UISwitch!
    @IBOutlet weak var FlowerSample: SCNView!
}
