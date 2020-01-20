//
//  SCNEllipse.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates an ellipse SCNNode geometry.
class SCNEllipse: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateEllipse()
    }
    
    /// Initializer.
    /// - Note: By convention, `MajorAxis` should be longer than `MinorAxis` but there are no restrains if the opposite is true.
    /// - Parameter MajorAxis: The long axis of the ellipse.
    /// - Parameter MinorAxis: The short axis of the ellipse.
    /// - Parameter Height: The extrusion depth of the ellipse.
    /// - Parameter Scale: The scale of the ellipse.
    init(MajorAxis: CGFloat, MinorAxis: CGFloat, Height: CGFloat, Scale: CGFloat)
    {
        super.init()
        _MajorAxis = MajorAxis
        _MinorAxis = MinorAxis
        _Height = Height
        _Scale = Scale
        UpdateEllipse()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateEllipse()
    }
    
    /// Update the ellipse with the current property values.
    private func UpdateEllipse()
    {
        let Geometry = SCNEllipse.Geometry(MajorAxis: MajorAxis, MinorAxis: MinorAxis, Height: Height)
        self.geometry = Geometry
        self.scale = SCNVector3(Scale, Scale, Scale)
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
            UpdateEllipse()
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
            UpdateEllipse()
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
            UpdateEllipse()
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
            UpdateEllipse()
        }
    }
    
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
    
    /// Returns geometry to be used to construct an elliptical node.
    /// - Node: Due to rounding errors by `UIBezierPath`, curves are not drawn properly for small values (eg, 0.1) of dimensions.
    ///         for this reason, this function multiplies all passed dimensions by the class property `Multiplier`. It is incumbant
    ///         on the called to rescale the result by calling
    ///
    ///         //The z value must be 1.0.
    ///         SCNNode.scale = SCNVector3(SCNEllipse.MultiplierReciprocal, SCNEllipse.MultiplierReciprocal, 1.0)
    ///         //or
    ///         SCNNode.scale = SCNEllipse.ReciprocalScale()
    ///
    /// - Note:
    ///   - By convention, `MajorAxis` should be longer than `MinorAxis` but there are no restrains if the opposite is true.
    ///   - The extrusion depth (passed in `Height`) is *not* altered by `Multiplier`.
    /// - Parameter MajorAxis: The long axis of the ellipse.
    /// - Parameter MinorAxis: The short axis of the ellipse.
    /// - Parameter Height: The extrusion depth of the ellipse.
    /// - Returns: Node geometry in the shape of an ellipse.
    public static func Geometry(MajorAxis: CGFloat, MinorAxis: CGFloat, Height: CGFloat) -> SCNGeometry
    {
        let EllipseRectangle = CGRect(x: 0, y: 0, width: MajorAxis * Multiplier, height: MinorAxis * Multiplier)
        let Ellipse = UIBezierPath(ovalIn: EllipseRectangle)
        Ellipse.close()
        let EllipseGeo = SCNShape(path: Ellipse, extrusionDepth: Height)
        return EllipseGeo
    }
}
