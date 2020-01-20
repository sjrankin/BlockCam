//
//  SCNStar.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// SCNNode with a star polygon shape.
/// - Note: Each point of the star is equal-distant from the point on either side.
/// - Note: The star shape is created using `UIBezierPath` data.
/// - Note: See [Star Polygon](https://en.wikipedia.org/wiki/Star_polygon)
class SCNStar: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        UpdateStar()
    }
    
    /// Initializer.
    /// - Note: If `VertexCount` is less than 3, a fatal error will be generated.
    /// - Parameter VertexCount: Number of points on the star. Points are distributed equally around a circle and all have the
    ///                          same height and base. This value must be 3 or greater.
    /// - Parameter Height: The height of each point from the center outwards. The full height of the geometry is twice this value.
    /// - parameter Base: The height of the base of each point.
    /// - Parameter ZHeight: The extrusion depth.
    /// - Parameter Scale: The scaling factor for the geometry.
    init(VertexCount: Int, Height: Double, Base: Double, ZHeight: Double, Scale: Float = 1.0)
    {
        super.init()
        if VertexCount < 3
        {
            Log.AbortMessage("VertexCount must be 3 or more.", FileName: #file, FunctionName: #function, LineNumber: #line)
            {
                Message in
                fatalError(Message)
            }
        }
        self.Scale = Scale
        SetVerticeParameters(Count: VertexCount, Height: Height, Base: Base, ZHeight: ZHeight)
        UpdateStar()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateStar()
    }
    
    /// Set vertex parameters from initializers.
    /// - Parameter Count: The number of vertices (eg, pointy parts) in the star.
    /// - Parameter Height: The height of each vertex from the center of the shape.
    /// - Parameter Base: The height of the base of each vertex triangle.
    func SetVerticeParameters(Count: Int, Height: Double, Base: Double, ZHeight: Double)
    {
        _Height = Height
        _VertexCount = Count
        _BaseHeight = Base
        _ZHeight = ZHeight
    }
    
    /// Holds the number of vertices.
    private var _VertexCount: Int = 5
    /// Get or set the number of vertices. Minimum legal value is 3.
    /// - Note: Setting this value to less than 3 will result in a fatal error.
    public var VertexCount: Int
    {
        get
        {
            return _VertexCount
        }
        set
        {
            _VertexCount = newValue
            if _VertexCount < 3
            {
                Log.AbortMessage("VertexCount must be 3 or more.", FileName: #file, FunctionName: #function, LineNumber: #line)
                {
                    Message in
                    fatalError(Message)
                }
            }
            UpdateStar()
        }
    }
    
    /// Holds the height of each vertex from the center of the shape.
    private var _Height: Double = 1.0
    /// Get or set the height of each vertex.
    public var Height: Double
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
            UpdateStar()
        }
    }
    
    /// Holds the extrusion depth.
    private var _ZHeight: Double = 1.0
    /// Get or set extrusion depth for the overall shape.
    public var ZHeight: Double
    {
        get
        {
            return _ZHeight
        }
        set
        {
            _ZHeight = newValue
            UpdateStar()
        }
    }
    
    /// Holds the height of the base of each vertex.
    private var _BaseHeight: Double = 0.5
    /// Get or set the height of the base of each vertex.
    public var BaseHeight: Double
    {
        get
        {
            return _BaseHeight
        }
        set
        {
            _BaseHeight = newValue
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
            UpdateStar()
        }
    }
    
    /// Updates the geometry of the current star. Should be called when one of the visual parameters changes.
    func UpdateStar()
    {
        let Geometry = SCNStar.Geometry(VertexCount: VertexCount, Height: Height, Base: BaseHeight, ZHeight: ZHeight)
        self.geometry = Geometry
        self.scale = SCNVector3(Scale, Scale, Scale)
    }

    /// Returns geometry to draw an extruded star with SceneKit.
    /// - Warning: If `VertexCount` is 0, a fatal error will be generated.
    /// - Parameters:
    ///   - VertexCount: Number of "rays" on the star, distributed equally.
    ///   - Height: Height of each "ray" on the star from the center of the shape.
    ///   - Base: Height of the base of each "ray" triangle.
    ///   - ZHeight: Extrusion depth.
    public static func Geometry(VertexCount: Int, Height: Double, Base: Double, ZHeight: Double) -> SCNGeometry
    {
        if VertexCount < 1
        {
            Log.AbortMessage("Vetex count is 0. Unable to continue.")
            {
                Message in
                fatalError(Message)
            }
        }
        let AngleIncrement = 360.0 / Double(VertexCount)
        let HalfIncrement = AngleIncrement / 2.0
        let Path = UIBezierPath()
        var Points = [SCNVector3]()
        for Multiplier in 0 ..< VertexCount
        {
            let Angle = Double(Multiplier) * AngleIncrement
            let RayData = MakeRay(AtAngle: Angle, HalfAngle: HalfIncrement, Base: Base, Height: Height)
            Points.append(contentsOf: RayData)
        }
        var IsFirst = true
        for SomePoint in Points
        {
            if IsFirst
            {
                Path.move(to: CGPoint(x: CGFloat(SomePoint.x), y: CGFloat(SomePoint.y)))
                IsFirst = false
            }
            else
            {
                Path.addLine(to: CGPoint(x: CGFloat(SomePoint.x), y: CGFloat(SomePoint.y)))
            }
        }
        Path.close()
        let StarGeo = SCNShape(path: Path, extrusionDepth: CGFloat(ZHeight))
        
        return StarGeo
    }
    
    /// Make one ray (pointed part/apex) of the star.
    /// - Parameter AtAngle: The angle at which to create the ray.
    /// - Parameter HalfAngle: Defines the lower (although it may be higher, depending on the values passed here), points on either
    ///                        side of the apex of the ray.
    /// - Parameter AngleOffset: Value to add to the angle before use.
    /// - Parameter Base: The height of the base points.
    /// - Parameter Height: The height of the apex points.
    /// - Returns: Array of `SCNVector3` values. The first point is a low point, the second point is the apex point, and the third
    ///            point is the opposite low point.
    public static func MakeRay(AtAngle: Double, HalfAngle: Double, AngleOffset: Double = 0.0,
                               Base: Double, Height: Double) -> [SCNVector3]
    {
        var Points = [SCNVector3]()
        let ActualAngle = AtAngle + AngleOffset
        let PointB = GetPoint(ActualAngle - HalfAngle, RadialLength: Base)
        Points.append(PointB)
        let PointA = GetPoint(ActualAngle, RadialLength: Height)
        Points.append(PointA)
        let PointC = GetPoint(ActualAngle + HalfAngle, RadialLength: Base)
        Points.append(PointC)
        return Points
    }
    
    /// Converts a polar coordinate into a cartesian coordinate.
    /// - Parameter AtAngle: The angle (in degrees) of the polar coordinate.
    /// - Parameter RadialLength: The length of the radius of the polar coordinate.
    /// - Returns: `SCNVector3` with the cartesian equivalent of the passed polar point. The returned vector has `z` set to 0.0.
    private static func GetPoint(_ AtAngle: Double, RadialLength: Double) -> SCNVector3
    {
        let Radians = AtAngle * Double.pi / 180.0
        let Point = SCNVector3(RadialLength * cos(Radians), RadialLength * sin(Radians), 0.0)
        return Point
    }
}
