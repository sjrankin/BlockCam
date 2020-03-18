//
//  BoxIndicator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/*@IBDesignable*/ class BoxIndicator: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    init(frame: CGRect, Text: String, Location: TextLocations = .Left)
    {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
        self.Text = Text
        self.TextLocation = Location
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = UIColor.clear
        self.Text = "Label"
        self.TextLocation = .Left
    }
    
    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        _BoxSize = CGSize(width: 50, height: 20)
        _Text = "Label"
        _Percent = 0.5
        DrawBox()
    }
    
    public func DrawBox()
    {
        self.backgroundColor = Background
        
        TextLabel.removeFromSuperview()
        TextLabel = UILabel()
        TextLabel.text = _Text
        TextLabel.font = _TextFont
        TextLabel.textColor = _TextColor
        TextLabel.sizeToFit()
        
        BoxView.removeFromSuperview()
        BoxView.isOpaque = false
        BoxView.backgroundColor = UIColor.clear
        let FinalBoxSize = CGSize(width: _BoxSize.width, height: self.frame.size.height)
        BoxView = UIView(frame: CGRect(origin: CGPoint.zero, size: FinalBoxSize))
        DrawBoxWithPercent(InView: BoxView)
        
        var SelfFrame = CGRect()
        let InteriorMargin: CGFloat = 4.0
        switch _TextLocation
        {
            case .Left, .Right:
                SelfFrame = CGRect(origin: CGPoint.zero,
                                   size: CGSize(width: TextLabel.frame.size.width + BoxView.frame.size.width + InteriorMargin,
                                                height: max(TextLabel.frame.size.height, BoxView.frame.size.height)))
            
            case .Top, .Bottom:
                SelfFrame = CGRect(origin: CGPoint.zero,
                                   size: CGSize(width: max(TextLabel.frame.size.width, BoxView.frame.size.width),
                                                height: TextLabel.frame.size.height + BoxView.frame.size.height + InteriorMargin))
        }
        self.frame = SelfFrame
        var TextOffset: CGFloat = (SelfFrame.height - TextLabel.frame.size.height) / 2.0
        if TextOffset < 0.0
        {
            TextOffset = 0.0
        }
        switch _TextLocation
        {
            case .Left:
                TextLabel.frame = CGRect(origin: CGPoint(x: 0, y: TextOffset), size: TextLabel.frame.size)
                BoxView.frame = CGRect(origin: CGPoint(x: TextLabel.frame.size.width + InteriorMargin, y: 0.0), size: BoxView.frame.size)
            
            case .Right:
                BoxView.frame = CGRect(origin: CGPoint.zero, size: BoxView.frame.size)
                TextLabel.frame = CGRect(origin: CGPoint(x: BoxView.frame.size.width + InteriorMargin, y: TextOffset), size: TextLabel.frame.size)
            
            case .Top:
                TextLabel.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: TextLabel.frame.size)
                BoxView.frame = CGRect(origin: CGPoint(x: 0, y: TextLabel.frame.size.height + InteriorMargin), size: BoxView.frame.size)
            
            case .Bottom:
                BoxView.frame = CGRect(origin: CGPoint.zero, size: BoxView.frame.size)
                TextLabel.frame = CGRect(origin: CGPoint(x: 0, y: BoxView.frame.size.height + InteriorMargin), size: TextLabel.frame.size)
        }
        
        self.addSubview(TextLabel)
        self.addSubview(BoxView)
    }
    
    func DrawBoxWithPercent(InView: UIView)
    {
        let Width = InView.frame.size.width
        let Height = InView.frame.size.height
        InView.layer.borderWidth = 1.0
        InView.layer.cornerRadius = 3.0
        InView.layer.borderColor = _BoxColor.cgColor
        InView.clipsToBounds = true
        
        let WidthPercent = Width * CGFloat(_Percent)
        let PercentComplete = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size:
            CGSize(width: WidthPercent, height: Height)))
        
        let PercentView = CAShapeLayer()
        PercentView.isOpaque = false
        PercentView.frame = InView.frame
        PercentView.fillColor = _BoxColor.cgColor
        PercentView.path = PercentComplete.cgPath
        
        InView.layer.addSublayer(PercentView)
    }
    
    var TextLabel: UILabel = UILabel()
    var BoxView: UIView = UIView()
    
    public func DrawBox(WithText: String, Percent: Double)
    {
        Text = WithText
        self.Percent = Percent
    }
    
    private var _Text: String = ""
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var Text: String
    {
        get
        {
            return _Text
        }
        set
        {
            _Text = newValue
        }
    }
    
    private var _TextFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var TextFont: UIFont
    {
        get
        {
            return _TextFont
        }
        set
        {
            _TextFont = newValue
        }
    }
    
    private var _Percent: Double = 0.0
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var Percent: Double
    {
        get
        {
            return _Percent
        }
        set
        {
            var Scratch = newValue
            if Scratch < 0.0
            {
                Scratch = 0.0
            }
            if Scratch > 1.0
            {
                Scratch = 1.0
            }
            _Percent = Scratch
        }
    }
    
    private var _BoxSize: CGSize = CGSize(width: 50, height: 20)
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var BoxSize: CGSize
    {
        get
        {
            return _BoxSize
        }
        set
        {
            _BoxSize = newValue
        }
    }
    
    private var _TextLocation: TextLocations = .Left
    {
        didSet
        {
            DrawBox()
        }
    }
   public var TextLocation: TextLocations
    {
        get
        {
            return _TextLocation
        }
        set
        {
            _TextLocation = newValue
        }
    }
    
    private var _TextPosition: String = "LEFT"
    {
        didSet
        {
            var Final = ""
            if _TextPosition.isEmpty
            {
                Final = "LEFT"
            }
            else
            {
            let Scratch = _TextPosition.trimmingCharacters(in: .whitespacesAndNewlines)
                Final = Scratch.uppercased()
            }
            switch Final
            {
                case "LEFT":
                    TextLocation = .Left
                
                case "RIGHT":
                    TextLocation = .Right
                
                case "TOP", "ABOVE":
                    TextLocation = .Top
                
                case "BOTTOM", "BELOW":
                    TextLocation = .Bottom
                
                default:
                    TextLocation = .Left
            }
            _TextPosition = Final
        }
    }
    @IBInspectable public var TextPostion: String
    {
        get
        {
            return _TextPosition
        }
        set
        {
            _TextPosition = newValue
        }
    }
    
    private var _TextColor: UIColor = UIColor.systemGreen
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var TextColor: UIColor
    {
        get
        {
            return _TextColor
        }
        set
        {
            _TextColor = newValue
        }
    }
    
    private var _BoxColor: UIColor = UIColor.green
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var BoxColor: UIColor
    {
        get
        {
            return _BoxColor
        }
        set
        {
            _BoxColor = newValue
        }
    }
    
    private var _Background: UIColor = UIColor.clear
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var Background: UIColor
        {
        get
        {
            return _Background
        }
        set
        {
            _Background = newValue
        }
    }
}

enum TextLocations: String, CaseIterable
{
    case Left = "Left"
    case Right = "Right"
    case Top = "Top"
    case Bottom = "Bottom"
}


