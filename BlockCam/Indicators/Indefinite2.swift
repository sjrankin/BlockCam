//
//  Indefinite2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements an indefinate indicator using layers.
class Indefinite2: UIView
{
    /// Initializer.
    /// - Parameter frame: Frame for the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        clipsToBounds = true
        DrawIndicator()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        clipsToBounds = true
        DrawIndicator()
    }
    
    /// Holds the background color.
    private var _BGColor: UIColor = UIColor.systemYellow
    /// Get or set the background color.
    public var BGColor: UIColor
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the fill color of each node.
    private var _NodeColor: UIColor = UIColor.orange
    /// Get or set the fill color of each node.
    public var NodeColor: UIColor
    {
        get
        {
            return _NodeColor
        }
        set
        {
            _NodeColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke color of each node.
    private var _NodeStrokeColor: UIColor = UIColor.black
    /// Get or set the stroke color of each node.
    public var NodeStrokeColor: UIColor
    {
        get
        {
            return _NodeStrokeColor
        }
        set
        {
            _NodeStrokeColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke thickness of each node.
    private var _NodeStrokeThickness: CGFloat = 1.0
    /// Get or set the stroke thickness of each node.
    public var NodeStrokeThickness: CGFloat
    {
        get
        {
            return _NodeStrokeThickness
        }
        set
        {
            _NodeStrokeThickness = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the number of radial nodes.
    private var _NodeCount: Int = 7
    /// Get or set the number of radial nodes.
    public var NodeCount: Int
    {
        get
        {
            return _NodeCount
        }
        set
        {
            _NodeCount = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the radius of each radial node.
    private var _NodeRadius: CGFloat = 5.0
    /// Get or set the radius of each radial node.
    public var NodeRadius: CGFloat
    {
        get
        {
            return _NodeRadius
        }
        set
        {
            _NodeRadius = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the radial adjustment.
    private var _RadialAdjustment: Double = 0.9
    /// Get or set the multiplier for the radius of the indicator.
    public var RadialAdjustment: Double
    {
        get
        {
            return _RadialAdjustment
        }
        set
        {
            _RadialAdjustment = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the radius of the center node.
    private var _CenterNodeRadius: CGFloat = 0.0
    /// Get or set the radius of the center node. Set to 0.0 to not display a node.
    public var CenterNodeRadius: CGFloat
    {
        get
        {
            return _CenterNodeRadius
        }
        set
        {
            _CenterNodeRadius = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the fill color of the center node.
    private var _CenterNodeColor: UIColor = UIColor.systemBlue
    /// Get or set the fill color for the center node.
    public var CenterNodeColor: UIColor
    {
        get
        {
            return _CenterNodeColor
        }
        set
        {
            _CenterNodeColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke color for the center node.
    private var _CenterNodeStrokeColor: UIColor = UIColor.systemGreen
    /// Get or set the stroke color for the center node.
    public var CenterNodeStrokeColor: UIColor
    {
        get
        {
            return _CenterNodeStrokeColor
        }
        set
        {
            _CenterNodeStrokeColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke thickness of the center node.
    private var _CenterNodeStrokeThickness: CGFloat = 1.0
    /// Get or set the stroke thickness of the center node.
    public var CenterNodeStrokeThickness: CGFloat
    {
        get
        {
            return _CenterNodeStrokeThickness
        }
        set
        {
            _CenterNodeStrokeThickness = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the fill color for the span.
    private var _SpanColor: UIColor = UIColor.systemTeal
    /// Get or set the fill color for the span.
    public var SpanColor: UIColor
    {
        get
        {
            return _SpanColor
        }
        set
        {
            _SpanColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke thickness for the span.
    private var _SpanStrokeThickness: CGFloat = 1.0
    /// Get or set the stroke thickness for the span.
    public var SpanStrokeThickness: CGFloat
    {
        get
        {
            return _SpanStrokeThickness
        }
        set
        {
            _SpanStrokeThickness = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the stroke color for the span.
    private var _SpanStrokeColor: UIColor = UIColor.black
    /// Get or set the stroke color for the span.
    public var SpanStrokeColor: UIColor
    {
        get
        {
            return _SpanStrokeColor
        }
        set
        {
            _SpanStrokeColor = newValue
            DrawIndicator()
        }
    }
    
    /// Holds the list of spans to display.
    private var _Spans: [(First: Int, Second: Int)] = []
    /// Get or set the list of spans to display. All items must be in the set of spans defined by the number of
    /// of nodes. For example, if there are 7 nodes, valid span `First` and `Second` values are 0, 1, 2, 3, 4, 5, 6.
    /// Invalid spans are ignored.
    public var Spans: [(First: Int, Second: Int)]
    {
        get
        {
            return _Spans
        }
        set
        {
            _Spans = newValue
            DrawIndicator()
        }
    }
    
    /// Returns a list of all available spans with an increment of 1. For example, if there are 4 spans, this property will return:
    /// `(0, 1), (1, 2), (2, 3), (3, 0)`.
    public var AllSpans: [(FirstNode: Int, SecondNode: Int)]
    {
        get
        {
            var SpanList = [(FirstNode: Int, SecondNode: Int)]()
            for Index in 0 ..< _NodeCount
            {
                SpanList.append((FirstNode: Index, SecondNode: Index + 1))
            }
            var LastSpan = SpanList.removeLast()
            LastSpan.SecondNode = 0
            SpanList.append(LastSpan)
            return SpanList
        }
    }
    
    /// Holds the list of layer names used. Used when clearing old sublayers.
    private let LayerNames = ["IndicatorLayer", "NodeMapLayer", "CenterNode", "Span"]
    
    /// Draw the indicator with the current set of attributes.
    private func DrawIndicator()
    {
        if self.layer.sublayers != nil
        {
            for SomeLayer in self.layer.sublayers!
            {
                if LayerNames.contains(SomeLayer.name!)
                {
                    SomeLayer.removeFromSuperlayer()
                }
            }
        }
        let BGLayer = CAShapeLayer()
        BGLayer.name = "IndicatorLayer"
        BGLayer.backgroundColor = _BGColor.cgColor
        BGLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let Increment = 360.0 / Double(_NodeCount)
        
        let Center = CGPoint(x: BGLayer.frame.width / 2.0, y: BGLayer.frame.height / 2.0)
        let ShortestDimension = Double(min(BGLayer.frame.width, BGLayer.frame.height))
        var Radius = ShortestDimension / 2.0
        if _RadialAdjustment > 0.0
        {
            Radius = Radius * _RadialAdjustment
        }
        
        if CenterNodeRadius > 0.0
        {
            let CenterNode = CAShapeLayer()
            CenterNode.zPosition = 100
            CenterNode.frame = BGLayer.frame
            CenterNode.backgroundColor = UIColor.clear.cgColor
            CenterNode.name = "CenterNode"
            let CenterSize = CGSize(width: _CenterNodeRadius * 2, height: _CenterNodeRadius * 2)
            let CenterLocation = CGPoint(x: Center.x - _CenterNodeRadius, y: Center.y - _CenterNodeRadius)
            let CenterShape = UIBezierPath(ovalIn: CGRect(origin: CenterLocation, size: CenterSize))
            CenterNode.fillColor = _CenterNodeColor.cgColor
            CenterNode.lineWidth = _CenterNodeStrokeThickness
            CenterNode.strokeColor = _CenterNodeStrokeColor.cgColor
            CenterNode.path = CenterShape.cgPath
            BGLayer.addSublayer(CenterNode)
        }
        
        NodeMap.removeAll()
        NodeAngles.removeAll()
        var Index = 0
        for Angle in stride(from: 0.0, through: 360.0, by: Increment)
        {
            let NodePoint = PolarToCartesian(Angle: Angle, Radius: Radius, Center: Center)
            let FinalPoint = CGPoint(x: NodePoint.x - NodeRadius, y: NodePoint.y - _NodeRadius)
            let Node = UIBezierPath(ovalIn: CGRect(origin: FinalPoint, size: CGSize(width: _NodeRadius * 2, height: _NodeRadius * 2)))
            let NodeLayer = CAShapeLayer()
            NodeLayer.zPosition = 100
            NodeLayer.backgroundColor = UIColor.clear.cgColor
            NodeLayer.name = "NodeMapLayer"
            NodeLayer.frame = BGLayer.frame
            NodeLayer.path = Node.cgPath
            NodeLayer.strokeColor = _NodeStrokeColor.cgColor
            NodeLayer.lineWidth = _NodeStrokeThickness
            NodeLayer.fillColor = _NodeColor.cgColor
            NodeMap[Angle] = NodeLayer
            NodeAngles.append(Angle)
            BGLayer.addSublayer(NodeLayer)
            Index = Index + 1
        }
        
        if !_Spans.isEmpty
        {
            for SomeSpan in _Spans
            {
                if SomeSpan.First < 0 || SomeSpan.First > NodeMap.count - 1
                {
                    continue
                }
                if SomeSpan.Second < 0 || SomeSpan.Second > NodeMap.count - 1
                {
                    continue
                }
                if SomeSpan.First == SomeSpan.Second
                {
                    continue
                }
                let SpanNode = CAShapeLayer()
                SpanNode.zPosition = 50
                SpanNode.name = "Span"
                SpanNode.fillColor = _SpanColor.cgColor
                SpanNode.strokeColor = _SpanStrokeColor.cgColor
                SpanNode.lineWidth = _SpanStrokeThickness
                let SpanPath = UIBezierPath()
                SpanPath.move(to: Center)
                let FirstPoint = PolarToCartesian(Angle: NodeAngles[SomeSpan.First], Radius: Radius, Center: Center)
                SpanPath.addLine(to: FirstPoint)
                let SecondPoint = PolarToCartesian(Angle: NodeAngles[SomeSpan.Second], Radius: Radius, Center: Center)
                SpanPath.addLine(to: SecondPoint)
                SpanPath.close()
                SpanNode.path = SpanPath.cgPath
                BGLayer.addSublayer(SpanNode)
            }
        }
        
        self.layer.addSublayer(BGLayer)
    }
    
    /// Holds a list of angles for each node in order of creation.
    var NodeAngles = [Double]()
    
    /// Map between node angle and its layer.
    var NodeMap = [Double: CAShapeLayer]()
    
    /// Convert a polar coordinate to a cartesian coordinate.
    /// - Parameter Angle: The angle (in degrees) of the polar coordinate.
    /// - Parameter Radius: The radius of the polar coordinate.
    /// - Parameter Center: The center of the polar coordinate.
    /// - Returns: Cartesian equivalent of the passed polar coordinate.
    func PolarToCartesian(Angle: Double, Radius: Double, Center: CGPoint) -> CGPoint
    {
        let X = Radius * cos((Angle - 90.0) * Double.pi / 180.0) + Double(Center.x)
        let Y = Radius * sin((Angle - 90.0) * Double.pi / 180.0) + Double(Center.y)
        return CGPoint(x: X, y: Y)
    }
    
    /// Redraw the indicate with the passed parameters.
    /// - Parameter BGColor: The background color.
    /// - Parameter NodeCount: The number of nodes.
    /// - Parameter NodeRadius: The radius of each node.
    /// - Parameter NodeColor: The fill color for each node.
    /// - Parameter NodeStrokeThickness: The thickness of the stroke of each node.
    /// - parameter NodeStrokeColor: The stroke color for each node.
    func Redraw(BGColor: UIColor, NodeCount: Int, NodeRadius: CGFloat, NodeColor: UIColor,
                NodeStrokeThickness: CGFloat, NodeStrokeColor: UIColor)
    {
        _BGColor = BGColor
        _NodeColor = NodeColor
        _NodeCount = NodeCount
        _NodeRadius = NodeRadius
        _NodeStrokeThickness = NodeStrokeThickness
        _NodeStrokeColor = NodeStrokeColor
        DrawIndicator()
    }
    
    /// Animate a span.
    /// - Parameter Start: The starting index of the span. Defaults to 0.
    /// - Parameter Direction: Determines if the span is animated in a clockwise (`1`) or counterclockwise (`-1`) direction. All other
    ///                        values default to `1`.
    /// - Parameter Duration: Number of seconds each span is in a given location.
    func AnimateSpans(Start: Int = 0, Direction: Int = 1, Duration: Double)
    {
        CurrentDisplayedSpan = Start
        PreviousSpan = -1
        if ![1, -1].contains(Direction)
        {
            RotationDirection = 1
        }
        else
        {
            RotationDirection = Direction
        }
        SpanTimer = Timer.scheduledTimer(timeInterval: Duration, target: self,
                                         selector: #selector(UpdateSpan), userInfo: nil, repeats: true)
    }
    
    /// Stop animating the spans.
    /// - Parameter RemoveSpans: If true, the span is removed from the view when animation is stopped. Otherwise,
    ///                          it is left in place.
    func StopSpanAnimation(RemoveSpans: Bool = true)
    {
        if SpanTimer == nil
        {
            return
        }
        SpanTimer.invalidate()
        if RemoveSpans
        {
            Spans.removeAll()
            DrawIndicator()
        }
    }
    
    /// Determines rotational direction.
    var RotationDirection: Int = 1
    
    /// Timer for the span animation.
    var SpanTimer: Timer!
    
    /// Holds the current span being displayed.
    private var CurrentDisplayedSpan: Int = -1
    
    /// Update which span to display.
    @objc func UpdateSpan()
    {
        if CurrentDisplayedSpan < 0
        {
            Spans.removeAll()
            DrawIndicator()
            return
        }
        CurrentDisplayedSpan = CurrentDisplayedSpan + RotationDirection
        if CurrentDisplayedSpan > AllSpans.count - 1
        {
            CurrentDisplayedSpan = 0
        }
        if CurrentDisplayedSpan < 0
        {
            CurrentDisplayedSpan = AllSpans.count - 1
        }
        if PreviousSpan > -1
        {
            
        }
        let NewSpan = AllSpans[CurrentDisplayedSpan]
        Spans.removeAll()
        Spans.append((First: NewSpan.FirstNode, Second: NewSpan.SecondNode))
    }
    
    /// Holds the previous span displayed.
    var PreviousSpan = -1
}
