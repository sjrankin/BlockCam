//
//  ShapeGenerator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class ShapeGenerator
{
    public static func CreateShape(_ Shape: NodeShapes, AtX: Int, AtY: Int, DimensionA: CGFloat, DimensionB: CGFloat,
                                   DimensionC: CGFloat, WithColor: UIColor, Prominence: CGFloat) -> SCNNode
    {
        if ShapeManager.MultipleGeometryShapes().contains(Shape)
        {
            return CreateMultiGeometryShape(Shape, AtX: AtX, AtY: AtY, DimensionA: DimensionA, DimensionB: DimensionB,
                                            DimensionC: DimensionC, WithColor: WithColor,
                                            Prominence: Prominence)
        }
        var DoXRotate = false
        var OtherRotation: CGFloat = 1.0
        var NewScale: CGFloat = 1.0
        let Node = SCNNode(geometry: CreateShapeGeometry(Shape, DimensionA: DimensionA, DimensionB: DimensionB,
                                                         DimensionC: DimensionC, WithColor: WithColor,
                                                         Prominence: Prominence, Color: WithColor,
                                                         DoRotateOnX: &DoXRotate, ApplyScale: &NewScale,
                                                         OtherRotation: &OtherRotation))
        if DoXRotate
        {
        Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
        }
        if OtherRotation != 1.0
        {
            Node.rotation = SCNVector4(0.0, 0.0, 0.0, OtherRotation)
        }
        Node.scale = SCNVector3(NewScale, NewScale, NewScale)
        Node.geometry?.firstMaterial?.diffuse.contents = WithColor
        Node.geometry?.firstMaterial?.specular.contents = UIColor.white
        Node.geometry?.firstMaterial?.lightingModel = Generator.GetLightModel()
        return Node
    }
    
    public static func CreateShapeGeometry(_ Shape: NodeShapes, DimensionA Side: CGFloat,
                                           DimensionB: CGFloat, DimensionC: CGFloat, WithColor: UIColor,
                                           Prominence: CGFloat, Color: UIColor, DoRotateOnX: inout Bool,
                                           ApplyScale: inout CGFloat, OtherRotation: inout CGFloat) -> SCNGeometry
    {
        var Geo: SCNGeometry? = nil
        switch Shape
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
            Geo = SCNBox(width: Side, height: Side, length: Side, chamferRadius: Chamfer)
            
            case .Cylinders:
                Geo = SCNCylinder(radius: Side, height: Prominence * 2.0)
            DoRotateOnX = true
            
            case .Cones:
                let (Top, Bottom) = Generator.GetConeDimensions(From: WithColor, Side: Side)
                Geo = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Prominence * 2)
                DoRotateOnX = true
            
            case .Pyramids:
                Geo = SCNPyramid(width: Side, height: Side, length: Prominence * 2.0)
            DoRotateOnX = true
            
            case .Toroids:
                Geo = SCNTorus(ringRadius: Prominence / 4.0, pipeRadius: Side)
            DoRotateOnX = true
            
            case .Spheres:
                Geo = SCNSphere(radius: Side * Prominence)
            
            case .Triangles:
                let VertexValue: Float = Float(Prominence * 1.5)
                Geo = SCNTriangle.Geometry(A: VertexValue, B: VertexValue, C: VertexValue,
                                           Scale: Float(Side * 2.0))
            
            case .Pentagons:
                Geo = SCNnGon.Geometry(VertexCount: 5, Radius: Side, Depth: Prominence * 2.0)
            
            case .Hexagons:
                Geo = SCNnGon.Geometry(VertexCount: 6, Radius: Side, Depth: Prominence * 2.0)
            
            case .Octagons:
                Geo = SCNnGon.Geometry(VertexCount: 8, Radius: Side, Depth: Prominence * 2.0)
            
            case .Tetrahedrons:
                Geo = SCNTetrahedron.Geometry(BaseLength: Side, Height: Prominence * 2.0)
            DoRotateOnX = true
            
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
                Geo = SCNStar.Geometry(VertexCount: ApexCount, Height: Double(Side), Base: Double(Side / 2.0),
                                              ZHeight: Double(Prominence * 2))
            
            case .Capsules:
                Geo = SCNCapsule(capRadius: Side, height: Prominence * 2)
                DoRotateOnX = true
            
            case .Lines:
                Geo = SCNCapsule(capRadius: 0.1, height: Prominence * 2)
                DoRotateOnX = true
            
            case .Diamonds:
                Geo = SCNDiamond.Geometry(MajorAxis: Side, MinorAxis: Side * 3, Height: Prominence * 2)
            
            // Flat Shapes
            
            case .Square2D:
                 Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
            
            case .Rectangle2D:
                 Geo = SCNBox(width: Side * 1.5, height: Side * 0.75, length: 0.05, chamferRadius: 0.0)
            
            case .Circle2D:
                 Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                DoRotateOnX = true
            
            case .Oval2D:
                let (Major, Minor) = Generator.GetEllipseParameters()
                Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                ApplyScale = SCNEllipse.MultiplierReciprocal
            
            case .Triangle2D:
                 Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
            
            case .Star2D:
                let Dim = Double(Side * 1.5)
                 Geo = SCNStar.Geometry(VertexCount: 5, Height: Dim, Base: Dim * 0.5, ZHeight: 0.05)
            
            case .Ellipses:
                let (Major, Minor) = Generator.GetEllipseParameters()
                Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: Prominence * 2.0)
                ApplyScale = SCNEllipse.MultiplierReciprocal
            
            case .HueTriangles:
                Geo = SCNArrowHead.Geometry(Height: Side * 2.5, Base: Side * 1.0, Inset: Side * 0.35,
                                   Extrusion: Prominence * 2.0)
                var Hue: CGFloat = 0.0
                var Saturation: CGFloat = 0.0
                var Brightness: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                Color.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
                let HueAngle = fmod((360.0 * Hue) + 180.0, 360.0)
                OtherRotation = -HueAngle * CGFloat.pi / 180.0
            
            default:
            break
        }
        return Geo!
    }
    
    private static func CreateMultiGeometryShape(_ Shape: NodeShapes, AtX: Int, AtY: Int, DimensionA Side: CGFloat, DimensionB: CGFloat,
                                                 DimensionC: CGFloat, WithColor: UIColor, Prominence: CGFloat) -> SCNNode
    {
        var Node: SCNNode? = nil
        switch Shape
        {
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
                let Shape1 = SCNCylinder(radius: 0.1, height: Prominence * 2)
                Shape1.firstMaterial?.diffuse.contents = WithColor
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = Generator.GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = Generator.GetCappedLineShape(Side: 0.25, Diffuse: WithColor)
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
                Node?.addChildNode(Node1)
                Node?.addChildNode(Node2)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
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
//                let UpLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let UpLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                UpLineGeo.firstMaterial?.diffuse.contents = WithColor
                UpLineGeo.firstMaterial?.specular.contents = UIColor.white
                UpLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                let UpLine = SCNNode(geometry: UpLineGeo)
                Node?.addChildNode(UpLine)
//                let DownLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                                let DownLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                DownLineGeo.firstMaterial?.diffuse.contents = WithColor
                DownLineGeo.firstMaterial?.specular.contents = UIColor.white
                DownLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                let DownLine = SCNNode(geometry: DownLineGeo)
                Node?.addChildNode(DownLine)
//                let LeftLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let LeftLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                LeftLineGeo.firstMaterial?.diffuse.contents = WithColor
                LeftLineGeo.firstMaterial?.specular.contents = UIColor.white
                LeftLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                let LeftLine = SCNNode(geometry: LeftLineGeo)
                LeftLine.eulerAngles = SCNVector3(0.0, 0.0, 90.0 * Double.pi / 180.0)
                Node?.addChildNode(LeftLine)
//                let RightLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                                let RightLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                RightLineGeo.firstMaterial?.diffuse.contents = WithColor
                RightLineGeo.firstMaterial?.specular.contents = UIColor.white
                RightLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                let RightLine = SCNNode(geometry: RightLineGeo)
                RightLine.eulerAngles = SCNVector3(0.0, 0.0, -90.0 * Double.pi / 180.0)
                Node?.addChildNode(RightLine)
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 4
                {
//                    let ULGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                                    let ULGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    ULGeo.firstMaterial?.diffuse.contents = WithColor
                    ULGeo.firstMaterial?.specular.contents = UIColor.white
                    ULGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let ULLine = SCNNode(geometry: ULGeo)
                    ULLine.eulerAngles = SCNVector3(0.0, 0.0, 45.0 * Double.pi / 180.0)
                    Node?.addChildNode(ULLine)
//                    let LLGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let LLGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    LLGeo.firstMaterial?.diffuse.contents = WithColor
                    LLGeo.firstMaterial?.specular.contents = UIColor.white
                    LLGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let LLLine = SCNNode(geometry: LLGeo)
                    LLLine.eulerAngles = SCNVector3(0.0, 0.0, 135.0 * Double.pi / 180.0)
                    Node?.addChildNode(LLLine)
//                    let URGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                    let URGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    URGeo.firstMaterial?.diffuse.contents = WithColor
                    URGeo.firstMaterial?.specular.contents = UIColor.white
                    URGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let URLine = SCNNode(geometry: URGeo)
                    URLine.eulerAngles = SCNVector3(0.0, 0.0, -45.0 * Double.pi / 180.0)
                    Node?.addChildNode(URLine)
//                    let LRGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                                    let LRGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    LRGeo.firstMaterial?.diffuse.contents = WithColor
                    LRGeo.firstMaterial?.specular.contents = UIColor.white
                    LRGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let LRLine = SCNNode(geometry: LRGeo)
                    LRLine.eulerAngles = SCNVector3(0.0, 0.0, -135.0 * Double.pi / 180.0)
                    Node?.addChildNode(LRLine)
                }
                if Settings.GetInteger(ForKey: .RadiatingLineCount) > 8
                {
//                    let UpLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let UpLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    UpLineGeo.firstMaterial?.diffuse.contents = WithColor
                    UpLineGeo.firstMaterial?.specular.contents = UIColor.white
                    UpLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let UpLine = SCNNode(geometry: UpLineGeo)
                    UpLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, 0.0)
                    Node?.addChildNode(UpLine)
//                    let DownLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let DownLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    DownLineGeo.firstMaterial?.diffuse.contents = WithColor
                    DownLineGeo.firstMaterial?.specular.contents = UIColor.white
                    DownLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let DownLine = SCNNode(geometry: DownLineGeo)
                    DownLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 0.0)
                    Node?.addChildNode(DownLine)
//                    let LeftLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let LeftLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    LeftLineGeo.firstMaterial?.diffuse.contents = WithColor
                    LeftLineGeo.firstMaterial?.specular.contents = UIColor.white
                    LeftLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let LeftLine = SCNNode(geometry: LeftLineGeo)
                    LeftLine.eulerAngles = SCNVector3(0.0, 0.0, 90.0 * Double.pi / 180.0)
                    Node?.addChildNode(LeftLine)
//                    let RightLineGeo = SCNCapsule(capRadius: RLineThickness, height: 1.0)
                let RightLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
                    RightLineGeo.firstMaterial?.diffuse.contents = WithColor
                    RightLineGeo.firstMaterial?.specular.contents = UIColor.white
                    RightLineGeo.firstMaterial?.lightingModel = Generator.GetLightModel()
                    let RightLine = SCNNode(geometry: RightLineGeo)
                    RightLine.eulerAngles = SCNVector3(0.0, 0.0, -90.0 * Double.pi / 180.0)
                    Node?.addChildNode(RightLine)
                }
                //ZLocation = ZLocation * 2.0
            
            case .StackedShapes:
            break
            case .HueVarying:
            break
            case .SaturationVarying:
            break
            case .BrightnessVarying:
            break
            case .PerpendicularSquares:
                let Shape1 = SCNBox(width: 0.25 * 2, height: 0.05, length: 0.25 * 2, chamferRadius: 0.0)
                Shape1.firstMaterial?.diffuse.contents = WithColor
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = Generator.GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNBox(width: 0.25 * 2, height: 0.25 * 2.0, length: 0.05, chamferRadius: 0.0)
                Shape2.firstMaterial?.diffuse.contents = WithColor
                Shape2.firstMaterial?.specular.contents = UIColor.white
                Shape2.firstMaterial?.lightingModel = Generator.GetLightModel()
                let Node2 = SCNNode2(geometry: Shape2)
                Node2.position = SCNVector3(0.0, 0.0, 0.0)
                Node?.addChildNode(Node1)
                Node?.addChildNode(Node2)
                Node?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .PerpendicularCircles:
                let Shape1 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape1.firstMaterial?.diffuse.contents = WithColor
                Shape1.firstMaterial?.specular.contents = UIColor.white
                Shape1.firstMaterial?.lightingModel = Generator.GetLightModel()
                let Node1 = SCNNode2(geometry: Shape1)
                Node1.position = SCNVector3(0.0, 0.0, 0.0)
                let Shape2 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape2.firstMaterial?.diffuse.contents = WithColor
                Shape2.firstMaterial?.specular.contents = UIColor.white
                Shape2.firstMaterial?.lightingModel = Generator.GetLightModel()
                let Node2 = SCNNode2(geometry: Shape2)
                Node2.position = SCNVector3(0.0, 0.0, 0.0)
                Node2.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                Node?.addChildNode(Node1)
                Node?.addChildNode(Node2)
                Node?.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .CombinedForHSB:
            break
            case .CombinedForRGB:
            break
            case .Meshes:
               break
            
            default:
            return SCNNode()
        }
        return Node!
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
            Shape1.firstMaterial?.lightingModel = Generator.GetLightModel()
            let Node1 = SCNNode2(geometry: Shape1)
            AncillaryNode.addChildNode(Node1)
        }
        let SX: Float = XLocation * Float(Side)
        let SY: Float = YLocation * Float(Side)
        
        var RightProminence = Generator.GenerateProminence(From: RightColor, VerticalExaggeration: VerticalExaggeration,
                                                 HeightSource: HeightSource)
        RightProminence = RightProminence / 2.0
        var BottomProminence = Generator.GenerateProminence(From: BottomColor, VerticalExaggeration: VerticalExaggeration,
                                                  HeightSource: HeightSource)
        BottomProminence = BottomProminence / 2.0
        var LowerRightProminence = Generator.GenerateProminence(From: LowerRightColor,
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
}
