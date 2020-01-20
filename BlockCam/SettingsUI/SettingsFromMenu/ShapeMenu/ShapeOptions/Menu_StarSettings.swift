//
//  Menu_StarSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_StarSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
        if ApexCount < 4
        {
            ApexCount = 4
            Settings.SetInteger(4, ForKey: .StarApexCount)
        }
        if ApexCount > 10
        {
            ApexCount = 10
            Settings.SetInteger(10, ForKey: .StarApexCount)
        }
        StarApexSegment.selectedSegmentIndex = ApexCount - 4
        StarApexCountVariesSwitch.isOn = Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
        IntensitySlider.value = 50.0
        IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
        UpdateSample(WithIntensity: 1.0)
    }
    
    var SampleInitialized = false
    
    func UpdateSample(WithIntensity: Float)
    {
        if !SampleInitialized
        {
            StarSample.layer.borderColor = UIColor.black.cgColor
            StarSample.scene = SCNScene()
            StarSample.scene?.background.contents = UIColor.black
            let Camera = SCNCamera()
            Camera.fieldOfView = 90.0
            let CameraNode = SCNNode()
            CameraNode.camera = Camera
            CameraNode.position = SCNVector3(0.0, 0.0, 5.0)
            let Light = SCNLight()
            Light.type = .omni
            Light.color = UIColor.white
            let LightNode = SCNNode()
            LightNode.light = Light
            LightNode.position = SCNVector3(-3.0, 3.0, 6.0)
            StarSample.scene?.rootNode.addChildNode(CameraNode)
            StarSample.scene?.rootNode.addChildNode(LightNode)
            SampleInitialized = true
        }
        StarSample.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node.name == "Star"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
        }
        var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
        IntensityLabel.text = ""
        if Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
        {
            ApexCount = ApexCount + Int(WithIntensity * 1.3)
            IntensityLabel.text = Utilities.RoundedString(Value: Double(WithIntensity), Precision: 2)
        }
        let StarGeometry = SCNStar.Geometry(VertexCount: ApexCount,
                                            Height: 3.5, Base: 1.75, ZHeight: 1.5)
        StarGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
        StarGeometry.firstMaterial?.specular.contents = UIColor.blue
        Star = SCNNode(geometry: StarGeometry)
        Star.name = "Star"
        Star.position = SCNVector3(0.0, 0.0, 0.0)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -CGFloat.pi / 180.0, duration: 0.1)
        let Forever = SCNAction.repeatForever(Rotate)
        Star.runAction(Forever)
        StarSample.scene?.rootNode.addChildNode(Star)
    }
    
    var Star: SCNNode!
    
    @IBAction func HandleStarApexCountChanged(_ sender: Any)
    {
        if let Segments = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.StarApexCount)
            Settings.SetInteger(Segments.selectedSegmentIndex + 4, ForKey: .StarApexCount)
            UpdateSample(WithIntensity: IntensitySlider.value / 100.0)
        }
    }
    
    @IBAction func HandleStarApexCountVariesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.IncreaseStarApexesWithProminence)
            Settings.SetBoolean(Switch.isOn, ForKey: .IncreaseStarApexesWithProminence)
            IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
            UpdateSample(WithIntensity: IntensitySlider.value / 100.0)
        }
    }
    
    @IBAction func HandleIntensityChanged(_ sender: Any)
    {
        if let Slider = sender as? UISlider
        {
            let Intensity = Slider.value / 100.0
            UpdateSample(WithIntensity: Intensity)
        }
    }
    
    @IBOutlet weak var IntensityLabel: UILabel!
    @IBOutlet weak var IntensitySlider: UISlider!
    @IBOutlet weak var StarApexCountVariesSwitch: UISwitch!
    @IBOutlet weak var StarApexSegment: UISegmentedControl!
    @IBOutlet weak var StarSample: SCNView!
}
