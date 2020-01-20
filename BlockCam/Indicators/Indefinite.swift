//
//  Indefinite.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// An indefinite progress indicator implmented with 3D objects.
class Indefinite: SCNView
{
    /// Initializer.
    /// - Parameter frame: The frame rectangle.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the indicator.
    private func Initialize()
    {
        self.scene = SCNScene()
        BackgroundColor = UIColor.systemYellow
        CreateNodes()
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        let CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 3.0)
        self.scene?.rootNode.addChildNode(CameraNode)
        let Light = SCNLight()
        Light.type = .spot
        Light.color = UIColor.white
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(-2.0, 2.0, 10.0)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    /// Plays the indefinite indicator.
    public func Play()
    {
        CreateNodes()
    }
    
    /// Remove the central node, which has all of the visible nodes as children. This has the effect of clearing the display.
    public func Clear()
    {
        self.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node.name == "MainNode"
                {
                    Node.removeFromParentNode()
                }
        }
        CenterNode?.removeAllActions()
    }
    
    /// Create the nodes based on the class' properties. Existing nodes are removed first.
    private func CreateNodes()
    {
        Clear()
        let Nodes = Int(360.0 / Double(NodeCount))
        CenterNode = SCNNode()
        CenterNode!.position = SCNVector3(0.0, 0.0, 0.0)
        CenterNode!.name = "MainNode"
        for Angle in stride(from: 0, to: 359, by: Nodes)
        {
            let Radians = Double(Angle) * Double.pi / 180.0
            let Radius = NodeDistance
            //let NodeShape = SCNNode2(geometry: SCNSphere(radius: CGFloat(NodeSize)))
            let Side = CGFloat(NodeSize)
            let NodeShape = SCNNode2(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: 0.01))
            NodeShape.Angle = Double(Angle)
            NodeShape.geometry?.firstMaterial?.diffuse.contents = NodeColor
            NodeShape.geometry?.firstMaterial?.specular.contents = UIColor.white
            let X = Radius * cos(Radians)
            let Y = Radius * sin(Radians)
            NodeShape.position = SCNVector3(X, Y, 0.0)
            CenterNode?.addChildNode(NodeShape)
            if NodesRotate
            {
                let Rotate = SCNAction.rotateBy(x: 0.5, y: 0.5, z: 1.0, duration: NodeRotationDuration)
                let Forever = SCNAction.repeatForever(Rotate)
                NodeShape.runAction(Forever)
            }
        }
        self.scene?.rootNode.addChildNode(CenterNode!)
        StartAnimation()
    }
    
    /// Start animating the nodes.
    private func StartAnimation()
    {
        CenterNode?.removeAllActions()
        let Orbit = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -1.0, duration: RotationDuration)
        let Forever = SCNAction.repeatForever(Orbit)
        CenterNode?.runAction(Forever)
    }
    
    /// The center node. This node has no primary visible geometries but is the parent for the visible nodes.
    private var CenterNode: SCNNode? = nil
    
    /// Holds the nodes rotate flag.
    private var _NodesRotate: Bool = true
    /// Get or set the nodes rotate flag.
    @IBInspectable public var NodesRotate: Bool
        {
        get
        {
            return _NodesRotate
        }
        set
        {
            _NodesRotate = newValue
            CreateNodes()
        }
    }
    
    /// Holds the duration of rotation for individual nodes.
    private var _NodeRotationDuration: Double = 1.0
    /// Get or set the duration of rotation for individual nodes.
    @IBInspectable public var NodeRotationDuration: Double
        {
        get
        {
            return _NodeRotationDuration
        }
        set
        {
            _NodeRotationDuration = newValue
            CreateNodes()
        }
    }
    
    /// Holds the scale value for the display.
    private var _Scale: Double = 1.0
    /// Get or set the scale value for the display.
    @IBInspectable public var Scale: Double
        {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            CenterNode?.scale = SCNVector3(_Scale, _Scale, _Scale)
        }
    }
    
    /// Holds the rotation duration.
    private var _RotationDuration: Double = 1.0
    /// Get or set the rotational duration for animating the nodes.
    @IBInspectable public var RotationDuration: Double
        {
        get
        {
            return _RotationDuration
        }
        set
        {
            _RotationDuration = newValue
            StartAnimation()
        }
    }
    
    /// Holds the size of the node.
    private var _NodeSize: Double = 0.5
    /// Get or set the size of the node.
    @IBInspectable public var NodeSize: Double
        {
        get
        {
            return _NodeSize
        }
        set
        {
            _NodeSize = newValue
            CreateNodes()
        }
    }
    
    /// Holds the radial distance of the node.
    private var _NodeDistance: Double = 2.0
    /// Get or set the radial distance of each node from the center of the display.
    @IBInspectable public var NodeDistance: Double
        {
        get
        {
            return _NodeDistance
        }
        set
        {
            _NodeDistance = newValue
            CreateNodes()
        }
    }
    
    /// Holds the background color of the display.
    private var _BackgroundColor: UIColor = UIColor.black
    /// Get or set the display's background color.
    public var BackgroundColor: UIColor
    {
        get
        {
            return _BackgroundColor
        }
        set
        {
            _BackgroundColor = newValue
            self.scene?.background.contents = _BackgroundColor
        }
    }
    
    /// Holds the color of the node.
    private var _NodeColor: UIColor = UIColor.red
    /// Get or set the node color.
    public var NodeColor: UIColor
    {
        get
        {
            return _NodeColor
        }
        set
        {
            _NodeColor = newValue
            CreateNodes()
        }
    }
    
    /// Holds the number of nodes.
    private var _NodeCount: Int = 6
    /// Get or set the number of nodes.
    @IBInspectable public var NodeCount: Int
        {
        get
        {
            return _NodeCount
        }
        set
        {
            _NodeCount = newValue
            CreateNodes()
        }
    }
    
    /// Holds the show border flag.
    private var _ShowBorder: Bool = false
    /// Get or set the show border flag.
    @IBInspectable public var ShowBorder: Bool
        {
        get
        {
            return _ShowBorder
        }
        set
        {
            _ShowBorder = newValue
            if _ShowBorder
            {
                self.layer.borderColor = UIColor.black.cgColor
                self.layer.borderWidth = 0.5
                self.layer.cornerRadius = 5.0
            }
            else
            {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0.0
                self.layer.cornerRadius = 0.0
            }
        }
    }
}
