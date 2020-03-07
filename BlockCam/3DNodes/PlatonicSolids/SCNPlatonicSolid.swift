//
//  SCNPlatonicSolid.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Implements a tetrahedron-shaped SCNNode.
/// - Notes: See [Custom Geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
class SCNPlatonicSolid: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        self.BaseLength = 1.0
        CommonInitialization(Solid: .Cube)
    }
    
    /// Initializer.
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    init(Solid: PlatonicSolids, BaseLength: CGFloat)
    {
        super.init()
        self.BaseLength = BaseLength
        CommonInitialization(Solid: Solid)
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization(Solid: .Cube)
    }
    
    /// Initialization common to all initializers.
    func CommonInitialization(Solid: PlatonicSolids)
    {
        _Solid = Solid
        self.geometry = SCNPlatonicSolid.Geometry(Solid: Solid, BaseLength: _BaseLength)
    }
    
    /// Updates the shape with new dimensions.
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    /// - Parameter Height: Height of the apex of the tetrahedron.
    /// - Parameter Sierpinski: Reserved for future use.
    private func UpdateDimensions(NewBase: CGFloat)
    {
        CommonInitialization(Solid: Solid)
    }
    
    private var _Solid: PlatonicSolids = .Cube
    public var Solid: PlatonicSolids
    {
        get
        {
            return _Solid
        }
    }
    
    /// Holds the length of each base of the tetrahedron.
    private var _BaseLength: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength)
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
    
    /// Holds the source geometry.
    private static var GeoSource: SCNGeometrySource!
    /// Holds the geometric element.
    private static var GeoElement: SCNGeometryElement!
    
    /// Returns geometry that defines the specified Platonic solid.
    /// - Note: see [Custom SCNGeometry Not Displaying Diffuse Contents as Texture](https://stackoverflow.com/questions/48728060/custom-scngeometry-not-displaying-diffuse-contents-as-texture?rq=1)
    /// - Parameter Solid: The Platonic solid whose geometry will be returned.
    /// - Parameter BaseLength: Length of the base of the solid.
    /// - Returns: SCNGeometry object with the specified Platonic solid.
    public static func Geometry(Solid: PlatonicSolids, BaseLength: CGFloat) -> SCNGeometry
    {
        let SolidVertices = PlatonicSolid.GetVertices(For: Solid)
        Vertices.removeAll()
        for Vertex in SolidVertices
        {
            let NewVertex = SCNVector3(Vertex.x * Float(BaseLength),
                                       Vertex.y * Float(BaseLength),
                                       Vertex.z * Float(BaseLength))
            Vertices.append(NewVertex)
        }
        GeoSource = SCNGeometrySource(vertices: Vertices)
        GeoElement = SCNGeometryElement(indices: PlatonicSolid.GetIndices(For: Solid),
                                        primitiveType: .triangles)
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

/// Set of all Platonic solids.
enum PlatonicSolids: String, CaseIterable
{
    /// Tetrahedron. 4 faced-solid.
    case Tetrahedron = "Tetrahedron"
    /// Cube. 6 faced-solid.
    case Cube = "Cube"
    /// Octahedron. 8 faced-solid.
    case Octahedron = "Octahedron"
    /// Dodecahedron. 12 faced-solid.
    case Dodecahedron = "Dodecahedron"
    /// Icosahedron. 20 faced-solid.
    case Icosahedron = "Icosahedron"
}
