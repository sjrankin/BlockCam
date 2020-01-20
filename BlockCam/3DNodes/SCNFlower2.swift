//
//  SCNFlower2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates an circle SCNNode geometry.
class SCNFlower2: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateFlower()
    }
    
    /// Initializer.
    /// - Parameter InteriorRadius: The radius of the interior circle.
    /// - Parameter PetalRadius: The radius of each petal.
    /// - Parameter PetalCount: The number of petals.
    /// - Parameter Extrusion: The extrusion depth of the ellipse.
    /// - Parameter Scale: The scale of the ellipse.
    init(InteriorRadius: CGFloat, PetalRadius: CGFloat, PetalCount: Int, Extrusion: CGFloat, Scale: CGFloat)
    {
        super.init()
        _InteriorRadius = InteriorRadius
        _PetalRadius = PetalRadius
        _Extrusion = Extrusion
        _Scale = Scale
        UpdateFlower()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateFlower()
    }
    
    /// Update the ellipse with the current property values.
    private func UpdateFlower()
    {
        let Geometry = SCNFlower2.Geometry(InteriorRadius: InteriorRadius, PetalRadius: PetalRadius,
                                           PetalCount: PetalCount, Extrusion: Extrusion)
        self.geometry = Geometry
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
    
    /// Holds the number of petals.
    private var _PetalCount: Int = 6
    /// Get or set the number of petals on the flower. Defaults to 6.
    public var PetalCount: Int
    {
        get
        {
            return _PetalCount
        }
        set
        {
            _PetalCount = newValue
            UpdateFlower()
        }
    }
    
    /// Holds the shape's interior radius value.
    private var _InteriorRadius: CGFloat = 3.0
    /// Get or set the shape's interior radius value. Defaults to 3.0.
    public var InteriorRadius: CGFloat
    {
        get
        {
            return _InteriorRadius
        }
        set
        {
            _InteriorRadius = newValue
            UpdateFlower()
        }
    }
    
    /// Holds the shape's petal radius value.
    private var _PetalRadius: CGFloat = 1.0
    /// Get or set the shape's interior radius value. Defaults to 1.0.
    public var PetalRadius: CGFloat
    {
        get
        {
            return _PetalRadius
        }
        set
        {
            _PetalRadius = newValue
            UpdateFlower()
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
            UpdateFlower()
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
            UpdateFlower()
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
    
    /// Rotates a point around another point.
    /// - Parameter Point: The point to rotate.
    /// - Parameter By: The angle (in degrees) to rotate th epoint by.
    /// - Parameter Around: The point around which `Point` is rotated.
    /// - Returns: New point based on the rotational parameters.
    private static func RotatePoint(_ Point: CGPoint, By Angle: CGFloat, Around Center: CGPoint) -> CGPoint
    {
        if Angle == 0.0
        {
            return Point
        }
        let NPoint = CGPoint(x: Point.x - Center.x, y: Point.y - Center.y)
        let X = NPoint.x * cos(Angle * CGFloat.pi / 180.0) - NPoint.y * sin(Angle * CGFloat.pi / 180.0)
        let Y = NPoint.x * sin(Angle * CGFloat.pi / 180.0) + NPoint.y * cos(Angle * CGFloat.pi / 180.0)
        return CGPoint(x: Center.x + X, y: Center.y + Y)
    }
    
    private static func GetAngleDegrees(Point: CGPoint, Center: CGPoint) -> CGFloat
    {
        let DeltaX = Point.x - Center.x
        let DeltaY = Point.y - Center.y
        var Angle = atan2(DeltaY, DeltaX)
        Angle = Angle < 0.0 ? Angle + 360.0 : 0.0
        return Angle
    }
    
    private static func GetAngleRadians(Point: CGPoint, Center: CGPoint) -> CGFloat
    {
        return GetAngleDegrees(Point: Point, Center: Center) * CGFloat.pi / 180.0
    }
    
    private static func Hypotenuse(B: CGFloat, C: CGFloat) -> CGFloat
    {
        return sqrt((B * B) + (C + C))
    }
    
    /// Convert a polar coordinate to a cartesian coordinate.
    /// - Paramete Angle: The angle (in degrees) of the polar coordinate.
    /// - Parameter Radius: The distance from the center (at (0,0)) of the polar coordinate.
    /// - Parameter Center: The actual center value used to add offsets as necessary.
    /// - Returns: Cartesian coordinate based on the polar coordinate.
    private static func PolarToCartesian(Angle: CGFloat, Radius: CGFloat, Center: CGPoint) -> CGPoint
    {
        let Radians = Angle * CGFloat.pi / 180.0
        let X = Radius * cos(Radians) + Center.x
        let Y = Radius * sin(Radians) + Center.y
        return CGPoint(x: X, y: Y)
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
    /// - Parameter InteriorRadius: The radius of the interior.
    /// - Parameter PetalRadius: The radius of individual petals.
    /// - Parameter PetalCount: The number of petals, spaced equidistantly.
    /// - Parameter Extrusion: The extrusion depth of the circle.
    /// - Returns: Node geometry in the shape of an circle.
    public static func Geometry(InteriorRadius: CGFloat, PetalRadius: CGFloat,
                                PetalCount: Int, Extrusion: CGFloat) -> SCNGeometry
    {
        let Origin = CGPoint(x: -InteriorRadius * Multiplier, y: -InteriorRadius * Multiplier)
        let BaseSize = CGSize(width: InteriorRadius * 2.0 * Multiplier, height: InteriorRadius * 2.0 * Multiplier)
        let CircleRectangle = CGRect(origin: Origin, size: BaseSize)
        let Circle = UIBezierPath(ovalIn: CircleRectangle)
        
        let Increment = 360.0 / Double(PetalCount)
        let RadialLength = (InteriorRadius * Multiplier + PetalRadius * Multiplier) + (PetalRadius * 0.4 * Multiplier)
        let LoopCenter = CGPoint(x: -InteriorRadius * Multiplier / 2,
                                 y: -InteriorRadius * Multiplier / 2)
        for Angle in stride(from: 0.0, to: 360.0, by: Increment)
        {
            let Rotated = RotatePoint(CGPoint(x: 0, y: -RadialLength), By: CGFloat(Angle), Around: LoopCenter)
            let PetalSize = CGSize(width: PetalRadius * 2.0 * Multiplier, height: PetalRadius * 2.0 * Multiplier)
            let Petal = UIBezierPath(ovalIn: CGRect(origin: Rotated, size: PetalSize))
            Circle.append(Petal)
        }
        
        Circle.close()
        let CircleGeo = SCNShape(path: Circle, extrusionDepth: Extrusion)
        return CircleGeo
    }
}
