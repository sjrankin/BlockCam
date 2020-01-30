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
@IBDesignable class GridLayer: UIView
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
    
    /// Draw a cross-hair grid.
    /// - Parameter WithActualAngle: The angle of the orientation of the device.
    /// - Parameter AtCardinalAngle: Flag the says the device is at a cardinal angle.
    func MakeCrossHairGrid(_ WithActualAngle: CGFloat = 0.0, AtCardinalAngle: Bool)
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
                    DegreeLayer.bounds = CGRect(x: 0, y: 0, width: 30, height: 20)
                    DegreeLayer.frame = CGRect(x: self.bounds.width - 30, y: self.bounds.height / 2.0 - 20,
                                               width: 30, height: 20)
                    DegreeLayer.backgroundColor = UIColor.clear.cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = _ActualLineColor.cgColor
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
                    DegreeLayer.frame = CGRect(x: self.bounds.width - 30, y: self.bounds.height / 2.0 - 20,
                                               width: 30, height: 20)
                    DegreeLayer.backgroundColor = UIColor.clear.cgColor
                    DegreeLayer.string = "\(360.0 - WithActualAngle)°"
                    DegreeLayer.foregroundColor = _ActualLineColor.cgColor
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
            
            case .RuleOfThree:
                MakeRuleOfThreeGrid(WithActualAngle, AtCardinalAngle: AtCardinalAngle)
            
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
/// - Note: The values of each enum case must be in lower case.
enum GridTypes: String, CaseIterable
{
    /// Do not show a grid.
    case None = "none"
    /// Lines marking the center of the view.
    case CrossHairs = "crosshairs"
    /// Rule of three grid.
    case RuleOfThree = "ruleofthree"
}
