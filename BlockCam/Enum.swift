//
//  Enum.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// This file holds most (but not all) enums used in BlockCam.

/// Program modes for the camera.
enum ProgramModes: String, CaseIterable
{
    /// Live view mode. Images selected by the user when the camera button is pressed.
    case LiveView = "LiveView"
    /// Processed view mode. Similar to live view but the app shows the processed view in real time (well, as fast as the
    /// hardware supports) instead of the camera's view.
    case ProcessedView = "ProcessedView"
    /// Photo library mode. Images selected by the user from the photo library.
    case PhotoLibrary = "PhotoLibrary"
    /// Make a video then process it.
    case MakeVideo = "MakeVideo"
}

/// Sources of block prominence.
enum HeightSources: String, CaseIterable
{
    /// Hue of the color.
    case Hue = "Hue"
    /// Saturation of the color.
    case Saturation = "Saturation"
    /// Brightness of the color.
    case Brightness = "Brightness"
    /// Red channel.
    case Red = "Red"
    /// Green channel.
    case Green = "Green"
    /// Blue channel.
    case Blue = "Blue"
    /// Cyan channel.
    case Cyan = "Cyan"
    /// Magenta channel.
    case Magenta = "Magenta"
    /// Yellow channel.
    case Yellow = "Yellow"
    /// Black channel.
    case Black = "Black"
    /// YUV Y channel.
    case YUV_Y = "YUV: Y"
    /// YUV U channel.
    case YUV_U = "YUV: U"
    /// YUV V channel.
    case YUV_V = "YUV: V"
    #if false
    /// LAB L channel.
    case LAB_L = "LAB: L"
    /// LAB A channel.
    case LAB_A = "LAB: A"
    /// LAB B channel.
    case LAB_B = "LAB: B"
    /// XYZ X channel.
    case XYZ_X = "XYZ: X"
    /// XYZ Y channel.
    case XYZ_Y = "XYZ: Y"
    /// XYZ Z channel.
    case XYZ_Z = "XYZ: Z"
    #endif
    /// The channel with the greatest magnitude.
    case GreatestChannel = "Greatest Channel"
    /// The channel with the least magnitude.
    case LeastChannel = "Least Channel"
}

/// Input size constraints for image processing.
enum SizeConstraints: String, CaseIterable
{
    /// No constraint - image is used as is.
    case None = "None"
    /// Image is reduced to a "small" size.
    case Small = "Small"
    /// Image is reduced to a "medium" size.
    case Medium = "Medium"
    /// Image is reduced to a "large" size (but still smaller than `.None`).
    case Large = "Large"
}

/// Quality levels for video in terms of resolution.
enum VideoQuality: String, CaseIterable
{
    /// Smallest video.
    case Smallest = "Smallest"
    /// Small video.
    case Small = "Small"
    /// Medium sized video.
    case Medium = "Medium"
    /// Large video.
    case Large = "Large"
    /// Original resolution video.
    case Original = "Original"
}

/// Material lighting types.
enum MaterialLightingTypes: String, CaseIterable
{
    /// Blinn lighting.
    case Blinn = "Blinn"
    /// Cosntant lighting.
    case Constant = "Constant"
    /// Lambert lighting.
    case Lambert = "Lambert"
    /// Phone lighting.
    case Phong = "Phong"
    /// Physically-based lighting.
    case PhysicallyBased = "PysicallyBased"
}

/// Types of setting data recognized by the SettingsManager.
enum SettingTypes: String, CaseIterable
{
    /// Returned when the caller finds a setting that is not yet integrated into the type system.
    case Unknown = "Unknown Type"
    /// `Bool` types.
    case Boolean = "Boolean"
    /// `String` types.
    case String = "String"
    /// `Int` types.
    case Integer = "Integer"
    /// `Double` types.
    case Double = "Double"
}

/// Ball locations for the capped line type of shape.
enum BallLocations: String, CaseIterable
{
    /// Ball is on the top of the line (highest Z).
    case Top = "Top"
    /// Ball is in the middle of the line.
    case Middle = "Middle"
    /// Ball is on the bottom of the line (lowest Z).
    case Bottom = "Bottom"
}

/// How to export logs.
enum ExportTypes: String, CaseIterable
{
    /// Export as SQLite3 database.
    case SQLite = "SQLite"
    /// Export as XML.
    case XML = "XML"
    /// Export as JSON.
    case JSON = "JSON"
    /// Cancel export.
    case Cancel = "Cancel"
}

/// Dot sizes for mesh nodes.
enum MeshDotSizes: String, CaseIterable
{
    /// No dot present.
    case None = "None"
    /// Small dots.
    case Small = "Small"
    /// Medium dots.
    case Medium = "Medium"
    /// Large dots.
    case Large = "Large"
}

/// Mesh line thicknesses for mesh nodes.
enum MeshLineThicknesses: String, CaseIterable
{
    /// Thin lines.
    case Thin = "Thin"
    /// Medium lines.
    case Medium = "Medium"
    /// Thick lines.
    case Thick = "Thick"
}

/// Line thicknesses for radiating lines.
enum RadiatingLineThicknesses: String, CaseIterable
{
    /// Thin lines.
    case Thin = "Thin"
    /// Medium lines.
    case Medium = "Medium"
    /// Thick lines.
    case Thick = "Thick"
}

/// Determines edge smoothing (AKA Chamfer Radius) for block shapes.
enum BlockEdgeSmoothings: String, CaseIterable
{
    /// Chamfer radius value of 0.0.
    case None = "None"
    /// Small Chamfer radius value.
    case Small = "Small"
    /// Medium Chamfer radius value.
    case Medium = "Medium"
    /// Large Chamfer radius value.
    case Large = "Large"
}

/// Determines how to place shapes.
enum ShapeLocations: String, CaseIterable
{
    /// Extrude shapes.
    case Extrude = "Extrude"
    /// Float shapes at the extrusion location but do not extrude.
    case Float = "Float"
    /// Enlarge shapes.
    case Enlarge = "Enlarge"
}

/// Determines how to size the base of a cone.
enum ConeBaseOptions: String, CaseIterable
{
    /// The base is the standard side value.
    case BaseIsSide = "Side"
    /// The base represents the saturation of the pixel.
    case BaseIsSaturation = "Saturation"
    /// The base represents the hue of the pixel.
    case BaseIsHue = "Hue"
    /// The base is 10% of the side.
    case TenPercentSide = "SideTen"
    /// The base is 50% of the side.
    case FiftyPercentSide = "SideFifty"
    /// The base has a radius of 0.0.
    case BaseIsZero = "Zero"
    /// The base has a radius of 10% of the top.
    case TenPercent = "Ten"
    /// The base has a radius of 50% of the top.
    case FiftyPercent = "Fifty"
}

/// Determines how to size the top of a cone.
enum ConeTopOptions: String, CaseIterable
{
    /// The top is the standard side value.
    case TopIsSide = "Side"
    /// The top represents the saturation of the pixel.
    case TopIsSaturation = "Saturation"
    /// The top represents the hue of the pixel.
    case TopIsHue = "Hue"
    /// The top is 10% of the side.
    case TenPercentSide = "SideTen"
    /// The top is 50% of the side.
    case FiftyPercentSide = "SideFifty"
    /// The top has a radius of 0.0.
    case TopIsZero = "Zero"
    /// The top has a radius of 10% of the bottom.
    case TenPercent = "Ten"
    /// The top has a radius of 50% of the bottom.
    case FiftyPercent = "Fifty"
}

/// Methods to hide the main title.
enum HideMethods
{
    /// Fade out via alpha.
    case FadeOut
    /// Quickly move the title off-screen right.
    case ZoomRight
    /// Quickly move the title off-screen left.
    case ZoomLeft
    /// Quickly move the title off-screen up.
    case ZoomUp
}

/// Determines the type of dynamic coloring to use.
enum DynamicColorTypes: String, CaseIterable
{
    /// No dynamic coloring enabled.
    case None = "None"
    /// Use hue to determine dynamic coloring.
    case Hue = "Hue"
    /// Use saturation to determine dynamic coloring.
    case Saturation = "Saturation"
    /// Use brightness to determine dynamic coloring.
    case Brightness = "Brightness"
}

/// The action to take when dynamic conditions pertain.
enum DynamicColorActions: String, CaseIterable
{
    /// Convert the color to grayscale.
    case Grayscale = "Grayscale"
    /// Increase the color's saturation.
    case IncreaseSaturation = "IncreaseSaturation"
    /// Decrease the color's saturation
    case DecreaseSaturation = "DecreaseSaturation"
}

/// Determines when dynamic colors come into effect.
enum DynamicColorConditions: String, CaseIterable
{
    /// When the `DynamicColorTypes` value is less than 0.1.
    case LessThan10 = "< 10"
    /// When the `DynamicColorTypes` value is less than 0.25.
    case LessThan25 = "< 25"
    /// When the `DynamicColorTypes` value is less than 0.5.
    case LessThan50 = "< 50"
    /// When the `DynamicColorTypes` value is less than 0.75.
    case LessThan75 = "< 75"
    /// When the `DynamicColorTypes` value is less than 0.9.
    case LessThan90 = "< 90"
}

/// Determines the shape of the cap for capped lines.
enum CappedLineCapShapes: String, CaseIterable
{
    /// Sphere shape.
    case Sphere = "Sphere"
    /// Box shape.
    case Box = "Box"
    /// Cone shape.
    case Cone = "Cone"
    /// 2D square.
    case Square = "Square"
    /// 2D circle.
    case Circle = "Circle"
}

/// How to crop processed images.
/// - Note: Cropping is available only when the background is a solid color.
enum CroppingOptions: String, CaseIterable
{
    /// No cropping.
    case None = "None"
    /// Crop as closely as possible.
    case Close = "Close"
    /// Crop a medium distance.
    case Medium = "Medium"
    /// Crop a far distance.
    case Far = "Far"
}

/// Basic "list" of colors.
enum BasicColors: String, CaseIterable
{
    case Black = "Black"
    case White = "White"
    case Gray = "Gray"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Orange = "Orange"
    case Indigo = "Indigo"
    case SysYellow = "System Yellow"
    case SysGreen = "System Green"
    case SysBlue = "System Blue"
    case SysOrange = "System Orange"
}

/// Ways ellipses can be drawn.
enum EllipticalShapes: String, CaseIterable
{
    /// Horizontal short ellipse (major and minor axes are close).
    case HorizontalShort = "Horizontal Short"
    /// Horizontal medium ellipse (between short and long).
    case HorizontalMedium = "Horizontal Medium"
    /// Horizontal long ellipse (major and minor axes far apart).
    case HorizontalLong = "Horizontal Long"
    /// Vertical short ellipse (major and minor axes are close).
    case VerticalShort = "Vertical Short"
    /// Vertical medium ellipse (between short and long).
    case VerticalMedium = "Vertical Medium"
    /// Vertical long ellipse (major and minor axes far apart).
    case VerticalLong = "Vertical Long"
}

/// Orders in which the histogram display can be shown.
enum HistogramOrders: String, CaseIterable
{
    /// Red, green, blue order.
    case RGB = "RGB"
    /// Red, blue, green order.
    case RBG = "RBG"
    /// Green, red, blue order.
    case GRB = "GRB"
    /// Green, blue, red order.
    case GBR = "GBR"
    /// Blue, red, green order.
    case BRG = "BRG"
    /// Blue, green, red order.
    case BGR = "BGR"
    /// Grayscale (showing synthetic brightness).
    case Gray = "Gray"
}

/// Determines how often (in frame counts) to create histograms.
enum HistogramCreationSpeeds: String, CaseIterable
{
    /// Create a histogram every frame.
    case Fastest = "Fastest"
    /// Crate a histogram at a fast rate.
    case Fast = "Fast"
    /// Create a histogram at a medium rate.
    case Medium = "Medium"
    /// Create a histogram at a slow rate.
    case Slow = "Slow"
    /// Create a histogram at the slowest rate.
    case Slowest = "Slowest"
}

/// How to rotate the UI in response to device rotation.
enum UIRotationTypes: String, CaseIterable
{
    /// No rotations.
    case None = "None"
    /// Rotate to cardinal directions only.
    case CardinalDirections = "Cardinal Directions"
    /// Rotate in degrees of 1°.
    case Continuous = "Continuous Rotation"
}

/// How to determine the color of the line for capped-line shapes.
enum CappedLineLineColors: String, CaseIterable
{
    /// Same color as the sphere.
    case Same = "Same"
    /// Darker than the sphere.
    case Darker = "Darker"
    /// Ligher than the sphere.
    case Lighter = "Lighter"
    /// Black.
    case Black = "Black"
    /// White.
    case White = "White"
}

/// Defines how spheres are generated based on the color prominence.
enum SphereBehaviors: String, CaseIterable
{
    /// Prominence affects the size of the sphere.
    case Size = "Size"
    /// Prominence affects the location of the sphere.
    case Location = "Location"
    /// Promonence affects the size and location of the sphere.
    case Both = "Both"
}

/// General definition of 3D axes.
enum Axes: String, CaseIterable
{
    /// The X axis.
    case X = "X"
    /// The Y axis.
    case Y = "Y"
    /// The Z axis.
    case Z = "Z"
}
