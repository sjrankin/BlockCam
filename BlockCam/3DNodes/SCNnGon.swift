//
//  SCNnGon.swift
//  BlockCam
//  Adapted from Fouris.
//
//  Created by Stuart Rankin on 11/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Creates an n-gon shape as the SCNNode.
/// - Note: See: [Custom Geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
class SCNnGon: SCNNode
{
    /// Default initializer. Sets the radius to 1.0, vertex count to 6, and depth to 0.5.
    override init()
    {
        super.init()
        self.Radius = 1.0
        self.VertexCount = 6
        self.Depth = 0.5
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Note:
    ///   - This initializer will generate fatal errors in the following conditions:
    ///     - If the vertex count is less than 3.
    ///     - If the radius is less or equal to 0.0.
    /// - Parameter VertexCount: Number of vertices the shape. Vertices are arranged in a regular pattern. **If this value is
    ///                           less than `3`, a fatal error will occur.**
    /// - Parameter Radius: The radius of the polygon. This is the value from the center of the shape to any vertex. **If this value
    ///                     is 0 or less, a fatal error will occur.**
    /// - Parameter Depth: The depth of the shape - this is the z-axis size. Values of 0.0 or less are ignored.
    init(VertexCount: Int, Radius: CGFloat, Depth: CGFloat)
    {
        super.init()
        if VertexCount < 3
        {
            Log.AbortMessage("Vertex count must be 3 or greater.")
            {
                Message in
                fatalError(Message)
            }
        }
        if Radius <= 0.0
        {
            Log.AbortMessage("Radius must be greater than 0.0.")
            {
                Message in
                fatalError(Message)
            }
        }
        self.Radius = Radius
        self.VertexCount = VertexCount
        if Depth <= 0.0
        {
            self.Depth = 1.0
        }
        else
        {
            self.Depth = Depth
        }
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization()
    }
    
    /// Returns the geometry necessary to create the n-gon.
    /// - Parameters:
    ///   - VertexCount: Number of vertices in the n-gon.
    ///   - Radius: Radius of the n-gon.
    ///   - Depth: Depth of the shape.
    /// - Returns: `SCNGeometry` object with the n-gon defined.
    public static func Geometry(VertexCount: Int, Radius: CGFloat, Depth: CGFloat) -> SCNGeometry
    {
        var Vertices = [CGPoint]()
        let AngleIncrement = 360.0 / Double(VertexCount)
        let TerminalAngle = 360.0 - AngleIncrement
        let Start = AngleIncrement / 2.0
        for Angle in stride(from: Start, through: Double(TerminalAngle + Start), by: Double(AngleIncrement))
        {
            let Adjusted = 360.0 - Angle
            let Radians = CGFloat(Adjusted) * CGFloat.pi / 180.0
            let X = 0 * cos(Radians) - Radius * sin(Radians)
            let Y = 0 * sin(Radians) + Radius * cos(Radians)
            Vertices.append(CGPoint(x: X, y: Y))
        }
        let NGonPath = UIBezierPath()
        NGonPath.move(to: Vertices[0])
        for Vertex in Vertices
        {
            NGonPath.addLine(to: Vertex)
        }
        NGonPath.addLine(to: Vertices[0])
        NGonPath.close()
        let NGonShape = SCNShape(path: NGonPath, extrusionDepth: Depth)
        return NGonShape
    }
    
    /// Returns a cloned node with a (potentially) different extrustion depth.
    /// - Parameter Node: The node to clone.
    /// - Parameter WithDepth: Depth of the extruded shape.
    /// - Returns: Cloned node with the edited depth.
    public static func CloneNode(_ Node: SCNNode, WithDepth: CGFloat) -> SCNNode
    {
        let Cloned = Node.flattenedClone()
        if let NodeShape = Node.geometry as? SCNShape
        {
            let NewPath = SCNShape(path: NodeShape.path, extrusionDepth: WithDepth)
            Cloned.geometry = NewPath
        }
        return Cloned
    }
    
    /// Creates an SCNShape with the specified number of regularly arranged vertices and extrusion depth and sets the `self.geometry`
    /// property to the new SCNShape object.
    /// - Note: This class uses internal fields and not the public properties.
    private func CommonInitialization()
    {
        self.geometry = SCNnGon.Geometry(VertexCount: _VertexCount, Radius: _Radius, Depth: _Depth)
    }
    
    /// Called when property values change.
    private func UpdateDimensions()
    {
        CommonInitialization()
    }
    
    /// Holds the depth (Z-axis value) of the shape.
    private var _Depth: CGFloat = 0.5
    {
        didSet
        {
            UpdateDimensions()
        }
    }
    /// Get or set the depth of the shape. Default value is 0.5.
    public var Depth: CGFloat
    {
        get
        {
            return _Depth
        }
        set
        {
            _Depth = newValue
        }
    }
    
    /// Holds the radius of the shape.
    private var _Radius: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions()
        }
    }
    /// Get or set the radius of the polygon. Defaults to 1.0.
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
        }
    }
    
    /// Holds the number of vertices in the polygon.
    private var _VertexCount: Int = 6
    {
        didSet
        {
            UpdateDimensions()
        }
    }
    /// Get or set the number of vertices of the polygon. Defaults to 6.
    public var VertexCount: Int
    {
        get
        {
            return _VertexCount
        }
        set
        {
            _VertexCount = newValue
        }
    }
}

