//
//  SettingsManager.swift
//  BlockCam
//  Adapted from GPS Log.
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Wrapper around `UserDefaults.standard` to provide atomic-level change notification for settings.
/// - Note:
///   - See the enum `SettingKeys` for a description of each setting.
///   - Currently, settings are stored in `UserDefaults.standard`. However, it is straightforward to refactor this class to use
///     a different storage type, such as a database or .XML or .JSON file.
/// - Warning: If the caller tries to access a setting with the incorrect type (such as calling `GetBoolean` with a String-
///            backed setting), a fatal error will be generated. See `GetSettingType` for a way to avoid this.
class Settings
{
    /// Table of subscribers.
    private static var Subscribers = [(String, SettingChangedProtocol?)]()
    
    /// Initialize the class. Creates the default set of settings if they do not exist.
    public static func Initialize ()
    {
        InitializeDefaults()
    }
    
    /// Add a subscriber to the notification list. Each subscriber is called just before a setting is committed and just after
    /// it is committed.
    /// - Parameter NewSubscriber: The delegate of the new subscriber.
    /// - Parameter Owner: The name of the owner.
    public static func AddSubscriber(_ NewSubscriber: SettingChangedProtocol, _ Owner: String)
    {
        Subscribers.append((Owner, NewSubscriber))
    }
    
    /// Remove a subscriber from the notification list.
    /// - Parameter Name: The name of the subscriber to remove. Must be identical to the name supplied to `AddSubscriber`.
    public static func RemoveSubscriber(_ Name: String)
    {
        Subscribers = Subscribers.filter{$0.0 != Name}
    }
    
    /// Initialize defaults if there are no current default settings available.
    public static func InitializeDefaults()
    {
        if UserDefaults.standard.string(forKey: "Initialized") == nil
        {
            AddDefaultSettings()
        }
    }
    
    /// Create and add default settings.
    /// - Note: If called after initialize instantiation, all user-settings will be overwritten. User data
    ///         (in the form of the log database) will *not* be affected.
    /// - Note: Depending on whether the compilation was for a debug build or a release build, default settings may
    ///         vary. For each instance of a variance between the two build types, comments are provided. In general,
    ///         debug builds are not as stringent with privacy.
    public static func AddDefaultSettings()
    {
        UserDefaults.standard.set(Versioning.VersionAsNumber(), forKey: "SettingsVersion")
        UserDefaults.standard.set("Initialized", forKey: "Initialized")
        UserDefaults.standard.set(32, forKey: SettingKeys.BlockSize.rawValue)
        UserDefaults.standard.set(NodeShapes.Blocks.rawValue, forKey: SettingKeys.ShapeType.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.InvertHeight.rawValue)
        UserDefaults.standard.set(HeightSources.Brightness.rawValue, forKey: SettingKeys.HeightSource.rawValue)
        UserDefaults.standard.set("Medium", forKey: SettingKeys.ImageSizeConstraints.rawValue)
        UserDefaults.standard.set(VerticalExaggerations.Medium.rawValue, forKey: SettingKeys.VerticalExaggeration.rawValue)
        UserDefaults.standard.set(2, forKey: SettingKeys.InputQuality.rawValue)
        UserDefaults.standard.set("Back", forKey: SettingKeys.CurrentCamera.rawValue)
        UserDefaults.standard.set("White", forKey: SettingKeys.LightColor.rawValue)
        UserDefaults.standard.set("Omni", forKey: SettingKeys.LightType.rawValue)
        UserDefaults.standard.set("Normal", forKey: SettingKeys.LightIntensity.rawValue)
        UserDefaults.standard.set("Normal", forKey: SettingKeys.FieldOfView.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.ShowHistogram.rawValue)
        UserDefaults.standard.set(HistogramOrders.RGB.rawValue, forKey: SettingKeys.HistogramOrder.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.ShowProcessedHistogram.rawValue)
        UserDefaults.standard.set(HistogramCreationSpeeds.Medium.rawValue, forKey: SettingKeys.HistogramCreationSpeed.rawValue)
        UserDefaults.standard.set("LiveView", forKey: SettingKeys.InitialView.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.FullyExtrudeLetters.rawValue)
        UserDefaults.standard.set("Extrude", forKey: SettingKeys.LetterLocation.rawValue)
        UserDefaults.standard.set(LetterSmoothnesses.Smooth.rawValue, forKey: SettingKeys.LetterSmoothness.rawValue)
        UserDefaults.standard.set("Futura", forKey: SettingKeys.LetterFont.rawValue)
        UserDefaults.standard.set("Basic Latin", forKey: SettingKeys.RandomCharacterSource.rawValue)
        UserDefaults.standard.set(1, forKey: SettingKeys.VideoFPS.rawValue)
        UserDefaults.standard.set("Smallest", forKey: SettingKeys.VideoDimensions.rawValue)
        UserDefaults.standard.set(48, forKey: SettingKeys.VideoBlockSize.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.UseMetal.rawValue)
        UserDefaults.standard.set(0, forKey: SettingKeys.AntialiasingMode.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.InitialBestFit.rawValue)
        UserDefaults.standard.set("Always", forKey: SettingKeys.SaveOriginalImageAction.rawValue)
        UserDefaults.standard.set(1, forKey: SettingKeys.NextSequentialInteger.rawValue)
        UserDefaults.standard.set(9999, forKey: SettingKeys.LoopSequentialIntegerAfter.rawValue)
        UserDefaults.standard.set(1, forKey: SettingKeys.StartSequentialIntegerAt.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.IncreaseStarApexesWithProminence.rawValue)
        UserDefaults.standard.set(5, forKey: SettingKeys.StarApexCount.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.HaltWhenCriticalThermal.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.HaltOnLowPower.rawValue)
        UserDefaults.standard.set(2.0, forKey: SettingKeys.BestFitOffset.rawValue)
        UserDefaults.standard.set(MaterialLightingTypes.Phong.rawValue, forKey: SettingKeys.LightingModel.rawValue)
        UserDefaults.standard.set("Top", forKey: SettingKeys.CappedLineBallLocation.rawValue)
        UserDefaults.standard.set(CappedLineLineColors.Same.rawValue, forKey: SettingKeys.CappedLineLineColor.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.InvertDynamicColorProcess.rawValue)
        UserDefaults.standard.set(DynamicColorTypes.None.rawValue, forKey: SettingKeys.DynamicColorType.rawValue)
        UserDefaults.standard.set(DynamicColorActions.Grayscale.rawValue, forKey: SettingKeys.DynamicColorAction.rawValue)
        UserDefaults.standard.set(DynamicColorConditions.LessThan50.rawValue, forKey: SettingKeys.DynamicColorCondition.rawValue)
        #if DEBUG
        //When compiling in debug mode, always enable logging.
        UserDefaults.standard.set(true, forKey: SettingKeys.LoggingEnabled.rawValue)
        #else
        //When compiling in release mode, the user must actively enable logging.
        UserDefaults.standard.set(false, forKey: SettingKeys.LoggingEnabled.rawValue)
        #endif
        UserDefaults.standard.set(36, forKey: SettingKeys.FontSize.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableUISounds.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.EnableShutterSound.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableImageProcessingSound.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableVideoRecordingSound.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableButtonPressSounds.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableOptionSelectSounds.rawValue)
        #if DEBUG
        //When compiling in debug mode, enable crash event sounds.
        UserDefaults.standard.set(true, forKey: SettingKeys.EnableCrashSounds.rawValue)
        #else
        //When compiling in release mode, do not enable crash event sounds.
        UserDefaults.standard.set(false, forKey: SettingKeys.EnableCrashSounds.rawValue)
        #endif
        UserDefaults.standard.set("Medium", forKey: SettingKeys.MeshDotSize.rawValue)
        UserDefaults.standard.set("Medium", forKey: SettingKeys.MeshLineThickness.rawValue)
        UserDefaults.standard.set("Medium", forKey: SettingKeys.RadiatingLineThickness.rawValue)
        UserDefaults.standard.set(8, forKey: SettingKeys.RadiatingLineCount.rawValue)
        UserDefaults.standard.set("None", forKey: SettingKeys.BlockChamferSize.rawValue)
        UserDefaults.standard.set(1024, forKey: SettingKeys.MaxImageDimension.rawValue)
        #if DEBUG
        //When compiling in debug mode, always add user data to saved processed image exif data. Images are released
        //under CC BY 3.0.
        UserDefaults.standard.set(true, forKey: SettingKeys.AddUserDataToExif.rawValue)
        UserDefaults.standard.set("Stuart Rankin", forKey: SettingKeys.UserName.rawValue)
        UserDefaults.standard.set("Attribution 3.0 Unported (CC BY 3.0)", forKey: SettingKeys.UserCopyright.rawValue)
        #else
        //When compiling in release mode, default value for saving user data in processed image exif data is false, meaning
        //the user must actively enable this setting.
        UserDefaults.standard.set(false, forKey: SettingKeys.AddUserDataToExif.rawValue)
        UserDefaults.standard.set("", forKey: SettingKeys.UserName.rawValue)
        UserDefaults.standard.set("", forKey: SettingKeys.UserCopyright.rawValue)
        #endif
        UserDefaults.standard.set(true, forKey: SettingKeys.ConeIsInverted.rawValue)
        UserDefaults.standard.set(ConeTopOptions.TopIsZero.rawValue, forKey: SettingKeys.ConeTopOptions.rawValue)
        UserDefaults.standard.set(ConeBaseOptions.BaseIsSide.rawValue, forKey: SettingKeys.ConeBottomOptions.rawValue)
        UserDefaults.standard.set("Blocks,Spheres,Cylinders,Hexagons,Stars", forKey: SettingKeys.HueShapeList.rawValue)
        UserDefaults.standard.set("Blocks,Hexagons,Octagons,Spheres,Capped Lines", forKey: SettingKeys.SaturationShapeList.rawValue)
        UserDefaults.standard.set("Cylinders,Blocks,Triangles,Hexagons,Spheres,Stars", forKey: SettingKeys.BrightnessShapeList.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.ShowSplashScreen.rawValue)
        UserDefaults.standard.set("Black", forKey: SettingKeys.SceneBackgroundColor.rawValue)
        UserDefaults.standard.set(CroppingOptions.Close.rawValue, forKey: SettingKeys.CroppedImageBorder.rawValue)
        #if DEBUG
        UserDefaults.standard.set(false, forKey: SettingKeys.AutoSaveProcessedImage.rawValue)
        #else
        UserDefaults.standard.set(true, forKey: SettingKeys.AutoSaveProcessedImage.rawValue)
        #endif
        UserDefaults.standard.set(false, forKey: SettingKeys.SourceAsBackground.rawValue)
        UserDefaults.standard.set(CappedLineCapShapes.Sphere.rawValue, forKey: SettingKeys.CappedLineCapShape.rawValue)
        UserDefaults.standard.set(0, forKey: SettingKeys.InstantiationTime.rawValue)
        #if DEBUG
        UserDefaults.standard.set(true, forKey: SettingKeys.LogImageSettings.rawValue)
        #else
        UserDefaults.standard.set(false, forKey: SettingKeys.LogImageSettings.rawValue)
        #endif
        UserDefaults.standard.set(EllipticalShapes.HorizontalMedium.rawValue, forKey: SettingKeys.EllipseShape.rawValue)
        UserDefaults.standard.set(6, forKey: SettingKeys.FlowerPetalCount.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.IncreasePetalCountWithProminence.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.CharacterUsesRandomFont.rawValue)
        UserDefaults.standard.set(RandomCharacterRanges.AnyCharacter.rawValue, forKey: SettingKeys.CharacterRandomRange.rawValue)
        UserDefaults.standard.set("Avenir", forKey: SettingKeys.CharacterFontName.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.CharacterRandomFontSize.rawValue)
        UserDefaults.standard.set(ShapeSeries.Flowers.rawValue, forKey: SettingKeys.CharacterSeries.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.AllPermissionsGranted.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.CameraAccessGranted.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.PhotoRollAccessGranted.rawValue)
        UserDefaults.standard.set(NodeShapes.Blocks.rawValue, forKey: SettingKeys.StackedShapesSet.rawValue)
        UserDefaults.standard.set(GridTypes.None.rawValue, forKey: SettingKeys.LiveViewGridType.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.ShowActualOrientation.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.ShowTapFeedback.rawValue)
        UserDefaults.standard.set("", forKey: SettingKeys.FavoriteShapeList.rawValue)
        UserDefaults.standard.set(UIRotationTypes.CardinalDirections.rawValue, forKey: SettingKeys.UIRotationStyle.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.EnableShadows.rawValue)
        UserDefaults.standard.set(5, forKey: SettingKeys.PolygonSideCount.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.PolygonSideCountVaries.rawValue)
        UserDefaults.standard.set(SphereBehaviors.Size.rawValue, forKey: SettingKeys.SphereBehavior.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Polygon2DAxis.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Circle2DAxis.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Oval2DAxis.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Diamond2DAxis.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Star2DAxis.rawValue)
        UserDefaults.standard.set(Axes.X.rawValue, forKey: SettingKeys.Rectangle2DAxis.rawValue)
        UserDefaults.standard.set(NodeShapes.Blocks.rawValue, forKey: SettingKeys.SpherePlusShape.rawValue)
        UserDefaults.standard.set(NodeShapes.Spheres.rawValue, forKey: SettingKeys.BoxPlusShape.rawValue)
        UserDefaults.standard.set(NodeShapes.Spheres.rawValue, forKey: SettingKeys.RandomBaseShape.rawValue)
        UserDefaults.standard.set(RandomIntensities.Moderate.rawValue, forKey: SettingKeys.RandomIntensity.rawValue)
        UserDefaults.standard.set(RandomRadiuses.Medium.rawValue, forKey: SettingKeys.RandomRadius.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.RandomShapeShowsBase.rawValue)
    }
    
    /// Call all subscribers in the notification list to let them know a setting will be changed.
    /// - Note: Callers have the opportunity to cancel the request. If the caller sets `CancelChange` in the protocol to
    ///         false, they want to cancel the settings change. If there are multiple subscribers and different responses,
    ///         the last response will take precedence.
    /// - Parameter WithKey: The key of the setting that will be changed.
    /// - Parameter AndValue: The new value (cast to Any).
    /// - Parameter CancelRequested: Will contain the caller's cancel change request on return.
    private static func NotifyWillChange(WithKey: SettingKeys, AndValue: Any, CancelRequested: inout Bool)
    {
        var RequestCancel = false
        Subscribers.forEach{$0.1?.WillChangeSetting(WithKey, NewValue: AndValue, CancelChange: &RequestCancel)}
        CancelRequested = RequestCancel
    }
    
    /// Send a notification to all subscribers that a settings change occurred.
    /// - Parameter WithKey: The key that changed.
    private static func NotifyDidChange(WithKey: SettingKeys)
    {
        Subscribers.forEach{$0.1?.DidChangeSetting(WithKey)}
    }
    
    /// Saves a boolean value to the settings.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter NewValue: The boolean value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetBoolean(_ NewValue: Bool, ForKey: SettingKeys)
    {
        if BooleanFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
    }
    
    /// Saves a boolean value to the settings.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter NewValue: The boolean value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetBoolean(_ NewValue: Bool, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if BooleanFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a boolean setting.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetBoolean(ForKey: SettingKeys) -> Bool
    {
        if BooleanFields.contains(ForKey)
        {
            return UserDefaults.standard.bool(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
    }
    
    /// Saves a Double value to the settings.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter NewValue: The Double value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetDouble(_ NewValue: Double, ForKey: SettingKeys)
    {
        if DoubleFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
    }
    
    /// Saves a Double value to the settings.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter NewValue: The Double value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetDouble(_ NewValue: Double, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if DoubleFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a Double setting.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetDouble(ForKey: SettingKeys) -> Double
    {
        if DoubleFields.contains(ForKey)
        {
            return UserDefaults.standard.double(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
    }
    
    /// Saves an integer value to the settings.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter NewValue: The integer value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetInteger(_ NewValue: Int, ForKey: SettingKeys)
    {
        if IntegerFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
    }
    
    /// Saves an integer value to the settings.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter NewValue: The integer value to set.
    /// - Parameter ForKey: The key to set.
    /// - Completed: Completion handler.
    public static func SetInteger(_ NewValue: Int, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if IntegerFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of an integer setting.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetInteger(ForKey: SettingKeys) -> Int
    {
        if IntegerFields.contains(ForKey)
        {
            return UserDefaults.standard.integer(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
    }
    
    /// Saves a string value to the settings.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter NewValue: The string value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetString(_ NewValue: String, ForKey: SettingKeys)
    {
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Saves a string value to the settings.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter NewValue: The string value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetString(_ NewValue: String, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a string setting.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned. Nil will be returned if the contents of
    ///                     `ForKey` are not set.
    /// - Returns: The string pointed to by `ForKey`. If no string has been stored, nil is returned.
    public static func GetString(ForKey: SettingKeys) -> String?
    {
        if StringFields.contains(ForKey)
        {
            return UserDefaults.standard.string(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Returns the value of a string setting. Guarenteed to always return a string.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter ForKey: The settings whose value will be returned.
    /// - Parameter Default: The value to return if there is no stored value. This value will
    ///                      also be used to populate the setting.
    /// - Returns: The string value pointed to by `ForKey` on success, the contents of `Default`
    ///            if there is no value in the setting pointed to by `ForKey`.
    public static func GetString(ForKey: SettingKeys, _ Default: String) -> String
    {
        if StringFields.contains(ForKey)
        {
            let StoredString = UserDefaults.standard.string(forKey: ForKey.rawValue)
            if StoredString == nil
            {
                UserDefaults.standard.set(Default, forKey: ForKey.rawValue)
                return Default
            }
            return StoredString!
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Return an enum case value from user settings.
    /// - Note: A fatal error is generated if `ForKey` does not point to a string setting.
    /// - Note: See: [Pass an enum type name](https://stackoverflow.com/questions/38793536/possible-to-pass-an-enum-type-name-as-an-argument-in-swift)
    /// - Parameter ForKey: The setting key that points to where the enum case is stored (as a string).
    /// - Parameter EnumType: The type of the enum to return.
    /// - Parameter Default: The default value returned for when `ForKey` has yet to be set.
    /// - Returns: Enum value (of type `EnumType`) for the specified setting key.
    public static func GetEnum<T: RawRepresentable>(ForKey: SettingKeys, EnumType: T.Type, Default: T) -> T where T.RawValue == String
    {
        if StringFields.contains(ForKey)
        {
            if let Raw = GetString(ForKey: ForKey)
            {
                guard let Value = EnumType.init(rawValue: Raw) else
                {
                    return Default
                }
                return Value
            }
            return Default
        }
        else
        {
            fatalError("\(ForKey) does not point to a string setting.")
        }
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    /// - Parameter Completed: Closure called at the end of the saving process.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingKeys,
                                                    Completed: ((SettingKeys) -> Void)) where T.RawValue == String
    {
        //If there is no error, this merely sets Raw equal to NewValue. We do this to make sure
        //the caller didn't use an enum case from the wrong enum with EnumType.
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum A to Enum B.")
        }
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue.rawValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
        Completed(ForKey)
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingKeys) where T.RawValue == String
    {
        //If there is no error, this merely sets Raw equal to NewValue. We do this to make sure
        //the caller didn't use an enum case from the wrong enum with EnumType.
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum type 'A' to Enum type 'B'.")
        }
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue.rawValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Returns the type of the backing data for the passed setting.
    /// - Parameter ForSetting: The setting whose backing type will be returned.
    /// - Returns: Backing type for the setting. `.Unknown` is returned if the type system does not yet comprehend the passed setting.
    public static func GetSettingType(_ ForSetting: SettingKeys) -> SettingTypes
    {
        if BooleanFields.contains(ForSetting)
        {
            return .Boolean
        }
        if IntegerFields.contains(ForSetting)
        {
            return .Integer
        }
        if DoubleFields.contains(ForSetting)
        {
            return .Double
        }
        if StringFields.contains(ForSetting)
        {
            return .String
        }
        return .Unknown
    }
    
    private static var DidUpdateUIPromptCount = false
    
    /// Contains a list of all boolean-type fields.
    public static let BooleanFields =
        [
            SettingKeys.InvertHeight,
            SettingKeys.ShowHistogram,
            SettingKeys.FullyExtrudeLetters,
            SettingKeys.UseMetal,
            SettingKeys.AntialiasingMode,
            SettingKeys.InitialBestFit,
            SettingKeys.IncreaseStarApexesWithProminence,
            SettingKeys.HaltWhenCriticalThermal,
            SettingKeys.HaltOnLowPower,
            SettingKeys.LoggingEnabled,
            SettingKeys.EnableUISounds,
            SettingKeys.EnableShutterSound,
            SettingKeys.EnableImageProcessingSound,
            SettingKeys.EnableVideoRecordingSound,
            SettingKeys.EnableButtonPressSounds,
            SettingKeys.EnableOptionSelectSounds,
            SettingKeys.EnableCrashSounds,
            SettingKeys.AddUserDataToExif,
            SettingKeys.ConeIsInverted,
            SettingKeys.ShowSplashScreen,
            SettingKeys.InvertDynamicColorProcess,
            SettingKeys.AutoSaveProcessedImage,
            SettingKeys.SourceAsBackground,
            SettingKeys.LogImageSettings,
            SettingKeys.IncreasePetalCountWithProminence,
            SettingKeys.CharacterUsesRandomFont,
            SettingKeys.CharacterRandomFontSize,
            SettingKeys.AllPermissionsGranted,
            SettingKeys.CameraAccessGranted,
            SettingKeys.PhotoRollAccessGranted,
            SettingKeys.ShowProcessedHistogram,
            SettingKeys.ShowActualOrientation,
            SettingKeys.ShowTapFeedback,
            SettingKeys.EnableShadows,
            SettingKeys.PolygonSideCountVaries,
            SettingKeys.RandomShapeShowsBase,
    ]
    
    /// Contains a list of all integer-type fields.
    public static let IntegerFields =
        [
            SettingKeys.BlockSize,
            SettingKeys.InputQuality,
            SettingKeys.VideoFPS,
            SettingKeys.VideoBlockSize,
            SettingKeys.AntialiasingMode,
            SettingKeys.NextSequentialInteger,
            SettingKeys.StartSequentialIntegerAt,
            SettingKeys.LoopSequentialIntegerAfter,
            SettingKeys.StarApexCount,
            SettingKeys.FontSize,
            SettingKeys.RadiatingLineCount,
            SettingKeys.MaxImageDimension,
            SettingKeys.InstantiationTime,
            SettingKeys.FlowerPetalCount,
            SettingKeys.PolygonSideCount,
    ]
    
    /// Contains a list of all string-type fields.
    public static let StringFields =
        [
            SettingKeys.ShapeType,
            SettingKeys.HeightSource,
            SettingKeys.ImageSizeConstraints,
            SettingKeys.VerticalExaggeration,
            SettingKeys.CurrentCamera,
            SettingKeys.LightColor,
            SettingKeys.LightType,
            SettingKeys.LightIntensity,
            SettingKeys.FieldOfView,
            SettingKeys.InitialView,
            SettingKeys.LetterSmoothness,
            SettingKeys.LetterFont,
            SettingKeys.LetterLocation,
            SettingKeys.RandomCharacterSource,
            SettingKeys.VideoDimensions,
            SettingKeys.SaveOriginalImageAction,
            SettingKeys.UnicodeMetaBlocks,
            SettingKeys.LightingModel,
            SettingKeys.CappedLineBallLocation,
            SettingKeys.MeshLineThickness,
            SettingKeys.MeshDotSize,
            SettingKeys.RadiatingLineThickness,
            SettingKeys.BlockChamferSize,
            SettingKeys.UserCopyright,
            SettingKeys.UserName,
            SettingKeys.ConeTopOptions,
            SettingKeys.ConeBottomOptions,
            SettingKeys.HueShapeList,
            SettingKeys.SaturationShapeList,
            SettingKeys.BrightnessShapeList,
            SettingKeys.DynamicColorAction,
            SettingKeys.DynamicColorType,
            SettingKeys.DynamicColorCondition,
            SettingKeys.SceneBackgroundColor,
            SettingKeys.CroppedImageBorder,
            SettingKeys.CappedLineCapShape,
            SettingKeys.EllipseShape,
            SettingKeys.CharacterUsesRandomFont,
            SettingKeys.CharacterRandomRange,
            SettingKeys.CharacterFontName,
            SettingKeys.CharacterSeries,
            SettingKeys.StackedShapesSet,
            SettingKeys.HistogramOrder,
            SettingKeys.HistogramCreationSpeed,
            SettingKeys.LiveViewGridType,
            SettingKeys.FavoriteShapeList,
            SettingKeys.UIRotationStyle,
            SettingKeys.CappedLineLineColor,
            SettingKeys.SphereBehavior,
            SettingKeys.SphereBehavior,
            SettingKeys.Polygon2DAxis,
            SettingKeys.Rectangle2DAxis,
            SettingKeys.Circle2DAxis,
            SettingKeys.Oval2DAxis,
            SettingKeys.Diamond2DAxis,
            SettingKeys.Star2DAxis,
            SettingKeys.SpherePlusShape,
            SettingKeys.BoxPlusShape,
            SettingKeys.RandomBaseShape,
            SettingKeys.RandomRadius,
            SettingKeys.RandomIntensity,
    ]
    
    /// Contains a list of all double-type fields.
    public static let DoubleFields: [SettingKeys] =
        [
            SettingKeys.BestFitOffset,
    ]
}

/// Keys for user settings.
/// - Note: This enum implements the `Comparable` and `Hashable` protocols to allow for efficient manipulation
///         of lists of setting keys.
enum SettingKeys: String, CaseIterable, Comparable, Hashable
{
    /// For enabling the `Comparable` protocol.
    /// - Parameter lhs: Left hand side.
    /// - Parameter rhs: Right hand side.
    /// - Returns: True if `lhs` is less than `rhs`, false otherwise.
    static func < (lhs: SettingKeys, rhs: SettingKeys) -> Bool
    {
        return lhs.rawValue < rhs.rawValue
    }
    
    //Initialization settings.
    /// String: Holds the initialized string. Used to detect if settings have been initialized.
    case Initialized = "Initialized"
    
    //General UI settings
    /// String: Initial view type.
    case InitialView = "InitialView"
    
    //Block and pixellation settings.
    /// Integer: Holds the size of a pixellated block.
    case BlockSize = "BlockSize"
    /// String: Size of the chamfer radius for block shapes.
    case BlockChamferSize = "BlockChamferSize"
    /// String: The shape each pixel will be rendered as.
    case ShapeType = "ShapeType"
    /// Boolean: Invert height flag.
    case InvertHeight = "InvertHeight"
    /// String: How the height of each extruded pixel is determined.
    case HeightSource = "HeightSource"
    /// String: How much to exaggerate vertical extrusion.
    case VerticalExaggeration = "VerticalExaggeration"
    /// Boolean: Determines if letters are fully extruded.
    case FullyExtrudeLetters = "FullyExtrudeLetters"
    /// String: The font to use when extruding letters.
    case LetterFont = "LetterFont"
    /// Integer: Font size for letters.
    case FontSize = "FontSize"
    /// String: How smoothly to draw each letter.
    case LetterSmoothness = "LetterSmoothness"
    /// String: Unicode block to use to obtain randomly selected letters.
    case RandomCharacterSource = "RandomCharacterSource"
    /// String: Unicode block list as source for random characters.
    case UnicodeMetaBlocks = "UnicodeMetaBlocks"
    /// String: Where to draw the lettter.
    case LetterLocation = "LetterLocation"
    /// Boolean: The number of apexes for stars will increase with the prominence.
    case IncreaseStarApexesWithProminence = "IncreaseStarApexes"
    /// Integer: Number of apexes for stars that don't vary their apex counts.
    case StarApexCount = "StarApexCount"
    /// String: Location of the ball for capped-line shapes.
    case CappedLineBallLocation = "CappedLineBallLocation"
    /// String: Shape of the cap of the capped line.
    case CappedLineCapShape = "CappedLineCapShape"
    /// String/Enum: How to calculate the color of the line for capped-line shapes.
    case CappedLineLineColor = "CappedLineLineColor"
    /// String: Thickness of mesh lines.
    case MeshLineThickness = "MeshLineThickness"
    /// String: Radius of mesh dots.
    case MeshDotSize = "MeshDotSize"
    /// String: Thickness of radiating lines for radiating line shapes.
    case RadiatingLineThickness = "RadiatingLineThickness"
    /// Integer: Number of radiating lines.
    case RadiatingLineCount = "RadiatingLineCount"
    /// String: Determines how the radius of the top of the cone is calculated.
    case ConeTopOptions = "ConeTopOptions"
    /// String: Determines how the radius of the bottom of the cone is calculated.
    case ConeBottomOptions = "ConeBottomOptions"
    /// Boolean: Base and height are inverted with cones.
    case ConeIsInverted = "ConeIsInverted"
    /// String: List of shapes for the composite hue shape.
    case HueShapeList = "HueShapeList"
    /// String: List of shapes for the composite saturation shape.
    case SaturationShapeList = "SaturationShapeList"
    /// String: List of shapes for the composite brightness shape.
    case BrightnessShapeList = "BrightnessShapeList"
    /// String: Background color of the scene.
    case SceneBackgroundColor = "SceneBackgroundColor"
    /// Boolean: Determines if the source image is also the background image.
    case SourceAsBackground = "SourceAsBackground"
    /// String: Determines how to draw an ellipse.
    case EllipseShape = "EllipseShape"
    /// Integer: Number of petals on flower shapes.
    case FlowerPetalCount = "FlowerPetalCount"
    /// Boolean: Petal counts for flower shapes vary with intensity.
    case IncreasePetalCountWithProminence = "IncreasePetalCountWithProminence"
    /// String: Name of the font for the character shape.
    case CharacterFontName = "CharacterFontName"
    /// Boolean: Character shape uses random font.
    case CharacterUsesRandomFont = "CharacterUsesRandomFont"
    /// String: Determines the range of font characters from which to select a random character.
    case CharacterRandomRange = "CharacterRandomRange"
    /// Boolean: Character shape uses random font sizes.
    case CharacterRandomFontSize = "CharacterRandomFontSize"
    /// String: Which character set to use with the character series shape.
    case CharacterSeries = "CharacterSeries"
    /// String: Comma-separated list of shapes for stacked shapes.
    case StackedShapesSet = "StackedShapesSet"
    /// Integer: Number of sides of the current polygon.
    case PolygonSideCount = "PolygonSideCount"
    /// Boolean: The number of sides of a polygon is dependent on the current height value of the pixel.
    case PolygonSideCountVaries = "PolygonSideCountVaries"
    /// String/Enum: How spheres are generated based on color prominence.
    case SphereBehavior = "SphereBehavior"
    /// String/Enum: The prominent axis for 2D polygons.
    case Polygon2DAxis = "Polygon2DAxis"
    /// String/Enum: The prominent axis for 2D rectangles.
    case Rectangle2DAxis = "Rectangle2DAxis"
    /// String/Enum: The prominent axis for 2D circles.
    case Circle2DAxis = "Circle2DAxis"
    /// String/Enum: The prominent axis for 2D ovals.
    case Oval2DAxis = "Oval2DAxis"
    /// String/Enum: The prominent axis for 2D diamonds.
    case Diamond2DAxis = "Diamond2DAxis"
    /// String/Enum: The prominent axis for 2D stars.
    case Star2DAxis = "Star2DAxis"
    /// String/Enum: The shape to use for sphere + shapes.
    case SpherePlusShape = "SpherePlusShape"
    /// String/Enum: The shape to use for box + shapes.
    case BoxPlusShape = "BoxPlusShape"
    /// String/Enum: Base shape for random shapes.
    case RandomBaseShape = "RandomBaseShape"
    /// String/Enum: Intensity of the randomness.
    case RandomIntensity = "RandomIntensity"
    /// String/Enum: Radial distances for the randomness.
    case RandomRadius = "RandomRadius"
    /// Boolean: If true, random shapes show the base shape as well.
    case RandomShapeShowsBase = "RandomShapeShowsBase"
    
    //Dynamic color settings.
    /// String: The type of dynamic color enabled (if any).
    case DynamicColorType = "DynamicColorType"
    /// Boolean: Invert the dynamic color conditional.
    case InvertDynamicColorProcess = "InvertDynamicColorProcess"
    /// String: What to do with dynamic colors.
    case DynamicColorAction = "DynamicColorAction"
    /// String: Determines when to perform dynamic colors.
    case DynamicColorCondition = "DynamicColorCondition"
    
    //Shadows
    /// Boolean: Show or hide shadows.
    case EnableShadows = "EnableShadows"
    
    //Scene settings
    /// Integer: Determines the input quality of the image to process.
    case InputQuality = "InputQuality"
    /// String: Constrains the size of the image to process.
    case ImageSizeConstraints = "ImageSizeConstraints"
    /// String: Color of the scene's light.
    case LightColor = "LightColor"
    /// String: Intensity of the scene's light.
    case LightIntensity = "LightIntensity"
    /// String: Type of the scene's light.
    case LightType = "LightType"
    /// String: Field of view for the scene's camera.
    case FieldOfView = "FieldOfView"
    /// String: Model for lighting.
    case LightingModel = "LightingModel"
    
    //Image processing
    /// Boolean: Holds the fit all nodes to the frustrum flag.
    case InitialBestFit = "InitialBestFit"
    /// Double: Offset to adjust the best fit camera height.
    case BestFitOffset = "BestFitOffset"
    /// Boolean: Determines when and how to save original images.
    case SaveOriginalImageAction = "SaveOriginalImageAction"
    /// String: The camera to use.
    case CurrentCamera = "CurrentCamera"
    /// String: Size of the cropped image border.
    case CroppedImageBorder = "CroppedImageBorder"
    /// Boolean: Determines if a processed image is saved automatically.
    case AutoSaveProcessedImage = "AutoSaveProcessedImage"
    
    //Video processing
    /// Integer: How many frames a second of video to process.
    case VideoFPS = "VideoFramesPerSecond"
    /// String: Final video image size.
    case VideoDimensions = "Smallest"
    /// Integer: Block size for processing videos.
    case VideoBlockSize = "VideoBlockSize"
    
    //Processing
    /// Boolean: Determines if Metal is used for processing.
    case UseMetal = "UseMetal"
    /// String: Antialiasing mode to use.
    case AntialiasingMode = "AntialiasingMode"
    
    //Histogram
    /// Boolean: Holds the show histogram flag.
    case ShowHistogram = "ShowHistogram"
    /// String: Holds the order of channels in histogram displays.
    case HistogramOrder = "HistogramOrder"
    /// Boolean: If true, histograms are displayed (if .ShowHistogram is true) for processed images.
    case ShowProcessedHistogram = "ShowProcessedHistogram"
    /// String: How often to create a histogram.
    case HistogramCreationSpeed = "HistogramCreationSpeed"
    
    //General purpose
    /// Integer: Next available sequential integer.
    case NextSequentialInteger = "NextSequentialInteger"
    /// Integer: Restart sequence of sequential integers.
    case LoopSequentialIntegerAfter = "LoopSequentialIntegerAfter"
    /// Integer: Initial value for sequential integer.
    case StartSequentialIntegerAt = "StartSequentialIntegerAt"
    
    //General purpose UI
    /// Boolean: Determines if the splash screen is shown on start-up.
    case ShowSplashScreen = "ShowSplashScreen"
    
    //Controls what to do in extreme circumstances.
    /// Boolean: Exit the app when the device reports a critical thermal condition.
    case HaltWhenCriticalThermal = "HaltWhenTooHot"
    /// Boolean: Exit the app when a low power condition is reported.
    case HaltOnLowPower = "HaltOnLowPower"
    
    //Logging settings
    /// Boolean: Flag that indicates the user's preference for logging.
    case LoggingEnabled = "LoggingEnabled"
    /// Boolean: Flag that indicates whether to log image-related settings when processing images. Set by the **#DEBUG** compile-
    /// time flag.
    case LogImageSettings = "LogImageSettings"
    
    //Sound settings
    /// Boolean: Flag that enables or disables all UI sounds (except for built-in system sounds).
    case EnableUISounds = "EnableUISounds"
    /// Boolean: Flag that enables the shutter sound.
    case EnableShutterSound = "EnableShutterSound"
    /// Boolean: Flag that enables image processing sounds.
    case EnableImageProcessingSound = "EnableImageProcessingSound"
    /// Boolean: Flag that enables video recording sounds.
    case EnableVideoRecordingSound = "EnableVideoRecordingSound"
    /// Boolean: Flag that enables button press sounds.
    case EnableButtonPressSounds = "EnableButtonPressSounds"
    /// Boolean: Flag that enables option selection sounds.
    case EnableOptionSelectSounds = "EnableOptionSelectSounds"
    /// Boolean: Flag that enables crash sounds.
    case EnableCrashSounds = "EnableCrashSounds"
    
    //Performance settings
    /// Integer: Maximum image dimension to be processed.
    case MaxImageDimension = "MaxImageDimension"
    
    //User copyright information for Exif data
    /// Boolean: Determines if user data is added to processed image Exif data.
    case AddUserDataToExif = "AddUserDataToExif"
    /// String: The user's name for copyright.
    case UserName = "UserName"
    /// String: The user's copyright information.
    case UserCopyright = "UserCopyright"
    
    //Onboarding and UI help
    /// Integer: The last time the program was instantiated.
    case InstantiationTime = "InstantiationTime"
    
    //Permissions
    /// Boolean: All required permissions have been granted.
    case AllPermissionsGranted = "AllPermissionsGranted"
    /// Boolean: Camera access has been granted.
    case CameraAccessGranted = "CameraAccessGranted"
    /// Boolean: Photo roll access has been granted.
    case PhotoRollAccessGranted = "PhotoRollAccessGranted"
    
    //Grid settings
    /// String: Grid type for the live view.
    case LiveViewGridType = "LiveViewGridType"
    /// Boolean: Show the actual orientation of the device.
    case ShowActualOrientation = "ShowActualOrientation"
    /// Boolean: Show feedback when the user taps the live view.
    case ShowTapFeedback = "ShowTapFeedBack"
    
    //UI rotation settings
    /// String: How to rotate the UI when the device is rotated.
    case UIRotationStyle = "UIRotationStyle"
    
    //Favorite settings
    case FavoriteShapeList = "FavoriteShapeList"
}

