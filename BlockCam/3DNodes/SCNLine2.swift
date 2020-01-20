//
//  SCNLine2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a line between two points.
class SCNLine2: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        UpdateLine()
    }
    
    /// Initializer.
    /// - Parameter Start: Starting point.
    /// - Parameter End: Ending point.
    /// - Parameter Scale: The scaling factor for the geometry.
    init(Start: SCNVector3, End: SCNVector3, Thickness: Double, Color: UIColor, Scale: Float = 1.0)
    {
        super.init()
        self.Thickness = Thickness
        StartingPoint = Start
        EndingPoint = End
        self.Scale = Scale
        UpdateLine()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateLine()
    }
    
    /// Update the line. Called when changes to properties that affect the line are made.
    public func UpdateLine()
    {
        let Geometry = SCNLine2.Geometry(StartAt: StartingPoint, EndAt: EndingPoint, Thickness: Thickness, LineColor: LineColor)
        self.geometry = Geometry
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
    
    private var _Thickness: Double = 0.01
    {
        didSet
        {
            UpdateLine()
        }
    }
    public var Thickness: Double
    {
        get
        {
            return _Thickness
        }
        set
        {
            _Thickness = newValue
        }
    }
    
    /// Holds the color of the line.
    private var _LineColor: UIColor = UIColor.white
    {
        didSet
        {
            UpdateLine()
        }
    }
    /// Get or set the color of the line.
    public var LineColor: UIColor
    {
        get
        {
            return _LineColor
        }
        set
        {
            _LineColor = newValue
        }
    }
    
    /// Holds the starting point of the line.
    private var _StartingPoint: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    {
        didSet
        {
            UpdateLine()
        }
    }
    /// Get or set the starting point of the line.
    public var StartingPoint: SCNVector3
    {
        get
        {
            return _StartingPoint
        }
        set
        {
            _StartingPoint = newValue
        }
    }
    
    /// Holds the ending point of the line.
    private var _EndingPoint: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    {
        didSet
        {
            UpdateLine()
        }
    }
    /// Get or set the ending point of the line.
    public var EndingPoint: SCNVector3
    {
        get
        {
            return _EndingPoint
        }
        set
        {
            _EndingPoint = newValue
        }
    }
    
    /// Holds the scale of the line.
    private var _Scale: Float = 1.0
    {
        didSet
        {
            UpdateLine()
        }
    }
    /// Get or set the scale of the line.
    public var Scale: Float
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
        }
    }
    
    /// Create geometry for a line.
    /// - Notes:
    ///   - See [Draw SceneKit Object Between Two Points](https://stackoverflow.com/questions/35002232/draw-scenekit-object-between-two-points)
    /// - Parameter StartAt: Starting point for the line.
    /// - Parameter EndAt: Ending point for the line.
    /// - Parameter Thickness: Thickness of the line.
    /// - Parameter LineColor: Color of the line.
    /// - Returns: Geometry for the specified line.
    public static func Geometry(StartAt: SCNVector3, EndAt: SCNVector3, Thickness: Double, LineColor: UIColor) -> SCNGeometry
    {
        let Vertices: [SCNVector3] = [StartAt, EndAt]
        let LineData = NSData(bytes: Vertices, length: MemoryLayout<SCNVector3>.size * Vertices.count) as Data
        let VertexSource = SCNGeometrySource(data: LineData,
                                             semantic: .vertex,
                                             vectorCount: Vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        let Indices: [Int32] = [0, 1]
        let IndexData = NSData(bytes: Indices, length: MemoryLayout<Int32>.size * Indices.count) as Data
        let Element = SCNGeometryElement(data: IndexData,
                                         primitiveType: .line,
                                         primitiveCount: Indices.count / 2,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        let Line = SCNGeometry(sources: [VertexSource], elements: [Element])
        Line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        Line.firstMaterial?.diffuse.contents = LineColor
        Line.firstMaterial?.specular.contents = UIColor.white
        return Line
    }
}
