//
//  PiePercent.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Creates a pie chart-like indicator for percent indications.
/// - Note: See [Making a pie chart using Core Graphics](https://stackoverflow.com/questions/35752762/making-a-pie-chart-using-core-graphics)
class PiePercent: UIView
{
    /// Default initializer.
    /// - Parameter frame: The frame of the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
        EmptySegment = PieChartSegment(UIColor.clear, 1.0)
        FullSegment = PieChartSegment(UIColor.black, 0.0)
    }
    
    /// Default initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
        EmptySegment = PieChartSegment(UIColor.clear, 1.0)
        FullSegment = PieChartSegment(UIColor.black, 0.0)
    }
    
    /// Contains the empty segment - this is the part that indicates something yet to be done.
    var EmptySegment: PieChartSegment? = nil
    
    /// Contain the full segment - this is the part that indicates something that has been completed.
    var FullSegment: PieChartSegment? = nil
    
    /// Refresh the display.
    func Refresh()
    {
        setNeedsDisplay()
    }
    
    /// Holds the color of the completed part of the indicator.
    private var _Color: UIColor = UIColor.black
    {
        didSet
        {
            FullSegment?.Color = _Color
            Refresh()
        }
    }
    /// Get or set the color of the completed part of the indicator.
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
    
    /// Holds the color of the incompleted part of the indicator.
    private var _IncompleteColor: UIColor = UIColor.black
    {
        didSet
        {
            EmptySegment?.Color = _IncompleteColor
            Refresh()
        }
    }
    /// Get or set the color of the incompleted part of the indicator.
    @IBInspectable public var IncompleteColor: UIColor
        {
        get
        {
            return _IncompleteColor
        }
        set
        {
            _IncompleteColor = newValue
        }
    }
    
    /// Holds the current percent value for the indicator.
    /// - Note: Out of range values are ignored. When encountered, no action is taken.
    private var _CurrentPercent: CGFloat = 0.5
    {
        didSet
        {
            if _CurrentPercent < 0.0 || _CurrentPercent > 1.0
            {
                return
            }
            FullSegment!.Value = _CurrentPercent
            EmptySegment!.Value = 1.0 - _CurrentPercent
            Refresh()
        }
    }
    /// Get or set the current percent value for the indicator.
    /// - Note: Out of range values are ignored.
    @IBInspectable public var CurrentPercent: CGFloat
    {
        get
        {
            return _CurrentPercent
        }
        set
        {
            _CurrentPercent = newValue
        }
    }
    
    /// Animate the complete value.
    /// - Parameter To: The new complete percent. Must be in the range 0.0 to 1.0. If not, no action is taken.
    /// - Parameter Duration: Number of seconds to take for the animation. If 0.0, no action is taken.
    func AnimatePercent(To: CGFloat, Duration: Double)
    {
        if To < 0.0 || To > 1.0
        {
            Log.Message("To must be in the range 0.0 to 1.0 (passed: \(To))")
            //print("To must be in the range 0.0 to 1.0 (passed: \(To))")
            return
        }
        if Duration <= 0.0
        {
            Log.Message("Duration of 0.0 or less not supported.")
            //print("Duration of 0.0 or less not supported.")
            return
        }
        SegmentStart = FullSegment!.Value
        SegmentEnd = To
        SegmentDelta = SegmentEnd - SegmentStart
        FinalDuration = Duration
        Anim = CADisplayLink(target: self, selector: #selector(SegmentAnimation))
        Anim?.preferredFramesPerSecond = 30
        Anim?.add(to: .current, forMode: .default)
    }
    
    /// Starting value of the completed segment.
    var SegmentStart: CGFloat = 0.0
    
    /// Ending value of the completed segment.
    var SegmentEnd: CGFloat = 0.0
    
    /// Delta value for the completed segment.
    var SegmentDelta: CGFloat = 0.0
    
    /// CADisplayLink animation object.
    var Anim: CADisplayLink? = nil
    
    /// Current cumulative duration of the animation.
    var CumulativeDuration: Double = 0.0
    
    /// Final duration value.
    var FinalDuration: Double = 0.0
    
    /// Handle the display link call - happens periodically and allows us to update the completed value.
    /// - Parameter Link: The display link with time stamps that allow us to calculate the percent complete of the animation.
    @objc func SegmentAnimation(Link: CADisplayLink)
    {
        let Duration = Link.targetTimestamp - Link.timestamp
        CumulativeDuration = CumulativeDuration + Duration
        if CumulativeDuration >= FinalDuration
        {
            //Be sure to manually set the end values here because rounding may leave an unsightly gap at the end of
            //the set of calls.
            FullSegment!.Value = SegmentEnd
            EmptySegment!.Value = 1.0 - SegmentEnd
            Refresh()
            Anim?.remove(from: .current, forMode: .default)
            Anim = nil
            return
        }
        let Percent = CumulativeDuration / FinalDuration
        let NewValue = (SegmentDelta * CGFloat(Percent)) + SegmentStart
        FullSegment!.Value = NewValue
        EmptySegment!.Value = 1.0 - NewValue
        Refresh()
    }
    
    /// Draw the indicator.
    /// - Parameter rect: The rectangle in which the indicator should be drawn.
    override func draw(_ rect: CGRect)
    {
        #if false
        let Radius = min(frame.size.width, frame.size.height) * 0.5
        let Center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let Path = UIBezierPath()
        let Circle = UIBezierPath(ovalIn: CGRect(origin: Center, size: CGSize(width: Radius * 2.0, height: Radius * 2.0)))
        UIColor.clear.setFill()
        UIColor.black.setStroke()
        Circle.lineWidth = 4.0
        Circle.stroke()
        Circle.fill()
        Path.append(Circle)
        let Segments = [EmptySegment!, FullSegment!]
        let Count = Segments.reduce(0, {$0 + $1.Value})
        var StartAngle = -CGFloat.pi / 2.0
        let ClockwiseRotation = -1.0 * 2.0 * CGFloat.pi
        for Segment in Segments
        {
            let EndAngle = StartAngle + ClockwiseRotation * (Segment.Value / Count)
            let Arc = UIBezierPath(arcCenter: Center, radius: Radius, startAngle: StartAngle, endAngle: EndAngle, clockwise: true)
            Segment.Color.setFill()
            UIColor.black.setStroke()
            Arc.lineWidth = 2.0
            Arc.stroke()
            Arc.fill()
            Path.append(Arc)
            StartAngle = EndAngle
        }
        #else
        let Context = UIGraphicsGetCurrentContext()
        let Radius = min(frame.size.width, frame.size.height) * 0.5
        let Center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let Segments = [EmptySegment!, FullSegment!]
        let Count = Segments.reduce(0, {$0 + $1.Value})
        var StartAngle = -CGFloat.pi / 2.0
        let ClockwiseRotation = -1.0 * 2.0 * CGFloat.pi
        for Segment in Segments
        {
            let EndAngle = StartAngle + ClockwiseRotation * (Segment.Value / Count)
            Context?.setFillColor(Segment.Color.cgColor)
            Context?.move(to: Center)
            Context?.addArc(center: Center, radius: Radius, startAngle: StartAngle,
                            endAngle: EndAngle, clockwise: true)
            Context?.fillPath()
            StartAngle = EndAngle
        }
        Context?.setStrokeColor(UIColor.black.cgColor)
        Context?.strokePath()
        #endif
    }
}
