//
//  Utility3D.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Utility functions related to 3D scenes, manipulations, and the like.
class Utility3D
{
    /// Determines if all child nodes (including the node itself) are in the frustrum of the passed scene.
    /// - Note: See [How to know if a node is visible in scene or not in SceneKit?](https://stackoverflow.com/questions/47828491/how-to-know-if-node-is-visible-in-screen-or-not-in-scenekit)
    /// - Parameter View: The SCNView used to determine visibility.
    /// - Parameter Node: The node to check for visibility. All child nodes (and all descendent nodes) also checked.
    /// - Parameter PointOfView: The point of view node for the scene.
    /// - Returns: True if all nodes are visible, false if not.
    private static func AllInView(View: SCNView, Node: SCNNode, PointOfView: SCNNode) -> Bool
    {
        if !View.isNode(Node, insideFrustumOf: PointOfView)
        {
            return false
        }
        for ChildNode in Node.childNodes
        {
            if !AllInView(View: View, Node: ChildNode, PointOfView: PointOfView)
            {
                return false
            }
        }
        return true
    }
    
    /// Forces all nodes in a scene to be visible in the current scene's viewport.
    /// - Note: This function assumes there are nodes not initially visible and works to increase the height of the camera to
    ///         make them all visible. If the initial view has all nodes visible (even if they are all very small), no changes
    ///         will be made.
    /// - Note: The user may specify an offset value to apply to the returned camera height via the `.BestFitOffset` setting.
    /// - Note: It is important that the scene creation be completed before calling this function or some nodes may be missed.
    /// - Parameter InView: The SCNView to adjust.
    /// - Returns: The new field of view for the camera. (The scene's camera will have its field of view set to this value.)
    @discardableResult public static func ForceVisibility(InView: SCNView) -> Double
    {
        let PointOfView = InView.pointOfView
        if let RootNode = GetNode(WithName: "ParentNode", InScene: InView.scene!)
        {
            if let CameraNode = GetNode(WithName: "SceneCamera", InScene: InView.scene!)
            {
                let InitialHeight = Double(CameraNode.position.z)
                for CameraHeight in stride(from: InitialHeight, to: 100.0, by: 0.1)
                {
                    let NewPosition = SCNVector3(CameraNode.position.x, CameraNode.position.y, Float(CameraHeight))
                    CameraNode.position = NewPosition
                    if AllInView(View: InView, Node: RootNode, PointOfView: PointOfView!)
                    {
                        let CameraHeightOffset = Settings.GetDouble(ForKey: .BestFitOffset)
                        return CameraHeight + CameraHeightOffset
                    }
                }
            }
            else
            {
                Log.Message("SceneCamera not found.")
            }
        }
        else
        {
            Log.Message("ParentNode not found.")
        }
        return 0.0
    }
    
    /// Moves the camera position such that all nodes in the scene are visible (or within the viewing frustrum).
    /// - Parameter InView: The SCNView to update.
    /// - Returns: The new camera `z` position value.
    @discardableResult public static func BestFit(InView: SCNView, ShowVisually: Bool = true) -> Double
    {
        let PointOfView = InView.pointOfView
        if let RootNode = GetNode(WithName: "ParentNode", InScene: InView.scene!)
        {
            if let CameraNode = GetNode(WithName: "SceneCamera", InScene: InView.scene!)
            {
                for CameraHeight in stride(from: 1.0, to: 100.0, by: 0.1)
                {
                    CameraNode.position = SCNVector3(CameraNode.position.x, CameraNode.position.y, Float(CameraHeight))
                    if AllInView(View: InView, Node: RootNode, PointOfView: PointOfView!)
                    {
                        return CameraHeight
                    }
                }
            }
            else
            {
                Log.Message("SceneCamera not found.")
            }
        }
        else
        {
            Log.Message("ParentNode not found.")
        }
        return 0.0
        
    }
    
    /// Returns a node with the specified name in the specified scene.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**. If multiple nodes have the same name,
    ///                       the first node encountered will be returned.
    /// - Parameter InScene: The scene to search for the named node.
    /// - Returns: The node with the specified name on success, nil if not found.
    public static func GetNode(WithName: String, InScene: SCNScene) -> SCNNode?
    {
        return DoGetNode(FromNode: InScene.rootNode, WithName: WithName)
    }
    
    /// Returns a node with the specified name in the passed node. Recursively (so large trees will use up a lot of stack space)
    /// searches child node.
    /// - Parameter FromNode: The parent node to search.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**.
    /// - Returns: The first node whose name matches `WithName`. Nil if not found. If multiple nodes have the same name, only the
    ///            first is returned.
    private static func DoGetNode(FromNode: SCNNode, WithName: String) -> SCNNode?
    {
        if let NodesName = FromNode.name
        {
            if NodesName == WithName
            {
                return FromNode
            }
        }
        for ChildNode in FromNode.childNodes
        {
            if let NamedNode = DoGetNode(FromNode: ChildNode, WithName: WithName)
            {
                return NamedNode
            }
        }
        return nil
    }
    
    /// Create a "line" and return it in a scene node.
    /// - Note: The line is really a very thin box. This makes lines a rather heavy operation.
    /// - Parameter From: Starting point of the line.
    /// - Parameter To: Ending point of the line.
    /// - Parameter Color: The color of the line.
    /// - Parameter LineWidth: Width of the line - defaults to 0.01.
    /// - Returns: Node with the specified line. The node has the name "SegmentLine".
    public static func MakeLine(From: SCNVector3, To: SCNVector3, Color: UIColor, LineWidth: CGFloat = 0.01) -> SCNNode2
    {
        var Width: Float = 0.01
        var Height: Float = 0.01
        let FinalLineWidth = Float(LineWidth)
        if From.y == To.y
        {
            Width = abs(From.x - To.x)
            Height = FinalLineWidth
        }
        else
        {
            Height = abs(From.y - To.y)
            Width = FinalLineWidth
        }
        let Line = SCNBox(width: CGFloat(Width), height: CGFloat(Height), length: CGFloat(FinalLineWidth),
                          chamferRadius: 0.0)
        Line.materials.first?.diffuse.contents = Color
        let Node = SCNNode2(geometry: Line)
        Node.position = From
        Node.name = "SegmentLine"
        return Node
    }
    
    /// Returns the number of nodes in the passed scene.
    /// - Parameter InScene: The scene whose nodes will be counted.
    public static func NodeCount(InScene: SCNScene) -> Int
    {
        let ParentNode = InScene.rootNode
        return GetChildNodeCount(OfNode: ParentNode) + 1
    }
    
    /// Returns the number of child nodes in the passed node.
    /// - Parameter OfNode: The node whose number of descendents will be returned.
    /// - Returns: Number of descendents of the passed node.
    private static func GetChildNodeCount(OfNode: SCNNode) -> Int
    {
        var Count = 0
        for Child in OfNode.childNodes
        {
            //Add the child node count.
            Count = Count + 1
            //Add the number of child nodes in the child node.
            Count = Count + GetChildNodeCount(OfNode: Child)
        }
        return Count
    }
}
