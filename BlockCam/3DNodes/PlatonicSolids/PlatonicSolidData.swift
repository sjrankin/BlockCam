//
//  PlatonicSolidData.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Contains data for drawing Platonic solids. Used by SCNPlatonicSolid.
/// - See: `SCNPlatonicSolid`.
class PlatonicSolid
{
    /// Return the set of vertex indices for the given Platonic solid.
    /// - Parameter For: The solid for which a set of vertex indices will be returned.
    /// - Returns: Array of vertex indices.
    public static func GetIndices(For Solid: PlatonicSolids) -> [UInt16]
    {
        switch Solid
        {
            case .Tetrahedron:
                return TetrahedronIndices
            
            case .Cube:
                return CubeIndices
            
            case .Octahedron:
                return OctahedronIndices
            
            case .Dodecahedron:
                return DodecahedronIndices
            
            case .Icosahedron:
                return IcosahedronIndices
        }
    }
    
    /// Tetrahedron vertex indices.
    private static let TetrahedronIndices: [UInt16] =
        [
            0, 1, 2,
            2, 3, 0,
            3, 1, 0,
            3, 2, 1
    ]
    
    /// Cube vertex indices.
    private static let CubeIndices: [UInt16] =
        [
    ]
    
    /// Octahedron vertex indices.
    private static let OctahedronIndices: [UInt16] =
        [
            0, 1, 2,
            2, 3, 0,
            3, 4, 0,
            4, 1, 0,
            1, 5, 2,
            2, 5, 3,
            3, 5, 4,
            4, 5, 1
    ]
    
    /// Dodecahedron vertex indices.
    private static let DodecahedronIndices: [UInt16] =
        [
    ]
    
    /// Icosahedron vertex indices.
    private static let IcosahedronIndices: [UInt16] =
        [
            0, 11, 5,
            0, 5, 1,
            0, 1, 7,
            0, 7, 10,
            0, 10, 11,
            1, 5, 9,
            5, 11, 4,
            11, 10, 2,
            10, 7, 6,
            7, 1, 8,
            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,
            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
    ]
    
    /// Get an array of vertices for the given Platonic solid.
    /// - Parameter For: The Platonic solid for which an array of vertices is returned.
    /// - Returns: Array of vertices for the given Platonic solid.
    public static func GetVertices(For Solid: PlatonicSolids) -> [SCNVector3]
    {
        switch Solid
        {
            case .Tetrahedron:
                return TetrahedonVertices
            
            case .Cube:
                return CubeVertices
            
            case .Octahedron:
                return OctahedronVertices
            
            case .Dodecahedron:
                return DodecahedronVertices
            
            case .Icosahedron:
                return IcosahedronVertices
        }
    }
    
    /// Tetrahedron vertices.
    private static let TetrahedonVertices: [SCNVector3] =
        [
            SCNVector3(0.5, 1.0, 0.0),
            SCNVector3(-0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, 0.5),
            SCNVector3(0.0, 0.0, -0.5)
    ]
    
    /// Cube vertices.
    private static let CubeVertices: [SCNVector3] =
        [
    ]
    
    /// Octahedron vertices.
    private static let OctahedronVertices: [SCNVector3] =
        [
            SCNVector3(0, 1, 0),
            SCNVector3(-0.5, 0, 0.5),
            SCNVector3(0.5, 0, 0.5),
            SCNVector3(0.5, 0, -0.5),
            SCNVector3(-0.5, 0, -0.5),
            SCNVector3(0, -1, 0)
    ]
    
    /// Dodecahedron vertices.
    private static let DodecahedronVertices: [SCNVector3] =
        [
    ]
    
    private static let T = (1.0 + sqrt(5.0)) / 2.0
    
    /// Icosahedron vertices.
    private static let IcosahedronVertices: [SCNVector3] =
        [
            SCNVector3(-1,  T, 0).normalized(),
            SCNVector3( 1,  T, 0).normalized(),
            SCNVector3(-1, -T, 0).normalized(),
            SCNVector3( 1, -T, 0).normalized(),
            
            SCNVector3(0, -1,  T).normalized(),
            SCNVector3(0,  1,  T).normalized(),
            SCNVector3(0, -1, -T).normalized(),
            SCNVector3(0,  1, -T).normalized(),
            
            SCNVector3( T,  0, -1).normalized(),
            SCNVector3( T,  0,  1).normalized(),
            SCNVector3(-T,  0, -1).normalized(),
            SCNVector3(-T,  0,  1).normalized()
    ]
}

extension SCNVector3
{
    //https://github.com/devindazzle/SCNVector3Extensions/blob/master/SCNVector3Extensions.swift
    func normalized() -> SCNVector3
    {
        return SCNVector3(x / length(), y / length(), z / length())
    }
    
    func length() -> Float
    {
        return sqrtf(x * x + y * y + z * z)
    }
}
