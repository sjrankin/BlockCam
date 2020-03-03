//
//  AboutBlockCam.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class AboutBlockCam: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        VersionLabel.text = Versioning.MakeVersionBlock()
        Show3DTitle()
    }
    
    func Show3DTitle(AnimateTime: Double = 2.0)
    {
        let ParentWidth = view.frame.width
        let ParentHeight = view.frame.height
        let TitleWidth = ParentWidth * 0.75
        let TitleHeight = ParentHeight * 0.2
        let TitleCenter = CGPoint(x: TitleWidth / 2,
                              y: ParentHeight * 0.33 - (TitleHeight / 2))
        BlockCam3DTitle.clipsToBounds = true
        BlockCam3DTitle.scene = SCNScene()
        BlockCam3DTitle.scene?.background.contents = UIColor.black
        
        let TitleCamera = SCNCamera()
        TitleCamera.fieldOfView = 90.0
        let CameraNode = SCNNode()
        CameraNode.camera = TitleCamera
        //Depending on the device, the width of the scene is narrow or wide. For narrow devices, position
        //the camera higher.
        let ZLocation = UIDevice.current.userInterfaceIdiom == .pad ? 10.0 : 15.0
        CameraNode.position = SCNVector3(0.0, 0.0, ZLocation)
        BlockCam3DTitle.scene?.rootNode.addChildNode(CameraNode)
        let TitleLight = SCNLight()
        TitleLight.type = .omni
        TitleLight.color = UIColor.white
        TitleLight.castsShadow = true
        TitleLight.shadowRadius = 10.0
        TitleLight.shadowColor = UIColor.black.withAlphaComponent(0.8)
        TitleLight.shadowMode = .forward
        let LightNode = SCNNode()
        LightNode.light = TitleLight
        LightNode.position = SCNVector3(-10.0, 5.0, 10.0)
        let RLightNode = SCNNode()
        RLightNode.addChildNode(LightNode)
        BlockCam3DTitle.scene?.rootNode.addChildNode(RLightNode)
        
        let TextNode = SCNText(string: "BlockCam", extrusionDepth: 2.0)
        TextNode.flatness = 0.0
        TextNode.font = UIFont.boldSystemFont(ofSize: 40.0)
        TextNode.firstMaterial?.specular.contents = UIColor.white
        TextNode.firstMaterial?.diffuse.contents = UIColor.systemYellow
        TextNode.firstMaterial?.lightingModel = .blinn
        let TitleNode = SCNNode(geometry: TextNode)
        TitleNode.castsShadow = true
        let (MinTextBox, MaxTextBox) = TitleNode.boundingBox
        let TextWidth = MaxTextBox.x - MinTextBox.x
        TitleNode.position = SCNVector3(0.0, -10.0, 0.0)
        TitleNode.pivot = SCNMatrix4MakeTranslation(TextWidth / 2, 0, 0)
        TitleNode.scale = SCNVector3(0.4, 0.4, 0.4)
        BlockCam3DTitle.scene?.rootNode.addChildNode(TitleNode)
        
        let ExAnim = CABasicAnimation(keyPath: "geometry.extrusionDepth")
        ExAnim.isRemovedOnCompletion = false
        ExAnim.fillMode = .forwards
        ExAnim.fromValue = 2.0
        ExAnim.toValue = 0.0
        ExAnim.duration = AnimateTime
        ExAnim.autoreverses = true
        ExAnim.repeatCount = Float.greatestFiniteMagnitude
        TitleNode.addAnimation(ExAnim, forKey: "extrude")
        
        let RotateLight = SCNAction.rotate(by: CGFloat.pi / 180.0, around: SCNVector3(0.0, 0.0, 1.0), duration: 0.05)
        let RotateForever = SCNAction.repeatForever(RotateLight)
        RLightNode.runAction(RotateForever)
    }
    
    
    @IBAction func HandleDoneButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var VersionLabel: UILabel!
    @IBOutlet weak var BlockCam3DTitle: SCNView!
}
