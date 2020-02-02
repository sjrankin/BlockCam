//
//  NodeGenerators.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extension to the scene generator. This file/extension contains functions for the creation of individual shapes.
extension Generator
{
    /// Get the dimensions of a cone given the pixel's color and side.
    /// - Parameter From: The pixel color.
    /// - Parameter Side: The calculated side value.
    /// - Returns: Tuple of the top and bottom sizes of the cone.
    public static func GetConeDimensions(From: UIColor, Side: CGFloat) -> (Top: CGFloat, Base: CGFloat)
    {
        let DoInvert = Settings.GetBoolean(ForKey: .ConeIsInverted)
        var TopSize = ConeTopOptions.TopIsZero
        if let RawTop = Settings.GetString(ForKey: .ConeTopOptions)
        {
            if let TopValue = ConeTopOptions(rawValue: RawTop)
            {
                TopSize = TopValue
            }
            else
            {
                Settings.SetString(ConeTopOptions.TopIsZero.rawValue, ForKey: .ConeTopOptions)
            }
        }
        else
        {
            Settings.SetString(ConeTopOptions.TopIsZero.rawValue, ForKey: .ConeTopOptions)
        }
        var BaseSize = ConeBaseOptions.BaseIsSide
        if let RawBase = Settings.GetString(ForKey: .ConeBottomOptions)
        {
            if let BaseValue = ConeBaseOptions(rawValue: RawBase)
            {
                BaseSize = BaseValue
            }
            else
            {
                Settings.SetString(ConeBaseOptions.BaseIsSide.rawValue, ForKey: .ConeBottomOptions)
            }
        }
        else
        {
            Settings.SetString(ConeBaseOptions.BaseIsSide.rawValue, ForKey: .ConeBottomOptions)
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        From.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var TopRadius: CGFloat = 0.0
        var TopSet = true
        switch TopSize
        {
            case .TopIsZero:
                TopRadius = 0.0
            
            case .TopIsHue:
                TopRadius = Side * Hue
            
            case .TopIsSaturation:
                TopRadius = Side * Saturation
            
            case .TopIsSide:
                TopRadius = Side
            
            case .TenPercentSide:
                TopRadius = Side * 0.1
            
            case .FiftyPercentSide:
                TopRadius = Side * 0.5
            
            default:
                TopSet = false
        }
        
        var BottomRadius: CGFloat = 0.0
        var BaseSet = true
        switch BaseSize
        {
            case .BaseIsZero:
                BottomRadius = 0.0
            
            case .BaseIsHue:
                BottomRadius = Side * Hue
            
            case .BaseIsSaturation:
                BottomRadius = Side * Saturation
            
            case .BaseIsSide:
                BottomRadius = Side
            
            case .TenPercentSide:
                BottomRadius = Side * 0.1
            
            case .FiftyPercentSide:
                BottomRadius = Side * 0.25
            
            default:
                BaseSet = false
        }
        
        switch (TopSet, BaseSet)
        {
            case (false, false):
                BottomRadius = Side
                TopRadius = 0.0
            
            case (true, false):
                switch BaseSize
                {
                    case .TenPercent:
                        BottomRadius = TopRadius * 0.1
                    
                    case .FiftyPercent:
                        BottomRadius = TopRadius * 0.5
                    
                    default:
                        break
            }
            
            case (false, true):
                switch TopSize
                {
                    case .TenPercent:
                        TopRadius = BottomRadius * 0.1
                    
                    case .FiftyPercent:
                        TopRadius = BottomRadius * 0.5
                    
                    default:
                        break
            }
            
            case (true, true):
                if BottomRadius == 0.0 && TopRadius == 0.0
                {
                    BottomRadius = Side
                    TopRadius = 0.0
            }
        }
        
        if DoInvert
        {
            return (BottomRadius, TopRadius)
        }
        else
        {
            return (TopRadius, BottomRadius)
        }
    }
    
    /// Create simple node geometry for basic extruded shapes.
    /// - Parameter ForShape: The shape of the node whose geometry is returned.
    /// - Parameter Side: The length of the side of the geometry.
    /// - Parameter Prominence: The prominence of the shape.
    /// - Parameter DoXRotate: Returned value indicating whether the caller should rotate the shape on the X axis.
    /// - Parameter WithColor: The color needed by some shapes for variable sizes.
    /// - Returns: SCNGeometry with the specified shape. Nil if `ForShape` is not handled by this function.
    public static func GenerateNodeGeometry(ForShape: NodeShapes, Side: CGFloat, Prominence: CGFloat, DoXRotate: inout Bool,
                                            WithColor: UIColor) -> SCNGeometry?
    {
        var FinalShape: SCNGeometry? = nil
        DoXRotate = false
        
        switch ForShape
        {
            case .Blocks:
                var Chamfer: CGFloat = 0.0
                if let ChamferValue = Settings.GetString(ForKey: .BlockChamferSize)
                {
                    if let TheChamfer = BlockEdgeSmoothings(rawValue: ChamferValue)
                    {
                        switch TheChamfer
                        {
                            case .None:
                                Chamfer = 0.0
                            
                            case .Small:
                                Chamfer = 0.08
                            
                            case .Medium:
                                Chamfer = 0.15
                            
                            case .Large:
                                Chamfer = 0.25
                        }
                    }
                    else
                    {
                        Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
                        Chamfer = 0.0
                    }
                }
                else
                {
                    Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
                    Chamfer = 0.0
                }
                FinalShape = SCNBox(width: Side, height: Side, length: Prominence * 2, chamferRadius: Chamfer)
            
            case .Cylinders:
                FinalShape = SCNCylinder(radius: Side, height: Prominence * 2)
                DoXRotate = true
            
            case .Cones:
                let (Top, Bottom) = GetConeDimensions(From: WithColor, Side: Side)
                FinalShape = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Prominence * 2)   
                DoXRotate = true
            
            case .Pyramids:
                FinalShape = SCNPyramid(width: Side, height: Side, length: Prominence * 2)
                DoXRotate = true
            
            case .Toroids:
                FinalShape = SCNTorus(ringRadius: Prominence / 4.0, pipeRadius: Side)
                DoXRotate = true
            
            case .Spheres:
                FinalShape = SCNSphere(radius: Side * Prominence)
            
            case .Triangles:
                FinalShape = SCNTriangle.Geometry(A: Float(Prominence * 1.5), B: Float(Prominence * 1.5),
                                                  C: Float(Prominence * 1.5), Scale: Float(Side * 2.0))
            
            case .Pentagons:
                FinalShape = SCNnGon.Geometry(VertexCount: 5, Radius: Side, Depth: Prominence * 2)
            
            case .Hexagons:
                FinalShape = SCNnGon.Geometry(VertexCount: 6, Radius: Side, Depth: Prominence * 2)
            
            case .Octagons:
                FinalShape = SCNnGon.Geometry(VertexCount: 8, Radius: Side, Depth: Prominence * 2)
            
            case .Tetrahedrons:
                FinalShape = SCNTetrahedron.Geometry(BaseLength: Side, Height: Prominence * 2)
                DoXRotate = true
            
            case .Stars:
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
                {
                    ApexCount = ApexCount + Int(Prominence * 1.3)
                    if ApexCount > 10
                    {
                        ApexCount = 10
                    }
                }
                FinalShape = SCNStar.Geometry(VertexCount: ApexCount, Height: Double(Side), Base: Double(Side / 2.0),
                                              ZHeight: Double(Prominence * 2))
            
            case .Capsules:
                FinalShape = SCNCapsule(capRadius: Side, height: Prominence * 2)
                DoXRotate = true
            
            case .Lines:
                FinalShape = SCNCapsule(capRadius: 0.1, height: Prominence * 2)
                DoXRotate = true
            
            case .Diamonds:
                FinalShape = SCNDiamond.Geometry(MajorAxis: Side * 3, MinorAxis: Side, Height: Prominence * 2)
            
            default:
                FinalShape = nil
        }
        
        return FinalShape
    }
    
    /// Returns the shape the user selected as the cap of a capped line shape.
    /// - Parameter Side: The radius of a sphere. Multiplied by various constants for other shapes.
    /// - Parameter Diffuse: The diffuse material color.
    /// - Reurns: Geometry for the specified (in user defaults) shape.
    public static func GetCappedLineShape(Side: CGFloat, Diffuse: UIColor) -> SCNGeometry
    {
        var CapShape = CappedLineCapShapes.Sphere
        if let RawShape = Settings.GetString(ForKey: .CappedLineCapShape)
        {
            if let FinalShape = CappedLineCapShapes(rawValue: RawShape)
            {
                CapShape = FinalShape
            }
            else
            {
                Settings.SetString(CappedLineCapShapes.Sphere.rawValue, ForKey: .CappedLineCapShape)
            }
        }
        else
        {
            Settings.SetString(CappedLineCapShapes.Sphere.rawValue, ForKey: .CappedLineCapShape)
        }
        var Shape: SCNGeometry!
        switch CapShape
        {
            case .Sphere:
                Shape = SCNSphere(radius: Side)
            
            case .Circle:
                Shape = SCNCylinder(radius: Side * 0.85, height: 0.05)
            
            case .Cone:
                Shape = SCNCone(topRadius: 0.0, bottomRadius: Side, height: Side * 2.5)
            
            case .Box:
                Shape = SCNBox(width: Side * 1.5, height: Side * 1.5, length: Side * 1.5, chamferRadius: 0.0)
            
            case .Square:
                Shape = SCNBox(width: Side * 1.5, height: 0.05, length: Side * 1.5, chamferRadius: 0.0)
        }
        
        Shape.firstMaterial?.diffuse.contents = Diffuse
        Shape.firstMaterial?.specular.contents = UIColor.white
        Shape.firstMaterial?.lightingModel = GetLightModel()
        
        return Shape
    }
    
    /// Get the parameters needed to create an ellipse.
    public static func GetEllipseParameters() -> (Major: CGFloat, Minor: CGFloat)
    {
        var Ellipse = EllipticalShapes.HorizontalMedium
        if let RawEllipseShape = Settings.GetString(ForKey: .EllipseShape)
        {
            if let SomeShape = EllipticalShapes(rawValue: RawEllipseShape)
            {
                Ellipse = SomeShape
            }
        }
        switch Ellipse
        {
            case .HorizontalShort:
                return (1.5, 1.0)
            
            case .HorizontalMedium:
                return (2.0, 1.0)
            
            case .HorizontalLong:
                return (3.0, 1.0)
            
            case .VerticalShort:
                return (1.0, 1.5)
            
            case .VerticalMedium:
                return (1.0, 2.0)
            
            case .VerticalLong:
                return (1.0, 3.0)
        }
    }
    
    /// Generate and return a "flat" node (which is really just a barely extruded 2D shape).
    /// - Warning: If the shape is not recognized, a fatal error is generated.
    /// - Parameter FlatShape: Determines which shape to return.
    /// - Parameter Promience: Prominence of the shape's color.
    /// - Parameter Side: Length of the side of the pixellated region.
    /// - Parameter Color: The color of the node.
    /// - Parameter ZLocation: The returned Z axis location.
    /// - Returns: `SCNNode2` instance with the specfied node.
    public static func GenerateFlatShape(FlatShape: NodeShapes, Prominence: CGFloat, Side: CGFloat,
                                         Color: UIColor, ZLocation: inout CGFloat) -> SCNNode2
    {
        var Node: SCNNode2!
        switch FlatShape
        {
            case .Square2D:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
                Node = SCNNode2(geometry: Geo)
            
            case .Rectangle2D:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 0.75, length: 0.05, chamferRadius: 0.0)
                Node = SCNNode2(geometry: Geo)
            
            case .Circle2D:
                let Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                Node = SCNNode2(geometry: Geo)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Oval2D:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode2(geometry: Geo)
                Node.scale = SCNEllipse.ReciprocalScale()
            
            case .Triangle2D:
                let Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
                Node = SCNNode2(geometry: Geo)
            
            case .Star2D:
                let Dim = Double(Side * 1.5)
                let Geo = SCNStar.Geometry(VertexCount: 5, Height: Dim, Base: Dim * 0.5, ZHeight: 0.05)
                Node = SCNNode2(geometry: Geo)
            
            default:
                Log.AbortMessage("Unexpected flat shape encountered: \(FlatShape.rawValue)", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
            }
        }
        ZLocation = Prominence * 2.0
        Node.geometry?.firstMaterial?.diffuse.contents = Color
        Node.geometry?.firstMaterial?.specular.contents = UIColor.white
        Node.geometry?.firstMaterial?.lightingModel = GetLightModel()
        return Node
    }
    
    private static func MakeShapeList(From Raw: String) -> [NodeShapes]
    {
        if Raw.isEmpty
        {
            return []
        }
        var Results = [NodeShapes]()
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let RawPart = String(Part)
            if let SomeShape = NodeShapes(rawValue: RawPart)
            {
                Results.append(SomeShape)
            }
        }
        return Results
    }
    
    private static func MakeQuickShape(Shape: NodeShapes, Side: CGFloat, Color: UIColor) -> SCNNode
    {
        var Node: SCNNode? = nil
        switch Shape
        {
            case .Blocks:
                Node = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
            
            case .Spheres:
                Node = SCNNode(geometry: SCNSphere(radius: Side))
            
            case .Capsules:
                let Geo = SCNCapsule(capRadius: Side * 0.25, height: Side)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cylinders:
                let Geo = SCNCylinder(radius: Side, height: Side * 2)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cones:
                let (Top, Bottom) = GetConeDimensions(From: Color, Side: Side)
                let Geo = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Side * 2)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Lines:
                let Geo = SCNCapsule(capRadius: 0.1, height: Side)
                Node = SCNNode(geometry: Geo)
            
            case .Triangles:
                let Geo = SCNTriangle.Geometry(A: Float(Side), B: Float(Side), C: Float(Side), Scale: 1.0)
                Node = SCNNode(geometry: Geo)
            
            case .Ellipses:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: Side)
                Node = SCNNode(geometry: Geo)
                Node?.scale = SCNEllipse.ReciprocalScale()
            
            case .Stars:
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
                {
                    ApexCount = ApexCount + Int(Side * 1.3)
                    if ApexCount > 10
                    {
                        ApexCount = 10
                    }
                }
                let Geo = SCNStar.Geometry(VertexCount: ApexCount, Height: Double(Side), Base: Double(Side / 2.0),
                                           ZHeight: Double(Side))
                Node = SCNNode(geometry: Geo)
            
            case .Square2D:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
                Node = SCNNode(geometry: Geo)
            
            case .Circle2D:
                let Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Oval2D:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.scale = SCNEllipse.ReciprocalScale()
            
            case .Triangle2D:
                let Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
                Node = SCNNode(geometry: Geo)
            
            default:
                Node = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
        }
        Node?.geometry?.firstMaterial?.diffuse.contents = Color
        Node?.geometry?.firstMaterial?.specular.contents = UIColor.white
        Node?.geometry?.firstMaterial?.lightingModel = GetLightModel()
        return Node!
    }
    
    private static func MakeStackShape(Prominence: CGFloat, Color: UIColor, Side: CGFloat,
                                       ZLocation: inout CGFloat, DoXRotate: inout Bool) -> SCNNode2
    {
        DoXRotate = false
        ZLocation = 0.0
        let StackNode = SCNNode2()
        var ShapeList = [NodeShapes]()
        if let RawShapeList = Settings.GetString(ForKey: .StackedShapesSet)
        {
            ShapeList = MakeShapeList(From: RawShapeList)
        }
        else
        {
            Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .StackedShapesSet)
            ShapeList.append(NodeShapes.Blocks)
        }
        var Index = 0
        let Count = Int((Prominence * 2.0 / Side)) + 1
        #if true
        for Node in 0 ..< Count
        {
            if Index > ShapeList.count - 1
            {
                Index = 0
            }
            let SubNodeShape = ShapeList[Index]
            Index = Index + 1
            let SubNode = MakeQuickShape(Shape: SubNodeShape, Side: Side, Color: Color)
            SubNode.position = SCNVector3(0.0, 0.0, Side * CGFloat(Node))
            StackNode.addChildNode(SubNode)
        }
        #else
        for Node in 0 ..< Count
        {
            //            let Stacked = SCNNode(geometry: SCNSphere(radius: Side))
            let Stacked = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
            Stacked.geometry?.firstMaterial?.diffuse.contents = Color
            Stacked.geometry?.firstMaterial?.specular.contents = UIColor.white
            Stacked.geometry?.firstMaterial?.lightingModel = GetLightModel()
            Stacked.position = SCNVector3(0.0, 0.0, Side * CGFloat(Node))
            StackNode.addChildNode(Stacked)
            Index = Index + 1
        }
        #endif
        return StackNode
    }
    
    /// Create a node of combined nodes for a given shape type.
    /// - Parameter ForShape: The shape of the node whose node is returned.
    /// - Parameter Side: The length of the side of the node.
    /// - Parameter Prominence: The prominence of the shape.
    /// - Parameter Color: The color of the node.
    /// - Parameter Side: Side size of the node for those nodes that require it.
    /// - Parameter ZLocation: Potentially updated Z location for the final node.
    /// - Parameter DoXRotate: Returned value indicating whether the caller should rotate the shape on the X axis.
    /// - Returns: SCNNode2 with the specified shape. Nil if `ForShape` is not handled by this function.
    public static func GenerateNode(ForShape: NodeShapes, Prominence: CGFloat, Color: UIColor, Side: CGFloat,
                                    ZLocation: inout CGFloat, DoXRotate: inout Bool) -> SCNNode2?
    {
        var AncillaryNode: SCNNode2? = nil
        DoXRotate = false
        
        switch ForShape
        {
            case .StackedShapes:
                return MakeStackShape(Prominence: Prominence, Color: Color, Side: Side, ZLocation: &ZLocation, DoXRotate: &DoXRotate)
            
            case .Ellipses:
                let (Major, Minor) = GetEllipseParameters()
                AncillaryNode = SCNNode2()
                AncillaryNode?.geometry = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: Prominence * 2)
                AncillaryNode?.scale = SCNEllipse.ReciprocalScale()
                AncillaryNode?.geometry?.firstMaterial?.diffuse.contents = Color
                AncillaryNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                AncillaryNode?.geometry?.firstMaterial?.lightingModel = GetLightModel()
            
            case .HueTriangles:
                AncillaryNode = SCNNode2()
                let TriangleGeo = SCNArrowHead.Geometry(Height: Side * 2.5, Base: Side * 1.0, Inset: Side * 0.35, Extrusion: Prominence * 2)
                AncillaryNode?.geometry = TriangleGeo
                AncillaryNode?.geometry?.firstMaterial?.diffuse.contents = Color
                AncillaryNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                AncillaryNode?.geometry?.firstMaterial?.lightingModel = GetLightModel()
                var Hue: CGFloat = 0.0
                var Saturation: CGFloat = 0.0
                var Brightness: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                Color.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
                let HueAngle = fmod((360.0 * Hue) + 180.0, 360.0)
                AncillaryNode?.rotation = SCNVector4(0.0, 0.0, 1.0, -HueAngle * CGFloat.pi / 180.0)
            
            case .PerpendicularSquares:
                AncillaryNode = SCNNode2()
                let Shape1 = SCNBox(width: 0.25 * 2, height: 0.05, length: 0.25 * 2, chamferRadius: 0.0)
                Shape1.firstMaterial?.diffuse.contents = Color
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNBox(width: 0.25 * 2, height: 0.25 * 2.0, length: 0.05, chamferRadius: 0.0)
                Shape2.firstMaterial?.diffuse.contents = Color
                Shape2.firstMaterial?.specular.contents = UIColor.white
                Shape2.firstMaterial?.lightingModel = GetLightModel()
                let Node2 = SCNNode2(geometry: Shape2)
                Node2.position = SCNVector3(0.0, 0.0, 0.0)
                AncillaryNode?.addChildNode(Node1)
                AncillaryNode?.addChildNode(Node2)
                AncillaryNode?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .PerpendicularCircles:
                AncillaryNode = SCNNode2()
                let Shape1 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape1.firstMaterial?.diffuse.contents = Color
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape2.firstMaterial?.diffuse.contents = Color
                Shape2.firstMaterial?.specular.contents = UIColor.white
                Shape2.firstMaterial?.lightingModel = GetLightModel()
                let Node2 = SCNNode2(geometry: Shape2)
                Node2.position = SCNVector3(0.0, 0.0, 0.0)
                Node2.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                AncillaryNode?.addChildNode(Node1)
                AncillaryNode?.addChildNode(Node2)
                AncillaryNode?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .CappedLines:
                var BallLocation = BallLocations.Top
                if let RawLocation = Settings.GetString(ForKey: .CappedLineBallLocation)
                {
                    if let Where = BallLocations(rawValue: RawLocation)
                    {
                        BallLocation = Where
                    }
                    else
                    {
                        BallLocation = BallLocations.Top
                        Settings.SetString("Top", ForKey: .CappedLineBallLocation)
                    }
                }
                else
                {
                    BallLocation = BallLocations.Top
                    Settings.SetString("Top", ForKey: .CappedLineBallLocation)
                }
                AncillaryNode = SCNNode2()
                let Shape1 = SCNCylinder(radius: 0.1, height: Prominence * 2)
                Shape1.firstMaterial?.diffuse.contents = Color
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = GetCappedLineShape(Side: 0.25, Diffuse: Color)
                let Node2 = SCNNode2(geometry: Shape2)
                var BallCoordinate: CGFloat = 0.0
                switch BallLocation
                {
                    case .Top:
                        BallCoordinate = (Prominence * 2.0) / 2.0
                    
                    case .Middle:
                        BallCoordinate = 0.0
                    
                    case .Bottom:
                        BallCoordinate = -((Prominence * 2.0) / 2.0)
                }
                Node2.position = SCNVector3(0.0, BallCoordinate, 0.0)
                AncillaryNode?.addChildNode(Node1)
                AncillaryNode?.addChildNode(Node2)
                DoXRotate = true
            
            case .RadiatingLines:
                var RLineThickness: CGFloat = 0.05
                switch Settings.GetString(ForKey: .RadiatingLineThickness)!
                {
                    case RadiatingLineThicknesses.Thin.rawValue:
                        RLineThickness = 0.02
                    
                    case RadiatingLineThicknesses.Medium.rawValue:
                        RLineThickness = 0.05
                    
                    case RadiatingLineThicknesses.Thick.rawValue:
                        RLineThickness = 0.08
                    default:
                        RLineThickness = 0.05
                }
                AncillaryNode = SCNNode2()
                let UpLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                UpLineGeo.firstMaterial?.diffuse.contents = Color
                UpLineGeo.firstMaterial?.specular.contents = UIColor.white
                UpLineGeo.firstMaterial?.lightingModel = GetLightModel()
                let UpLine = SCNNode(geometry: UpLineGeo)
                AncillaryNode?.addChildNode(UpLine)
                let DownLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                DownLineGeo.firstMaterial?.diffuse.contents = Color
                DownLineGeo.firstMaterial?.specular.contents = UIColor.white
                DownLineGeo.firstMaterial?.lightingModel = GetLightModel()
                let DownLine = SCNNode(geometry: DownLineGeo)
                AncillaryNode?.addChildNode(DownLine)
                let LeftLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                LeftLineGeo.firstMaterial?.diffuse.contents = Color
                LeftLineGeo.firstMaterial?.specular.contents = UIColor.white
                LeftLineGeo.firstMaterial?.lightingModel = GetLightModel()
                let LeftLine = SCNNode(geometry: LeftLineGeo)
                LeftLine.eulerAngles = SCNVector3(0.0, 0.0, 90.0 * Double.pi / 180.0)
                AncillaryNode?.addChildNode(LeftLine)
                let RightLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                RightLineGeo.firstMaterial?.diffuse.contents = Color
                RightLineGeo.firstMaterial?.specular.contents = UIColor.white
                RightLineGeo.firstMaterial?.lightingModel = GetLightModel()
                let RightLine = SCNNode(geometry: RightLineGeo)
                RightLine.eulerAngles = SCNVector3(0.0, 0.0, -90.0 * Double.pi / 180.0)
                AncillaryNode?.addChildNode(RightLine)
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 4
                {
                    let ULGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    ULGeo.firstMaterial?.diffuse.contents = Color
                    ULGeo.firstMaterial?.specular.contents = UIColor.white
                    ULGeo.firstMaterial?.lightingModel = GetLightModel()
                    let ULLine = SCNNode(geometry: ULGeo)
                    ULLine.eulerAngles = SCNVector3(0.0, 0.0, 45.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(ULLine)
                    let LLGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    LLGeo.firstMaterial?.diffuse.contents = Color
                    LLGeo.firstMaterial?.specular.contents = UIColor.white
                    LLGeo.firstMaterial?.lightingModel = GetLightModel()
                    let LLLine = SCNNode(geometry: LLGeo)
                    LLLine.eulerAngles = SCNVector3(0.0, 0.0, 135.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LLLine)
                    let URGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    URGeo.firstMaterial?.diffuse.contents = Color
                    URGeo.firstMaterial?.specular.contents = UIColor.white
                    URGeo.firstMaterial?.lightingModel = GetLightModel()
                    let URLine = SCNNode(geometry: URGeo)
                    URLine.eulerAngles = SCNVector3(0.0, 0.0, -45.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(URLine)
                    let LRGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    LRGeo.firstMaterial?.diffuse.contents = Color
                    LRGeo.firstMaterial?.specular.contents = UIColor.white
                    LRGeo.firstMaterial?.lightingModel = GetLightModel()
                    let LRLine = SCNNode(geometry: LRGeo)
                    LRLine.eulerAngles = SCNVector3(0.0, 0.0, -135.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LRLine)
                }
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 8
                {
                    let UpLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    UpLineGeo.firstMaterial?.diffuse.contents = Color
                    UpLineGeo.firstMaterial?.specular.contents = UIColor.white
                    UpLineGeo.firstMaterial?.lightingModel = GetLightModel()
                    let UpLine = SCNNode(geometry: UpLineGeo)
                    UpLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, 0.0)
                    AncillaryNode?.addChildNode(UpLine)
                    let DownLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    DownLineGeo.firstMaterial?.diffuse.contents = Color
                    DownLineGeo.firstMaterial?.specular.contents = UIColor.white
                    DownLineGeo.firstMaterial?.lightingModel = GetLightModel()
                    let DownLine = SCNNode(geometry: DownLineGeo)
                    DownLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 0.0)
                    AncillaryNode?.addChildNode(DownLine)
                    let LeftLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    LeftLineGeo.firstMaterial?.diffuse.contents = Color
                    LeftLineGeo.firstMaterial?.specular.contents = UIColor.white
                    LeftLineGeo.firstMaterial?.lightingModel = GetLightModel()
                    let LeftLine = SCNNode(geometry: LeftLineGeo)
                    LeftLine.eulerAngles = SCNVector3(0.0, 0.0, 90.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LeftLine)
                    let RightLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    RightLineGeo.firstMaterial?.diffuse.contents = Color
                    RightLineGeo.firstMaterial?.specular.contents = UIColor.white
                    RightLineGeo.firstMaterial?.lightingModel = GetLightModel()
                    let RightLine = SCNNode(geometry: RightLineGeo)
                    RightLine.eulerAngles = SCNVector3(0.0, 0.0, -90.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(RightLine)
                }
                ZLocation = ZLocation * 2.0
            
            default:
                AncillaryNode = nil
        }
        return AncillaryNode
    }
    
    /// Return an `SCNNode2` with combined nodes for a mesh-appearance of the specified location.
    /// - Parameters:
    ///   - X: The horizontal shape location in the original image.
    ///   - Y: The vertical shape location in the original image.
    ///   - XCount: Number of horizontal nodes.
    ///   - YCount: Number of vertical nodes.
    ///   - XLocation: Adjusted horizontal location.
    ///   - YLocation: Adjusted vertical location.
    ///   - ZLocation: Adjusted Z location.
    ///   - Side: Size of the shape's side.
    ///   - HeightSource: How the height source is determined.
    ///   - VerticalExaggeration: Vertical exaggeration value.
    ///   - Color: Color of the current node.
    ///   - RightColor: Color to the right of the node.
    ///   - BottomColor: Color to the bottom of the node.
    ///   - LowerRightColor: Color to the lower-right of the node.
    /// - Returns: `SCNNode2` with appropriate sub-nodes to form a mesh of the image.
    public static func GenerateMesh(X: Int, Y: Int, XCount: Int, YCount: Int, XLocation: Float, YLocation: Float, ZLocation: CGFloat,
                                    Side: CGFloat, HeightSource: HeightSources, VerticalExaggeration: Double,
                                    Color: UIColor, RightColor: UIColor, BottomColor: UIColor,
                                    LowerRightColor: UIColor) -> SCNNode2
    {
        let AncillaryNode = SCNNode2()
        if Settings.GetString(ForKey: .MeshDotSize) != MeshDotSizes.None.rawValue
        {
            var DotRadius: CGFloat = 0.01
            switch Settings.GetString(ForKey: .MeshDotSize)
            {
                case MeshDotSizes.Small.rawValue:
                    DotRadius = 0.08
                
                case MeshDotSizes.Medium.rawValue:
                    DotRadius = 0.2
                
                case MeshDotSizes.Large.rawValue:
                    DotRadius = 0.35
                
                default:
                    DotRadius = 0.2
            }
            let Shape1 = SCNSphere(radius: DotRadius)
            Shape1.firstMaterial?.diffuse.contents = Color
            Shape1.firstMaterial?.specular.contents = UIColor.white
            Shape1.firstMaterial?.lightingModel = GetLightModel()
            let Node1 = SCNNode2(geometry: Shape1)
            AncillaryNode.addChildNode(Node1)
        }
        let SX: Float = XLocation * Float(Side)
        let SY: Float = YLocation * Float(Side)
        
        var RightProminence = GenerateProminence(From: RightColor, VerticalExaggeration: VerticalExaggeration,
                                                 HeightSource: HeightSource)
        RightProminence = RightProminence / 2.0
        var BottomProminence = GenerateProminence(From: BottomColor, VerticalExaggeration: VerticalExaggeration,
                                                  HeightSource: HeightSource)
        BottomProminence = BottomProminence / 2.0
        var LowerRightProminence = GenerateProminence(From: LowerRightColor,
                                                      VerticalExaggeration: VerticalExaggeration,
                                                      HeightSource: HeightSource)
        LowerRightProminence = LowerRightProminence / 2.0
        let RightLocation = Float((X + 1) - (XCount / 2)) * Float(Side)
        let LineToRight = SCNLine1(Start: SCNVector3(SX, SY, Float(ZLocation)),
                                   End: SCNVector3(RightLocation, SY + (YLocation * 0.5), Float(-RightProminence)), Color: Color)
        let BottomLocation = Float((Y - 1) - (YCount / 2)) * Float(Side)
        let LineToBottom = SCNLine1(Start: SCNVector3(SX, SY, Float(ZLocation)),
                                    End: SCNVector3(SX + (XLocation * 0.5), BottomLocation, Float(-BottomProminence)), Color: Color)
        let LineToLR = SCNLine1(Start: SCNVector3(SX, SY, Float(ZLocation)),
                                End: SCNVector3(RightLocation, BottomLocation, Float(-LowerRightProminence)),
                                Color: Color)
        AncillaryNode.addChildNode(LineToRight)
        AncillaryNode.addChildNode(LineToBottom)
        AncillaryNode.addChildNode(LineToLR)
        return AncillaryNode
    }
    
    /// Return geometry for a randomly-chosen letter.
    /// - Parameters:
    ///   - Prominence: Determines the extrusion/height of the letter.
    ///   - LetterFont: The font to draw the letter in.
    ///   - RandomSet: Set of Unicode blocks from which to generate a random character to draw.
    ///   - FinalScale: Final scale to apply to the final node.
    /// - Returns: Geometry for a randomly chosen letter.
    public static func GenerateLetters(Prominence: CGFloat, LetterFont: UIFont, RandomSet: [UnicodeRanges],
                                       FinalScale: inout Double) -> SCNGeometry
    {
        FinalScale = 1.0
        var FinalShape: SCNGeometry? = nil
        
        var RandomLetter = RandomCharacter.Get(FromRanges: RandomSet, InFont: LetterFont)
        if RandomLetter == nil
        {
            RandomLetter = "?"
        }
        var ProminenceMultiplier = 1.0
        if Settings.GetBoolean(ForKey: .FullyExtrudeLetters)
        {
            ProminenceMultiplier = 20.0
        }
        FinalShape = SCNText(string: RandomLetter, extrusionDepth: Prominence * 2 * CGFloat(ProminenceMultiplier))
        let TextShape = FinalShape as? SCNText
        TextShape?.font = LetterFont
        if let Smoothness = Settings.GetString(ForKey: .LetterSmoothness)
        {
            switch Smoothness
            {
                case "Roughest":
                    TextShape?.flatness = 1.2
                
                case "Rough":
                    TextShape?.flatness = 0.8
                
                case "Medium":
                    TextShape?.flatness = 0.5
                
                case "Smooth":
                    TextShape?.flatness = 0.25
                
                case "Smoothest":
                    TextShape?.flatness = 0.0
                
                default:
                    TextShape?.flatness = 0.5
            }
        }
        else
        {
            Settings.SetString("Smooth", ForKey: .LetterSmoothness)
            TextShape?.flatness = 0.0
        }
        FinalScale = 0.035
        return FinalShape!
    }
    
    typealias FontData = (Family: String, Weights: [String], PSNames: [String])
    
    private static func CharacterFont() -> (Font: UIFont, Name: String, Size: CGFloat)
    {
        var FontSize: CGFloat = 20.0
        if Settings.GetBoolean(ForKey: .CharacterRandomFontSize)
        {
            FontSize = CGFloat.random(in: 10.0 ... 30.0)
        }
        else
        {
            FontSize = CGFloat(Settings.GetInteger(ForKey: .FontSize))
        }
        var FontName = Settings.GetString(ForKey: .CharacterFontName)
        if Settings.GetBoolean(ForKey: .CharacterUsesRandomFont)
        {
            #if false
            if RandomFontList == nil
            {
                let FontSizeCount = Settings.GetInteger(ForKey: .CharacterRandomFontCount)
                RandomFontList = Utilities.RandomlySelectedFontList(FontSizeCount)
            }
            FontName = RandomFontList?.randomElement()!
            #else
            FontName = Utilities.GetRandomFont()
            #endif
        }
        return (UIFont(name: FontName!, size: FontSize)!, FontName!, FontSize)
    }
    
    #if false
    public static var RandomFontList: [String]? = nil
    #endif
    
    /// Returns a letter geometry based on user settings and the passed prominence.
    /// - Parameter Prominence: The prominence of the returned geometry.
    /// - Parameter FinalScale: The scale to use by the caller.
    /// - Returns: Geometry for characters.
    public static func GenerateCharacters(Prominence: CGFloat, FinalScale: inout Double) -> SCNGeometry
    {
        FinalScale = 1.0
        var ProminenceMultiplier = 1.0
        if Settings.GetBoolean(ForKey: .FullyExtrudeLetters)
        {
            ProminenceMultiplier = 20.0
        }
        let (Font, RandomFontName, FontSize) = CharacterFont()
        let RandomCharacter = Utilities.RandomCharacterFromFont(RandomFontName, FontSize)
        let FinalShape = SCNText(string: RandomCharacter,
                                 extrusionDepth: Prominence * 2 * CGFloat(ProminenceMultiplier))
        FinalShape.font = Font
        if let Smoothness = Settings.GetString(ForKey: .LetterSmoothness)
        {
            switch Smoothness
            {
                case "Roughest":
                    FinalShape.flatness = 1.2
                
                case "Rough":
                    FinalShape.flatness = 0.8
                
                case "Medium":
                    FinalShape.flatness = 0.5
                
                case "Smooth":
                    FinalShape.flatness = 0.25
                
                case "Smoothest":
                    FinalShape.flatness = 0.0
                
                default:
                    FinalShape.flatness = 0.5
            }
        }
        else
        {
            Settings.SetString("Smooth", ForKey: .LetterSmoothness)
            FinalShape.flatness = 0.0
        }
        FinalScale = 0.035
        return FinalShape
    }
    
    private static func GetCharSet() -> (Random: String, Font: String)
    {
        if let CharSetName = Settings.GetString(ForKey: .CharacterSeries)
        {
            if let CharSet = ShapeSeries(rawValue: CharSetName)
            {
                if let Series = ShapeManager.ShapeMap[CharSet]
                {
                    let Characters = Series.rawValue
                    let Font = ShapeManager.SeriesFontMap[Series]!
                    return (String(Characters.randomElement()!), Font)
                }
            }
        }
        return ("?", "Avenir")
    }
    
    public static func GenerateCharacterFromSet(Prominence: CGFloat, FinalScale: inout Double) -> SCNGeometry
    {
        FinalScale = 1.0
        var ProminenceMultiplier = 1.0
        if Settings.GetBoolean(ForKey: .FullyExtrudeLetters)
        {
            ProminenceMultiplier = 20.0
        }
        let (RandomCharacter, FontName) = GetCharSet()
        let FinalShape = SCNText(string: RandomCharacter,
                                 extrusionDepth: Prominence * 2 * CGFloat(ProminenceMultiplier))
        FinalShape.font = UIFont(name: FontName, size: CGFloat(Settings.GetInteger(ForKey: .FontSize)))
        if let Smoothness = Settings.GetString(ForKey: .LetterSmoothness)
        {
            switch Smoothness
            {
                case "Roughest":
                    FinalShape.flatness = 1.2
                
                case "Rough":
                    FinalShape.flatness = 0.8
                
                case "Medium":
                    FinalShape.flatness = 0.5
                
                case "Smooth":
                    FinalShape.flatness = 0.25
                
                case "Smoothest":
                    FinalShape.flatness = 0.0
                
                default:
                    FinalShape.flatness = 0.5
            }
        }
        else
        {
            Settings.SetString("Smooth", ForKey: .LetterSmoothness)
            FinalShape.flatness = 0.0
        }
        FinalScale = 0.035
        return FinalShape
    }
    
    /// Return an array of geometries for use as shapes.
    /// - Parameter ForShape: The shape to return.
    /// - Parameter Prominence: The prominence of the shape.
    /// - Parameter Color: The base color of the shape.
    /// - Returns: Array of `SCNGeometry` objects for the shape. Nil if `ForShape` is not handled in this function.
    public static func GenerateCombinedShapes(ForShape: NodeShapes, Prominence: CGFloat, Color: UIColor) -> [SCNGeometry]?
    {
        var Combined = [SCNGeometry]()
        
        switch ForShape
        {
            case .CombinedForRGB:
                var RedP: CGFloat = 0.0
                var GreenP: CGFloat = 0.0
                var BlueP: CGFloat = 0.0
                var AlphaP: CGFloat = 0.0
                Color.getRed(&RedP, green: &GreenP, blue: &BlueP, alpha: &AlphaP)
                Combined.append(SCNTorus(ringRadius: RedP, pipeRadius: RedP / 2.0))
                Combined[0].firstMaterial?.diffuse.contents = UIColor(red: RedP, green: 0.0, blue: 0.0, alpha: 1.0)
                Combined[0].firstMaterial?.specular.contents = UIColor.white
                Combined[0].firstMaterial?.lightingModel = GetLightModel()
                Combined.append(SCNSphere(radius: GreenP))
                Combined[1].firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: GreenP, blue: 0.0, alpha: 1.0)
                Combined[1].firstMaterial?.specular.contents = UIColor.white
                Combined[1].firstMaterial?.lightingModel = GetLightModel()
                Combined.append(SCNTorus(ringRadius: BlueP, pipeRadius: BlueP / 2.0))
                Combined[2].firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: BlueP, alpha: 1.0)
                Combined[2].firstMaterial?.specular.contents = UIColor.white
                Combined[2].firstMaterial?.lightingModel = GetLightModel()
            
            case .CombinedForHSB:
                var Gray: CGFloat = 0.0
                var SaturationP: CGFloat = 0.0
                var HueP: CGFloat = 0.0
                var BrightnessP: CGFloat = 0.0
                var AlphaP: CGFloat = 0.0
                Color.getHue(&HueP, saturation: &SaturationP, brightness: &BrightnessP, alpha: &AlphaP)
                var RedP: CGFloat = 0.0
                var GreenP: CGFloat = 0.0
                var BlueP: CGFloat = 0.0
                Color.getRed(&RedP, green: &GreenP, blue: &BlueP, alpha: &AlphaP)
                var NotUsed: CGFloat = 0.0
                Color.getWhite(&Gray, alpha: &NotUsed)
                Combined.append(SCNBox(width: SaturationP, height: SaturationP, length: SaturationP, chamferRadius: 0.0))
                let Channel0Color = UIColor(red: RedP * 0.75, green: GreenP * 0.75, blue: BlueP * 0.75, alpha: 1.0)
                Combined[0].firstMaterial?.diffuse.contents = Channel0Color
                Combined[0].firstMaterial?.specular.contents = UIColor.white
                Combined[0].firstMaterial?.lightingModel = GetLightModel()
                Combined.append(SCNSphere(radius: HueP))
                Combined[1].firstMaterial?.diffuse.contents = Color
                Combined[1].firstMaterial?.specular.contents = UIColor.white
                Combined[1].firstMaterial?.lightingModel = GetLightModel()
                Combined.append(SCNTorus(ringRadius: BrightnessP, pipeRadius: BrightnessP / 2.0))
                Combined[2].firstMaterial?.diffuse.contents = UIColor(red: Gray, green: Gray, blue: Gray, alpha: 1.0)
                Combined[2].firstMaterial?.specular.contents = UIColor.white
                Combined[2].firstMaterial?.lightingModel = GetLightModel()
            
            default:
                return nil
        }
        return Combined
    }
}
