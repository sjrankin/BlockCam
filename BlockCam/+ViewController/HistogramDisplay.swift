//
//  HistogramDisplay.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Simple UIView to draw histogram data.
class HistogramDisplay: UIView
{
    /// Initializer.
    /// - Parameter frame: Frame of the control.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the control.
    func Initialize()
    {
        self.isUserInteractionEnabled = false
    }
    
    /// Draw a channel in a shape layer.
    /// - Parameter InColor: The color to use to draw the channel.
    /// - Parameter WithData: The channel data to use to draw the curve.
    /// - Parameter Bounds: The bounds of the host control.
    /// - Parameter Frame: The frame of the host control.
    /// - Parameter MaxValue: The maximum value of all channels. Used for vertical scaling.
    /// - Returns: A shape layer with the channel drawn on it.
    func DrawChannel(InColor: UIColor, WithData: [UInt], Bounds: CGRect, Frame: CGRect, MaxValue: UInt) -> CAShapeLayer
    {
        let UnitWidth: CGFloat = Bounds.size.width / 256.0
        let Channel = CAShapeLayer()
        Channel.bounds = Frame
        Channel.frame = Bounds
        Channel.backgroundColor = UIColor.clear.cgColor
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: 0.0, y: Bounds.size.height))
        for Index in 0 ..< 255
        {
            let Percent = CGFloat(WithData[Index]) / CGFloat(MaxValue)
            let YValue = Bounds.size.height - (Percent * Bounds.size.height)
            Path.addLine(to: CGPoint(x: CGFloat(Index) * UnitWidth, y: YValue))
        }
        Path.addLine(to: CGPoint(x: 256.0 * UnitWidth, y: Bounds.size.height))
        Path.close()
        Channel.strokeColor = InColor.cgColor
        let FillColor = InColor.withAlphaComponent(0.5)
        Channel.fillColor = FillColor.cgColor
        Channel.path = Path.cgPath
        return Channel
    }
    
    /// Plot histogram data.
    /// - Parameter RawData: Tuple of Red, Green, and Blue values to plot.
    /// - Parameter MaxValue: The maximum value for all three passed channels. Used for vertical
    ///                       scaling.
    func ShowHistogram(_ RawData: (Red: [UInt], Green: [UInt], Blue: [UInt]), _ MaxValue: UInt)
    {
        OperationQueue.main.addOperation
            {
                self.layer.sublayers?.forEach
                    {
                        if $0.name == "DisplayLayer"
                        {
                            $0.removeFromSuperlayer()
                        }
                }
                let FinalRed: [UInt] = RawData.Red.dropLast()
                let FinalGreen: [UInt] = RawData.Green.dropLast()
                let FinalBlue: [UInt] = RawData.Blue.dropLast()
                let RedChannel = self.DrawChannel(InColor: UIColor.red, WithData: FinalRed, Bounds: self.bounds,
                                                  Frame: self.frame, MaxValue: MaxValue)
                let GreenChannel = self.DrawChannel(InColor: UIColor.green, WithData: FinalGreen, Bounds: self.bounds,
                                                    Frame: self.frame, MaxValue: MaxValue)
                let BlueChannel = self.DrawChannel(InColor: UIColor.blue, WithData: FinalBlue, Bounds: self.bounds,
                                                   Frame: self.frame, MaxValue: MaxValue)
                let FinalLayer = CAShapeLayer()
                FinalLayer.zPosition = 100
                FinalLayer.name = "DisplayLayer"
                FinalLayer.bounds = self.bounds
                FinalLayer.frame = self.frame
                FinalLayer.addSublayer(RedChannel)
                FinalLayer.addSublayer(GreenChannel)
                FinalLayer.addSublayer(BlueChannel)
                self.layer.addSublayer(FinalLayer)
        }
    }
}
