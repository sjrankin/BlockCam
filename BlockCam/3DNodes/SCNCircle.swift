//
//  SCNCircle.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates an circle SCNNode geometry.
class SCNCircle: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateCircle()
    }
    
    /// Initializer.
    /// - Parameter Radius: The radius of the circle.
    /// - Parameter Extrusion: The extrusion depth of the circle.
    /// - Parameter Scale: The scale of the circle.
    init(Radius: CGFloat, Extrusion: CGFloat, Scale: CGFloat)
    {
        super.init()
        _Radius = Radius
        _Extrusion = Extrusion
        _Scale = Scale
        UpdateCircle()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateCircle()
    }
    
    /// Update the ellipse with the current property values.
    private func UpdateCircle()
    {
        let Geometry = SCNCircle.Geometry(Radius: Radius, Extrusion: Extrusion)
        self.geometry = Geometry
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
    
    /// Holds the radius value.
    private var _Radius: CGFloat = 5.0
    /// Get or set the radius value. Defaults to 5.0.
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
            UpdateCircle()
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
            UpdateCircle()
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
            UpdateCircle()
        }
    }
    
    // MARK: - Static functions.
    
    /// Holds the multiplier value to get around a bug in `UIBezierPath`.
    private static var _Multiplier: CGFloat = 1000.0
    /// Get or set the multiplier value used to work around a bug in `UIBezierPath`. This value is multiplied by all passed
    /// dimensions when creating elliptical geometry. Setting this value too low will result in unattractive ellipses. Defaults
    /// to 1000.0.
    /// - Note:
    ///    - Because this is a class property, all ellipses will use the same value.
    ///    - Setting `Multiplier` also sets the returned value for `MultiplierReciprocal`.
    public static var Multiplier: CGFloat
    {
        get
        {
            return _Multiplier
        }
        set
        {
            _Multiplier = newValue
            _MultiplierReciprocal = 1.0 / _MultiplierReciprocal
        }
    }
    
    /// Holds the reciprocal to `Multiplier`.
    private static var _MultiplierReciprocal: CGFloat = 1.0 / 1000.0
    /// Get the reciprocal of `Multiplier`. Defaults to `1.0 / 1000.0` (repiprocal to the default `Multiplier` value).
    /// - Note: This value is set when `Multiplier` is set.
    public static var MultiplierReciprocal: CGFloat
    {
        get
        {
            return _MultiplierReciprocal
        }
    }
    
    /// Returns an `SCNVector3` structure populate with the reciprocal value from `MultiplierReciprocal`. Useful for resizing
    /// nodes created by this class. For example:
    ///
    ///      let EllipseGeo = SCNEllipse.Geometry(MajorAxis: 2.0, MinorAxis: 0.5, Height: 5.0)
    ///      let Node = SCNNode(geometry: EllipseGeo)
    ///      Node.scale = SCNEllipse.ReciprocalScale()
    ///
    /// - Note:
    ///    - This function uses the value in `MultiplierReciprocal` which is set when the caller changes the `Multiplier` value.
    ///      The default value is used if the caller does not set `Multiplier`.
    ///    - The `z` value of the returned `SCNVector3` structure is set to 1.0 because `SCNEllipse.Geometry` does *not* multiply
    ///      the extrusion depth by `Multiplier`.
    public static func ReciprocalScale() -> SCNVector3
    {
        return SCNVector3(MultiplierReciprocal, MultiplierReciprocal, 1.0)
    }
    
    /// Returns geometry to be used to construct an circular node.
    /// - Node: Due to rounding errors by `UIBezierPath`, curves are not drawn properly for small values (eg, 0.1) of dimensions.
    ///         for this reason, this function multiplies all passed dimensions by the class property `Multiplier`. It is incumbant
    ///         on the called to rescale the result by calling
    ///
    ///         //The z value must be 1.0.
    ///         SCNNode.scale = SCNVector3(SCNCircle.MultiplierReciprocal, SCNCircle.MultiplierReciprocal, 1.0)
    ///         //or
    ///         SCNNode.scale = SCNCircle.ReciprocalScale()
    ///
    /// - Note:
    ///   - The extrusion depth is *not* altered by `Multiplier`.
    /// - Parameter Radius: The radius of the circle.
    /// - Parameter Extrusion: The extrusion depth of the circle.
    /// - Returns: Node geometry in the shape of an circle.
    public static func Geometry(Radius: CGFloat, Extrusion: CGFloat) -> SCNGeometry
    {
        let CircleRectangle = CGRect(x: 0, y: 0, width: Radius * 2.0 * Multiplier, height: Radius * 2.0 * Multiplier)
        let Circle = UIBezierPath(ovalIn: CircleRectangle)
        Circle.close()
        let CircleGeo = SCNShape(path: Circle, extrusionDepth: Extrusion)
        return CircleGeo
    }
}
