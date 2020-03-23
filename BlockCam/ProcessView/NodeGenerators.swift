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
    /// Returns a sample image of the passed shape.
    /// - Parameter ForShape: The shape whose sample image will be returned.
    /// - Parameter WithColor: Color to use for the node.
    /// - Returns: Image of the passed shape.
    public static func ShapeImage(_ ForShape: NodeShapes, WithColor: UIColor = UIColor.yellow) -> UIImage
    {
        let SView = SCNView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        SView.scene = SCNScene()
        SView.scene?.background.contents = UIColor.black
        let Light = SCNLight()
        Light.color = UIColor.white
        Light.type = .omni
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(-5.0, 3.0, 10.0)
        SView.scene?.rootNode.addChildNode(LightNode)
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        let CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 2.0)
        SView.scene?.rootNode.addChildNode(CameraNode)
        
        let Colors = [[WithColor]]
        let Node = CreateSceneNodeSet(From: Colors, HBlocks: 1, VBlocks: 1,
                                      ShapeOverride: ForShape, SideOverride: 2.0)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.eulerAngles = SCNVector3(0.0, 45.0 * CGFloat.pi / 180.0, 35.0 * CGFloat.pi / 180.0)
        SView.scene?.rootNode.addChildNode(Node)

        return SView.snapshot()
    }
    
    /// Get the dimensions of a cone given the pixel's color and side.
    /// - Parameter From: The pixel color.
    /// - Parameter Side: The calculated side value.
    /// - Returns: Tuple of the top and bottom sizes of the cone.
    public static func GetConeDimensions(From: UIColor, Side: CGFloat) -> (Top: CGFloat, Base: CGFloat)
    {
        let DoInvert = Settings.GetBoolean(ForKey: .ConeIsInverted)
        var TopSize = ConeTopOptions.TopIsZero
        let TopValue = Settings.GetEnum(ForKey: .ConeTopOptions, EnumType: ConeTopOptions.self,
                                        Default: ConeTopOptions.TopIsZero)
        #if false
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
        #endif
        //var BaseSize = ConeBaseOptions.BaseIsSide
        let BaseSize = Settings.GetEnum(ForKey: .ConeBottomOptions, EnumType: ConeBaseOptions.self,
                                        Default: .BaseIsSide)
        #if false
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
        #endif
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
    
    /// Gets the current chamfer setting and returns a numeric equivalent.
    /// - Returns: Numeric value based on the saved chamfer size.
    public static func GetBaseChamfer() -> CGFloat
    {
        let Chamfer = Settings.GetEnum(ForKey: .BlockChamferSize, EnumType: BlockEdgeSmoothings.self,
                                       Default: .None)
        switch Chamfer
        {
            case .None:
                return 0.0
            
            case .Small:
                return 0.08
            
            case .Medium:
                return 0.15
            
            case .Large:
                return 0.25
        }
    }
    
    /// Create simple node geometry for basic extruded shapes.
    /// - Parameter ForShape: The shape of the node whose geometry is returned.
    /// - Parameter Side: The length of the side of the geometry.
    /// - Parameter Prominence: The prominence of the shape.
    /// - Parameter DoXRotate: Returned value indicating whether the caller should rotate the shape on the X axis.
    /// - Parameter WithColor: The color needed by some shapes for variable sizes.
    /// - Parameter ZLocation: New Z location for shapes that need to be moved.
    /// - Returns: SCNGeometry with the specified shape. Nil if `ForShape` is not handled by this function.
    public static func GenerateNodeGeometry(ForShape: NodeShapes, Side: CGFloat, Prominence: CGFloat, DoXRotate: inout Bool,
                                            WithColor: UIColor, ZLocation: inout CGFloat) -> SCNGeometry?
    {
        var FinalShape: SCNGeometry? = nil
        DoXRotate = false
        ZLocation = 0.0
        
        switch ForShape
        {
            case .Blocks:
                let Chamfer = GetBaseChamfer()
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
                let Behavior = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self,
                                                Default: .Size)
                var FinalRadius = Side
                switch Behavior
                {
                    case .Size:
                        FinalRadius = Side * Prominence
                    
                    case .Location:
                        FinalRadius = Side * Prominence * 0.5
                        ZLocation = Prominence * 2.0
                    
                    case .Both:
                        FinalRadius = Side * Prominence * 0.85
                        ZLocation = Prominence * 1.5
                }
                FinalShape = SCNSphere(radius: FinalRadius)
            
            case .Polygons:
                var SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                if Settings.GetBoolean(ForKey: .PolygonSideCountVaries)
                {
                    SideCount = SideCount + Int(Prominence * 1.3)
                    if SideCount > 12
                    {
                        SideCount = 12
                    }
                }
                FinalShape = SCNnGon.Geometry(VertexCount: SideCount, Radius: Side, Depth: Prominence * 2.0)
            
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
    
    /// Returns a color for the line for the capped line shape. The color is determined by user settings.
    /// - Parameter BasedOn: The base color of the shape.
    /// - Returns: Color to use for the line.
    public static func GetCappedLineColor(BasedOn: UIColor) -> UIColor
    {
        let LineColor = Settings.GetEnum(ForKey: .CappedLineLineColor, EnumType: CappedLineLineColors.self,
                                         Default: CappedLineLineColors.Same)
        switch LineColor
        {
            case .Same:
                return BasedOn
            
            case .Black:
                return UIColor.black
            
            case .White:
                return UIColor.white
            
            case .Darker:
                return BasedOn.Darken(By: 0.7)
            
            case .Lighter:
                return BasedOn.Brighten(By: 0.4)
        }
    }
    
    /// Returns the shape the user selected as the cap of a capped line shape.
    /// - Parameter Side: The radius of a sphere. Multiplied by various constants for other shapes.
    /// - Parameter Diffuse: The diffuse material color.
    /// - Reurns: Geometry for the specified (in user defaults) shape.
    public static func GetCappedLineShape(Side: CGFloat, Diffuse: UIColor) -> SCNGeometry
    {
        #if true
        let CapShape = Settings.GetEnum(ForKey: .CappedLineCapShape, EnumType: CappedLineCapShapes.self,
                                        Default: CappedLineCapShapes.Sphere)
        #else
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
        #endif
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

        SetMaterials(To: Shape, With: Diffuse)
        
        return Shape
    }
    
    /// Get the parameters needed to create an ellipse.
    public static func GetEllipseParameters() -> (Major: CGFloat, Minor: CGFloat)
    {
        #if true
        let Ellipse = Settings.GetEnum(ForKey: .EllipseShape, EnumType: EllipticalShapes.self,
                                       Default: .HorizontalMedium)
        #else
        var Ellipse = EllipticalShapes.HorizontalMedium
        if let RawEllipseShape = Settings.GetString(ForKey: .EllipseShape)
        {
            if let SomeShape = EllipticalShapes(rawValue: RawEllipseShape)
            {
                Ellipse = SomeShape
            }
        }
        #endif
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
    /// - ToDo: Update size generation for .Diamond2D.
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
            
            case .Star2D:
                let Dim = Double(Side * 1.5)
                let Geo = SCNStar.Geometry(VertexCount: 5, Height: Dim, Base: Dim * 0.5, ZHeight: 0.05)
                Node = SCNNode2(geometry: Geo)
            
            case .Polygon2D:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                let Geo = SCNnGon.Geometry(VertexCount: SideCount, Radius: Side * 1.5, Depth: 0.05)
                Node = SCNNode2(geometry: Geo)
            
            case .Diamond2D:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNDiamond.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode2(geometry: Geo)
            
            default:
                Log.AbortMessage("Unexpected flat shape encountered: \(FlatShape.rawValue)", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
            }
        }
        ZLocation = Prominence * 2.0
        SetMaterials(To: Node.geometry!, With: Color)
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
    
    /// Make a shape quickly for use as sub-shapes.
    /// - Parameter Shape: The shape to create and return.
    /// - Parameter Side: The length of a side of a shape.
    /// - Parameter Color: The color of the resultant shape.
    /// - Returns: Node with the shape.
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
            
            case .Polygons:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                let Geo = SCNnGon.Geometry(VertexCount: SideCount, Radius: Side, Depth: Side)
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
            
            case .Circle2D:
                let Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Oval2D:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.scale = SCNEllipse.ReciprocalScale()
            
            case .Diamond2D:
                let (Major, Minor) = GetEllipseParameters()
                let Geo = SCNDiamond.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode(geometry: Geo)
            
            case .Polygon2D:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                let Geo = SCNnGon.Geometry(VertexCount: SideCount, Radius: Side * 1.5, Depth: 0.05)
                Node = SCNNode2(geometry: Geo)
            
            default:
                Node = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
        }
        SetMaterials(To: Node!.geometry!, With: Color)
        return Node!
    }
    
    /// Create a stack of shapes.
    /// - Warming: Stacked shape shapes are very slow to render.
    /// - Parameter Prominence: The color prominence.
    /// - Parameter Color: The color of the cell.
    /// - Parameter Side: The size length of the shape.
    /// - Parameter ZLocation: The Z axis location for the shape.
    /// - Parameter DoXRotate: Tells the caller whether or not to rotate the final shape.
    /// - Returns: Node with a set of sub-nodes.
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
        return StackNode
    }
    
    /// Returns a shape to be used in conjection with a base shape for certain combined shapes.
    /// - Warning: Generates a fatal error if `For` does not have an associated extruded shape.
    /// - Parameter For: The base shape type.
    /// - Returns: The extruded shape to add to the base shape.
    public static func GetPlusShape(For: NodeShapes) -> NodeShapes
    {
        switch For
        {
            case .SpherePlus:
                return Settings.GetEnum(ForKey: .SpherePlusShape, EnumType: NodeShapes.self,
                                        Default: NodeShapes.Blocks)
            
            case .BoxPlus:
                return Settings.GetEnum(ForKey: .BoxPlusShape, EnumType: NodeShapes.self,
                                        Default: NodeShapes.Spheres)
            
            default:
                fatalError("Encountered unsupported shape (\(For.rawValue)) in GetPlusShape.")
        }
    }
    
    /// Creates a base shape along with an extruded shape added to it.
    /// - Parameter ForShape: The base shape (must be a valid plus shape).
    /// - Parameter Prominence: The color prominence for the shape.
    /// - Parameter Color: The color of the shape.
    /// - Parameter Side: The side value of the shape.
    /// - Parameter ZLocation: If needed, new Z location for the returned shape.
    /// - Parameter DoXRotate: Returns true if the shape needs to be rotated along the X axis.
    /// - Returns: Node with a combined shapes.
    public static func MakePlusShape(ForShape: NodeShapes, Prominence: CGFloat, Color: UIColor, Side: CGFloat,
                                     ZLocation: inout CGFloat, DoXRotate: inout Bool) -> SCNNode2?
    {
        var AncillaryNode: SCNNode2? = nil
        DoXRotate = false
        
        switch ForShape
        {
            case .SpherePlus:
                let ExtrudedShape = GetPlusShape(For: ForShape)
                let SphereHeight = Prominence * 2.0
                let Chamfer = GetBaseChamfer()
                let Sphere = SCNSphere(radius: Side / 2.0)
                SetMaterials(To: Sphere, With: Color)
                let SphereNode = SCNNode(geometry: Sphere)
                AncillaryNode = SCNNode2()
                AncillaryNode?.addChildNode(SphereNode)
                var Geo = SCNGeometry()
                var ExZ: CGFloat = Side / 4.0
                var RotateOnX = false
                switch ExtrudedShape
                {
                    case .Spheres:
                        Geo = SCNSphere(radius: Side * 0.25)
                    
                    case .Blocks:
                        Geo = SCNBox(width: Side * 0.45, height: Side * 0.45, length: Side * 0.45,
                                     chamferRadius: Chamfer * 0.75)
                    
                    case .Cones:
                        Geo = SCNCone(topRadius: 0.0, bottomRadius: Side * 0.25, height: Side)
                        RotateOnX = true
                    
                    case .Lines:
                        Geo = SCNBox(width: 0.05, height: 0.05, length: Side * 2.5, chamferRadius: 0.0)
                    
                    case .Capsules:
                        Geo = SCNCapsule(capRadius: Side * 0.25, height: Side * 2.5)
                        RotateOnX = true
                    
                    case .Cylinders:
                        Geo = SCNCylinder(radius: Side * 0.25, height: Side * 3.0)
                        RotateOnX = true
                    
                    default:
                        Geo = SCNSphere(radius: Side * 0.25)
                }
                SetMaterials(To: Geo, With: Color)
                let OtherNode = SCNNode(geometry: Geo)
                if RotateOnX
                {
                    OtherNode.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                }
                OtherNode.position = SCNVector3(0.0, 0.0, ExZ)
                AncillaryNode!.addChildNode(OtherNode)
                ZLocation = SphereHeight
            
            case .BoxPlus:
                let ExtrudedShape = GetPlusShape(For: ForShape)
                let BoxHeight = Prominence * 2.0
                let Chamfer = GetBaseChamfer()
                let Box = SCNBox(width: Side, height: Side, length: BoxHeight, chamferRadius: Chamfer)
                SetMaterials(To: Box, With: Color)
                let BoxNode = SCNNode(geometry: Box)
                BoxNode.position = SCNVector3(0.0, 0.0, 0.0)
                AncillaryNode = SCNNode2()
                AncillaryNode?.addChildNode(BoxNode)
                var Geo = SCNGeometry()
                var ExZ: CGFloat = 0.0
                var RotateOnX = false
                switch ExtrudedShape
                {
                    case .Spheres:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNSphere(radius: Side * 0.15)
                    
                    case .Blocks:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNBox(width: Side * 0.65, height: Side * 0.65, length: Side * 0.65,
                                     chamferRadius: Chamfer * 0.75)
                    
                    case .Cones:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNCone(topRadius: 0.0, bottomRadius: Side * 0.25, height: Side)
                        RotateOnX = true
                    
                    case .Lines:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNBox(width: 0.05, height: 0.05, length: Side * 2.5, chamferRadius: 0.0)
                    
                    case .Capsules:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNCapsule(capRadius: Side * 0.25, height: Side)
                        RotateOnX = true
                    
                    case .Pyramids:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNPyramid(width: Side * 0.65, height: Side, length: Side * 0.65)
                        RotateOnX = true
                    
                    case .Cylinders:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNCylinder(radius: Side * 0.25, height: Side * 2.0)
                        RotateOnX = true
                    
                    default:
                        ExZ = BoxHeight / 2.0
                        Geo = SCNSphere(radius: Side * 0.15)
                }
                SetMaterials(To: Geo, With: Color)
                let OtherNode = SCNNode(geometry: Geo)
                if RotateOnX
                {
                    OtherNode.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                }
                OtherNode.position = SCNVector3(0.0, 0.0, ExZ)
                AncillaryNode!.addChildNode(OtherNode)
                ZLocation = 0.0
            
            default:
                break
        }
        return AncillaryNode
    }
    
    /// Returns a random position in the defined cube.
    /// - Parameter BoxSideLength: The length of each side of the cube.
    /// - Returns: Randomly generated location in the cube.
    public static func GetRandomPosition(BoxSideLength: CGFloat) -> SCNVector3
    {
        let X = CGFloat.random(in: -BoxSideLength ... BoxSideLength)
        let Y = CGFloat.random(in: -BoxSideLength ... BoxSideLength)
        let Z = CGFloat.random(in: -BoxSideLength ... BoxSideLength)
        return SCNVector3(X, Y, Z)
    }
    
    /// Creates and returns a random shape in the sense the base shape and sub-shapes are all well-
    /// defined by the user, but the location of each sub-shape is randomly assigned.
    /// - Warning: Rendering many of this type of shape is very slow.
    /// - Parameter Prominence: The color prominence.
    /// - Parameter Color: The color of the shape.
    /// - Parameter Side: The length of each side of the shape.
    /// - Parameter ZLocation: Potentially updated Z location for the shape.
    /// - Returns: Node with probably several sub-nodes.
    public static func MakeRandomShape(Prominence: CGFloat, Color: UIColor, Side: CGFloat,
                                       ZLocation: inout CGFloat) -> SCNNode2
    {
        let RandomShape = Settings.GetEnum(ForKey: .RandomBaseShape, EnumType: NodeShapes.self,
                                           Default: .Spheres)
        let ShowBaseShape = Settings.GetBoolean(ForKey: .RandomShapeShowsBase)
        let Intensity = Settings.GetEnum(ForKey: .RandomIntensity, EnumType: RandomIntensities.self,
                                         Default: .Moderate)
        let Radius = Settings.GetEnum(ForKey: .RandomRadius, EnumType: RandomRadiuses.self,
                                      Default: .Medium)
        var Radial = 1.0
        switch Radius
        {
            case .VeryClose:
                Radial = 1.5
            
            case .Close:
                Radial = 2.0
            
            case .Medium:
                Radial = 3.0
            
            case .Far:
                Radial = 3.5
            
            case .VeryFar:
                Radial = 5.0
        }
        var Count = 6
        switch Intensity
        {
            case .VeryWeak:
                Count = 3
            
            case .Weak:
                Count = 5
            
            case .Moderate:
                Count = 8
            
            case .Strong:
                Count = 12
            
            case .VeryStrong:
                Count = 16
        }
        
        let Parent = SCNNode2()
        if ShowBaseShape
        {
            var Geo = SCNGeometry()
            switch RandomShape
            {
                case .Spheres:
                    Geo = SCNSphere(radius: Side / 2.0)
                
                case .Blocks:
                    Geo = SCNBox(width: Side, height: Side, length: Side, chamferRadius: GetBaseChamfer())
                
                case .Circle2D:
                    Geo = SCNCylinder(radius: Side / 2.0, height: 0.05)
                
                case .Rectangle2D:
                    Geo = SCNBox(width: Side, height: Side * 0.75, length: 0.05, chamferRadius: 0.0)
                
                default:
                    fatalError("Unexpected shape (\(RandomShape.rawValue)) found in MakeRandomShape")
            }
            SetMaterials(To: Geo, With: Color)
            let Center = SCNNode(geometry: Geo)
            if RandomShape == .Circle2D
            {
                Center.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            }
            Parent.addChildNode(Center)
        }
        for _ in 0 ... Count
        {
            let HalfSide = Side * 0.5
            var Geo = SCNGeometry()
            switch RandomShape
            {
                case .Spheres:
                    Geo = SCNSphere(radius: HalfSide / 2.0)
                
                case .Blocks:
                    Geo = SCNBox(width: HalfSide, height: HalfSide, length: HalfSide,
                                 chamferRadius: GetBaseChamfer() * 0.5)
                
                case .Circle2D:
                    Geo = SCNCylinder(radius: HalfSide / 2.0, height: 0.05)
                
                case .Rectangle2D:
                    Geo = SCNBox(width: HalfSide, height: HalfSide * 0.75, length: 0.05, chamferRadius: 0.0)
                
                default:
                    fatalError("Unexpected shape (\(RandomShape.rawValue)) found in MakeRandomShape")
            }
            SetMaterials(To: Geo, With: Color)
            let Child = SCNNode(geometry: Geo)
            if RandomShape == .Circle2D
            {
                Child.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            }
            Child.position = GetRandomPosition(BoxSideLength: CGFloat(Radial))
            Parent.addChildNode(Child)
        }
        return Parent
    }
    
    /// Map from the general-purpose shape enum to the platonic solid enum.
    static private let SolidMap: [NodeShapes: PlatonicSolids] =
    [
    .Tetrahedrons: .Tetrahedron,
    .Cubes: .Cube,
    .Octahedrons: .Octahedron,
    .Dodecahedrons: .Dodecahedron,
    .Icosahedrons: .Icosahedron
    ]
    
    /// Create a regular geometric solid.
    /// - Parameter ForShape: Determines the solid to create.
    /// - Parameter Prominence: The color prominence that determines the height or size of the solid.
    /// - Parameter Color: The color of the shape.
    /// - Parameter Side: The side value for the shape.
    /// - Parameter ZLocation: The location of the shape in the Z axis if user settings use it.
    /// - Returns: Node with the specified regular solid.
    public static func GenerateRegularSolid(ForShape: NodeShapes, Prominence: CGFloat, Color: UIColor,
                                            Side: CGFloat, ZLocation: inout CGFloat) -> SCNNode2?
    {
        ZLocation = 0.0
        var ShapeScale = SCNVector3(1.0, 1.0, 1.0)
        let FinalShape = SCNPlatonicSolid.Geometry(Solid: SolidMap[ForShape]!)!
        FinalShape.firstMaterial = SCNMaterial()
        
        switch Settings.GetEnum(ForKey: .RegularSolidBehavior, EnumType: RegularSolidBehaviors.self,
                                Default: .Size)
        {
            case .Location:
                ZLocation = Prominence * 2
            
            case .Size:
                ShapeScale = SCNVector3(Prominence, Prominence, Prominence)
        }

        SetMaterials(To: FinalShape, With: Color)
        let Node = SCNNode2(geometry: FinalShape)
        Node.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        Node.scale = ShapeScale
        return Node
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
            case .EmbeddedBlocks:
                AncillaryNode = SCNNode2()
                let Chamfer = GetBaseChamfer()
                let SideValue = Side + Prominence
                let Box1Geo = SCNBox(width: SideValue, height: SideValue, length: SideValue, chamferRadius: Chamfer)
                SetMaterials(To: Box1Geo, With: Color)
                let Box1 = SCNNode(geometry: Box1Geo)
                Box1.position = SCNVector3(0.0, 0.0, 0.0)
                let Box2Geo = SCNBox(width: SideValue, height: SideValue, length: SideValue, chamferRadius: Chamfer)
                let Box2RelativeColor = Settings.GetEnum(ForKey: .EmbeddedBoxColor, EnumType: RelativeColors.self,
                                                         Default: .Darker)
               let Box2Color = Color.RelativeColor(Box2RelativeColor)
                SetMaterials(To: Box2Geo, With: Box2Color)
                let Box2 = SCNNode(geometry: Box2Geo)
                Box2.position = SCNVector3(0.0, 0.0, 0.0)
                Box2.eulerAngles = SCNVector3(45.0 * CGFloat.pi / 180.0, 45.0 * CGFloat.pi / 180.0, 0.0)
                AncillaryNode?.addChildNode(Box1)
                AncillaryNode?.addChildNode(Box2)
                ZLocation = Prominence
            
            case .SphereWithTorus:
                AncillaryNode = SCNNode2()
                let Radius = (Side / 2.0) + (Prominence / 3.0)
                let Sphere = SCNSphere(radius: Radius)
                SetMaterials(To: Sphere, With: Color)
                let SphereNode = SCNNode(geometry: Sphere)
                SphereNode.position = SCNVector3(0.0, 0.0, 0.0)
                let Torus = SCNTorus(ringRadius: Radius * 1.2, pipeRadius: Radius * 0.5)
                let TorusRelativeColor = Settings.GetEnum(ForKey: .SphereRingColor, EnumType: RelativeColors.self,
                                                          Default: .Darker)
                let TorusColor = Color.RelativeColor(TorusRelativeColor) 
                SetMaterials(To: Torus, With: TorusColor)
                let TorusNode = SCNNode(geometry: Torus)
                TorusNode.position = SCNVector3(0.0, 0.0, 0.0)
                let RingRotation = Settings.GetEnum(ForKey: .SphereRingOrientation, EnumType: RingOrientations.self,
                                                    Default: .Flat)
                switch RingRotation
                {
                    case .Flat:
                TorusNode.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                    
                    case .Extruded:
                        break
                    
                    case .Hue:
                        let (Hue, _, _) = Color.HSB
                        let Degrees = 360.0 * Hue
                        TorusNode.eulerAngles = SCNVector3(Degrees * CGFloat.pi / 180.0, 0.0, 0.0)
                    
                    case .Saturation:
                        let (_, Saturation, _) = Color.HSB
                        let Degrees = 360.0 * Saturation
                        TorusNode.eulerAngles = SCNVector3(Degrees * CGFloat.pi / 180.0, 0.0, 0.0)
                    
                    case .Brightness:
                        let (_, _, Brightness) = Color.HSB
                        let Degrees = 360.0 * Brightness
                        TorusNode.eulerAngles = SCNVector3(Degrees * CGFloat.pi / 180.0, 0.0, 0.0)
                    
                    case .HueBrightness:
                        let (Hue, _, Brightness) = Color.HSB
                        let HueDegrees = 360.0 * Hue
                        let BrightDegrees = 360.0 * Brightness
                        TorusNode.eulerAngles = SCNVector3(HueDegrees * CGFloat.pi / 180.0,
                                                           BrightDegrees * CGFloat.pi / 180.0,
                                                           0.0)
                    
                    case .HueSaturation:
                        let (Hue, Saturation, _) = Color.HSB
                        let HueDegrees = 360.0 * Hue
                        let SaturationDegrees = 360.0 * Saturation
                        TorusNode.eulerAngles = SCNVector3(HueDegrees * CGFloat.pi / 180.0,
                                                           SaturationDegrees * CGFloat.pi / 180.0,
                                                           0.0)
                }
                AncillaryNode?.addChildNode(SphereNode)
                AncillaryNode?.addChildNode(TorusNode)
                ZLocation = Prominence
            
            case .Random:
                return MakeRandomShape(Prominence: Prominence, Color: Color, Side: Side,
                                       ZLocation: &ZLocation)
            
            case .SpherePlus, .BoxPlus:
                return MakePlusShape(ForShape: ForShape, Prominence: Prominence, Color: Color,
                                     Side: Side, ZLocation: &ZLocation, DoXRotate: &DoXRotate)
            
            case .StackedShapes:
                return MakeStackShape(Prominence: Prominence, Color: Color, Side: Side,
                                      ZLocation: &ZLocation, DoXRotate: &DoXRotate)
            
            case .Ellipses:
                let (Major, Minor) = GetEllipseParameters()
                AncillaryNode = SCNNode2()
                AncillaryNode?.geometry = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: Prominence * 2)
                AncillaryNode?.scale = SCNEllipse.ReciprocalScale()
                SetMaterials(To: AncillaryNode!.geometry!, With: Color)
            
            case .HueTriangles:
                AncillaryNode = SCNNode2()
                let TriangleGeo = SCNArrowHead.Geometry(Height: Side * 2.5, Base: Side * 1.0, Inset: Side * 0.35, Extrusion: Prominence * 2)
                AncillaryNode?.geometry = TriangleGeo
                SetMaterials(To: AncillaryNode!.geometry!, With: Color)
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
                SetMaterials(To: Shape1, With: Color)
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNBox(width: 0.25 * 2, height: 0.25 * 2.0, length: 0.05, chamferRadius: 0.0)
                SetMaterials(To: Shape2, With: Color)
                let Node2 = SCNNode2(geometry: Shape2)
                Node2.position = SCNVector3(0.0, 0.0, 0.0)
                AncillaryNode?.addChildNode(Node1)
                AncillaryNode?.addChildNode(Node2)
                AncillaryNode?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .PerpendicularCircles:
                AncillaryNode = SCNNode2()
                let Shape1 = SCNCylinder(radius: 0.25, height: 0.05)
                SetMaterials(To: Shape1, With: Color)
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNCylinder(radius: 0.25, height: 0.05)
                SetMaterials(To: Shape2, With: Color)
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
                let LineColor = GetCappedLineColor(BasedOn: Color)
                SetMaterials(To: Shape1, With: LineColor)
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
                let UpLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                SetMaterials(To: UpLineGeo, With: Color)
                let UpLine = SCNNode(geometry: UpLineGeo)
                UpLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 0.0)
                AncillaryNode?.addChildNode(UpLine)
                
                let DownLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                SetMaterials(To: DownLineGeo, With: Color)
                let DownLine = SCNNode(geometry: DownLineGeo)
                DownLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, 0.0)
                AncillaryNode?.addChildNode(DownLine)
                
                let LeftLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                SetMaterials(To: LeftLineGeo, With: Color)
                let LeftLine = SCNNode(geometry: LeftLineGeo)
                LeftLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 90.0 * Double.pi / 180.0)
                AncillaryNode?.addChildNode(LeftLine)
                
                let RightLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                SetMaterials(To: RightLineGeo, With: Color)
                let RightLine = SCNNode(geometry: RightLineGeo)
                RightLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, -90.0 * Double.pi / 180.0)
                AncillaryNode?.addChildNode(RightLine)
                
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 4
                {
                    let ULGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: ULGeo, With: Color)
                    let ULLine = SCNNode(geometry: ULGeo)
                    ULLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 45.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(ULLine)
                    
                    let LLGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: LLGeo, With: Color)
                    let LLLine = SCNNode(geometry: LLGeo)
                    LLLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 135.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LLLine)
                    
                    let URGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: URGeo, With: Color)
                    let URLine = SCNNode(geometry: URGeo)
                    URLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, -45.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(URLine)
                    
                    let LRGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: LRGeo, With: Color)
                    let LRLine = SCNNode(geometry: LRGeo)
                    LRLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, -135.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LRLine)
                }
                
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 8
                {
                    let UpLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: UpLineGeo, With: Color)
                    let UpLine = SCNNode(geometry: UpLineGeo)
                    UpLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 90.0 * Double.pi / 180.0, 90.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(UpLine)
                    
                    let DownLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: DownLineGeo, With: Color)
                    let DownLine = SCNNode(geometry: DownLineGeo)
                    DownLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 90.0 * Double.pi / 180.0, 90.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(DownLine)
                    
                    let LeftLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: LeftLineGeo, With: Color)
                    let LeftLine = SCNNode(geometry: LeftLineGeo)
                    LeftLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 90.0 * Double.pi / 180.0)
                    AncillaryNode?.addChildNode(LeftLine)
                    
                    let RightLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    SetMaterials(To: RightLineGeo, With: Color)
                    let RightLine = SCNNode(geometry: RightLineGeo)
                    RightLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, -90.0 * Double.pi / 180.0)
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
        #if true
        var DotRadius: CGFloat = 0.01
        var NoDots = false
        switch Settings.GetEnum(ForKey: .MeshDotSize, EnumType: MeshDotSizes.self, Default: MeshDotSizes.Small)
        {
            case .Small:
                DotRadius = 0.08
            
            case .Medium:
                DotRadius = 0.2
            
            case .Large:
                DotRadius = 0.35
            
            case .None:
                NoDots = true
        }
        if !NoDots
        {
            let Shape1 = SCNSphere(radius: DotRadius)
            SetMaterials(To: Shape1, With: Color)
            let Node1 = SCNNode2(geometry: Shape1)
            AncillaryNode.addChildNode(Node1)
        }
        #else
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
            SetMaterials(To: Shape1, With: Color)
            let Node1 = SCNNode2(geometry: Shape1)
            AncillaryNode.addChildNode(Node1)
        }
        #endif
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
        TextShape?.flatness = SmoothMap[Settings.GetEnum(ForKey: .LetterFont, EnumType: LetterSmoothnesses.self, Default: .Smooth)]!
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
        FinalShape.flatness = SmoothMap[Settings.GetEnum(ForKey: .LetterFont, EnumType: LetterSmoothnesses.self, Default: .Smooth)]!
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
        FinalShape.flatness = SmoothMap[Settings.GetEnum(ForKey: .LetterFont, EnumType: LetterSmoothnesses.self, Default: .Smooth)]!
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
                SetMaterials(To: Combined[0], With: UIColor(red: RedP, green: 0.0, blue: 0.0, alpha: 1.0))
                Combined.append(SCNSphere(radius: GreenP))
                SetMaterials(To: Combined[1], With: UIColor(red: 0.0, green: GreenP, blue: 0.0, alpha: 1.0))
                Combined.append(SCNTorus(ringRadius: BlueP, pipeRadius: BlueP / 2.0))
                SetMaterials(To: Combined[2], With: UIColor(red: 0.0, green: 0.0, blue: BlueP, alpha: 1.0))
            
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
                SetMaterials(To: Combined[0], With: Channel0Color)
                Combined.append(SCNSphere(radius: HueP))
                SetMaterials(To: Combined[1], With: Color)
                Combined.append(SCNTorus(ringRadius: BrightnessP, pipeRadius: BrightnessP / 2.0))
                SetMaterials(To: Combined[2], With: UIColor(red: Gray, green: Gray, blue: Gray, alpha: 1.0))
            
            default:
                return nil
        }
        return Combined
    }
}
