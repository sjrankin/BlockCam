//
//  SCNTriangle.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates an extruded equilateral triangle that supports various heights for the extruded vertices.
/// - Note: See [Custom geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
class SCNTriangle: SCNNode
{
    /// Default initializer. Creates extruded equilateral triangle. Scale and all depths set to 1.0. Each base side is 1.0.
    override init()
    {
        super.init()
        UpdateTriangle()
    }
    
    /// Initializer. Creates extruded equilateral triangle.
    /// - Parameter A: Height of vertex A.
    /// - Parameter B: Height of vertex B.
    /// - Parameter C: Height of vertex C.
    /// - Parameter Scale: Scale of the shape. Defaults to 1.0.
    init(A: Float, B: Float, C: Float, Scale: Float = 1.0)
    {
        super.init()
        self.Scale = Scale
        SetVertexHeights(A: A, B: B, C: C)
        UpdateTriangle()
    }
    
    /// Required initializer. Creates extruded equilateral triangle. Scale and all depths set to 1.0. Each base side is 1.0.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateTriangle()
    }
    
    /// Set all vertex heights. Updates the shape.
    /// - Parameter A: Height of vertex A.
    /// - Parameter B: Height of vertex B.
    /// - Parameter C: Height of vertex C.
    public func SetVertexHeights(A: Float, B: Float, C: Float)
    {
        _VertexA = A
        _VertexB = B
        _VertexC = C
        UpdateTriangle()
    }
    
    /// Holds the scale.
    private var _Scale: Float = 1.0
    /// Get or set the scale. Updates the shape.
    public var Scale: Float
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            UpdateTriangle()
        }
    }
    
    /// Holds the height of vertex A.
    private var _VertexA: Float = 1.0
    /// Get or set the height of vertex A. Updates the shape.
    public var VertexA: Float
    {
        get
        {
            return _VertexA
        }
        set
        {
            _VertexA = newValue
            UpdateTriangle()
        }
    }
    
    /// Holds the height of vertex B.
    private var _VertexB: Float = 1.0
    /// Get or set the height of vertex B. Updates the shape.
    public var VertexB: Float
    {
        get
        {
            return _VertexB
        }
        set
        {
            _VertexB = newValue
            UpdateTriangle()
        }
    }
    
    /// Holds the height of vertex C.
    private var _VertexC: Float = 1.0
    /// Get or set the height of vertex C. Updates the shape.
    public var VertexC: Float
    {
        get
        {
            return _VertexC
        }
        set
        {
            _VertexC = newValue
            UpdateTriangle()
        }
    }
    
    /// Recreate the geometry for the shape.
    func UpdateTriangle()
    {
        let Geometry = SCNTriangle.Geometry(A: VertexA, B: VertexB, C: VertexC, Scale: Scale)
        self.geometry = Geometry
    }
    
    /// Return the geometry for an extruded equilateral triangle.
    /// - Parameter A: The height of vertex A.
    /// - Parameter B: The height of vertex B.
    /// - Parameter C: The height of vertex C.
    /// - Parameter Scale: The scaling factor to apply to all vertices.
    public static func Geometry(A: Float = 1.0, B: Float = 1.0, C: Float = 1.0, Scale: Float = 1.0) -> SCNGeometry
    {
        let Indices: [UInt16] =
            [
                2, 1, 0,
                3, 4, 5,
                1, 2, 5,
                4, 3, 1,
                0, 5, 2,
                0, 3, 5,
                0, 1, 3,
                5, 4, 1
        ]
        
        var FinalVertices = [SCNVector3]()
        FinalVertices.append(SCNVector3(0.0, 0.0, 0.0)) //0
        FinalVertices.append(SCNVector3(1.0 * Scale, 0.0, 0.0)) //1
        FinalVertices.append(SCNVector3(0.5 * Scale, 0.866 * Scale, 0.0)) //2
        FinalVertices.append(SCNVector3(0.0, 0.0, A * Scale)) //3
        FinalVertices.append(SCNVector3(1.0 * Scale, 0.0, B * Scale)) //4
        FinalVertices.append(SCNVector3(0.5 * Scale, 0.866 * Scale, C * Scale)) //5
        let Source = SCNGeometrySource(vertices: FinalVertices)
        let Element = SCNGeometryElement(indices: Indices, primitiveType: .triangles)
        let TextureCoordinates =
            [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 1, y: 1)
        ]
        let UVPoints = SCNGeometrySource(textureCoordinates: TextureCoordinates)
        let Geo = SCNGeometry(sources: [Source, UVPoints], elements: [Element])
        return Geo
    }
}
