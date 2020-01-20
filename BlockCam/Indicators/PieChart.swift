//
//  PieChart.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Creates a pie chart to indicate percent complete values.
/// - Note: See [Making a pie chart using CoreGrahics](https://stackoverflow.com/questions/35752762/making-a-pie-chart-using-core-graphics)
class PieChart: UIView
{
    /// Initializer.
    /// - Parameter frame: The frame to use for the indicator.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
    
    /// Pie chart segments.
    var Segments = [PieChartSegment]()
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    /// Refresh the pie chart.
    func Refresh()
    {
        setNeedsDisplay()
    }
    
    /// Animate a segment to a new value.
    /// - Warning: If `Index` is out of bounds, a fatal error will be generated.
    /// - Parameter Index: The index of the segment to animate.
    /// - Parameter To: The new value for the segment.
    /// - Parameter Duration: Number of seconds for the animation. If this value is 0.0 or less, no animation or changes occur.
    func AnimateSegment(_ Index: Int, To: CGFloat, Duration: Double)
    {
        if Index < 0 || Index > Segments.count - 1
        {
            Crash.ShowCrashAlert(WithController: self.ParentViewController!, "Error",
                                 "Invalid segment index for AnimateSegment. BlockCam will close.")
            Log.AbortMessage("Invalid segment index (\(Index)) for AnimateSegment - out of bounds.")
            {
                Message in
                fatalError(Message)
            }
        }
        if Duration <= 0.0
        {
            Log.Message("Duration of 0.0 or less not supported.", FileName: #file, FunctionName: #function)
            return
        }
        SegmentIndex = Index
        SegmentStart = Segments[Index].Value
        SegmentEnd = To
        SegmentDelta = SegmentEnd - SegmentStart
        FinalDuration = Duration
        Anim = CADisplayLink(target: self, selector: #selector(SegmentAnimation))
        Anim?.preferredFramesPerSecond = 30
        Anim?.add(to: .current, forMode: .default)
    }
    
    var SegmentIndex:Int = 0
    var SegmentStart: CGFloat = 0.0
    var SegmentEnd: CGFloat = 0.0
    var SegmentDelta: CGFloat = 0.0
    var Anim: CADisplayLink? = nil
    var CumulativeDuration: Double = 0.0
    var FinalDuration: Double = 0.0
    
    /// Does the actual animation of the segment.
    /// - Parameter Link: The display link object.
    @objc func SegmentAnimation(Link: CADisplayLink)
    {
        let Duration = Link.targetTimestamp - Link.timestamp
        CumulativeDuration = CumulativeDuration + Duration
        if CumulativeDuration >= FinalDuration
        {
            Anim?.remove(from: .current, forMode: .default)
            Anim = nil
            return
        }
        let Percent = CumulativeDuration / FinalDuration
        let NewValue = (SegmentDelta * CGFloat(Percent)) + SegmentStart
        Segments[SegmentIndex].Value = NewValue
        print("\(NewValue)")
        Refresh()
    }
    
    /// Draw the pie chart.
    /// - Parameter rect: The rectangle in which to draw the pie chart.
    override func draw(_ rect: CGRect)
    {
        let Context = UIGraphicsGetCurrentContext()
        let Radius = min(frame.size.width, frame.size.height) * 0.5
        let Center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let Count = Segments.reduce(0, {$0 + $1.Value})
        var StartAngle = -CGFloat.pi / 2.0
        for Segment in Segments
        {
            let EndAngle = StartAngle + 2.0 * CGFloat.pi * (Segment.Value / Count)
            Context?.setFillColor(Segment.Color.cgColor)
            Context?.move(to: Center)
            Context?.addArc(center: Center, radius: Radius, startAngle: StartAngle,
                            endAngle: EndAngle, clockwise: false)
            Context?.fillPath()
            StartAngle = EndAngle
        }
    }
}

/// Encapsulates one pie chart segment.
class PieChartSegment
{
    /// Initializer.
    /// - Parameter Color: The color of the segment.
    /// - Parameter Value: the value of the segment, ranging between 0.0 and 1.0.
    init(_ Color: UIColor, _ Value: CGFloat)
    {
        self.Color = Color
        self.Value = Value
    }
    
    /// The color of the segment.
    var Color: UIColor = UIColor.white
    /// The border color of the segment.
    var BorderColor: UIColor = UIColor.black
    /// The value of the segment.
    var Value: CGFloat = 0.0
}
