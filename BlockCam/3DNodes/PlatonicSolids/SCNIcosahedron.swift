//
//  SCNIcosahedron.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Implements a icosahedron-shaped SCNNode.
/// - Notes: See [Custom Geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
/// - Notes: See [SceneKit tutorial part 2](https://www.invasivecode.com/weblog/scenekit-tutorial-part-2/)
class SCNIcosahedron: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        self.BaseLength = 1.0
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter BaseLength: Length of the base of the icosahedron.
    init(BaseLength: CGFloat)
    {
        super.init()
        self.BaseLength = BaseLength
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
        self.geometry = SCNIcosahedron.Geometry(BaseLength: _BaseLength)  
    }
    
    /// Updates the shape with new dimensions.
    /// - Parameter BaseLength: Length of the base of the icosahedron.
    private func UpdateDimensions(NewBase: CGFloat)
    {
        CommonInitialization()
    }
    
    /// Holds the length of each base of the icosahedron.
    private var _BaseLength: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength)
        }
    }
    /// Get or set the base length of the icosahedron. Defaults to 1.0
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
    
    private static func GetVertices(With Side: CGFloat) -> [SCNVector3]
    {
        let Length = CGFloat((Side + sqrt(5.0)) / 2.0)
        let VertexList: [SCNVector3] =
        [
            SCNVector3(-Side, Length, 0),
            SCNVector3(Side, Length, 0),
            SCNVector3(-Side, -Length, 0),
            SCNVector3(Side, -Length, 0),
            SCNVector3(0, -Side, Length),
            SCNVector3(0, Side, Length),
            SCNVector3(0, -Side, -Length),
            SCNVector3(0, Side, -Length),
            SCNVector3(Length, 0, -Side),
            SCNVector3(Length, 0, Side),
            SCNVector3(-Length,  0, -Side),
            SCNVector3(-Length, 0, Side)
        ]
        return VertexList
    }
    
    /// Holds the indices of the vertices that defines the shape.
    private static let Indices: [UInt16] =
        [
            0, 5, 1, 0, 1, 5, 1, 7, 1, 8, 1, 9, 2, 3, 2, 4, 2, 6, 2, 10, 2, 11, 3, 6, 3, 8, 3, 9, 4, 3, 4, 5,
            4, 9, 5, 9, 6, 7, 6, 8, 6, 10, 9, 8, 8, 7, 7, 0, 10, 0, 10, 7, 10, 11, 11, 0, 11, 4, 11, 5
    ]
    
    /// Holds the source geometry.
    private static var GeoSource: SCNGeometrySource!
    
    /// Holds the geometric element.
    private static var GeoElement: SCNGeometryElement!
    
    /// Returns geometry that defines a tetrahedron.
    /// - Note: see [Custom SCNGeometry Not Displaying Diffuse Contents as Texture](https://stackoverflow.com/questions/48728060/custom-scngeometry-not-displaying-diffuse-contents-as-texture?rq=1)
    /// - Parameter BaseLength: Length of the base of the tetrahedron.
    /// - Returns: SCNGeometry object with a dodecahedron.
    public static func Geometry(BaseLength: CGFloat) -> SCNGeometry
    {
        let Vertices = GetVertices(With: BaseLength) 
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

