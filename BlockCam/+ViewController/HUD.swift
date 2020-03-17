//
//  HUD.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    func InitializeHUD()
    {
        HUDView.backgroundColor = UIColor.clear
        CreateHUDMap()
    }
    
    func CreateHUDMap()
    {
        HUDViewMap = [HUDViews: UIView]()
        var BoxFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 20))
        for ViewType in HUDViews.allCases
        {
            switch ViewType
            {
                case .Histogram:
                    HUDViewMap[ViewType] = HistogramDisplay()
                
                case .Brightness:
                    HUDViewMap[ViewType] = BoxIndicator(frame: BoxFrame, Text: "Brightness", Location: .Right)
                
                case .Hue:
                    HUDViewMap[ViewType] = BoxIndicator(frame: BoxFrame, Text: "Hue", Location: .Right)
                
                case .Saturation:
                    HUDViewMap[ViewType] = BoxIndicator(frame: BoxFrame, Text: "Saturation", Location: .Right)
                
                case .MeanColor:
                    HUDViewMap[ViewType] = SimpleColorIndicator(frame: BoxFrame, Text: "Mean", Location: .Left)
                
                case .Version:
                    HUDVersionLabel.text = Versioning.ApplicationName + " " +
                        Versioning.VerySimpleVersionString() + " " +
                    "Build \(Versioning.Build)"
                
                case .Altitude:
                    HUDAltitudeLabel.text = "8m"
                
                case .Compass:
                    HUDCompassLabel.text = "180°"
            }
            //HUDViewMap[ViewType]!.isHidden = true
            //HUDView.addSubview(HUDViewMap[ViewType]!)
        }
    }
    
    /// Updates all views in terms of displaying them or hiding them. Individual settings in various
    /// views are *not* updated here.
    func UpdateHUDViews()
    {
        let HideAll = !Settings.GetBoolean(ForKey: .EnableHUD)
        if HideAll
        {
            for (_, View) in HUDViewMap
            {
                View.isHidden = true
            }
            return
        }
        
        HUDVersionLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowVersionOnHUD)
        let LightMeter = HUDViewMap[.Brightness] as! BoxIndicator
        LightMeter.isHidden = !Settings.GetBoolean(ForKey: .ShowLightMeter)
        let HueView = HUDViewMap[.Hue] as! BoxIndicator
        HueView.isHidden = !Settings.GetBoolean(ForKey: .ShowHue)
        let SatView = HUDViewMap[.Saturation] as! BoxIndicator
        SatView.isHidden = !Settings.GetBoolean(ForKey: .ShowSaturation)
        let MeanView = HUDViewMap[.MeanColor] as! SimpleColorIndicator
        MeanView.isHidden = !Settings.GetBoolean(ForKey: .ShowMeanColor)
        HUDCompassLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowCompass)
        HUDAltitudeLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowAltitude)
        let HistView = HUDViewMap[.Histogram]!
        HistView.isHidden = !Settings.GetBoolean(ForKey: .ShowHUDHistogram)
    }
    
    /// Update a HUD view with the supplied data.
    /// - Warning: Fatal errors are generated if incorrect type data is sent.
    /// - Note: If the appropriate setting is false, no HUD views will be visible and calls to this
    ///         function will be immediately returned.
    /// - Parameter View: Indicates which view to update.
    /// - Parameter With: The data to use to update the display. Sending incorrect types will
    ///                   result in fatalErrors.
    func UpdateHUDView(_ View: HUDViews, With Value: Any?)
    {
        if !Settings.GetBoolean(ForKey: .EnableHUD)
        {
            return
        }
        switch View
        {
            case .Hue:
                if let V = HUDViewMap[View] as? BoxIndicator
                {
                    if let FinalValue = Value as? CGFloat
                    {
                        V.Percent = Double(FinalValue)
                    }
            }
            
            case .Saturation:
                if let V = HUDViewMap[View] as? BoxIndicator
                {
                    if let FinalValue = Value as? CGFloat
                    {
                        V.Percent = Double(FinalValue)
                    }
            }
            
            case .Brightness:
                if let V = HUDViewMap[View] as? BoxIndicator
                {
                    if let FinalValue = Value as? CGFloat
                    {
                        V.Percent = Double(FinalValue)
                    }
            }
            
            case .MeanColor:
                if let V = HUDViewMap[View] as? SimpleColorIndicator
                {
                    if let FinalValue = Value as? UIColor
                    {
                        V.Color = FinalValue
                    }
            }
            
            case .Version:
                if let V = HUDViewMap[View] as? UILabel
                {
                    if let FinalValue = Value as? String
                    {
                        V.text = FinalValue
                    }
            }
            
            case .Compass:
                if let V = HUDViewMap[View] as? UILabel
                {
                    if let FinalValue = Value as? String
                    {
                        V.text = FinalValue
                    }
            }
            
            case .Altitude:
                if let V = HUDViewMap[View] as? UILabel
                {
                    if let FinalValue = Value as? String
                    {
                        V.text = FinalValue
                    }
            }
            
            case .Histogram:
                break
        }
    }
}

/// Logical views in the HUD.
enum HUDViews: String, CaseIterable
{
    /// Histogram view.
    case Histogram = "Histogram"
    /// Brightness/light meter view.
    case Brightness = "Brightness"
    /// Mean hue view.
    case Hue = "Hue"
    /// Mean saturation view.
    case Saturation = "Saturation"
    /// Mean color view.
    case MeanColor = "MeanColor"
    /// Version data view.
    case Version = "Version"
    /// Current altitude view.
    case Altitude = "Altitude"
    /// Current compass view.
    case Compass = "Compass"
}
