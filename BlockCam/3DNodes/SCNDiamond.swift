//
//  SCNDiamond.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates a diamond SCNNode geometry.
class SCNDiamond: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateDiamond()
    }
    
    /// Initializer.
    /// - Note: By convention, `MajorAxis` should be longer than `MinorAxis` but there are no restraints if the opposite is true.
    /// - Parameter MajorAxis: The long axis of the diamond.
    /// - Parameter MinorAxis: The short axis of the diamond.
    /// - Parameter Height: The extrusion depth of the diamond.
    /// - Parameter Scale: The scale of the diamond.
    init(MajorAxis: CGFloat, MinorAxis: CGFloat, Height: CGFloat, Scale: CGFloat)
    {
        super.init()
        _MajorAxis = MajorAxis
        _MinorAxis = MinorAxis
        _Height = Height
        _Scale = Scale
        UpdateDiamond()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateDiamond()
    }
    
    /// Update the diamond with the current property values.
    private func UpdateDiamond()
    {
        let Geometry = SCNDiamond.Geometry(MajorAxis: _MajorAxis, MinorAxis: _MinorAxis, Height: _Height)
        self.geometry = Geometry
        self.scale = SCNVector3(_Scale, _Scale, _Scale)
    }
    
    /// Holds the major axis value.
    private var _MajorAxis: CGFloat = 5.0
    /// Get or set the major axis value. Defaults to 5.0.
    public var MajorAxis: CGFloat
    {
        get
        {
            return _MajorAxis
        }
        set
        {
            _MajorAxis = newValue
            UpdateDiamond()
        }
    }
    
    /// Holds the minor axis value.
    private var _MinorAxis: CGFloat = 2.0
    /// Get or set the minor axis value. Defaults to 2.0.
    public var MinorAxis: CGFloat
    {
        get
        {
            return _MinorAxis
        }
        set
        {
            _MinorAxis = newValue
            UpdateDiamond()
        }
    }
    
    /// Holds the height/extrusion depth.
    private var _Height: CGFloat = 1.0
    /// Get or set the height/extrusion depth. Defaults to 1.0.
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
            UpdateDiamond()
        }
    }
    
    /// Holds the node's scale.
    private var _Scale: CGFloat = 1.0
    /// Get or set the scale of the node. Defaults to 1.0.
    public var Scale: CGFloat
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            UpdateDiamond()
        }
    }
    
    /// Returns geometry to be used to construct an diamond node.
    /// - Note: By convention, `MajorAxis` should be longer than `MinorAxis` but there are no restraints if the opposite is true.
    /// - Parameter MajorAxis: The long axis of the diamond.
    /// - Parameter MinorAxis: The short axis of the diamond.
    /// - Parameter Height: The extrusion depth of the diamond.
    /// - Returns: Node geometry in the shape of a diamond (parallelogram).
    public static func Geometry(MajorAxis: CGFloat, MinorAxis: CGFloat, Height: CGFloat) -> SCNGeometry
    {
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: MinorAxis / 2.0, y: 0.0))
        Path.addLine(to: CGPoint(x: MinorAxis, y: MajorAxis / 2.0))
        Path.addLine(to: CGPoint(x: MinorAxis / 2.0, y: MajorAxis))
        Path.addLine(to: CGPoint(x: 0.0, y: MajorAxis / 2.0))
        Path.addLine(to: CGPoint(x: MinorAxis / 2.0, y: 0.0))
        Path.close()
        let DiamondGeo = SCNShape(path: Path, extrusionDepth: Height)
        return DiamondGeo
    }
}
