//
//  SCNTetrahedron.swift
//  BlockCam
//  Adapted from Fouris
//
//  Created by Stuart Rankin on 11/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Implements a tetrahedron-shaped SCNNode.
/// - Notes: See [Custom Geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
class SCNTetrahedron: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        self.BaseLength = 1.0
        self.Height = 1.0
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    /// - Parameter Height: Height of the apex of the tetrahedron.
    /// - Parameter Sierpinski: Reserved for future use.
    init(BaseLength: CGFloat, Height: CGFloat, Sierpinski: Int = 1)
    {
        super.init()
        self.BaseLength = BaseLength
        self.Height = Height
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization()
    }
    
    /// Initialization common to all initializers.
    func CommonInitialization()
    {
        self.geometry = SCNTetrahedron.Geometry(BaseLength: _BaseLength, Height: _Height, Sierpinski: _Sierpinski)
    }
    
    /// Updates the shape with new dimensions.
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    /// - Parameter Height: Height of the apex of the tetrahedron.
    /// - Parameter Sierpinski: Reserved for future use.
    private func UpdateDimensions(NewBase: CGFloat, NewHeight: CGFloat, NewSierpinski: Int)
    {
        CommonInitialization()
    }
    
    /// Holds the Sierpinski level.
    private var _Sierpinski: Int = 1
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    /// Get or set the Sierpinski level. Not currently implemented and reserved for future use.
    public var Sierpinski: Int
    {
        get
        {
            return _Sierpinski
        }
        set
        {
            _Sierpinski = newValue
        }
    }
    
    /// Holds the hieght of the apex of the tetrahedron.
    private var _Height: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    /// Get or set the height of the apex of the tetrahedron. Defaults to 1.0.
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
        }
    }
    
    /// Holds the length of each base of the tetrahedron.
    private var _BaseLength: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    /// Get or set the base length of the tetrahedron. Defaults to 1.0
    public var BaseLength: CGFloat
    {
        get
        {
            return _BaseLength
        }
        set
        {
            _BaseLength = newValue
        }
    }
    
    /// Holds the vertices of the shape.
    private static var Vertices = [SCNVector3]()
    
    /// Holds the original vertices of the shape (with a radius of 1.0).
    private static let OriginalVertices: [SCNVector3] =
        [
            SCNVector3(0.5, 1.0, 0.0),
            SCNVector3(-0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, 0.5),
            SCNVector3(0.0, 0.0, -0.5)
    ]
    
    /// Holds the indices of the vertices that defines the shape.
    private static let Indices: [UInt16] =
        [
            0, 1, 2,
            2, 3, 0,
            3, 1, 0,
            3, 2, 1
    ]
    
    /// Holds the source geometry.
    private static var GeoSource: SCNGeometrySource!
    /// Holds the geometric element.
    private static var GeoElement: SCNGeometryElement!
    
    /// Returns geometry that defines a tetrahedron.
    /// - Note: see [Custom SCNGeometry Not Displaying Diffuse Contents as Texture](https://stackoverflow.com/questions/48728060/custom-scngeometry-not-displaying-diffuse-contents-as-texture?rq=1)
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    /// - Parameter Height: Height of the apex of the tetrahedron.
    /// - Parameter Sierpinski: Reserved for future use.
    /// - Returns: SCNGeometry object with a dodecahedron.
    public static func Geometry(BaseLength: CGFloat, Height: CGFloat, Sierpinski: Int = 1) -> SCNGeometry
    {
        Vertices.removeAll()
        let OperationalHeight = Height
        let OperationalBase = BaseLength
        for Vertex in OriginalVertices
        {
            let NewVertex = SCNVector3(Vertex.x * Float(OperationalBase),
                                       Vertex.y * Float(OperationalHeight),
                                       Vertex.z * Float(OperationalBase))
            Vertices.append(NewVertex)
        }
        GeoSource = SCNGeometrySource(vertices: Vertices)
        GeoElement = SCNGeometryElement(indices: Indices, primitiveType: .triangles)
        let TextureCoordinates =
            [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 1, y: 1)
        ]
        let UVPoints = SCNGeometrySource(textureCoordinates: TextureCoordinates)
        let Geo = SCNGeometry(sources: [GeoSource, UVPoints], elements: [GeoElement])
        return Geo
    }
}

