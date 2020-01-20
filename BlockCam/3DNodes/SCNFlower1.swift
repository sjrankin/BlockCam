//
//  SCNFlower1.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates a stylized flower shape.
class SCNFlower1: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateFlower()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init()
        UpdateFlower()
    }
    
    /// Initializer.
    /// - Parameter Petals: The number of petals on the flower.
    /// - Parameter Radius: The overall flower radius.
    /// - Parameter Extrusion: The extrusion depth of the flower.
    /// - Parameter Scale: The node's scale value.
    init(Petals: Int, Radius: CGFloat, Extrusion: CGFloat, Scale: Float = 1.0)
    {
        super.init()
        _Scale = Scale
        _PetalCount = Petals
        _Extrusion = Extrusion
        _Radius = Radius
        UpdateFlower()
    }

    /// Updates the flower's geometry based on current property values.
    private func UpdateFlower()
    {
        self.geometry = SCNFlower1.Geometry(Radius: Radius, PetalCount: PetalCount, Extrusion: Extrusion)
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
    
    /// Holds the number of petals.
    private var _PetalCount: Int = 5
    /// Get or set the number of petals. Defaults to 5.
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
    
    /// Holds the scale.
    private var _Scale: Float = 1.0
    /// Get or set the scale. Updates the shape.
    public var Scale: Float
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
    
    /// Holds the extrusion depth.
    private var _Extrusion: CGFloat = 1.0
    /// Get or set extrusion depth for the overall shape.
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
    
    /// Holds the radius of the flower.
    private var _Radius: CGFloat = 1.0
    /// Get or set the radius of the flower.
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
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
    ///      let FlowerGeo = SCNFlower1.Geometry(Radius: 5.0, PetalCount: 6, Extrusion: 5.0)
    ///      let Node = SCNNode(geometry: FlowerGeo)
    ///      Node.scale = SCNFlower1.ReciprocalScale()
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
    
    /// Returns the quadrant of `From` based on `Center`.
    /// - Parameter From: The point whose quadrant will be returned.
    /// - Parameter Center: The center of the coordinate system used to determine the quadrant.
    /// - Returns: Quadrant number. Only values 1 through 4 are returned.
    private static func GetQuadrant(From Point: CGPoint, Center: CGPoint) -> Int
    {
        if Point.x < Center.x && Point.y < Center.y
        {
            return 1
        }
        if Point.x >= Center.x && Point.y <= Center.y
        {
            return 2
        }
        if Point.x > Center.x && Point.y > Center.y
        {
            return 3
        }
        return 4
    }
    
    /// Convert a polar coordinate to a cartesian coordinate.
    /// - Paramete Angle: The angle (in degrees) of the polar coordinate.
    /// - Parameter Radius: The distance from the center (at (0,0)) of the polar coordinate.
    /// - Parameter Center: The actual center value used to add offsets as necessary.
    /// - Returns: Cartesian coordinate based on the polar coordinate.
    private static func PolarToCartesian(Angle: CGFloat, Radius: CGFloat, Center: CGPoint) -> CGPoint
    {
        let X = Radius * cos((Angle - 90.0) * CGFloat.pi / 180.0) + Center.x
        let Y = Radius * sin((Angle - 90.0) * CGFloat.pi / 180.0) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    /// Add a petal to the flower. Each petal is initially created at the top of the base of the flower then rotated into
    /// its proper position.
    /// - Parameter Center: The center of the flower.
    /// - Parameter Angle1: The angle of the left-side base.
    /// - Parameter Angle2: The angle of the right-side base.
    /// - Parameter BaseRadius: The radius of the base (and where the base points sit).
    /// - Parameter RotateBy: Angle (in degrees) to rotate the shape to put it in its final position.
    /// - Returns: A `UIBezierPath` with the petal shape.
    private static func AddPetal(Center: CGPoint, Angle1: CGFloat, Angle2: CGFloat, BaseRadius: CGFloat,
                                 RotateBy: CGFloat) -> UIBezierPath
    {
        let Petal = UIBezierPath()
        var B1 = PolarToCartesian(Angle: Angle1, Radius: BaseRadius, Center: Center)
        var B2 = PolarToCartesian(Angle: Angle2, Radius: BaseRadius, Center: Center)
        let B1Quadrant = GetQuadrant(From: B1, Center: Center)
        let B2Quadrant = GetQuadrant(From: B2, Center: Center)
        let O1X = 250
        let O1Y = 250
        let O2X = 250
        let O2Y = 250
        var Offset1: CGPoint!
        var Offset2: CGPoint!
        switch B1Quadrant
        {
            case 1:
                Offset1 = CGPoint(x: -O1X, y: -O1Y)
            
            case 2:
                Offset1 = CGPoint(x: O1X, y: -O1Y)
            
            case 3:
                Offset1 = CGPoint(x: O1X, y: O1Y)
            
            default:
                Offset1 = CGPoint(x: -O1X, y: O1Y)
        }
        switch B2Quadrant
        {
            case 1:
                Offset2 = CGPoint(x: -O2X, y: -O2Y)
            
            case 2:
                Offset2 = CGPoint(x: O2X, y: -O2Y)
            
            case 3:
                Offset2 = CGPoint(x: O2X, y: O2Y)
            
            default:
                Offset2 = CGPoint(x: -O2X, y: O2Y)
        }
        
        var CP1 = CGPoint(x: B1.x + Offset1.x, y: B1.y + Offset1.y)
        var CP2 = CGPoint(x: B2.x + Offset2.x, y: B2.y + Offset2.y)
        B1 = RotatePoint(B1, By: RotateBy, Around: Center)
        B2 = RotatePoint(B2, By: RotateBy, Around: Center)
        CP1 = RotatePoint(CP1, By: RotateBy, Around: Center)
        CP2 = RotatePoint(CP2, By: RotateBy, Around: Center)
        Petal.move(to: B1)
        Petal.addCurve(to: B2, controlPoint1: CP1, controlPoint2: CP2)
        Petal.close()
        return Petal
    }
    
    /// Creates and returns geometry for a stylized flower.
    /// - Parameter Petals: The number of petals on the flower.
    /// - Parameter Radius: The overall flower radius.
    /// - Parameter Extrusion: The extrusion depth of the flower.
    /// - Returns: `SCNGeometry` object for a stylized flower.
    public static func Geometry(Radius: CGFloat, PetalCount: Int, Extrusion: CGFloat) -> SCNGeometry
    {
        let Center = CGPoint(x: Radius, y: Radius)
        let HalfRadius = Radius / 2.0
        let Path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: Radius, height: Radius))
        
        let Increment = 360.0 / Double(PetalCount)
        for Angle in stride(from: 0.0, through: 360.0, by: Increment)
        {
            let Petal = AddPetal(Center: Center, Angle1: 345.0, Angle2: 15.0,
                                 BaseRadius: HalfRadius / 2.0, RotateBy: CGFloat(Angle))
            Path.append(Petal)
        }
        
        let FlowerGeo = SCNShape(path: Path, extrusionDepth: Extrusion)
        return FlowerGeo
    }
}
