//
//  FloatingText.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that displays scrolling (or floating) text.
class FloatingText: UIView
{
    /// Initializer.
    /// - Parameter frame: Initial frame.
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
    private func Initialize()
    {
        self.layer.borderColor = UIColor(red: 0.0, green: 65.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5.0
        //self.layer.backgroundColor = UIColor(red: 138.0 / 255.0, green: 43.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0).cgColor
        //self.layer.backgroundColor = UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0).cgColor
        //self.layer.addSublayer(Colors.GetCompositeTextGradient(Container: self.bounds))
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.clipsToBounds = true
    }
    
    /// Holds the font of the text.
    private var _LabelFont: UIFont = UIFont.systemFont(ofSize: 16.0)
    /// Get or set the font of the text. All visible text is affected by setting.
    public var LabelFont: UIFont
    {
        get
        {
            return _LabelFont
        }
        set
        {
            _LabelFont = newValue
        }
    }
    
    /// Holds the color the text.
    private var _LabelTextColor: UIColor = UIColor.white
    {
        didSet
        {
            if let Current = GetTaggedLabel(TagValue: CurrentLabelTag)
            {
                Current.textColor = _LabelTextColor
            }
        }
    }
    /// Get or set the color of the text. All visible text is affected by setting.
    public var LabelTextColor: UIColor
    {
        get
        {
            return _LabelTextColor
        }
        set
        {
            _LabelTextColor = newValue
        }
    }
    
    /// Show a new label.
    /// - Note: The old label is scrolled upwards and the new label scrolls in from the bottom.
    /// - Parameter WithText: The text of the new label.
    public func ShowLabel(_ WithText: String)
    {
        MoveLabels(WithText, NewLabelTag: LabelTagValue, OldLabelTag: LabelTagValue - 1)
        CurrentLabelTag = LabelTagValue
        LabelTagValue = LabelTagValue + 1
        AnimateBorder(From: UIColor.yellow, To: UIColor(red: 0.0, green: 65.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0), Duration: 1.0)
    }
    
    /// Show a new label.
    /// - Note: The old label is scrolled upwards and the new label scrolls in from the bottom.
    /// - Parameter WithText: The text of the new label.
    /// - Parameter Hide: The number of seconds to wait before scrolling the label away (eg, hiding it).
    public func ShowLabel(_ WithText: String, Hide After: Double = 1.0)
    {
        MoveLabels(WithText, NewLabelTag: LabelTagValue, OldLabelTag: LabelTagValue - 1)
        CurrentLabelTag = LabelTagValue
        LabelTagValue = LabelTagValue + 1
        AnimateBorder(From: UIColor.yellow, To: UIColor(red: 0.0, green: 65.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0), Duration: 1.0)
        ClearText(After: After)
    }
    
    /// Animate the color of the border. The border is initially set to the `From` color.
    /// - Parameter From: The source color.
    /// - Parameter To: The destination color.
    /// - Parameter Duration: Number of seconds to take to animate the color.
    func AnimateBorder(From: UIColor, To: UIColor, Duration: Double)
    {
        self.layer.removeAllAnimations()
        let CAAnim = CABasicAnimation(keyPath: "borderColor")
        CAAnim.fromValue = From.cgColor
        CAAnim.toValue = To.cgColor
        CAAnim.duration = Duration
        //CAAnim.repeatCount = 0
        CAAnim.fillMode = CAMediaTimingFillMode.forwards
        CAAnim.isRemovedOnCompletion = false
        self.layer.borderColor = From.cgColor
        self.layer.add(CAAnim, forKey: "borderColor")
    }
    
    var CurrentLabelTag = -1
    var LabelTagValue = 0
    
    /// Searches all of the children of control's view for a sub-view with the specified tag value. If found it is cast to
    /// a `UILabel` then returned.
    /// - Parameter TagValue: The value of the control (hopefully a `UILabel`) to return.
    /// - Returns: The `UILabel` with the specified tag value on success, nil if not found.
    func GetTaggedLabel(TagValue: Int) -> UILabel?
    {
        for SomeView in self.subviews
        {
            if SomeView.tag == TagValue
            {
                return SomeView as? UILabel
            }
        }
        return nil
    }
    
    /// Create a new label and assign the passed text to it. Animate the new label up from the bottom while simultaneously
    /// moving the old text out through the top.
    /// - Parameter Text: The text of the new label.
    /// - Parameter NewLabelTag: Tag value to assign to the new label. Assumed to be sequential from the previously created
    ///                          label values.
    /// - Parameter OldLabelTag: The tag of the label to move out through the top of teh container.
    func MoveLabels(_ Text: String, NewLabelTag: Int, OldLabelTag: Int)
    {
        let ContainerWidth = self.frame.width
        let ContainerHeight = self.frame.height
        let NewLabel = UILabel(frame: CGRect(x: 0, y: ContainerHeight + 10,
                                             width: ContainerWidth, height: 20))
        NewLabel.text = Text
        NewLabel.tag = NewLabelTag
        NewLabel.textAlignment = .left
        NewLabel.textColor = LabelTextColor
        NewLabel.font = LabelFont
        NewLabel.alpha = 0.0
        NewLabel.layer.zPosition = 2000
        self.addSubview(NewLabel)
        if let LabelToRemove = GetTaggedLabel(TagValue: OldLabelTag)
        {
            UIView.animate(withDuration: 0.4,
                           animations:
                {
                    LabelToRemove.frame = CGRect(x: 5, y: -30, width: ContainerWidth, height: 20)
                    LabelToRemove.alpha = 0.0
            },
                           completion:
                {
                    Completed in
                    if Completed
                    {
                        LabelToRemove.removeFromSuperview()
                    }
            }
            )
        }
        let FinalLocation = CGRect(x: 5, y: (ContainerHeight / 2) - (NewLabel.frame.height / 2),
                                   width: ContainerWidth, height: 20)
        UIView.animate(withDuration: 0.5, delay: 0.25,
                       usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1,
                       options: [],
                       animations:
            {
                NewLabel.alpha = 1.0
                NewLabel.frame = FinalLocation
        }
        )
    }
    
    /// Removes the text without replacing it.
    /// - Note: Assumes the current label has a tag value of `CurrentLabelTag`.
    /// - Parameter After: Number of seconds to wait before clearing the text.
    public func ClearText(After Duration: Double = 0.0)
    {
        if let CurrentLabel = GetTaggedLabel(TagValue: CurrentLabelTag)
        {
            UIView.animate(withDuration: 0.2, delay: Duration, animations:
                {
                    CurrentLabel.frame = CGRect(x: 0, y: -(CurrentLabel.frame.height + 10),
                                                width: CurrentLabel.frame.width,
                                                height: CurrentLabel.frame.height)
                    CurrentLabel.alpha = 0.0
            },
                            completion:
                {
                    _ in
                    CurrentLabel.removeFromSuperview()
            })
        }
    }
}
