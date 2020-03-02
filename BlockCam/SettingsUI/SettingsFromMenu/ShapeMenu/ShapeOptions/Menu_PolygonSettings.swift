//
//  Menu_PolygonSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Menu_PolygonSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
        if SideCount < 3
        {
            SideCount = 3
            Settings.SetInteger(4, ForKey: .PolygonSideCount)
        }
        if SideCount > 12
        {
            SideCount = 12
            Settings.SetInteger(12, ForKey: .PolygonSideCount)
        }
        SideSegment.selectedSegmentIndex = SideCount - 3
        SideCountVariesSwitch.isOn = Settings.GetBoolean(ForKey: .PolygonSideCountVaries)
        IntensitySlider.value = 50.0
        IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .PolygonSideCountVaries)
        UpdateSample(WithIntensity: 1.0)
    }
    
    var SampleInitialized = false
    
    func UpdateSample(WithIntensity: Float)
    {
        if !SampleInitialized
        {
            PolygonSample.layer.borderColor = UIColor.black.cgColor
            PolygonSample.scene = SCNScene()
            PolygonSample.scene?.background.contents = UIColor.black
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
            PolygonSample.scene?.rootNode.addChildNode(CameraNode)
            PolygonSample.scene?.rootNode.addChildNode(LightNode)
            SampleInitialized = true
        }
        PolygonSample.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node.name == "Polygon"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
        }
        var SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
        IntensityLabel.text = ""
        if Settings.GetBoolean(ForKey: .PolygonSideCountVaries)
        {
            SideCount = SideCount + Int(WithIntensity * 1.3)
            IntensityLabel.text = Utilities.RoundedString(Value: Double(WithIntensity), Precision: 2)
        }
        let Geometry = SCNnGon.Geometry(VertexCount: SideCount, Radius: 3.5, Depth: 1.5)
        Geometry.firstMaterial?.diffuse.contents = UIColor.cyan
        Geometry.firstMaterial?.specular.contents = UIColor.blue
        Node = SCNNode(geometry: Geometry)
        Node.name = "Polygon"
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -CGFloat.pi / 180.0, duration: 0.1)
        let Forever = SCNAction.repeatForever(Rotate)
        Node.runAction(Forever)
        PolygonSample.scene?.rootNode.addChildNode(Node)
    }
    
    var Node: SCNNode!
    
    @IBAction func HandleSideCountChanged(_ sender: Any)
    {
        if let Segments = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.PolygonSideCount)
            Settings.SetInteger(Segments.selectedSegmentIndex + 3, ForKey: .PolygonSideCount)
            UpdateSample(WithIntensity: IntensitySlider.value / 100.0)
        }
    }
    
    @IBAction func HandleSideCountVariesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.PolygonSideCountVaries)
            Settings.SetBoolean(Switch.isOn, ForKey: .PolygonSideCountVaries)
            IntensitySlider.isEnabled = Settings.GetBoolean(ForKey: .PolygonSideCountVaries)
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
    @IBOutlet weak var SideCountVariesSwitch: UISwitch!
    @IBOutlet weak var SideSegment: UISegmentedControl!
    @IBOutlet weak var PolygonSample: SCNView!
}
