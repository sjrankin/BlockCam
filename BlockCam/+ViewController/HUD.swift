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
        HUDHSBIndicator1.TextLocation = .Right
        HUDHSBIndicator2.TextLocation = .Right
        HUDHSBIndicator3.TextLocation = .Right
        HUDVersionLabel.text = Versioning.ApplicationName + " " +
            Versioning.VerySimpleVersionString() + " " +
        "Build \(Versioning.Build)"
        HUDVersionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        HUDAltitudeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        HUDCompassLabel.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        let HUDWidth = HUDView.frame.size.width
        //HistogramWidthConstraint.isActive = false
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let NewRect = CGRect(x: 0,
                                 y: 0,
                                 width: HUDWidth / 2.0,
                                 height: HistogramView.frame.size.height)
            HistogramView.frame = NewRect
            HistogramView.bounds = NewRect
            //print("NewRect=\(NewRect), HistogramView.frame=\(HistogramView.frame)")
        }
        else
        {
            HistogramView.frame = CGRect(x: 0, y: 0, width: HUDWidth, height: HistogramView.frame.size.height)
            HistogramView.bounds = CGRect(x: 0, y: 0, width: HUDWidth, height: HistogramView.frame.size.height)
        }
        HistogramView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        HistogramView.layer.borderWidth = 1.0
        HistogramView.layer.cornerRadius = 5.0
        HistogramView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        HistogramView.isUserInteractionEnabled = false
        HistogramView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        HistogramView.clipsToBounds = true
    }
    
    /// Updates all views in terms of displaying them or hiding them. Individual settings in various
    /// views are *not* updated here.
    func UpdateHUDViews()
    {
        let HideAll = !Settings.GetBoolean(ForKey: .EnableHUD)
        if HideAll
        {
            HUDView.isHidden = true
            return
        }
        else
        {
            HUDView.isHidden = false
        }
        
        HUDHSBIndicator1.isHidden = !Settings.GetBoolean(ForKey: .ShowHue)
        HUDHSBIndicator2.isHidden = !Settings.GetBoolean(ForKey: .ShowSaturation)
        HUDHSBIndicator3.isHidden = !Settings.GetBoolean(ForKey: .ShowLightMeter)
        HUDVersionLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowVersionOnHUD)
        MeanColorIndicator.isHidden = !Settings.GetBoolean(ForKey: .ShowMeanColor)
        HUDCompassLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowCompass)
        HUDAltitudeLabel.isHidden = !Settings.GetBoolean(ForKey: .ShowAltitude)
        HistogramView.isHidden = !Settings.GetBoolean(ForKey: .ShowHUDHistogram)
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
                if let FinalValue = Value as? CGFloat
                {
                    HUDHSBIndicator1.Percent = Double(FinalValue)
            }
            
            case .Saturation:
                if let FinalValue = Value as? CGFloat
                {
                    HUDHSBIndicator2.Percent = Double(FinalValue)
            }
            
            case .Brightness:
                if let FinalValue = Value as? CGFloat
                {
                    HUDHSBIndicator3.Percent = Double(FinalValue)
            }
            
            case .MeanColor:
                if let FinalValue = Value as? UIColor
                {
                    MeanColorIndicator.Color = FinalValue
            }
            
            case .Version:
                if let FinalValue = Value as? String
                {
                    HUDVersionLabel.text = FinalValue
            }
            
            case .Compass:
                if let FinalValue = Value as? String
                {
                    HUDCompassLabel.text = FinalValue
            }
            
            case .Altitude:
                if let FinalValue = Value as? String
                {
                    HUDAltitudeLabel.text = FinalValue
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
