//
//  ColorIndicator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorIndicator: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        CommonInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    private func CommonInitialization()
    {
        backgroundColor = UIColor.darkGray
        clipsToBounds = true
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 3.0
    }
    
    public func Draw(_ Color: UIColor)
    {
        let Width = self.frame.size.width
        let Height = self.frame.size.height
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Color.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let SatPercent = Width * Saturation
        let BriPercent = Height * Brightness
        let VOffset = Height - (BriPercent)
        
        let ColorBox = UIBezierPath(rect: CGRect(x: 0, y: VOffset, width: SatPercent, height: BriPercent))
        let Layer = CAShapeLayer()
        Layer.frame = self.frame
        Layer.fillColor = Color.cgColor
        Layer.path = ColorBox.cgPath
        
        self.layer.addSublayer(Layer)
    }
}
