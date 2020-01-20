//
//  CurrentSettingsDescription.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Descriptions of how to render. Intended for human readability.
class CurrentSettings
{
    /// Returns each setting used to render the image in a tuple.
    /// - Returns: Tuple with the user-facing setting name and its value.
    public static func DescriptionComponents() -> [(String, String)]
    {
        var Results = [(String, String)]()
        Results.append(("Shape", Settings.GetString(ForKey: .ShapeType)!))
        switch Settings.GetString(ForKey: .ShapeType)!
        {
            case NodeShapes.Blocks.rawValue:
                Results.append(("Edge smoothing", Settings.GetString(ForKey: .BlockChamferSize)!))
            
            case NodeShapes.CappedLines.rawValue:
                Results.append(("Cap location", Settings.GetString(ForKey: .CappedLineBallLocation)!))
                Results.append(("Cap shape", Settings.GetString(ForKey: .CappedLineCapShape)!))
            
            case NodeShapes.Letters.rawValue:
                Results.append(("Font", Settings.GetString(ForKey: .LetterFont)!))
                Results.append(("Font size", "\(Settings.GetInteger(ForKey: .FontSize))"))
                Results.append(("Location", Settings.GetString(ForKey: .LetterLocation)!))
                Results.append(("Render quality", Settings.GetString(ForKey: .LetterSmoothness)!))
            
            case NodeShapes.Stars.rawValue:
                Results.append(("Apex count", "\(Settings.GetInteger(ForKey: .StarApexCount))"))
                Results.append(("Prominence determines apex count", "\(Settings.GetBoolean(ForKey: .IncreaseStarApexesWithProminence))"))
            
            case NodeShapes.Meshes.rawValue:
                Results.append(("Mesh thickness", Settings.GetString(ForKey: .MeshLineThickness)!))
                Results.append(("Dot size", Settings.GetString(ForKey: .MeshDotSize)!))
            
            case NodeShapes.RadiatingLines.rawValue:
                Results.append(("Radiating line thickness", Settings.GetString(ForKey: .RadiatingLineThickness)!))
                Results.append(("Radiating line count", "\(Settings.GetInteger(ForKey: .RadiatingLineCount))"))
            
            case NodeShapes.Cones.rawValue:
                Results.append(("Invert cone", "\(Settings.GetBoolean(ForKey: .ConeIsInverted))"))
                Results.append(("Top radius", Settings.GetString(ForKey: .ConeTopOptions)!))
                Results.append(("Base radius", Settings.GetString(ForKey: .ConeBottomOptions)!))
            
            case NodeShapes.Ellipses.rawValue:
                Results.append(("Ellipse shape", "\(Settings.GetString(ForKey: .EllipseShape)!)"))
            
            case NodeShapes.Flowers.rawValue:
                Results.append(("Flower petal count", "\(Settings.GetInteger(ForKey: .FlowerPetalCount))"))
                Results.append(("Prominence determines petal count", "\(Settings.GetBoolean(ForKey: .IncreasePetalCountWithProminence))"))
            
            case NodeShapes.HueVarying.rawValue:
                Results.append(("Hue shape list", "\(Settings.GetString(ForKey: .HueShapeList)!)"))
            
            case NodeShapes.SaturationVarying.rawValue:
                Results.append(("Saturation shape list", "\(Settings.GetString(ForKey: .SaturationShapeList)!)"))
            
            case NodeShapes.BrightnessVarying.rawValue:
                Results.append(("Brightness shape list", "\(Settings.GetString(ForKey: .BrightnessShapeList)!)"))
            
            case NodeShapes.CharacterSets.rawValue:
                Results.append(("Character set", "\(Settings.GetString(ForKey: .CharacterSeries)!)"))
            
            case NodeShapes.Characters.rawValue:
                Results.append(("Fully extrude", "\(Settings.GetBoolean(ForKey: .FullyExtrudeLetters))"))
                Results.append(("Random character font size", "\(Settings.GetBoolean(ForKey: .CharacterRandomFontSize))"))
                Results.append(("Random character font", "\(Settings.GetBoolean(ForKey: .CharacterUsesRandomFont))"))
                Results.append(("Character smoothness", Settings.GetString(ForKey: .LetterSmoothness)!))
                Results.append(("Character font name", Settings.GetString(ForKey: .CharacterFontName)!))
            
            case NodeShapes.RadiatingLines.rawValue:
                Results.append(("Radiating line count","\(Settings.GetInteger(ForKey: .RadiatingLineCount))"))
                Results.append(("Radiating line thickness", Settings.GetString(ForKey: .RadiatingLineThickness)!))
            
            default:
                break
        }
        Results.append(("Shape size", "\(Settings.GetInteger(ForKey: .BlockSize))"))
        Results.append(("Maximum image size", "\(Settings.GetInteger(ForKey: .MaxImageDimension))"))
        Results.append(("Height determination", Settings.GetString(ForKey: .HeightSource)!))
        Results.append(("Vertical exaggeration", Settings.GetString(ForKey: .VerticalExaggeration)!))
        Results.append(("Invert node height", "\(Settings.GetBoolean(ForKey: .InvertHeight))"))
        let Mode = UInt(Settings.GetInteger(ForKey: .AntialiasingMode))
        let AntialiasMode = SCNAntialiasingMode(rawValue: Mode)!
        switch AntialiasMode
        {
            case .multisampling2X:
                Results.append(("Antialiasing", "Multisampling 2X"))
            
            case .multisampling4X:
                Results.append(("Antialiasing", "Multisampling 4X"))
            
            default:
                break
        }
        Results.append(("Light color", Settings.GetString(ForKey: .LightColor)!))
        Results.append(("Light type", Settings.GetString(ForKey: .LightType)!))
        Results.append(("Light intensity", Settings.GetString(ForKey: .LightIntensity)!))
        Results.append(("Light model", Settings.GetString(ForKey: .LightingModel)!))
        let DColorTypeRaw = Settings.GetString(ForKey: .DynamicColorType)!
        if let DColorType = DynamicColorTypes(rawValue: DColorTypeRaw)
        {
            if DColorType != .None
            {
                Results.append(("Dynamic color type", DColorTypeRaw))
                Results.append(("Dynamic color action", "\(Settings.GetString(ForKey: .DynamicColorAction)!)"))
                Results.append(("Dynamic color conditional", "\(Settings.GetString(ForKey: .DynamicColorCondition)!)"))
                Results.append(("Invert dynamic color conditional", "\(Settings.GetBoolean(ForKey: .InvertDynamicColorProcess))"))
            }
        }
        return Results
    }
    
    /// Returns the current description of how to render images in human-readable form.
    public static var Description: String
    {
        get
        {
            var Result = ""
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("\(Title): \(Value)\n")
            }
            return Result
        }
    }
    
    /// Returns the current settings as an XML fragment.
    public static var XMLDescription: String
    {
        get
        {
            var Result = "<Settings>\n"
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("  <Setting Name=\"\(Title)\", Value=\"\(Value)\"/>\n")
            }
            Result.append("</Settings>")
            return Result
        }
    }
    
    /// Returns the current settings as a JSON fragment.
    public static var JSONDescription: String
    {
        get
        {
            var Result = "{\n\"Settings\":\n {\n"
            Result.append("    [\n")
            let Current = DescriptionComponents()
            for (Title, Value) in Current
            {
                Result.append("      {\n")
                Result.append("        \"Title\": \"\(Title)\",\n")
                Result.append("        \"Value\": \"\(Value)\"\n")
                Result.append("      },\n")
            }
            Result.append("    ]\n")
            Result.append("  }\n")
            Result.append("}\n")
            return Result
        }
    }
    
    /// Returns the current settings as a list of semi-colon-separated key-value pairs.
    public static var KVPs: String
    {
        get
        {
            var Result = ""
            let Current = DescriptionComponents()
            for (Name, Value) in Current
            {
                Result.append("\(Name)=\(Value);")
            }
            return Result
        }
    }
    
    /// Returns the current settings as a list of semi-colon-separated key-value pairs, appended with extra information.
    /// - Parameter AppendWith: Extra information to append.
    /// - Returns: String of semi-colon-separated key value pairs of current settings plus passed data.
    public static func KVPs(AppendWith: [(String, String)]) -> String
    {
        var StandardKVPs = KVPs
        for (Key, Value) in AppendWith
        {
            StandardKVPs.append("\(Key)=\(Value);")
        }
        return StandardKVPs
    }
}
