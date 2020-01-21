//
//  Colors.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Colors
{
    /// Return a gradient to use for the main bottom toolbar.
    /// - Parameter ProgramView: The mode the view is in. Determines the gradient to return.
    /// - Parameter Container: The bounds value for the bottom toolbar.
    /// - Returns: `CAGradientLayer` that can be used as a background for the main bottom toolbar.
    public static func GetGradientFor(_ ProgramView: ProgramModes, Container Frame: CGRect) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.name = "GradientBackground"
        Layer.zPosition = -1000
        Layer.frame = Frame
        switch ProgramView
        {
            case .LiveView:
                Layer.colors = [UIColor.yellow.cgColor, UIColor.systemYellow.cgColor, UIColor.yellow.cgColor]
                Layer.locations = [NSNumber(value: -0.2), NSNumber(value: 0.2), NSNumber(value: 0.8)]
            
            case .MakeVideo:
                Layer.colors = [UIColor.systemGreen.cgColor, UIColor.green.cgColor, UIColor.systemGreen.cgColor]
                Layer.locations = [NSNumber(value: -0.1), NSNumber(value: 0.2), NSNumber(value: 0.8)]
            
            case .PhotoLibrary:
                Layer.colors = [UIColor.orange.cgColor, UIColor.systemOrange.cgColor, UIColor.orange.cgColor]
                Layer.locations = [NSNumber(value: -0.1), NSNumber(value: 0.2), NSNumber(value: 0.8)]
            
            case .ProcessedView:
                return Layer
        }
        return Layer
    }
    
    /// Return a gradient to use with the image processing bottom toolbar.
    /// - Parameter Container: The bounds value for the bottom toolbar.
    /// - Returns: `CAGradientLayer` to be used by the image processing bottom toolbar.
    public static func GetProcessingGradient(Container Frame: CGRect) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.name = "GradientBackground"
        Layer.zPosition = -1000
        Layer.frame = Frame
        Layer.colors = [UIColor.systemIndigo.cgColor, UIColor.black.cgColor]
        return Layer
    }
    
    /// Return a gradient to use with the SmallStatusDisplay background.
    /// - Parameter Container: The bounds value for the small status display.
    /// - Returns: `CAGradientLayer` to be used by the small status display.
    public static func GetCompositeStatusGradient(Container Frame: CGRect) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.name = "GradientBackground"
        Layer.zPosition = -1000
        Layer.frame = Frame
        let DarkIndigo = UIColor(red: 70.0 / 255.0, green: 65.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
        Layer.colors = [UIColor.black.cgColor, DarkIndigo.cgColor]
        Layer.locations = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
        return Layer
    }
    
    /// Return a gradient to use with the scene recording bar background.
    /// - Parameter Container: The bounds value for the scene recorder.
    /// - Returns: `CAGradientLayer` to be used by the scene recorder.
    public static func GetSceneRecordGradient(Container Frame: CGRect) -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.name = "GradientBackground"
        Layer.zPosition = -1000
        Layer.frame = Frame
        let Green1 = UIColor(red: 24.0 / 255.0, green: 220.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
        let Green2 = UIColor(red: 52.0 / 255.0, green: 199.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
        Layer.colors = [Green1.cgColor, Green2.cgColor]
        Layer.locations = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
        return Layer
    }
}
