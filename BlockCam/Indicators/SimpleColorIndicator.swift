//
//  SimpleColorIndicator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SimpleColorIndicator: UIView
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
        self.Text = "Color"
        self.TextLocation = .Left
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
        
        ColorView.removeFromSuperview()
        ColorView = UIView(frame: CGRect(origin: CGPoint.zero, size: _BoxSize))
        ColorView.isOpaque = false
        ColorView.backgroundColor = _Color
        ColorView.layer.borderColor = _BoxColor.cgColor
        ColorView.layer.borderWidth = 1.0
        ColorView.layer.cornerRadius = 3.0
        
        var SelfFrame = CGRect()
        let InteriorMargin: CGFloat = 4.0
        switch _TextLocation
        {
            case .Left, .Right:
                SelfFrame = CGRect(origin: CGPoint.zero,
                                   size: CGSize(width: TextLabel.frame.size.width + ColorView.frame.size.width + InteriorMargin,
                                                height: max(TextLabel.frame.size.height, ColorView.frame.size.height)))
            
            case .Top, .Bottom:
                SelfFrame = CGRect(origin: CGPoint.zero,
                                   size: CGSize(width: max(TextLabel.frame.size.width, ColorView.frame.size.width),
                                                height: TextLabel.frame.size.height + ColorView.frame.size.height + InteriorMargin))
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
                ColorView.frame = CGRect(origin: CGPoint(x: TextLabel.frame.size.width + InteriorMargin, y: 0.0), size: ColorView.frame.size)
            
            case .Right:
                ColorView.frame = CGRect(origin: CGPoint.zero, size: ColorView.frame.size)
                TextLabel.frame = CGRect(origin: CGPoint(x: ColorView.frame.size.width + InteriorMargin, y: TextOffset), size: TextLabel.frame.size)
            
            case .Top:
                TextLabel.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: TextLabel.frame.size)
                ColorView.frame = CGRect(origin: CGPoint(x: 0, y: TextLabel.frame.size.height + InteriorMargin), size: ColorView.frame.size)
            
            case .Bottom:
                ColorView.frame = CGRect(origin: CGPoint.zero, size: ColorView.frame.size)
                TextLabel.frame = CGRect(origin: CGPoint(x: 0, y: ColorView.frame.size.height + InteriorMargin), size: TextLabel.frame.size)
        }
        
        self.addSubview(TextLabel)
        self.addSubview(ColorView)
    }
    
    var TextLabel: UILabel = UILabel()
    var ColorView: UIView = UIView()
    
    public func DrawColorBox(WithText: String, WithColor: UIColor)
    {
        Text = WithText
        Color = WithColor
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
    
    private var _Color: UIColor = UIColor.white
    {
        didSet
        {
            DrawBox()
        }
    }
    @IBInspectable public var Color: UIColor
        {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
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
    
    private var _BoxColor: UIColor = UIColor.black
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
}
