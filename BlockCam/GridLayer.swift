//
//  GridLayer.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Draws a grid to help with alignment. This grid is shown over the live view.
class GridLayer: UIView
{
    /// Initializer.
    /// - Parameter frame: Frame of the base view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    /// Initialization common to all initializers.
    func CommonInitialization()
    {
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.layer.zPosition = 10000
        self.clipsToBounds = true
        GridType = Settings.GetEnum(ForKey: .LiveViewGridType, EnumType: GridTypes.self, Default: GridTypes.None)
        ShowActualOrientation = Settings.GetBoolean(ForKey: .ShowActualOrientation)
    }
    
    /// Show the grid.
    func ShowGrid()
    {
        self.isHidden = false
    }
    
    /// Hide the grid.
    func HideGrid()
    {
        self.isHidden = true
    }
    
    func PolarToCartesian(Radius: CGFloat, Radians: CGFloat) -> CGPoint
    {
        let X = Radius * cos(Radians)
        let Y = Radius * sin(Radians)
        return CGPoint(x: X, y: Y)
    }
    
    /// Set offsets for the preview that doesn't fit fully into the UI element. Sets up a masking layer
    /// to make sure things fit where they should.
    func SetPreviewOffsets(LeftOffset: CGFloat, RightOffset: CGFloat, TopOffset: CGFloat, BottomOffset: CGFloat)
    {
        self.LeftOffset = LeftOffset
        self.RightOffset = RightOffset
        self.TopOffset = TopOffset
        self.BottomOffset = BottomOffset
        let MaskLayer = CALayer()
        MaskLayer.opacity = 1.0
        MaskLayer.backgroundColor = UIColor.white.cgColor
        MaskLayer.bounds = CGRect(x: 0,
                                  y: 0,
                                  width: self.bounds.width - (LeftOffset + RightOffset),
                                  height: self.bounds.height - (TopOffset + BottomOffset))
        MaskLayer.frame = CGRect(x: LeftOffset,
                                 y: TopOffset,
                                 width: self.bounds.width - (LeftOffset + RightOffset),
                                 height: self.bounds.height - (TopOffset + BottomOffset))
        self.layer.mask = MaskLayer
        DrawGrid(_ActualAngle)
    }
    
    var LeftOffset: CGFloat = 0.0
    var RightOffset: CGFloat = 0.0
    var TopOffset: CGFloat = 0.0
    var BottomOffset: CGFloat = 0.0
    
    /// Make an exotic, most definitely non-standard grid..
    /// - Parameter WithActualAngle: The angle of the orientation of the device.
    /// - Parameter AtCardinalAngle: Flag the says the device is at a cardinal angle.
    func MakeExoticGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
    {
        let Shortest = min(self.bounds.size.width, self.bounds.size.height)
        let Smallest = Shortest * 0.1
        let EvenSmaller = Smallest * 0.3
        let Center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let CircleRect = CGRect(origin: CGPoint(x: Center.x - Smallest / 2.0,
                                                y: Center.y - Smallest / 2.0),
                                size: CGSize(width: Smallest,
                                             height: Smallest))
        //Top
        let ShortestThird = Shortest * 0.333
        let CircleR1 = CGRect(origin: CGPoint(x: Center.x - EvenSmaller / 2.0,
                                              y: Center.y - ShortestThird),
                              size: CGSize(width: EvenSmaller, height: EvenSmaller))
        //Left
        let CircleR4 = CGRect(origin: CGPoint(x: Center.x - ShortestThird,
                                              y: Center.y - EvenSmaller / 2.0),
                              size: CGSize(width: EvenSmaller, height: EvenSmaller))
        
        //Bottom
        let CircleR2 = CGRect(origin: CGPoint(x: Center.x - EvenSmaller / 2.0,
                                              y: Center.y + ShortestThird - self.frame.origin.y),
                              size: CGSize(width: EvenSmaller, height: EvenSmaller))
        //Right
        let CircleR3 = CGRect(origin: CGPoint(x: Center.x + ShortestThird - self.frame.origin.y,
                                              y: Center.y - EvenSmaller / 2.0),
                              size: CGSize(width: EvenSmaller, height: EvenSmaller))
        
        let BigCircleRect = CGRect(x: Center.x - Smallest * 3.2, y: Center.y - Smallest * 3.2,
                                   width: Smallest * 6.4, height:  Smallest * 6.4)

        if _ShowIdealOrientation
        {
            IdealLayer = CAShapeLayer()
            IdealLayer?.name = "IdealLayer"
            IdealLayer?.bounds = self.bounds
            IdealLayer?.frame = self.bounds
            IdealLayer?.backgroundColor = UIColor.clear.cgColor
            IdealLayer?.fillColor = UIColor.clear.cgColor
            let Exotic = UIBezierPath(ovalIn: CircleRect)
            let BigCircle = UIBezierPath(ovalIn: BigCircleRect)

            let Circle1 = UIBezierPath(ovalIn: CircleR1)
            let Circle2 = UIBezierPath(ovalIn: CircleR2)
            let Circle3 = UIBezierPath(ovalIn: CircleR3)
            let Circle4 = UIBezierPath(ovalIn: CircleR4)
            
            Exotic.close()
            if AtCardinalAngle
            {
                IdealLayer?.strokeColor = _AlignedColor.cgColor
            }
            else
            {
                IdealLayer?.strokeColor = _IdealLineColor.cgColor
            }
            let Combined = Exotic.cgPath.mutableCopy()
            Combined?.addPath(Circle1.cgPath)
            Combined?.addPath(Circle2.cgPath)
            Combined?.addPath(Circle3.cgPath)
            Combined?.addPath(Circle4.cgPath)
            Combined?.addPath(BigCircle.cgPath)
            IdealLayer?.path = Combined
            IdealLayer?.zPosition = 100
            
            let FinalAngle = 45.0 * CGFloat.pi / 180.0
            IdealLayer?.transform = CATransform3DRotate(IdealLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
            self.layer.addSublayer(IdealLayer!)
        }
        if !AtCardinalAngle
        {
            if _ShowActualOrientation
            {
                ActualLayer = CAShapeLayer()
                ActualLayer?.name = "ActualLayer"
                ActualLayer?.bounds = self.bounds
                ActualLayer?.frame = self.bounds
                ActualLayer?.backgroundColor = UIColor.clear.cgColor
                ActualLayer?.fillColor = UIColor.clear.cgColor
                let Exotic = UIBezierPath(ovalIn: CircleRect)
                Exotic.move(to: Center)
                Exotic.addLine(to: CGPoint(x: Center.x, y: Center.y - Smallest * 3.2))
                Exotic.move(to: Center)
                Exotic.addLine(to: CGPoint(x: Center.x - 150.0, y: Center.y))
                Exotic.move(to: Center)
                Exotic.addLine(to: CGPoint(x: Center.x + 150.0, y: Center.y))
                
                Exotic.move(to: CGPoint(x: Center.x, y: Center.y - Smallest * 3.2))
                Exotic.addLine(to: CGPoint(x: Center.x - 150.0, y: Center.y - Smallest * 3.2))
                Exotic.move(to: CGPoint(x: Center.x, y: Center.y - Smallest * 3.2))
                Exotic.addLine(to: CGPoint(x: Center.x + 150.0, y: Center.y - Smallest * 3.2))
                Exotic.close()
                let BigCircle = UIBezierPath(ovalIn: BigCircleRect)
                let Circle1 = UIBezierPath(ovalIn: CircleR1)
                let Combined = Exotic.cgPath.mutableCopy()
                Combined?.addPath(Circle1.cgPath)
                Combined?.addPath(BigCircle.cgPath)
                ActualLayer?.lineWidth = 1.0
                ActualLayer?.strokeColor = _ActualLineColor.cgColor
                ActualLayer?.path = Combined!
                ActualLayer?.zPosition = 200
                if _ShowActualDegreeValue
                {
                    let DegreeLayer = CATextLayer()
                    let LayerHeight: CGFloat = 16.0
                    let LayerWidth: CGFloat = 40.0
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: LayerWidth, height: LayerHeight)
                    DegreeLayer.frame = CGRect(x: Center.x - LayerWidth / 2.0,
                                               y: Center.y - Smallest * 3.2 - LayerHeight * 2,
                                               width: LayerWidth,
                                               height: LayerHeight)
                    DegreeLayer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
                    DegreeLayer.string = "\(Int(360.0 - WithActualAngle))°"
                    DegreeLayer.foregroundColor = UIColor.black.cgColor
                    DegreeLayer.alignmentMode = .center
                    DegreeLayer.font = UIFont.systemFont(ofSize: 12.0)
                    DegreeLayer.fontSize = 12.0
                    ActualLayer?.addSublayer(DegreeLayer)
                }
                let FinalAngle = WithActualAngle * CGFloat.pi / 180.0
                ActualLayer?.transform = CATransform3DRotate(ActualLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
                self.layer.addSublayer(ActualLayer!)
            }
        }
    }
    
    /// Make a cross-hair like grid.
    /// - Parameter WithActualAngle: The angle of the orientation of the device.
    /// - Parameter AtCardinalAngle: Flag the says the device is at a cardinal angle.
    func MakeCrossHairGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
    {
        var Smallest = min(self.bounds.size.width, self.bounds.size.height)
        Smallest = Smallest * 0.35
        let Center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let CircleRect = CGRect(origin: CGPoint(x: Center.x - Smallest / 2.0,
                                                y: Center.y - Smallest / 2.0),
                                size: CGSize(width: Smallest,
                                             height: Smallest))
        
        if _ShowIdealOrientation
        {
            IdealLayer = CAShapeLayer()
            IdealLayer?.name = "IdealLayer"
            IdealLayer?.bounds = self.bounds
            IdealLayer?.frame = self.bounds
            IdealLayer?.backgroundColor = UIColor.clear.cgColor
            let Circle = UIBezierPath(ovalIn: CircleRect)
            Circle.move(to: Center)
            Circle.addLine(to: CGPoint(x: Center.x, y: Center.y - Smallest / 2.0))
            Circle.move(to: Center)
            Circle.addLine(to: CGPoint(x: Center.x, y: Center.y + Smallest / 2.0))
            Circle.move(to: Center)
            Circle.addLine(to: CGPoint(x: Center.x - Smallest / 2.0, y: Center.y))
            Circle.move(to: Center)
            Circle.addLine(to: CGPoint(x: Center.x + Smallest / 2.0, y: Center.y))
            Circle.close()
            IdealLayer?.fillColor = UIColor.clear.cgColor
            IdealLayer?.lineWidth = 1.0
            if AtCardinalAngle
            {
                IdealLayer?.strokeColor = _AlignedColor.cgColor
            }
            else
            {
                IdealLayer?.strokeColor = _IdealLineColor.cgColor
            }
            IdealLayer?.path = Circle.cgPath
            IdealLayer?.zPosition = 100
            self.layer.addSublayer(IdealLayer!)
        }
        if !AtCardinalAngle
        {
            if _ShowActualOrientation
            {
                ActualLayer = CAShapeLayer()
                ActualLayer?.name = "ActualLayer"
                ActualLayer?.bounds = self.bounds
                ActualLayer?.frame = self.bounds
                ActualLayer?.backgroundColor = UIColor.clear.cgColor
                let Circle = UIBezierPath(ovalIn: CircleRect)
                Circle.move(to: Center)
                Circle.addLine(to: CGPoint(x: Center.x, y: Center.y - Smallest / 2.0))
                Circle.move(to: Center)
                Circle.addLine(to: CGPoint(x: Center.x, y: Center.y + Smallest / 2.0))
                Circle.move(to: Center)
                Circle.addLine(to: CGPoint(x: Center.x - Smallest / 2.0, y: Center.y))
                Circle.move(to: Center)
                Circle.addLine(to: CGPoint(x: Center.x + Smallest / 2.0, y: Center.y))
                Circle.close()
                ActualLayer?.fillColor = UIColor.clear.cgColor
                ActualLayer?.lineWidth = 1.0
                ActualLayer?.strokeColor = _ActualLineColor.cgColor
                ActualLayer?.path = Circle.cgPath
                ActualLayer?.zPosition = 200
                if _ShowActualDegreeValue
                {
                    let DegreeLayer = CATextLayer()
                    let LayerHeight: CGFloat = 16.0
                    let LayerWidth: CGFloat = 40.0
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: LayerWidth, height: LayerHeight)
                    DegreeLayer.frame = CGRect(x: Center.x,
                                               y: Center.y - Smallest / 2.0 - LayerHeight - 3.0,
                                               width: LayerWidth,
                                               height: LayerHeight)
                    DegreeLayer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = UIColor.black.cgColor
                    DegreeLayer.font = UIFont.systemFont(ofSize: 12.0)
                    DegreeLayer.fontSize = 12.0
                    ActualLayer?.addSublayer(DegreeLayer)
                }
                let FinalAngle = WithActualAngle * CGFloat.pi / 180.0
                ActualLayer?.transform = CATransform3DRotate(ActualLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
                self.layer.addSublayer(ActualLayer!)
                self.layer.addSublayer(ActualLayer!)
            }
        }
    }
    
    /// Draw a cross-hair grid.
    /// - Parameter WithActualAngle: The angle of the orientation of the device.
    /// - Parameter AtCardinalAngle: Flag the says the device is at a cardinal angle.
    func MakeSimpleGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
    {
        if _ShowIdealOrientation
        {
            IdealLayer = CAShapeLayer()
            IdealLayer?.name = "IdealLayer"
            IdealLayer?.bounds = self.bounds
            IdealLayer?.frame = self.bounds
            IdealLayer?.backgroundColor = UIColor.clear.cgColor
            let LinePath = UIBezierPath()
            LinePath.move(to: CGPoint(x: self.bounds.width / 2.0, y: 0.0))
            LinePath.addLine(to: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height))
            LinePath.move(to: CGPoint(x: 0, y: self.bounds.height / 2.0))
            LinePath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height / 2.0))
            LinePath.close()
            IdealLayer?.lineWidth = 1.0
            if AtCardinalAngle
            {
                IdealLayer?.strokeColor = _AlignedColor.cgColor
            }
            else
            {
                IdealLayer?.strokeColor = _IdealLineColor.cgColor
            }
            IdealLayer?.path = LinePath.cgPath
            IdealLayer?.zPosition = 100
            self.layer.addSublayer(IdealLayer!)
        }
        
        if !AtCardinalAngle
        {
            if _ShowActualOrientation
            {
                var LineLength = (self.bounds.width * self.bounds.width) + (self.bounds.height * self.bounds.height)
                LineLength = sqrt(LineLength) * 1.2
                ActualLayer = CAShapeLayer()
                ActualLayer?.name = "ActualLayer"
                ActualLayer?.bounds = self.bounds
                ActualLayer?.frame = self.bounds
                ActualLayer?.backgroundColor = UIColor.clear.cgColor
                let Anchor = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
                let LinePath = UIBezierPath()
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x, y: Anchor.y + LineLength))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x, y: Anchor.y - LineLength))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x + LineLength, y: Anchor.y))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x - LineLength, y: Anchor.y))
                LinePath.close()
                ActualLayer?.lineWidth = 1.0
                ActualLayer?.strokeColor = _ActualLineColor.cgColor
                ActualLayer?.path = LinePath.cgPath
                ActualLayer?.zPosition = 200
                if _ShowActualDegreeValue
                {
                    let DegreeLayer = CATextLayer()
                    let LayerHeight: CGFloat = 16.0
                    let LayerWidth: CGFloat = 40.0
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: LayerWidth, height: LayerHeight)
                    DegreeLayer.frame = CGRect(x: self.bounds.width - (40 + RightOffset),
                                               y: self.bounds.height / 2.0 - LayerHeight,
                                               width: LayerWidth,
                                               height: LayerHeight)
                    DegreeLayer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = UIColor.black.cgColor
                    DegreeLayer.font = UIFont.systemFont(ofSize: 12.0)
                    DegreeLayer.fontSize = 12.0
                    ActualLayer?.addSublayer(DegreeLayer)
                }
                let FinalAngle = WithActualAngle * CGFloat.pi / 180.0
                ActualLayer?.transform = CATransform3DRotate(ActualLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
                self.layer.addSublayer(ActualLayer!)
            }
        }
    }
    
    /// Draw a rule of three grid. The actual angle grid is a cross-hair because the proportions
    /// of the rule of three do not rotate well...
    /// - Parameter WithActualAngle: The angle of the orientation of the device.
    /// - Parameter AtCardinalAngle: Flag the says the device is at a cardinal angle.
    func MakeRuleOfThreeGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
    {
        if _ShowIdealOrientation
        {
            IdealLayer = CAShapeLayer()
            IdealLayer?.name = "IdealLayer"
            IdealLayer?.bounds = self.bounds
            IdealLayer?.frame = self.bounds
            IdealLayer?.backgroundColor = UIColor.clear.cgColor
            let LinePath = UIBezierPath()
            LinePath.move(to: CGPoint(x: self.bounds.width * 0.333, y: 0.0))
            LinePath.addLine(to: CGPoint(x: self.bounds.width * 0.333, y: self.bounds.height))
            LinePath.move(to: CGPoint(x: self.bounds.width * 0.667, y: 0.0))
            LinePath.addLine(to: CGPoint(x: self.bounds.width * 0.667, y: self.bounds.height))
            LinePath.move(to: CGPoint(x: 0, y: self.bounds.height * 0.333))
            LinePath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height * 0.333))
            LinePath.move(to: CGPoint(x: 0, y: self.bounds.height * 0.667))
            LinePath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height * 0.667))
            LinePath.close()
            IdealLayer?.lineWidth = 1.0
            if AtCardinalAngle
            {
                IdealLayer?.strokeColor = _AlignedColor.cgColor
            }
            else
            {
                IdealLayer?.strokeColor = _IdealLineColor.cgColor
            }
            IdealLayer?.path = LinePath.cgPath
            IdealLayer?.zPosition = 100
            self.layer.addSublayer(IdealLayer!)
        }
        
        if !AtCardinalAngle
        {
            if _ShowActualOrientation
            {
                var LineLength = (self.bounds.width * self.bounds.width) + (self.bounds.height * self.bounds.height)
                LineLength = sqrt(LineLength) * 1.2
                ActualLayer = CAShapeLayer()
                ActualLayer?.name = "ActualLayer"
                ActualLayer?.bounds = self.bounds
                ActualLayer?.frame = self.bounds
                ActualLayer?.backgroundColor = UIColor.clear.cgColor
                let Anchor = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
                let LinePath = UIBezierPath()
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x, y: Anchor.y + LineLength))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x, y: Anchor.y - LineLength))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x + LineLength, y: Anchor.y))
                LinePath.move(to: Anchor)
                LinePath.addLine(to: CGPoint(x: Anchor.x - LineLength, y: Anchor.y))
                LinePath.close()
                ActualLayer?.lineWidth = 1.0
                ActualLayer?.strokeColor = _ActualLineColor.cgColor
                ActualLayer?.path = LinePath.cgPath
                ActualLayer?.zPosition = 200
                if _ShowActualDegreeValue
                {
                    let DegreeLayer = CATextLayer()
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: 30, height: 20)
                    DegreeLayer.frame = CGRect(x: self.bounds.width - (35 + RightOffset),
                                               y: self.bounds.height / 2.0 - 20,
                                               width: 30,
                                               height: 20)
                    DegreeLayer.backgroundColor = UIColor.clear.cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = UIColor.black.cgColor
                    DegreeLayer.font = UIFont.systemFont(ofSize: 10.0)
                    DegreeLayer.fontSize = 10.0
                    ActualLayer?.addSublayer(DegreeLayer)
                }
                let FinalAngle = WithActualAngle * CGFloat.pi / 180.0
                ActualLayer?.transform = CATransform3DRotate(ActualLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
                self.layer.addSublayer(ActualLayer!)
            }
        }
    }
    
    func MakeTightGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
    {
        if _ShowIdealOrientation
        {
            IdealLayer = CAShapeLayer()
            IdealLayer?.name = "IdealLayer"
            IdealLayer?.bounds = self.bounds
            IdealLayer?.frame = self.bounds
            IdealLayer?.backgroundColor = UIColor.clear.cgColor
            IdealLayer?.fillColor = UIColor.clear.cgColor
            let LinePath = UIBezierPath()
            
            for X in stride(from: 0.0, to: self.bounds.size.width, by: 32.0)
            {
                let From = CGPoint(x: X, y: 0.0)
                let To = CGPoint(x: X, y: self.bounds.size.height)
                LinePath.move(to: From)
                LinePath.addLine(to: To)
            }
            for Y in stride(from: 0.0, to: self.bounds.size.height, by: 32.0)
            {
                LinePath.move(to: CGPoint(x: 0.0, y: Y))
                LinePath.addLine(to: CGPoint(x: self.bounds.size.width, y: Y))
            }
            
            LinePath.close()
            IdealLayer?.lineWidth = 1.0
            if AtCardinalAngle
            {
                IdealLayer?.strokeColor = _AlignedColor.withAlphaComponent(0.5).cgColor
            }
            else
            {
                IdealLayer?.strokeColor = _IdealLineColor.withAlphaComponent(0.5).cgColor
            }
            IdealLayer?.path = LinePath.cgPath
            IdealLayer?.zPosition = 100
            self.layer.addSublayer(IdealLayer!)
        }
        if !AtCardinalAngle
        {
            if _ShowActualOrientation
            {
                var LineLength = (self.bounds.width * self.bounds.width) + (self.bounds.height * self.bounds.height)
                LineLength = sqrt(LineLength) * 1.2
                ActualLayer = CAShapeLayer()
                ActualLayer?.name = "ActualLayer"
                ActualLayer?.bounds = self.bounds
                ActualLayer?.frame = self.bounds
                ActualLayer?.backgroundColor = UIColor.clear.cgColor
                ActualLayer?.fillColor = UIColor.clear.cgColor
                let LinePath = UIBezierPath()
                
                for X in stride(from: -self.bounds.size.width, to: self.bounds.size.width * 2.0, by: 32.0)
                {
                    LinePath.move(to: CGPoint(x: X, y: -self.bounds.size.height))
                    LinePath.addLine(to: CGPoint(x: X, y: self.bounds.size.height * 2.0))
                }
                for Y in stride(from: -self.bounds.size.height, to: self.bounds.size.height * 2.0, by: 32.0)
                {
                    LinePath.move(to: CGPoint(x: -self.bounds.size.width, y: Y))
                    LinePath.addLine(to: CGPoint(x: self.bounds.size.width * 2.0, y: Y))
                }
                
                ActualLayer?.lineWidth = 1.0
                ActualLayer?.strokeColor = _ActualLineColor.withAlphaComponent(0.5).cgColor
                ActualLayer?.path = LinePath.cgPath
                ActualLayer?.zPosition = 200
                if _ShowActualDegreeValue
                {
                    let DegreeLayer = CATextLayer()
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: 30, height: 20)
                    DegreeLayer.frame = CGRect(x: self.bounds.width - (35 + RightOffset),
                                               y: self.bounds.height / 2.0 - 20,
                                               width: 30,
                                               height: 20)
                    DegreeLayer.backgroundColor = UIColor.clear.cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = UIColor.black.cgColor
                    DegreeLayer.font = UIFont.systemFont(ofSize: 10.0)
                    DegreeLayer.fontSize = 10.0
                    ActualLayer?.addSublayer(DegreeLayer)
                }
                let FinalAngle = WithActualAngle * CGFloat.pi / 180.0
                ActualLayer?.transform = CATransform3DRotate(ActualLayer!.transform, FinalAngle, 0.0, 0.0, 1.0)
                self.layer.addSublayer(ActualLayer!)
            }
        }
    }
    
    /// Draws the grid.
    /// - Parameter WithActualAngle: The angle to use to draw the actual orientation grid.
    public func DrawGrid(_ WithActualAngle: CGFloat = 0.0)
    {
        _ActualAngle = WithActualAngle
        if self.layer.sublayers != nil
        {
            self.layer.sublayers!.forEach
                {
                    if $0.name == "ActualLayer" || $0.name == "IdealLayer"
                    {
                        $0.removeFromSuperlayer()
                    }
            }
        }
        ActualLayer = nil
        IdealLayer = nil
        if _GridType == .None
        {
            return
        }
        
        var AtCardinalAngle = false
        if [0.0, 90.0, 180.0, 270.0, 360.0].contains(WithActualAngle)
        {
            AtCardinalAngle = true
        }
        if !_HighlightAtCardinalDirections
        {
            AtCardinalAngle = false
        }
        
        switch _GridType
        {
            case .CrossHairs:
                MakeCrossHairGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
            case .Simple:
                MakeSimpleGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
            case .RuleOfThree:
                MakeRuleOfThreeGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
            case .Exotic:
                MakeExoticGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
            case .Tight:
                MakeTightGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
            default:
                break
        }
    }
    
    /// Holds the actual orientation layer.
    private var ActualLayer: CAShapeLayer? = nil
    /// Holds the ideal (eg, never changing) orientation layer.
    private var IdealLayer: CAShapeLayer? = nil
    
    /// Holds the show actual orientation flag.
    private var _ShowActualOrientation: Bool = true
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the flag that determines the actual orientation is shown.
    public var ShowActualOrientation: Bool
    {
        get
        {
            return _ShowActualOrientation
        }
        set
        {
            _ShowActualOrientation = newValue
        }
    }
    
    /// Holds the show ideal orientation flag.
    private var _ShowIdealOrientation: Bool = true
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the flag that determines the ideal orientation is shown.
    public var ShowIdealOrientation: Bool
    {
        get
        {
            return _ShowIdealOrientation
        }
        set
        {
            _ShowIdealOrientation = newValue
        }
    }
    
    /// Holds the current angle.
    private var _ActualAngle: CGFloat = 0.0
    /// Get or set the current angle.
    public var ActualAngle: CGFloat
    {
        get
        {
            return _ActualAngle
        }
        set
        {
            _ActualAngle = newValue
            DrawGrid(_ActualAngle)
        }
    }
    
    /// Holds the line color for the ideal grid.
    private var _IdealLineColor: UIColor = UIColor.green
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the line color for the ideal grid.
    public var IdealLineColor: UIColor
    {
        get
        {
            return _IdealLineColor
        }
        set
        {
            _IdealLineColor = newValue
        }
    }
    
    /// Holds the line color for the actual orientation grid.
    private var _ActualLineColor: UIColor = UIColor.systemYellow
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the line color for the actual orientation grid.
    public var ActualLineColor: UIColor
    {
        get
        {
            return _ActualLineColor
        }
        set
        {
            _ActualLineColor = newValue
        }
    }
    
    /// Holds the aligned grid color.
    private var _AlignedColor: UIColor = UIColor.green
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Holds the color to draw the aligned grid.
    public var AlignedColor: UIColor
    {
        get
        {
            return _AlignedColor
        }
        set
        {
            _AlignedColor = newValue
        }
    }
    
    /// Holds the show the degree value flag.
    private var _ShowActualDegreeValue = true
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the show degree value flag.
    public var ShowActualDegreeValue: Bool
    {
        get
        {
            return _ShowActualDegreeValue
        }
        set
        {
            _ShowActualDegreeValue = newValue
        }
    }
    
    /// Holds the highlight grid flag.
    private var _HighlightAtCardinalDirections: Bool = true
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the flag that highlights the grid when the device is at a cardinal orientation.
    public var HighlightAtCardinalDirections: Bool
    {
        get
        {
            return _HighlightAtCardinalDirections
        }
        set
        {
            _HighlightAtCardinalDirections = newValue
        }
    }
    
    /// Holds the grid type.
    private var _GridType: GridTypes = .None
    {
        didSet
        {
            DrawGrid(_ActualAngle)
        }
    }
    /// Get or set the grid type.
    public var GridType: GridTypes
    {
        get
        {
            return _GridType
        }
        set
        {
            _GridType = newValue
        }
    }
}

/// Types of grids that can be shown.
enum GridTypes: String, CaseIterable
{
    /// Do not show a grid.
    case None = "None"
    /// Simple grid of a vertical and horizontal line centered in the view.
    case Simple = "Simple"
    /// Lines marking the center of the view.
    case CrossHairs = "Crosshairs"
    /// Rule of three grid.
    case RuleOfThree = "Rule of 3"
    /// Exotic grid.
    case Exotic = "Exotic"
    /// Tight grid.
    case Tight = "Tight Grid"
}
