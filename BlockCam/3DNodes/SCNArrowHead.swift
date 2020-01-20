//
//  SCNArrowHead.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Arrowhead shape node.
class SCNArrowHead: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateArrowHead()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateArrowHead()
    }
    
    /// Initializer.
    /// - Parameter Height: Vertical height of the arrowhead shape. Defaults to 5.0.
    /// - Parameter Base: Horizontal width of the base of the shape. Defaults to 2.0.
    /// - Parameter Inset: Depth of the inset at the base of the shape. Defaults to 1.5.
    /// - Parameter Extrusion: Extrusion height in the Z plane. Defaults to 1.0.
    /// - Parameter Scale: Scale of the node. Defaults to 1.0.
    init(Height: CGFloat = 5.0, Base: CGFloat = 2.0, Inset: CGFloat = 1.5, Extrusion: CGFloat = 1.0, Scale: CGFloat = 1.0)
    {
        super.init()
        _Height = Height
        _Base = Base
        _Inset = Inset
        _Extrusion = Extrusion
        _Scale = Scale
        UpdateArrowHead()
    }
    
    /// Update the arrowhead shape with (presumably) changed parameters.
    func UpdateArrowHead()
    {
        self.geometry = SCNArrowHead.Geometry(Height: Height, Base: Base, Inset: Inset, Extrusion: Extrusion)
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
    
    /// Holds the height of the arrowhead.
    private var _Height: CGFloat = 5.0
    /// Get or set the height of the arrowhead shape. Defaults to 5.0.
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
            UpdateArrowHead()
        }
    }
    
    /// Holds the base size of the arrowhead shape.
    private var _Base: CGFloat = 2.0
    /// Get or set the base size/width of the arrowhead. Defaults to 2.0.
    public var Base: CGFloat
    {
        get
        {
            return _Base
        }
        set
        {
            _Base = newValue
            UpdateArrowHead()
        }
    }
    
    /// Holds the scale of the node.
    private var _Scale: CGFloat = 1.0
    /// get or set the scale of the node. Defaults to 1.0.
    public var Scale: CGFloat
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            UpdateArrowHead()
        }
    }
    
    /// Holds the inset value.
    private var _Inset: CGFloat = 1.5
    /// Get or set the inset value - the depth of the bottom inset. Defaults to 1.5. (If negative, the inset will become
    /// an outset.)
    public var Inset: CGFloat
    {
        get
        {
            return _Inset
        }
        set
        {
            _Inset = newValue
            UpdateArrowHead()
        }
    }
    
    /// Holds the extrusion depth.
    private var _Extrusion: CGFloat = 1.0
    /// Get or set the extrusion depth. Defaults to 1.0.
    public var Extrusion: CGFloat
    {
        get
        {
            return _Extrusion
        }
        set
        {
            _Extrusion = newValue
            UpdateArrowHead()
        }
    }
    
    /// Creates and returns the geometry needed to create an arrowhead shape.
    /// - Parameter Height: Vertical height of the arrowhead shape.
    /// - Parameter Base: Horizontal width of the base of the shape.
    /// - Parameter Inset: Depth of the inset at the base of the shape.
    /// - Parameter Extrusion: Extrusion height in the Z plane.
    /// - Returns: `SCNGeometry` object representing a stylized arrowhead shape.
    public static func Geometry(Height: CGFloat, Base: CGFloat, Inset: CGFloat, Extrusion: CGFloat) -> SCNGeometry
    {
        let HCenter = Base / 2.0
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: HCenter, y: 0.0))
        Path.addLine(to: CGPoint(x: 0, y: Height))
        Path.addLine(to: CGPoint(x: HCenter, y: Height - Inset))
        Path.addLine(to: CGPoint(x: HCenter * 2.0, y: Height))
        Path.close()
        let ArrowHeadGeo = SCNShape(path: Path, extrusionDepth: Extrusion)
        return ArrowHeadGeo
    }
}
