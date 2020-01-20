//
//  LinearPercent.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a linear percent indicator.
class LinearPercent: UIView
{
    /// Initializer.
    /// - Parameter frame: Frame of the initializer.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter frame: Frame of the initializer.
    /// - Parameter Orientation: Orientation of the initializer.
    init(frame: CGRect, Orientation: LinearPercentOrientations)
    {
        super.init(frame: frame)
        Initialize()
        _Orientation = Orientation
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the UI.
    private func Initialize()
    {
        switch _Orientation
        {
            case .HorizontalLeft, .HorizontalRight:
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY,
                                    width: self.frame.width, height: _Thickness)
            
            case .VerticalUp, .VerticalDown:
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY,
                                    width: _Thickness, height: self.frame.height)
        }
        self.backgroundColor = _IndicatorBackgroundColor
        Indication = UIView(frame: CGRect(x: 0.0, y: 0.0,
                                          width: 0.0, height: 0.0))
        Indication.backgroundColor = _IndicatorFillColor
        Indication.layer.zPosition = 1000
        Indication.layer.borderColor = IndicatorFillColor.cgColor
        Indication.layer.cornerRadius = 1.0
        Indication.layer.borderWidth = 0.5
        Indication.clipsToBounds = true
        self.clipsToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = _IndicatorFillColor.cgColor
        self.layer.cornerRadius = 1.0
        self.subviews.forEach{$0.removeFromSuperview()}
        self.addSubview(Indication)
        Update(NewPercent: PercentValue)
    }
    
    /// Update the percentage value.
    /// - Parameter NewPercent: New percent to display. Values less than 0.0 or greater than 1.0 are ignored and if passed,
    ///                         control returned immediately with no change made.
    private func Update(NewPercent: Double)
    {
        if NewPercent < 0.0 || NewPercent > 1.0
        {
            return
        }
        var Extent: CGFloat = CGFloat(NewPercent)
        switch _Orientation
        {
            case .HorizontalRight, .HorizontalLeft:
                Extent = Extent * self.frame.width
                Indication.frame = CGRect(x: Indication.frame.minX,
                                          y: Indication.frame.minY,
                                          width: Extent,
                                          height: _Thickness)
                
            
            case .VerticalDown, .VerticalUp:
                Extent = Extent * self.frame.height
                Indication.frame = CGRect(x: Indication.frame.minX,
                                                y: Indication.frame.minY,
                                                width: _Thickness,
                                                height: Extent)
        }
    }
    
    /// Animate the indicator to the passed percent.
    /// - Note:
    ///   - Percentages are required to be in the range 0.0 to 1.0. Values falling outside that range are ignored
    ///     and no action is taken.
    ///   - This function will set `PercentValue` after animation has completed.
    /// - Parameter NewPercent: The new percent to animate the indicator to and to set the `PercentValue`.
    /// - Parameter WithDuration: The duration (in seconds) of the animation.
    public func AnimateTo(_ NewPercent: Double, WithDuration: Double = 0.5)
    {
        if NewPercent < 0.0 || NewPercent > 1.0
        {
            return
        }
        var Extent: CGFloat = CGFloat(NewPercent)
        var NewFrame: CGRect = CGRect()
        switch _Orientation
        {
            case .HorizontalRight, .HorizontalLeft:
                Extent = Extent * self.frame.width
                NewFrame = CGRect(x: Indication.frame.minX,
                                          y: Indication.frame.minY,
                                          width: Extent,
                                          height: _Thickness)
            
            
            case .VerticalDown, .VerticalUp:
                Extent = Extent * self.frame.height
                NewFrame = CGRect(x: Indication.frame.minX,
                                          y: Indication.frame.minY,
                                          width: _Thickness,
                                          height: Extent)
        }
        UIView.animate(withDuration: WithDuration,
                       animations:
            {
                self.Indication.frame = NewFrame
        }, completion:
            {
                Completed in
                if Completed
                {
                    self.NoUpdate = true
                    self._PercentValue = NewPercent
                    self.NoUpdate = false
                }
        }
        )
    }
    
    private var NoUpdate = false
    
    /// Holds the current percent value to display.
    private var _PercentValue: Double = 0.5
    {
        didSet
        {
            if NoUpdate
            {
                return
            }
            Update(NewPercent: _PercentValue)
        }
    }
    /// Get or set the current percent value. Values less than 0.0 or greater than 1.0 are ignored.
    @IBInspectable public var PercentValue: Double
    {
        get
        {
            return _PercentValue
        }
        set
        {
            _PercentValue = newValue
        }
    }
    
    /// Holds the thickness of the indicator.
    private var _Thickness: CGFloat = 5.0
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the thickness of the indicator - for vertical orientations, the thickness is the width, and for horizontal
    /// orientations, the thickness is the height.
    @IBInspectable public var Thickness: CGFloat
        {
        get
        {
            return _Thickness
        }
        set
        {
            _Thickness = newValue
        }
    }
    
    /// Holds the orientation of the indicator.
    private var _Orientation: LinearPercentOrientations = .HorizontalRight
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the orientation of the indicator.
    public var Orientation: LinearPercentOrientations
    {
        get
        {
            return _Orientation
        }
        set
        {
            _Orientation = newValue
        }
    }
    
    /// Holds the fill (highlight) color.
    private var _IndicatorFillColor: UIColor = UIColor.systemYellow
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the fill/highlight/completed color.
    @IBInspectable public var IndicatorFillColor: UIColor
        {
        get
        {
            return _IndicatorFillColor
        }
        set
        {
            _IndicatorFillColor = newValue
        }
    }
    
    /// Holds the background color.
    private var _IndicatorBackgroundColor: UIColor = UIColor.gray
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the background/uncompleted color.
    @IBInspectable public var IndicatorBackgroundColor: UIColor
        {
        get
        {
            return _IndicatorBackgroundColor
        }
        set
        {
            _IndicatorBackgroundColor = newValue
        }
    }
    
    /// The indication view, eg, the UI element that shows the percent complete.
    private var Indication: UIView!
}

/// Orientations for the linear percent indicator.
enum LinearPercentOrientations: String, CaseIterable
{
    /// Horizontal orientation with increasing values to the right
    case HorizontalRight = "HorizontalRight"
    /// Horizontal orientation with increasing values to the left.
    case HorizontalLeft = "HorizontalLeft"
    /// Vertical orientation with increasing values up.
    case VerticalUp = "VerticalUp"
    /// Vertical orientation with increasing values down.
    case VerticalDown = "VerticalDown"
}
