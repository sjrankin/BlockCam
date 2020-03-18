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
    
    /// Draw a color histogram. This function assumes all data here are for color histograms.
    /// - Parameter InColors: Set of colors, one color per horizontal unit in the histogram.
    /// - Parameter WithData: The combined color histogram data.
    /// - Parameter Bounds: The bounds of the control where the histogram will be displayed.
    /// - Parameter Frame: The frame of the control where the histogram will be displayed.
    /// - Parameter MaxValue: Maximum value in WithData.
    func DrawChannel(InColors: [UIColor], WithData: [UInt], Bounds: CGRect, Frame: CGRect,
                     MaxValue: UInt) -> CAShapeLayer
    {
        let UnitWidth: CGFloat = Bounds.size.width / 256.0
        let Channel = CAShapeLayer()
        Channel.bounds = Frame
        Channel.frame = Bounds
        Channel.backgroundColor = UIColor.clear.cgColor
        Channel.strokeColor = UIColor.clear.cgColor
        Channel.zPosition = 1000
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
        Channel.path = Path.cgPath
        
        let BarWidth = Bounds.size.width / CGFloat(InColors.count)
        var Bars = [CAShapeLayer]()
        for Index in 0 ..< InColors.count
        {
            let Percent = CGFloat(WithData[Index]) / CGFloat(MaxValue)
            let YValue = Bounds.size.height - (Bounds.size.height - (Percent * Bounds.size.height))
            let BarRect = CGRect(x: CGFloat(Index) * BarWidth,
                                 y: Bounds.size.height - YValue,
                                 width: BarWidth,
                                 height: YValue)
            let BarShape = UIBezierPath(rect: BarRect)
            let Layer = CAShapeLayer()
            Layer.frame = CGRect(x: 0, y: 0, width: Bounds.size.width, height: Bounds.size.height)
            Layer.bounds = CGRect(x: 0, y: 0, width: Bounds.size.width, height: Bounds.size.height)
            Layer.backgroundColor = UIColor.clear.cgColor
            Layer.fillColor = InColors[Index].cgColor
            Layer.strokeColor = UIColor.systemRed.cgColor
            Layer.lineWidth = 0.0
            Layer.path = BarShape.cgPath
            Layer.zPosition = 900
            Bars.append(Layer)
        }
        
        for Layer in Bars
        {
            Channel.addSublayer(Layer)
        }
        return Channel
    }
    
    /// Plot histogram data.
    /// - Note: The histogram data (generated by `vImageHistogramCalculation_ARGB8888`) seems to return a very
    ///         large number in the last bucket (`[255]`). There seems to be no reason for such a large value
    ///         so it is thrown out.
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
                
                //Delete the last item as it is usually absurdly large for no known (eg, documented) reason.
                let FinalRed: [UInt] = RawData.Red.dropLast()
                let FinalGreen: [UInt] = RawData.Green.dropLast()
                let FinalBlue: [UInt] = RawData.Blue.dropLast()
                
                var ChannelOrder = HistogramOrders.RGB
                if let RawOrder = Settings.GetString(ForKey: .HistogramOrder)
                {
                    if let COrder = HistogramOrders(rawValue: RawOrder)
                    {
                        ChannelOrder = COrder
                    }
                }
                var RedChannel = CAShapeLayer()
                var GreenChannel = CAShapeLayer()
                var BlueChannel = CAShapeLayer()
                var GrayChannel = CAShapeLayer()
                var ColorChannel = CAShapeLayer()
                
                if Settings.GetBoolean(ForKey: .CombinedHistogram)
                {
                    var MaxRed: UInt = 0
                    var MaxGreen: UInt = 0
                    var MaxBlue: UInt = 0
                    var CombinedColors = [UIColor]()
                    var FinalData = [UInt]()
                    for Index in 0 ..< FinalRed.count
                    {
                        FinalData.append(FinalRed[Index] + FinalGreen[Index] + FinalBlue[Index])
                        MaxRed = FinalRed[Index] > MaxRed ? FinalRed[Index] : MaxRed
                        MaxGreen = FinalGreen[Index] > MaxGreen ? FinalGreen[Index] : MaxGreen
                        MaxBlue = FinalBlue[Index] > MaxBlue ? FinalBlue[Index] : MaxBlue
                    }
                    for Index in 0 ..< FinalRed.count
                    {
                        let Color = UIColor(red: CGFloat(FinalRed[Index]) / CGFloat(MaxRed),
                                            green: CGFloat(FinalGreen[Index]) / CGFloat(MaxGreen),
                                            blue: CGFloat(FinalBlue[Index]) / CGFloat(MaxBlue),
                                            alpha: 1.0)
                        CombinedColors.append(Color)
                    }
                    let MaxCombined: UInt = MaxRed + MaxGreen + MaxBlue
                    ColorChannel = self.DrawChannel(InColors: CombinedColors, WithData: FinalData, Bounds: self.bounds,
                                                    Frame: self.frame, MaxValue: MaxCombined)
                }
                else
                {
                    if ChannelOrder == .Gray
                    {
                        var Gray = [UInt]()
                        var MaxGray: UInt = 0
                        for Bin in 0 ..< 255
                        {
                            let MeanChannel: UInt = (FinalRed[Bin] + FinalGreen[Bin] + FinalBlue[Bin]) / 3
                            if MeanChannel > MaxGray
                            {
                                MaxGray = MeanChannel
                            }
                            Gray.append(MeanChannel)
                        }
                        GrayChannel = self.DrawChannel(InColor: UIColor.gray, WithData: Gray, Bounds: self.bounds,
                                                       Frame: self.frame, MaxValue: MaxGray)
                    }
                    else
                    {
                        RedChannel = self.DrawChannel(InColor: UIColor.red, WithData: FinalRed, Bounds: self.bounds,
                                                      Frame: self.frame, MaxValue: MaxValue)
                        GreenChannel = self.DrawChannel(InColor: UIColor.green, WithData: FinalGreen, Bounds: self.bounds,
                                                        Frame: self.frame, MaxValue: MaxValue)
                        BlueChannel = self.DrawChannel(InColor: UIColor.blue, WithData: FinalBlue, Bounds: self.bounds,
                                                       Frame: self.frame, MaxValue: MaxValue)
                    }
                    
                    switch ChannelOrder
                    {
                        case .RGB:
                            RedChannel.zPosition = 100
                            GreenChannel.zPosition = 90
                            BlueChannel.zPosition = 80
                        
                        case .RBG:
                            RedChannel.zPosition = 100
                            GreenChannel.zPosition = 80
                            BlueChannel.zPosition = 90
                        
                        case .GRB:
                            RedChannel.zPosition = 90
                            GreenChannel.zPosition = 100
                            BlueChannel.zPosition = 80
                        
                        case .GBR:
                            RedChannel.zPosition = 80
                            GreenChannel.zPosition = 100
                            BlueChannel.zPosition = 90
                        
                        case .BRG:
                            RedChannel.zPosition = 90
                            GreenChannel.zPosition = 80
                            BlueChannel.zPosition = 100
                        
                        case .BGR:
                            RedChannel.zPosition = 80
                            GreenChannel.zPosition = 90
                            BlueChannel.zPosition = 100
                        
                        default:
                            break
                    }
                }
                
                let FinalLayer = CAShapeLayer()
                FinalLayer.zPosition = 100
                FinalLayer.name = "DisplayLayer"
                FinalLayer.bounds = self.bounds
                FinalLayer.frame = self.frame
                if Settings.GetBoolean(ForKey: .CombinedHistogram)
                {
                    FinalLayer.addSublayer(ColorChannel)
                }
                else
                {
                    if ChannelOrder == .Gray
                    {
                        GrayChannel.zPosition = 100
                        FinalLayer.addSublayer(GrayChannel)
                    }
                    else
                    {
                        FinalLayer.addSublayer(RedChannel)
                        FinalLayer.addSublayer(GreenChannel)
                        FinalLayer.addSublayer(BlueChannel)
                    }
                }
                self.layer.addSublayer(FinalLayer)
        }
    }
}
