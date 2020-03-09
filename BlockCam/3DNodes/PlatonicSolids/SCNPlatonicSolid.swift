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

/// This class encapsulates the reading of `.dae` files that contain Platonic solid shapes. See `PlatonicSolids`
/// for all supported shapes.
/// - Note:
///    - There are no sizing functions for Platonic solids - the caller must use `SCNNode.scale` to resize
///      each node as appropriate.
///    - Each Platonic solid is cached after it is successfully read to reduce performance issues. The caching
///      occurs in the static portion of the class.
///    - The shape of instance values is immutable.
class SCNPlatonicSolid: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        CommonInitialization(Solid: .Cube)
    }
    
    /// Initializer.
    /// - Parameter Solid: The Platonic solid shape to create and return. This value is immutable.
    init(Solid: PlatonicSolids)
    {
        super.init()
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
        self.geometry = SCNPlatonicSolid.Geometry(Solid: Solid)
    }
    
    /// Updates the shape with new dimensions.
    private func UpdateDimensions()
    {
        CommonInitialization(Solid: Solid)
    }
    
    private var _Solid: PlatonicSolids = .Cube
    /// Returns the Platonic solid shape.
    public var Solid: PlatonicSolids
    {
        get
        {
            return _Solid
        }
    }
    
    /// Returns geometry that defines the specified Platonic solid.
    /// - Parameter Solid: The Platonic solid whose geometry will be returned.
    /// - Returns: SCNGeometry object with the specified Platonic solid. Nil is returned on error.
    public static func Geometry(Solid: PlatonicSolids) -> SCNGeometry?
    {
        if let Node = GetPlatonicSolidNode(Solid: Solid)
        {
            return Node.geometry
        }
        return nil
    }
    
    /// Loads a Platonic solid node from an embedded .dae file created with an external program (Wings3D).
    /// - Note: The final Platonic shape `SCNNode` is cached to avoid performance hits when several
    ///         thousand nodes are needed for a scene.
    /// - Parameter Solid: The solid node to load.
    /// - Returns: `SCNNode` of the specified Platonic solid on success, nil if not found or on error.
    public static func GetPlatonicSolidNode(Solid: PlatonicSolids) -> SCNNode?
    {
        if let Cached = ShapeCache[Solid]
        {
            return Cached
        }
        var SolidFileName = "Cube"
        var NodeName = "Cube"
        var FileType = "dae"
        switch Solid
        {
            case .Cube:
                SolidFileName = "Cube2"
                NodeName = "Cube2"
            FileType = "scn"
            
            case .Dodecahedron:
                SolidFileName = "Dodecahedron"
                NodeName = "Dodecahedron"
            
            case .Icosahedron:
                SolidFileName = "Icosahedron"
                NodeName = "Icosahedron"
            
            case .Octahedron:
                SolidFileName = "Octahedron"
                NodeName = "Octahedron"
            
            case .Tetrahedron:
                SolidFileName = "Tetrahedron"
                NodeName = "Tetrahedron"
        }
        
        if let Path = Bundle.main.path(forResource: SolidFileName, ofType: FileType, inDirectory: "Solids.scnassets")
        {
            var SolidScene = SCNScene()
            do
            {
                SolidScene = try SCNScene(url: URL(fileURLWithPath: Path), options: [:])
            }
            catch
            {
                return nil
            }
            if let Node = SolidScene.rootNode.childNode(withName: NodeName, recursively: true)
            {
                let FinalNode = Node.clone() as SCNNode
                ShapeCache[Solid] = FinalNode
                return FinalNode
            }
        }
        return nil
    }
    
    private static var ShapeCache = [PlatonicSolids: SCNNode]()
}
