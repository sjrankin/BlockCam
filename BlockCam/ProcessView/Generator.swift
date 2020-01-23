//
//  Generator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif
import SceneKit
import CoreImage
import CoreMedia
import CoreVideo
import AVFoundation
import Photos

class Generator
{
    /// Delegate to the main class.
    public static var Delegate: MainProtocol? = nil
    
    /// Contains the most recent original image size. Set in `PrepareImage`.
    public static var OriginalImageSize: CGSize = CGSize.zero
    
    /// Contains the most recent reduced image size. Set in `PrepareImage`.
    public static var ReducedImageSize: CGSize = CGSize.zero
    
    /// Prepare an image to be processed.
    /// - Note:
    ///   1. Images are rotated 90° right.
    ///   2. Images are resized as required as determined by the original image size and the `.MaxImageDimension` setting.
    /// - Parameter Image: The image to prepare.
    /// - Returns: Resized (potentially) and rotated image on success, nil on failure.
    private static func PrepareImage(_ Image: UIImage) -> UIImage?
    {
        let ResizeStart = CACurrentMediaTime()
        OriginalImageSize = Image.size
        var ImageToProcess: UIImage = Image.Rotate(Radians: CGFloat.pi * 2)
        var DidResize = false
        if Int(max(Image.size.height, Image.size.width)) > Settings.GetInteger(ForKey: .MaxImageDimension)
        {
            ImageToProcess = ResizeImage(Image: Image, Longest: CGFloat(Settings.GetInteger(ForKey: .MaxImageDimension)))
            ReducedImageSize = ImageToProcess.size
            DidResize = true
        }
        let EndPrepare = CACurrentMediaTime() - ResizeStart
        Log.Message(" Prepare duration: \(EndPrepare), \(DidResize ? "with resize" : "no resize")")
        return ImageToProcess
    }
    
    /// Pixellate the image. This creates a mean color over a larger area of the image, which makes this program
    /// feasible from a performance standpoint.
    /// - Note: Pixellation is accomplished using CoreImage's `CIFilter` functions. Depending on the shape set by the
    ///         user, different `CIFilter`s are used.
    /// - Parameter Image: The image to pixellate.
    /// - Parameter BlockSize: The size of each pixel. All pixels are square. Smaller sizes lead to slower performance.
    /// - Returns: Pixellated image in a `CIImage` on success, nil on failure.
    private static func PixellateImage(_ Image: UIImage, BlockSize: CGFloat, Frame: Int) -> CIImage?
    {
        let PixellationStart = CACurrentMediaTime()
        var Reduced: CIImage? = nil
        if let Reduction = CIFilter(name: "CIPixellate")
        {
            let CGImg = Image.cgImage
            let Source = CIImage(cgImage: CGImg!)
            Reduction.setDefaults()
            Reduction.setValue(Source, forKey: kCIInputImageKey)
            Reduction.setValue(BlockSize, forKey: kCIInputScaleKey)
            Reduced = Reduction.value(forKey: kCIOutputImageKey) as? CIImage
            if Reduced == nil
            {
                Log.Message("Error generating pixellated image.")
                return nil
            }
        }
        
        let PixellationEnd = CACurrentMediaTime() - PixellationStart
        Log.Message("  Pixellation duration: \(PixellationEnd)")
        FileIO.SaveImageEx(UIImage(ciImage: Reduced!), WithName: "\(Frame)_Pixellated.jpg",
            InDirectory: FileIO.ScratchDirectory)
        return Reduced
    }
    
    /// Parses a pixellated image into an array of colors.
    /// - Parameter Image: The pixellated image to parse. Only one pixel from each block/pixel is sampled.
    /// - Parameter BlockSize: The size of each pixellated block in the image.
    /// - Parameter HBlocks: Upon exit, will contain the number of horizontal pixel blocks.
    /// - Parameter VBlocks: Upon exit, will contain the number of vertical pixel blocks.
    /// - Returns: Array of colors in the same order as the pixel blocks in the passed image.
    private static func ParseImage(_ Image: CIImage, BlockSize: CGFloat, HBlocks: inout Int, VBlocks: inout Int) -> [[UIColor]]
    {
        let ParseStart = CACurrentMediaTime()
        let Context = CIContext()
        let FinalImage = UIImage(ciImage: Image)
        HBlocks = Int(FinalImage.size.width / BlockSize)
        VBlocks = Int(FinalImage.size.height / BlockSize)
        
        let Width: Int = Int(Image.extent.width)
        let Height: Int = Int(Image.extent.height)
        let AdjustedWidth = Width - Int(fmod(CGFloat(Width), BlockSize))
        let AdjustedHeight = Height - Int(fmod(CGFloat(Height), BlockSize))
        let ParseSetupStart = CACurrentMediaTime()
        let BCImage = Context.createCGImage(Image, from: Image.extent)
        let BytesPerRow: Int = (BCImage?.bytesPerRow)!
        let BitsPerPixel: Int = (BCImage?.bitsPerPixel)!
        let BitsPerComponent: Int = (BCImage?.bitsPerComponent)!
        let ColorSize = BitsPerPixel / BitsPerComponent
        let PixelData = BCImage?.dataProvider!.data
        let Data: UnsafePointer<UInt8> = CFDataGetBytePtr(PixelData)
        let ParseSetupStop = CACurrentMediaTime() - ParseSetupStart
        
        let ParseLoopStart = CACurrentMediaTime()
        var Colors = Array(repeating: Array(repeating: UIColor.black, count: Int(HBlocks)), count: Int(VBlocks))
        var RowIndex: Int = 0
        for Row in stride(from: 0, through: AdjustedHeight - 1, by: Int(BlockSize))
        {
            let RowOffset = ((Height - 1) - Row) * BytesPerRow
            var ColumnIndex: Int = 0
            for Column in stride(from: 0, through: AdjustedWidth - 1, by: Int(BlockSize))
            {
                autoreleasepool
                    {
                        let Address: Int = RowOffset + (Column * ColorSize)
                        let R = Data[Address + 0]
                        let G = Data[Address + 1]
                        let B = Data[Address + 2]
                        let A = Data[Address + 3]
                        let PixelColor = UIColor(red: CGFloat(R) / 255.0,
                                                 green: CGFloat(G) / 255.0,
                                                 blue: CGFloat(B) / 255.0,
                                                 alpha: CGFloat(A) / 255.0)
                        Colors[RowIndex][ColumnIndex] = PixelColor
                        ColumnIndex = ColumnIndex + 1
                }
            }
            RowIndex = RowIndex + 1
        }
        let ParseLoopEnd = CACurrentMediaTime() - ParseLoopStart
        
        let ParseEnd = CACurrentMediaTime() - ParseStart
        WritePixelsToFileSystem(Colors)
        Log.Message("  Image parsing duration: \(ParseEnd)")
        Log.Message("    Image parsing setup duration: \(ParseSetupStop)")
        let NodeString = ", Nodes: \(Colors[0].count)x\(Colors.count) = \(Colors.count * Colors[0].count)"
        Log.Message("    Image parsing loop duration: \(ParseLoopEnd)\(NodeString)")
        
        return Colors
    }
    
    /// Write the array of pixels to the file system.
    /// - Parameter Colors: The array of colors from the pixellated image.
    public static func WritePixelsToFileSystem(_ Colors: [[UIColor]])
    {
        #if true
        let FileName = "Pixels.dat"
        #else
        let FileName = Utilities.MakeSequentialName("Pixels", Extension: "dat")
        #endif
        let ColorArray = Utilities.MakeStringArray(From: Colors, Separator: ",")
        let SavedOK = FileIO.SavePixellatedData(ColorArray, WithName: FileName)
        Log.Message("Wrote pixellation data to \"\(FileName)\": SavedOK=\(SavedOK)")
    }
    
    /// Determines if the passed list of Unicode blocks contains any of the secondary passed list.
    /// - Parameter List: The soruce list of Unicode blocks to look for subsets.
    /// - Parameter AnyOf: The list of subsets that we're looking for in `List`.
    /// - Returns: True if any single instance in `AnyOf` exists in `List`, false if not.
    private static func BlockListContains(_ List: [UnicodeRanges], AnyOf: [UnicodeRanges]) -> Bool
    {
        for Item in AnyOf
        {
            for ListItem in List
            {
                if ListItem == Item
                {
                    return true
                }
            }
        }
        return false
    }
    
    /// Update every node's lighting model.
    public static func UpdateNodeLightingModel()
    {
        if MasterNode == nil
        {
            return
        }
        let Model = GetLightModel()
        for Node in MasterNode!.childNodes
        {
            Node.geometry?.firstMaterial?.lightingModel = Model
        }
    }
    
    /// Create a prominence value from the passed color.
    /// - Parameter From: The color used to generate a prominence value.
    /// - Parameter VerticalExaggeration: The vertical exaggeration value.
    /// - Parameter HeightSource: How to determine the prominence.
    /// - Returns: The prominence of the color.
    public static func GenerateProminence(From Color: UIColor, VerticalExaggeration: Double, HeightSource: HeightSources) -> Double
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Luminance: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Color.getHue(&Hue, saturation: &Saturation, brightness: &Luminance, alpha: &Alpha)
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        Color.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        var Prominence: CGFloat = 0.0
        switch HeightSource
        {
            case .Hue:
                Prominence = Hue
            
            case .Saturation:
                Prominence = Saturation
            
            case .Brightness:
                Prominence = Luminance
            
            case .Red:
                Prominence = Red
            
            case .Green:
                Prominence = Green
            
            case .Blue:
                Prominence = Blue
            
            case .Cyan:
                Prominence = Color.CMYK.C
            
            case .Black:
                Prominence = Color.CMYK.K
            
            case .Magenta:
                Prominence = Color.CMYK.M
            
            case .Yellow:
                Prominence = Color.CMYK.Y
            
            case .YUV_Y:
                Prominence = Color.YUV.Y
            
            case .YUV_U:
                Prominence = Color.YUV.U
            
            case .YUV_V:
                Prominence = Color.YUV.V
            
            #if false
            case .LAB_L:
                Prominence = Color.LAB.L
            
            case .LAB_A:
                Prominence = Color.LAB.A
            
            case .LAB_B:
                Prominence = Color.LAB.B
            
            case .XYZ_X:
                Prominence = Color.XYZ.X
            
            case .XYZ_Y:
                Prominence = Color.XYZ.Y
            
            case .XYZ_Z:
                Prominence = Color.XYZ.Z
            #endif
            
            case .GreatestChannel:
                Prominence = Color.GreatestMagnitude
            
            case .LeastChannel:
                Prominence = Color.LeastMagnitude
        }
        if Settings.GetBoolean(ForKey: .InvertHeight)
        {
            Prominence = 1.0 - Prominence
        }
        Prominence = Prominence * CGFloat(VerticalExaggeration)
        
        return Double(Prominence)
    }
    
    /// Read the contents of the specified composite shape key and return a list of all shapes found at that key.
    /// - Parameter ForKey: The settings key that determines what is read.
    /// - Returns: All valide shapes found at the specified settings key. If no valid shapes found, an empty array is returned.
    private static func GetShapeList(ForKey: SettingKeys) -> [NodeShapes]
    {
        var Results = [NodeShapes]()
        if let Raw = Settings.GetString(ForKey: ForKey)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            for Part in Parts
            {
                let SPart = String(Part)
                if let ActualShape = NodeShapes(rawValue: SPart)
                {
                    Results.append(ActualShape)
                }
            }
        }
        return Results
    }
    
    /// Create a 3D scene from the passed array of colors. The colors were generated from a pixellation process of a source image.
    /// - Parameter From: Array of colors created by `ParseImage`.
    /// - Parameter HBlocks: Number of horizontal pixel blocks.
    /// - Parameter VBlocks: Number of vertical pixel blocks.
    /// - Returns: `SCNNode` containing all of the 3D nodes required to create the scene.
    private static func CreateSceneNodeSet(From Colors: [[UIColor]], HBlocks: Int, VBlocks: Int) -> SCNNode
    {
        let SceneStart = CACurrentMediaTime()
        Delegate?.HideIndefiniteIndicator()
        var RawSource = Settings.GetString(ForKey: .HeightSource)
        if RawSource == nil
        {
            RawSource = "Brightness"
        }
        
        let HueShapes = GetShapeList(ForKey: .HueShapeList)
        let SatShapes = GetShapeList(ForKey: .SaturationShapeList)
        let BriShapes = GetShapeList(ForKey: .BrightnessShapeList)
        
        var VEx = Settings.GetString(ForKey: .VerticalExaggeration)
        if VEx == nil
        {
            VEx = "Medium"
        }
        var VerticalExaggeration: CGFloat = 1.0
        switch VEx!
        {
            case "Low":
                VerticalExaggeration = 1.0
            
            case "Medium":
                VerticalExaggeration = 2.0
            
            case "High":
                VerticalExaggeration = 4.0
            
            default:
                break
        }
        let HeightSource = HeightSources(rawValue: RawSource!)!
        let Side: CGFloat = 0.5
        
        let WorkingNode = SCNNode()
        WorkingNode.name = "ParentNode"
        
        let Ranges = Settings.GetString(ForKey: .RandomCharacterSource)
        var RandomSet = [UnicodeRanges]()
        let Parts = Ranges?.split(separator: ",", omittingEmptySubsequences: true)
        if Parts?.count == 0
        {
            RandomSet.append(.BasicLatin)
        }
        else
        {
            for Part in Parts!
            {
                let BlockName = String(Part)
                if let SomeBlock = UnicodeRanges(rawValue: BlockName)
                {
                    RandomSet.append(SomeBlock)
                }
                else
                {
                    Log.Message("Found unrecognized Unicode block: \(BlockName)", FileName: #file, FunctionName: #function)
                }
            }
        }
        let FontPointSize = Settings.GetInteger(ForKey: .FontSize)
        var LetterFont: UIFont!
        var SpecialFont: CustomFonts? = nil
        if BlockListContains(RandomSet, AnyOf: [.HangulJamo, .HangulSyllables])
        {
            SpecialFont = .NotoSerifCJKkr
        }
        if BlockListContains(RandomSet, AnyOf: [.CJKUnifiedIdeographs, .Hiragana, .Katakana])
        {
            SpecialFont = .NotoSerifCJKjp
        }
        if SpecialFont != nil
        {
            LetterFont = FontManager.CustomFont(SpecialFont!, Size: CGFloat(FontPointSize))
            Log.Message("Using special font: \(SpecialFont!.rawValue)")
        }
        else
        {
            let FontName = Settings.GetString(ForKey: .LetterFont)!
            let (Family, _) = Utilities.GetFontAndWeight(FontName)!
            LetterFont = UIFont(name: Family, size: CGFloat(FontPointSize))!
        }
        
        Delegate?.SubStatus(0.0, UIColor.systemOrange)
        let Total: Double = Double(VBlocks * HBlocks)
        var Count = 0
        var WorkingShape = NodeShapes.Blocks
        if let ShapeValue = Settings.GetString(ForKey: .ShapeType)
        {
            if let TheShape = NodeShapes(rawValue: ShapeValue)
            {
                WorkingShape = TheShape
            }
            else
            {
                WorkingShape = .Blocks
                Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .ShapeType)
            }
        }
        else
        {
            WorkingShape = .Blocks
            Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .ShapeType)
        }
        
        for Y in 0 ... VBlocks - 1
        {
            for X in 0 ... HBlocks - 1
            {
                autoreleasepool
                    {
                        Count = Count + 1
                        let Percent = Double(Count) / Total
                        Delegate?.SubStatus(Percent, UIColor.systemTeal)
                        
                        var Color = Colors[Y][X]
                        let Prominence = CGFloat(GenerateProminence(From: Color, VerticalExaggeration: Double(VerticalExaggeration),
                                                                    HeightSource: HeightSource))
                        
                        var FinalShape: SCNGeometry!
                        var DoXRotate = false
                        
                        var Combined: [SCNGeometry] = []
                        var FinalScale = 1.0
                        var RotateBy: Double? = nil
                        var AncillaryNode: SCNNode2? = nil
                        let XLocation: Float = Float(X - (HBlocks / 2))
                        let YLocation: Float = Float(Y - (VBlocks / 2))
                        var ZLocation = Prominence / 2.0
                        
                        var ShapeSelector = WorkingShape
                        
                        let OriginalColor = Color
                        Color = GetFinalColor(From: Color)
                        
                        //If the selected shape is a varying shape, determine which shape to use for this particular pixellated region.
                        if [NodeShapes.HueVarying, NodeShapes.SaturationVarying, NodeShapes.BrightnessVarying].contains(WorkingShape)
                        {
                            let MetaShape = WorkingShape
                            var Hue: CGFloat = 0.0
                            var Sat: CGFloat = 0.0
                            var Bri: CGFloat = 0.0
                            var Alp: CGFloat = 0.0
                            OriginalColor.getHue(&Hue, saturation: &Sat, brightness: &Bri, alpha: &Alp)
                            
                            switch MetaShape
                            {
                                case .HueVarying:
                                    let Count = HueShapes.count
                                    if Count > 0
                                    {
                                        let ShapeRange = 1.0 / CGFloat(Count)
                                        var ShapeIndex = Int(Hue / ShapeRange)
                                        if ShapeIndex > Count - 1
                                        {
                                            ShapeIndex = Count - 1
                                        }
                                        ShapeSelector = HueShapes[ShapeIndex]
                                    }
                                    else
                                    {
                                        ShapeSelector = .Blocks
                                }
                                
                                case .SaturationVarying:
                                    let Count = SatShapes.count
                                    if Count > 0
                                    {
                                        let ShapeRange = 1.0 / CGFloat(Count)
                                        var ShapeIndex = Int(Sat / ShapeRange)
                                        if ShapeIndex > Count - 1
                                        {
                                            ShapeIndex = Count - 1
                                        }
                                        ShapeSelector = SatShapes[ShapeIndex]
                                    }
                                    else
                                    {
                                        ShapeSelector = .Blocks
                                }
                                
                                case .BrightnessVarying:
                                    let Count = BriShapes.count
                                    if Count > 0
                                    {
                                        let ShapeRange = 1.0 / CGFloat(Count)
                                        var ShapeIndex = Int(Bri / ShapeRange)
                                        if ShapeIndex > Count - 1
                                        {
                                            ShapeIndex = Count - 1
                                        }
                                        ShapeSelector = BriShapes[ShapeIndex]
                                    }
                                    else
                                    {
                                        ShapeSelector = .Blocks
                                }
                                
                                default:
                                    ShapeSelector = WorkingShape
                            }
                        }
                        
                        //Depending on the shape class, different functions are used to create the actual final shape. Some functions
                        //return an SCNGeometry object while others an SCNNode2 object.
                        switch ShapeSelector
                        {
                            //Simple shapes.
                            case .Blocks, .Spheres, .Pentagons, .Hexagons, .Octagons, .Stars, .Triangles,
                                 .Cylinders, .Pyramids, .Toroids, .Tetrahedrons, .Capsules, .Lines, .Cones,
                                 .Diamonds:
                                FinalShape = GenerateNodeGeometry(ForShape: ShapeSelector, Side: Side, Prominence: Prominence,
                                                                  DoXRotate: &DoXRotate, WithColor: Color)
                            
                            //Extruded letters.
                            case .Letters:
                                FinalShape = GenerateLetters(Prominence: Prominence, LetterFont: LetterFont, RandomSet: RandomSet,
                                                             FinalScale: &FinalScale)
                            case .Characters:
                                FinalShape = GenerateCharacters(Prominence: Prominence, FinalScale: &FinalScale)
                            
                            case .CharacterSets:
                                FinalShape = GenerateCharacterFromSet(Prominence: Prominence, FinalScale: &FinalScale)
                            
                            //Combined shapes or shapes that need extra processing.
                            case .CappedLines, .RadiatingLines, .PerpendicularSquares, .PerpendicularCircles, .Ellipses,
                                 .HueTriangles, .Flowers, .StackedShapes:
                                AncillaryNode = GenerateNode(ForShape: ShapeSelector, Prominence: Prominence, Color: Color,
                                                             Side: Side, ZLocation: &ZLocation, DoXRotate: &DoXRotate) 
                            
                            //Different type of combined shapes.
                            case .CombinedForHSB, .CombinedForRGB:
                                Combined = GenerateCombinedShapes(ForShape: ShapeSelector, Prominence: Prominence, Color: Color)!
                            
                            //Meshes.
                            case .Meshes:
                                if X < HBlocks - 1 && Y < VBlocks - 1
                                {
                                    AncillaryNode = GenerateMesh(X: X, Y: Y, XCount: HBlocks, YCount: VBlocks, XLocation: XLocation,
                                                                 YLocation: YLocation, ZLocation: ZLocation, Side: Side,
                                                                 HeightSource: HeightSource, VerticalExaggeration: Double(VerticalExaggeration),
                                                                 Color: Color, RightColor: Colors[Y][X + 1], BottomColor: Colors[Y - 1][X],
                                                                 LowerRightColor: Colors[Y - 1][X + 1])
                            }
                            
                            default:
                                return
                        }
                        
                        var Node: SCNNode2!
                        if AncillaryNode == nil
                        {
                            let Position = SCNVector3(XLocation * Float(Side), YLocation * Float(Side), Float(ZLocation))
                            if Combined.count > 0
                            {
                                Node = SCNNode2()
                                Node.LogicalX = X
                                Node.LogicalY = Y
                                Node.position = Position
                                var Index = 0
                                for Geo in Combined
                                {
                                    let SubNode = SCNNode(geometry: Geo)
                                    if Index == 1
                                    {
                                        SubNode.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
                                    }
                                    if Index == 2
                                    {
                                        SubNode.rotation = SCNVector4(1.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
                                    }
                                    Node.addChildNode(SubNode)
                                    Index = Index + 1
                                }
                            }
                            else
                            {
                                Node = SCNNode2(geometry: FinalShape)
                                Node.LogicalX = X
                                Node.LogicalY = Y
                                Node.position = Position
                                FinalShape.firstMaterial?.diffuse.contents = Color
                                FinalShape.firstMaterial?.specular.contents = UIColor.white
                                FinalShape.firstMaterial?.lightingModel = GetLightModel()
                            }
                        }
                        else
                        {
                            Node = AncillaryNode!
                            Node.LogicalX = X
                            Node.LogicalY = Y
                            Node.position = SCNVector3(XLocation * Float(Side), YLocation * Float(Side), Float(ZLocation))
                        }
                        if FinalScale != 1.0
                        {
                            Node.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                        }
                        if DoXRotate
                        {
                            Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
                        }
                        if let Angle = RotateBy
                        {
                            //Some nodes need to be rotated to fit properly in certain circumstances.
                            let RotateNodeBy: CGFloat = CGFloat(Angle) * (CGFloat.pi / 180.0)
                            
                            Node.eulerAngles = SCNVector3(0.0, 0.0, RotateNodeBy)
                            Node.geometry?.firstMaterial?.diffuse.contents = Color//UIColor.red
                            Node.geometry?.firstMaterial?.lightingModel = GetLightModel()
                        }
                        Node.name = "PixelNode"
                        WorkingNode.addChildNode(Node)
                }
            }
        }
        let SceneEnd = CACurrentMediaTime() - SceneStart
        Log.Message("  Scene generation duration: \(SceneEnd)")
        return WorkingNode
    }
    
    /// Return the lighting model based on the contents of user settings.
    /// - Returns: Lighting model to use.
    public static func GetLightModel() -> SCNMaterial.LightingModel
    {
        var LightModel = SCNMaterial.LightingModel.phong
        if let LightModelRaw = Settings.GetString(ForKey: SettingKeys.LightingModel)
        {
            if let Model = MaterialLightingTypes(rawValue: LightModelRaw)
            {
                switch Model
                {
                    case .Blinn:
                        LightModel = .blinn
                    
                    case .Constant:
                        LightModel = .constant
                    
                    case .Lambert:
                        LightModel = .lambert
                    
                    case .Phong:
                        LightModel = .phong
                    
                    case .PhysicallyBased:
                        LightModel = .physicallyBased
                }
                return LightModel
            }
            else
            {
                Settings.SetString(MaterialLightingTypes.Phong.rawValue, ForKey: SettingKeys.LightingModel)
                return .phong
            }
        }
        else
        {
            Settings.SetString(MaterialLightingTypes.Phong.rawValue, ForKey: SettingKeys.LightingModel)
            return .phong
        }
    }
    
    /// Resizes a UIImage to the passed target size.
    /// - Parameter Image: The image to resize.
    /// - Parameter TargetSize: The size of the returned image.
    /// - Returns: Resized image.
    public static func ResizeImage(Image: UIImage, TargetSize: CGSize) -> UIImage
    {
        let Size = Image.size
        let WidthRatio = TargetSize.width / Size.width
        let HeightRatio = TargetSize.height / Size.height
        var NewSize: CGSize!
        if WidthRatio > HeightRatio
        {
            NewSize = CGSize(width: Size.width * HeightRatio, height: Size.height * HeightRatio)
        }
        else
        {
            NewSize = CGSize(width: Size.width * WidthRatio, height: Size.height * WidthRatio)
        }
        let Rect = CGRect(x: 0, y: 0, width: NewSize.width, height: NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, 1.0)
        Image.draw(in: Rect)
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
    }
    
    /// Resizes a UIImage such that the longest dimension of the returned image is `Longest`.
    /// - Parameter Image: The image to resize.
    /// - Parameter Longest: The new longest dimension.
    /// - Returns: Resized image. If the longest dimension of the original image is less than `Longest`, the
    ///            original image is returned unchanged.
    public static func ResizeImage(Image: UIImage, Longest: CGFloat) -> UIImage
    {
        let ImageMax = max(Image.size.width, Image.size.height)
        let Ratio = Longest / ImageMax
        if Ratio >= 1.0
        {
            return Image
        }
        let NewSize = CGSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        let Rect = CGRect(x: 0, y: 0, width: NewSize.width, height: NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, 1.0)
        Image.draw(in: Rect)
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
    }
    
    /// Resizes a UIImage to meet the video quality specified in `Quality`.
    /// - Parameter Image: The image to resize.
    /// - Parameter Quality: Determines how the image is resized.
    /// - Returns: Resized image.
    private static func ResizeImage(Image: UIImage, Quality: VideoQuality) -> UIImage
    {
        var MaxDimension: CGFloat = 0
        switch Quality
        {
            case .Smallest:
                MaxDimension = 600
            
            case .Small:
                MaxDimension = 800
            
            case .Medium:
                MaxDimension = 1000
            
            case .Large:
                MaxDimension = 1600
            
            case .Original:
                return Image
        }
        return ResizeImage(Image: Image, Longest: MaxDimension)
    }
    
    /// Dump settings used to create images. Calling this function has no effect if the **#DEBUG** flag is false/not defined. This
    /// is to help with performance for the release version. Additionally, most of the same information is stored with processed
    /// images in XMP metadata with each image.
    public static func LogSettings()
    {
        if !Settings.GetBoolean(ForKey: .LogImageSettings)
        {
            return
        }
        var CurrentShape = NodeShapes.Blocks
        if let RawShape = Settings.GetString(ForKey: .ShapeType)
        {
            if let FinalShape = NodeShapes(rawValue: RawShape)
            {
                CurrentShape = FinalShape
            }
        }
        let Parent = Log.Message("Image process settings:")
        Log.ChildMessage(Parent: Parent, "  Block size: \(Settings.GetInteger(ForKey: .BlockSize))")
        let ShapeParent = Log.ChildMessage(Parent: Parent, "  Node shape: \((Settings.GetString(ForKey: .ShapeType)!))")
        switch CurrentShape
        {
            case .Blocks:
                Log.ChildMessage(Parent: ShapeParent, "    Chamfer size: \((Settings.GetString(ForKey: .BlockChamferSize)!))")
            
            case .CappedLines:
                Log.ChildMessage(Parent: ShapeParent, "    Capped line ball location: \((Settings.GetString(ForKey: .CappedLineBallLocation)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Cap shape: \((Settings.GetString(ForKey: .CappedLineCapShape))!)")
            
            case .Meshes:
                Log.ChildMessage(Parent: ShapeParent, "    Mesh center dot size: \((Settings.GetString(ForKey: .MeshDotSize)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Mesh line thickness: \((Settings.GetString(ForKey: .MeshLineThickness)!))")
            
            case .Stars:
                Log.ChildMessage(Parent: ShapeParent, "    Star apex count: \(Settings.GetInteger(ForKey: .StarApexCount))")
                Log.ChildMessage(Parent: ShapeParent, "    Star apexes increase: \(Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence))")
            
            case .Letters:
                Log.ChildMessage(Parent: ShapeParent, "    Fully extrude letters: \(Settings.GetBoolean(ForKey: .FullyExtrudeLetters))")
                Log.ChildMessage(Parent: ShapeParent, "    Letter smoothness: \((Settings.GetString(ForKey: .LetterSmoothness)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Letter font: \((Settings.GetString(ForKey: .LetterFont)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Font size: \(Settings.GetInteger(ForKey: .FontSize))")
                Log.ChildMessage(Parent: ShapeParent, "    Random source: \((Settings.GetString(ForKey: .RandomCharacterSource))!)")
            
            case .Cones:
                Log.ChildMessage(Parent: ShapeParent, "    Invert cone: \(Settings.GetBoolean(ForKey: .ConeIsInverted))")
                Log.ChildMessage(Parent: ShapeParent, "    Cone top radius: \((Settings.GetString(ForKey: .ConeTopOptions))!)")
                Log.ChildMessage(Parent: ShapeParent, "    Cone base radius: \((Settings.GetString(ForKey: .ConeBottomOptions))!)")
            
            case .CharacterSets:
                Log.ChildMessage(Parent: ShapeParent, "    Set: \((Settings.GetString(ForKey: .CharacterSeries))!)")
            
            case .Characters:
                Log.ChildMessage(Parent: ShapeParent, "    Fully extrude characters: \(Settings.GetBoolean(ForKey: .FullyExtrudeLetters))")
                Log.ChildMessage(Parent: ShapeParent, "    Letter smoothness: \((Settings.GetString(ForKey: .LetterSmoothness)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Character font name: \((Settings.GetString(ForKey: .CharacterFontName)!))")
                Log.ChildMessage(Parent: ShapeParent, "    Character random font size: \(Settings.GetBoolean(ForKey: .CharacterRandomFontSize))")
                Log.ChildMessage(Parent: ShapeParent, "    Character font is random: \(Settings.GetBoolean(ForKey: .CharacterUsesRandomFont))")
            
            case .Ellipses:
                Log.ChildMessage(Parent: ShapeParent, "    Ellipse shape: \((Settings.GetString(ForKey: .EllipseShape))!)")
            
            case .Flowers:
                Log.ChildMessage(Parent: ShapeParent, "    Petal count: \(Settings.GetInteger(ForKey: .FlowerPetalCount))")
                Log.ChildMessage(Parent: ShapeParent, "    Petal count increase: \(Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence))")
            
            case .HueVarying:
                Log.ChildMessage(Parent: ShapeParent, "    Hue shape list: \((Settings.GetString(ForKey: .HueShapeList))!)")
            
            case .SaturationVarying:
                Log.ChildMessage(Parent: ShapeParent, "    Saturation shape list: \((Settings.GetString(ForKey: .SaturationShapeList))!)")
            
            case .BrightnessVarying:
                Log.ChildMessage(Parent: ShapeParent, "    Brightness shape list: \((Settings.GetString(ForKey: .BrightnessShapeList))!)")
            
            case .RadiatingLines:
                Log.ChildMessage(Parent: ShapeParent, "    Line thickness: \((Settings.GetString(ForKey: .RadiatingLineThickness))!)")
                Log.ChildMessage(Parent: ShapeParent, "    Line count: \(Settings.GetInteger(ForKey: .RadiatingLineCount))")
            
            default:
                break
        }
        let HeightParent = Log.ChildMessage(Parent: Parent, "  Extrusion:")
        Log.ChildMessage(Parent: HeightParent, "    Invert height: \(Settings.GetBoolean(ForKey: .InvertHeight))")
        Log.ChildMessage(Parent: HeightParent, "    Height source: \((Settings.GetString(ForKey: .HeightSource)!))")
        Log.ChildMessage(Parent: HeightParent, "    Vertical exaggeration: \((Settings.GetString(ForKey: .VerticalExaggeration)!))")
        let VidParent = Log.ChildMessage(Parent: Parent, "  Video:")
        Log.ChildMessage(Parent: VidParent, "    Video FPS: \(Settings.GetInteger(ForKey: .VideoFPS))")
        Log.ChildMessage(Parent: VidParent, "    Video dimensions: \((Settings.GetString(ForKey: .VideoDimensions)!))")
        Log.ChildMessage(Parent: VidParent, "    Video block size: \(Settings.GetInteger(ForKey: .VideoBlockSize))")
        let LightParent = Log.ChildMessage(Parent: Parent, "  Lighting:")
        Log.ChildMessage(Parent: LightParent, "    Light color: \((Settings.GetString(ForKey: .LightColor)!))")
        Log.ChildMessage(Parent: LightParent, "    Light type: \((Settings.GetString(ForKey: .LightType)!))")
        Log.ChildMessage(Parent: LightParent, "    Material lighting model: \((Settings.GetString(ForKey: .LightingModel)!))")
        let PerfParent = Log.ChildMessage(Parent: Parent, "  Quality/Performance:")
        Log.ChildMessage(Parent: PerfParent, "    Maximum image dimension: \(Settings.GetInteger(ForKey: .MaxImageDimension))")
        Log.ChildMessage(Parent: PerfParent, "    Use Metal: \(Settings.GetBoolean(ForKey: .UseMetal))")
        Log.ChildMessage(Parent: PerfParent, "    Antialiasing mode: \(Settings.GetInteger(ForKey: .AntialiasingMode))")
        Log.ChildMessage(Parent: PerfParent, "    Image size contraint: \((Settings.GetString(ForKey: .ImageSizeConstraints)!))")
        Log.ChildMessage(Parent: PerfParent, "    Input quality: \(Settings.GetInteger(ForKey: .InputQuality))")
        let ResVParent = Log.ChildMessage(Parent: Parent, "  3D View:")
        Log.ChildMessage(Parent: ResVParent, "    Initial best fit: \(Settings.GetBoolean(ForKey: .InitialBestFit))")
        Log.ChildMessage(Parent: ResVParent, "    Best fit offset: \(Settings.GetDouble(ForKey: .BestFitOffset))")
        let LastImg = Log.ChildMessage(Parent: Parent, "  Last image size:")
        Log.ChildMessage(Parent: LastImg, "    Source size: \(OriginalImageSize)")
        Log.ChildMessage(Parent: LastImg, "    Reduced size: \(ReducedImageSize)")
        let DynColor = Log.ChildMessage(Parent: Parent, "  Dynamic colors:")
        Log.ChildMessage(Parent: DynColor, "    Dynamic color type: \((Settings.GetString(ForKey: .DynamicColorType))!)")
        Log.ChildMessage(Parent: DynColor, "    Dynamic color action: \((Settings.GetString(ForKey: .DynamicColorAction))!)")
        Log.ChildMessage(Parent: DynColor, "    Dynamic color condition: \((Settings.GetString(ForKey: .DynamicColorCondition))!)")
        Log.ChildMessage(Parent: DynColor, "    Invert dynamic color conditional: \(Settings.GetBoolean(ForKey: .InvertDynamicColorProcess))")
    }
    
    /// Update an image in-place. Certain settings changes do not require regengeration of shape nodes. To take advantage of that
    /// when those settings are changed, this function will change attributes of each node in-place.
    /// - Parameter InView: The view whose scene nodes will be updated.
    public static func UpdateImage(_ InView: ProcessViewer)
    {
        LogSettings()
        autoreleasepool
            {
                if Settings.GetBoolean(ForKey: .EnableImageProcessingSound)
                {
                    Sounds.PlaySound(.Begin)
                }
                var MainNode: SCNNode? = nil
                for Nodes in (InView.scene?.rootNode.childNodes)!
                {
                    if Nodes.name == "ParentNode"
                    {
                        MainNode = Nodes
                        break
                    }
                }
                if MainNode == nil
                {
                    Log.AbortMessage("Did not find \"ParentNode\" in current scene.")
                    {
                        Message in
                        fatalError(Message)
                    }
                }
                
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
                                Chamfer = 0.1
                            
                            case .Medium:
                                Chamfer = 0.3
                            
                            case .Large:
                                Chamfer = 0.5
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
                
                let RawShape = Settings.GetString(ForKey: .ShapeType)
                if RawShape == nil
                {
                    return
                }
                if let TheShape = NodeShapes(rawValue: RawShape!)
                {
                    for ChildNode in MainNode!.childNodes
                    {
                        switch TheShape
                        {
                            case .Blocks:
                                if let Geo = ChildNode.geometry as? SCNBox
                                {
                                    Geo.chamferRadius = Chamfer
                                    ChildNode.geometry = Geo
                            }
                            
                            case .Stars:
                                if !Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence)
                                {
                                    if let StarNode = ChildNode as? SCNStar
                                    {
                                        StarNode.VertexCount = Settings.GetInteger(ForKey: .StarApexCount)
                                    }
                            }
                            
                            default:
                                break
                        }
                    }
                }
        }
    }
    
    /// Create a processed (eg, 3D extruded) image fromthe passed set of pre-processed pixels.
    /// - Note: Intended for use for single images only.
    /// - Parameter InView: The 3D scene to use to render the processed image.
    /// - Parameter With: The set of pixels created earlier and stored for use.
    public static func MakeImage(_ InView: ProcessViewer, With Pixels: [[UIColor]])
    {
        LogSettings()
        autoreleasepool
            {
                Delegate?.ShowIndefiniteIndicator()
                if Settings.GetBoolean(ForKey: .EnableImageProcessingSound)
                {
                    Sounds.PlaySound(.Begin)
                }
                Log.Message("Starting node count: \(Utility3D.NodeCount(InScene: InView.scene!))")
                FileIO.ClearScratchDirectory()
                let VBlocks = Pixels.count
                let HBlocks = Pixels[0].count
                Delegate?.Status(0.6, UIColor.systemYellow, NSLocalizedString("GeneratorMaking3D", comment: ""))
                let FinalNode = CreateSceneNodeSet(From: Pixels, HBlocks: HBlocks, VBlocks: VBlocks)
                MasterNode = FinalNode
                Delegate?.Status(0.8, UIColor.systemYellow, NSLocalizedString("GeneratingAddingNodes", comment: ""))
                Delegate?.ShowIndefiniteIndicator()
                InView.prepare([FinalNode], completionHandler:
                    {
                        success in
                        if success
                        {
                            InView.isPlaying = true
                            InView.loops = true
                            InView.scene!.rootNode.addChildNode(FinalNode)
                            if Settings.GetBoolean(ForKey: .InitialBestFit)
                            {
                                Utility3D.BestFit(InView: InView)
                            }
                            let NodeCount = Utility3D.NodeCount(InScene: InView.scene!)
                            Log.Message("Ending node count: \(NodeCount)")
                            if Settings.GetBoolean(ForKey: .EnableImageProcessingSound)
                            {
                                Sounds.PlaySound(.Confirm)
                            }
                            Delegate?.HideIndefiniteIndicator()
                            Delegate?.Status(1.0, UIColor.systemYellow, NSLocalizedString("GeneratorCompleted", comment: ""))
                            Delegate?.Completed(true)
                        }
                        else
                        {
                            Crash.ShowCrashAlert(WithController: InView.ParentViewController!, "Error",
                                                 "Error preparing 3D nodes for final image assembly. BlockCam will close.")
                            Log.AbortMessage("Failure rendering scene.", FileName: #file, FunctionName: #function)
                            {
                                Message in
                                fatalError(Message)
                            }
                        }
                })
        }
        InView.isPlaying = true
    }
    
    /// Returns the dynamic color type.
    /// - Warning: Generates a fatal error if no dynamic color type or an invalid/unknown dynamic color type is encountered.
    /// - Returns: The stored dynamic color type.
    private static func GetDynamicColorType() -> DynamicColorTypes
    {
        if let Raw = Settings.GetString(ForKey: .DynamicColorType)
        {
            if let DynamicType = DynamicColorTypes(rawValue: Raw)
            {
                return DynamicType
            }
            else
            {
                Log.AbortMessage("Invalid dynamic color type encountered: \(Raw).", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
                }
            }
        }
        else
        {
            Log.AbortMessage(".DynamicColorType not defined in settings.", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
        return .None
    }
    
    /// Returns the dynamic color condition.
    /// - Warning: Generates a fatal error if no dynamic color type or an invalid/unknown dynamic color condition is encountered.
    /// - Returns: The stored dynamic color condition.
    private static func GetDynamicColorCondition() -> DynamicColorConditions
    {
        if let Raw = Settings.GetString(ForKey: .DynamicColorCondition)
        {
            if let Condition = DynamicColorConditions(rawValue: Raw)
            {
                return Condition
            }
            else
            {
                Log.AbortMessage("Invalid dynamic color condition encountered: \(Raw).", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
                }
            }
        }
        else
        {
            Log.AbortMessage("Dynamic color condition not defined in settings.", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
        return .LessThan50
    }
    
    /// Returns the action to take when dynamic colors are in force.
    /// - Warning: Generates a fatal error if no dynamic color action or an invalid/unknown color action is encountered.
    /// - Returns: The stored dynamic color action.
    private static func GetDynamicColorAction() -> DynamicColorActions
    {
        if let Raw = Settings.GetString(ForKey: .DynamicColorAction)
        {
            if let DAction = DynamicColorActions(rawValue: Raw)
            {
                return DAction
            }
            else
            {
                Log.AbortMessage("Invalid dynamic color action encountered: \(Raw).", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
                }
            }
        }
        else
        {
            Log.AbortMessage("Dynamic color action not defined in settings.", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
        return .Grayscale
    }
    
    /// Returns the numeric value associated with the passed dynamic color condition enum.
    /// - Parameter From: The dynamic color condition enum.
    /// - Returns: Numeric value associated with `From`.
    private static func GetConditionValue(_ From: DynamicColorConditions) -> CGFloat
    {
        switch From
        {
            case .LessThan10:
                return 0.1
            
            case .LessThan25:
                return 0.25
            
            case .LessThan50:
                return 0.5
            
            case .LessThan75:
                return 0.75
            
            case .LessThan90:
                return 0.9
        }
    }
    
    /// Depending on the user settings, change the color to reflect the original pixellated region's color attributes.
    /// - Parameter From: The color to test against the dynamic color conditions.
    /// - Returns: Potentially altered color.
    private static func GetFinalColor(From Source: UIColor) -> UIColor
    {
        let DynamicColorType = GetDynamicColorType()
        if DynamicColorType == .None
        {
            return Source
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Condition = GetDynamicColorCondition()
        let InvertCondition = Settings.GetBoolean(ForKey: .InvertDynamicColorProcess)
        let ColorAction = GetDynamicColorAction()
        var ConditionEnabled = false
        let ConditionalValue = GetConditionValue(Condition)
        switch DynamicColorType
        {
            case .Hue:
                if InvertCondition
                {
                    if Hue > ConditionalValue
                    {
                        ConditionEnabled = true
                    }
                }
                else
                {
                    if Hue < ConditionalValue
                    {
                        ConditionEnabled = true
                    }
            }
            
            case .Saturation:
                if InvertCondition
                {
                    if Saturation > ConditionalValue
                    {
                        ConditionEnabled = true
                    }
                }
                else
                {
                    if Saturation < ConditionalValue
                    {
                        ConditionEnabled = true
                    }
            }
            
            case .Brightness:
                if InvertCondition
                {
                    if Brightness > ConditionalValue
                    {
                        ConditionEnabled = true
                    }
                }
                else
                {
                    if Brightness < ConditionalValue
                    {
                        ConditionEnabled = true
                    }
            }
            
            case .None:
                return Source
        }
        if ConditionEnabled
        {
            switch ColorAction
            {
                case .Grayscale:
                    return UIColor(hue: Hue, saturation: 0.0, brightness: Brightness, alpha: 1.0)
                
                case .DecreaseSaturation:
                    return UIColor(hue: Hue, saturation: Saturation * 0.4, brightness: Brightness, alpha: 1.0)
                
                case .IncreaseSaturation:
                    return UIColor(hue: Hue, saturation: Saturation * 1.4, brightness: Brightness, alpha: 1.0)
            }
        }
        else
        {
            return Source
        }
    }
    
    /// Create a processed (eg, 3D extruded) image from the passed flat image.
    /// - Parameter InView: The 3D scene to use to render the processed image.
    /// - Parameter SomeImage: The 2D image to render/process.
    /// - Parameter BlockSize: The size of each block - this is pixellation size.
    /// - Parameter Frame: Not currently used.
    /// - Parameter ForVideo: If true, the processing is intended for videos.
    public static func MakeImage(_ InView: ProcessViewer, _ SomeImage: UIImage,
                                 BlockSize: CGFloat, Frame: Int? = nil, ForVideo: Bool = false)
    {
        LogSettings()
        autoreleasepool
            {
                Delegate?.ShowIndefiniteIndicator()
                Delegate?.Status(0.0, UIColor.systemOrange, NSLocalizedString("GeneratorPreparing", comment: ""))
                if !ForVideo
                {
                    //If we are working on an individual image (and not a series of images from a video), clear the
                    //scratch directory.
                    FileIO.ClearScratchDirectory()
                    if Settings.GetBoolean(ForKey: .EnableImageProcessingSound)
                    {
                        Sounds.PlaySound(.Begin)
                    }
                }
                Log.Message("Starting node count: \(Utility3D.NodeCount(InScene: InView.scene!))")
                if let Prepared = PrepareImage(SomeImage)
                {
                    Delegate?.Status(0.2, UIColor.systemYellow, NSLocalizedString("GeneratorPixellating", comment: ""))
                    let FrameIndex = Frame == nil ? 0 : Frame!
                    if let Pixellated = PixellateImage(Prepared, BlockSize: BlockSize, Frame: FrameIndex)
                    {
                        Delegate?.Status(0.4, UIColor.systemYellow, NSLocalizedString("GeneratorParsing", comment: ""))
                        var HBlocks: Int = 0
                        var VBlocks: Int = 0
                        let Colors = ParseImage(Pixellated, BlockSize: BlockSize, HBlocks: &HBlocks, VBlocks: &VBlocks)
                        WritePixelsToFileSystem(Colors)
                        Delegate?.Status(0.6, UIColor.systemYellow, NSLocalizedString("GeneratorMaking3D", comment: ""))
                        let FinalNode = CreateSceneNodeSet(From: Colors, HBlocks: HBlocks, VBlocks: VBlocks)
                        MasterNode = FinalNode
                        Delegate?.SubStatus(0.0, UIColor.clear)
                        Delegate?.Status(0.8, UIColor.systemYellow, NSLocalizedString("GeneratorAddingNodes", comment: ""))
                        Delegate?.ShowIndefiniteIndicator()
                        let PrepStart = CACurrentMediaTime()
                        InView.prepare([FinalNode], completionHandler:
                            {
                                success in
                                if success
                                {
                                    //If we are here, the nodes have been loaded into the scene and will soon be visible.
                                    //"Soon" is not necessarily well defined...
                                    let Total = CACurrentMediaTime() - PrepStart
                                    Log.Message("** Prepare time: \(Total)")
                                    InView.isPlaying = true
                                    InView.loops = true
                                    InView.scene!.rootNode.addChildNode(FinalNode)
                                    if Settings.GetBoolean(ForKey: .InitialBestFit)
                                    {
                                        Utility3D.BestFit(InView: InView)
                                    }
                                    let NodeCount = Utility3D.NodeCount(InScene: InView.scene!)
                                    Log.Message("Final node count \(NodeCount)")
                                    if Settings.GetBoolean(ForKey: .EnableImageProcessingSound) && !ForVideo
                                    {
                                        Sounds.PlaySound(.Confirm)
                                    }
                                    Delegate?.Status(1.0, UIColor.yellow, NSLocalizedString("GeneratorCompleted", comment: ""))
                                    Delegate?.HideIndefiniteIndicator()
                                    Delegate?.Completed(true)
                                }
                                else
                                {
                                    Crash.ShowCrashAlert(WithController: InView.ParentViewController!, "Error",
                                                         "Error preparing 3D nodes for final image assembly. BlockCam will close.")
                                    Log.AbortMessage("Failure rendering scene.")
                                    {
                                        Message in
                                        fatalError(Message)
                                    }
                                }
                        }
                        )
                    }
                }
                if Settings.GetBoolean(ForKey: .SourceAsBackground)
                {
                    DispatchQueue.main.sync
                        {
                            let RImage = ResizeImage(Image: SomeImage, TargetSize: CGSize(width: InView.frame.width, height: InView.frame.height))
                            InView.scene?.background.contents = RImage
                    }
                }
                InView.isPlaying = true
        }
    }
    
    /// Holds the master node. This node contains all of the sub-nodes that actually make up the 3D scene.
    public static var MasterNode: SCNNode? = nil
    
    /// Create a processed (eg, 3D extruded) image from the passed flat image.
    /// - Parameter InView: The 3D scene to use to render the processed image.
    /// - Parameter Status: Status callback - called after a step is completed.
    /// - Parameter Completed: Completion block.
    public static func MakeImage(_ InView: ProcessViewer, _ SomeImage: UIImage,
                                 Status: ((Double, UIColor, String) -> ())? = nil,
                                 Completed: (() -> ())? = nil)
    {
        let BlockSize: CGFloat = CGFloat(Settings.GetInteger(ForKey: .BlockSize))
        #if false
        var ConstraintS = Settings.GetString(ForKey: .ImageSizeConstraints)
        if ConstraintS == nil
        {
            ConstraintS = "Medium"
        }
        let SizeConstraint = SizeConstraints(rawValue: ConstraintS!)!
        var MaxDimensions = 0
        var ResizeTo: CGSize? = nil
        switch SizeConstraint
        {
            case .None:
                break
            
            case .Small:
                MaxDimensions = 800
            
            case .Medium:
                MaxDimensions = 1600
            
            case .Large:
                MaxDimensions = 2000
        }
        if SizeConstraint != .None
        {
            let MaxOriginalDimension = max(SomeImage.size.width, SomeImage.size.height)
            if MaxOriginalDimension > CGFloat(MaxDimensions)
            {
                let Ratio = CGFloat(MaxDimensions) / MaxOriginalDimension
                ResizeTo = CGSize(width: SomeImage.size.width * Ratio, height: SomeImage.size.height * Ratio)
            }
        }
        #endif
        MakeImage(InView, SomeImage, BlockSize: BlockSize)
    }
    
    static var SourceFrameCount = 0
    
    /// Extracts frames from a video and resizes them as indicated by `Quality`. Extracted frames are placed in the scratch directory.
    /// - Parameter From: The URL of the video from which frames will be extracted.
    /// - Parameter FPS: The frames per second.
    /// - Parameter Quality: The quality (resolution) of the video - this determines the final size of each frame. Frames are resized
    ///                      before they are saved.
    static func GetVideoFrames(From: URL, InView: ProcessViewer, FPS: Int, Quality: VideoQuality,
                               BlockSize: CGFloat,
                               FrameProcessor: ((Int, ProcessViewer, CGFloat) -> ())? = nil)
    {
        FileIO.ClearScratchDirectory()
        var FrameIndex = 0
        let BGThread = DispatchQueue(label: "FrameExtraction", qos: .background)
        BGThread.async
            {
                let VideoDuration = GetVideoDuration(From)
                let Asset = AVAsset(url: From)
                let Tracks = Asset.tracks(withMediaType: .video)
                let VideoFPS = Tracks.first?.nominalFrameRate
                let AVGenerator = AVAssetImageGenerator(asset: Asset)
                AVGenerator.appliesPreferredTrackTransform = true
                AVGenerator.requestedTimeToleranceAfter = CMTime.zero
                AVGenerator.requestedTimeToleranceBefore = CMTime.zero
                var FrameTimes: [CMTime] = []
                let FrameCount = VideoDuration * Double(FPS)
                let Increment = 1.0 / Double(FPS)
                let SampleCount = FrameCount
                let TotalTime = Int(Asset.duration.seconds * Double(Asset.duration.timescale))
                let Step = TotalTime / Int(SampleCount)
                for I in 0 ..< Int(SampleCount)
                {
                    let Time = CMTimeMake(value: Int64(I * Step), timescale: Int32(Asset.duration.timescale))
                    FrameTimes.append(Time)
                }
                
                for FrameTime in FrameTimes
                {
                    autoreleasepool
                        {
                            var FrameImage: CGImage
                            do
                            {
                                let ImageName = "\(FrameIndex)_SourceFrame.jpg"
                                FrameImage = try AVGenerator.copyCGImage(at: FrameTime, actualTime: nil)
                                let ReducedImage = ResizeImage(Image: UIImage(cgImage: FrameImage), Quality: Quality)
                                let Saved = FileIO.SaveImageEx(ReducedImage, WithName: ImageName, InDirectory: FileIO.ScratchDirectory)
                                if !Saved
                                {
                                    fatalError("Error saving \(ImageName) to file system.")
                                }
                                Log.Message("Saved \(ImageName)")
                                FrameIndex = FrameIndex + 1
                                Delegate?.Status(Double(FrameIndex) / Double(FrameTimes.count), UIColor.systemBlue,
                                                 NSLocalizedString("GeneratorGatheringFrames", comment: ""))
                            }
                            catch
                            {
                                Crash.ShowCrashAlert(WithController: InView.ParentViewController!, "Error",
                                                     "Error getting image from video at frame \(FrameTime). BlockCam will close.")
                                Log.AbortMessage("Error getting CGImage from video at \(FrameTime)")
                                {
                                    Message in
                                    fatalError(Message)
                                }
                            }
                    }
                }
                Log.Message("\(FrameIndex) frames saved.")
                SourceFrameCount = FrameIndex
                FrameProcessor?(FrameIndex, InView, BlockSize)
        }
    }
    
    /// Convert a video (or at least the first portion of it) to 3D scene with the current settings. The API we use to get stored
    /// videos only returns the first 30 seconds.
    /// - Notes:
    ///   - Converting a video to a processed video is a multi-stage process:
    ///     1. Get current settings.
    ///     2. Retrieve frames from the video.
    ///     3. Resize each frame as necessary.
    ///     4. Process each resized frame as a 3D visualization image.
    ///     5. Combine each processed image into a new video.
    ///     6. Save the new video to the photo album.
    ///   - See: [Get all frames from a video](https://stackoverflow.com/questions/42665271/swift-get-all-frames-from-video)
    ///   - See: [Export UIImage array as video](https://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie)
    ///   - See: [How to capture frames from a video using generateCGImagesAsynchronously()](https://forums.developer.apple.com/thread/66332)
    /// - Parameter SomeVideo: URL of the video to convert.
    public static func MakeVideo(_ InView: ProcessViewer, _ SomeVideo: URL)
    {
        Log.Message(">>> Make Video <<<")
        Delegate?.Status(0.0, UIColor.red, NSLocalizedString("GeneratorStartVideo", comment: ""))
        let VideoDuration = GetVideoDuration(SomeVideo)
        var QualityS = Settings.GetString(ForKey: .VideoDimensions)
        if QualityS == nil
        {
            QualityS = "Smallest"
            Settings.SetString(QualityS!, ForKey: .VideoDimensions)
        }
        if QualityS!.isEmpty
        {
            QualityS = "Smallest"
            Settings.SetString(QualityS!, ForKey: .VideoDimensions)
        }
        guard let Quality = VideoQuality(rawValue: QualityS!) else
        {
            Crash.ShowCrashAlert(WithController: InView.ParentViewController!, "Error",
                                 "Found unexpected video quality: \(QualityS!). BlockCam will close.")
            Log.AbortMessage("Found unexpected video quality: \(QualityS!)")
            {
                Message in
                fatalError(Message)
            }
            return
        }
        var FPS = Settings.GetInteger(ForKey: .VideoFPS)
        if FPS == 0
        {
            FPS = 1
            Settings.SetInteger(FPS, ForKey: .VideoFPS)
        }
        var VideoBlockSize = Settings.GetInteger(ForKey: .VideoBlockSize)
        if VideoBlockSize < 16
        {
            Settings.SetInteger(48, ForKey: .VideoBlockSize)
            VideoBlockSize = 48
        }
        
        GetVideoFrames(From: SomeVideo, InView: InView, FPS: FPS, Quality: Quality,
                       BlockSize: CGFloat(VideoBlockSize),
                       FrameProcessor: ProcessVideoFrames)
        InView.isPlaying = true
    }
    
    /// Process the frames in the scratch directory.
    static func ProcessVideoFrames(_ Count: Int, _ InView: ProcessViewer, _ BlockSize: CGFloat)
    {
        Log.Message("Processing frames")
        for Index in 0 ..< Count
        {
            let ImageName = "\(Index)_SourceFrame.jpg"
            Log.Message(" Frame Image: \(ImageName)")
            Delegate?.Status(Double(Index) / Double(Count), UIColor.systemBlue,
                             "\(NSLocalizedString("GeneratorCreatingFrame", comment: "")) \(Index + 1)")
            if let Frame = FileIO.LoadImage(ImageName, InDirectory: FileIO.ScratchDirectory)
            {
                MakeImage(InView, Frame, BlockSize: BlockSize, Frame: Index, ForVideo: true) 
            }
        }
    }
    
    /// Holds the set of processed frames from a video.
    private static var ProcessedFrames: [UIImage] = []
    
    /// Get the length (in seconds) of the passed video.
    /// - Note: See: [Get the accuration duration of a video.](https://stackoverflow.com/questions/44267013/get-the-accurate-duration-of-a-video)
    /// - Parameter SomeVideo: The video whose length in seconds is returned.
    /// - Returns: Length of the video in seconds.
    private static func GetVideoDuration(_ SomeVideo: URL) -> CFTimeInterval
    {
        let Asset = AVAsset(url: SomeVideo)
        let Duration = Asset.duration
        let DurationTime = CMTimeGetSeconds(Duration)
        return CFTimeInterval(DurationTime)
    }
    
    static var ExpectedFrameCount = -1
    static var VideoIncrement: Double = 0
    static var VideoStatusHandler: ((Double, UIColor, String) -> ())?
    static var VideoCompletionHandler: ((Bool) -> ())?
    static var VideoFrameSize: CGSize = .zero
}
