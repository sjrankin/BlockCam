//
//  SCNShapeRange.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extruded character selected from a list of caller-supplied characters.
class SCNShapeRange: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        UpdateShape()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateShape()
    }
    
    /// Initializer.
    /// - Warning: If `Character` is empty, a fatal error will be generated.
    /// - Parameter FromRange: Range of characters from which to choose a random character.
    /// - Parameter Font: The name of the font to use to create the character.
    /// - Parameter FontSize: The size of the font.
    /// - Parameter Extrusion: The extrusion depth of the geometry.
    /// - Parameter Scale: Scale of the node. Defaults to 1.0.
    init(FromRange: [String], Font: String, FontSize: CGFloat, Extrusion: CGFloat = 1.0, Scale: CGFloat = 1.0)
    {
        super.init()
        _CharRange = FromRange
        _Font = Font
        _FontSize = FontSize
        _Extrusion = Extrusion
        _Scale = Scale
        UpdateShape()
    }
    
    private func UpdateShape()
{
    self.geometry = SCNShapeRange.Geometry(Character: _Character, Font: _Font, FontSize: _FontSize, Extrusion: _Extrusion)
    self.scale = SCNVector3(_Scale, _Scale, _Scale)
    }
    
    /// Holds the range of source characters.
    private var _CharRange: [String] = ["a"]
    /// Get or set the range of source characters. Assigning a value here will automatically select a character from the
    /// range. If the assigned range is empty, a place-holder character is used.
    public var CharacterRange: [String]
    {
        get
        {
            return _CharRange
        }
        set
        {
            _CharRange = newValue
            if _CharRange.isEmpty
            {
                _CharRange.append("a")
            }
            _Character = _CharRange.randomElement()!
            UpdateShape()
        }
    }
    
    private var _FontSize: CGFloat = 10.0
    public var FontSize: CGFloat
    {
        get
        {
            return _FontSize
        }
        set
        {
            _FontSize = newValue
            UpdateShape()
        }
    }
    
    /// Holds the name of the font.
    private var _Font: String = "Avenir"
    /// Get or set the name of the font. Defaults to "Avenir"
    public var Font: String
    {
        get
        {
            return _Font
        }
        set
        {
            _Font = newValue
            UpdateShape()
        }
    }
    
    /// Holds the character to use to generate geometry.
    private var _Character: String = "a"
    /// Get or set the character to use to generate geometry. Defaults to "a".
    public var Character: String
    {
        get
        {
            return _Character
        }
        set
        {
            _Character = newValue
            UpdateShape()
        }
    }
    
    /// Holds the scale of the node.
    private var _Scale: CGFloat = 1.0
    /// get or set the scale of the node. Defaults to 1.0.
    public var Scale: CGFloat
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            UpdateShape()
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
            UpdateShape()
        }
    }
    
    // MARK: - Static functions.
    
    /// Creates and returns the geometry for the passed string and font.
    /// - Warning: If `Character` is empty, a fatal error will be generated.
    /// - Parameter Character: The character to use to create the shape. If more than one character is passed, only the first
    ///                        character is used. If an empty string is passed, an error will occur.
    /// - Parameter Font: The name of the font to use to create the character.
    /// - Parameter FontSize: The size of the font.
    /// - Parameter Extrusion: The extrusion depth of the geometry.
    /// - Returns: `SCNGeometry` object with the geometry as determined by the parameters.
    public static func Geometry(Character: String, Font: String, FontSize: CGFloat, Extrusion: CGFloat) -> SCNGeometry
    {
        if Character.isEmpty
        {
            Log.AbortMessage("Empty string sent to SCNShapeRange.Geometry().", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
        let Shape = SCNText(string: String(Character.first!), extrusionDepth: Extrusion)
        Shape.font = UIFont(name: Font, size: FontSize)
        if let Smoothness = Settings.GetString(ForKey: .LetterSmoothness)
        {
            switch Smoothness
            {
                case "Roughest":
                    Shape.flatness = 1.2
                
                case "Rough":
                    Shape.flatness = 0.8
                
                case "Medium":
                    Shape.flatness = 0.5
                
                case "Smooth":
                    Shape.flatness = 0.25
                
                case "Smoothest":
                    Shape.flatness = 0.0
                
                default:
                    Shape.flatness = 0.5
            }
        }
        else
        {
            Settings.SetString("Smooth", ForKey: .LetterSmoothness)
            Shape.flatness = 0.0
        }
        return Shape
    }
}
