//
//  SmallStatusDisplay.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a small view with three types of status display: 1) A text display, 2) a task percentage complete display, and
/// 3) an overall percent complete display.
class SmallStatusDisplay: UIView
{
    weak var MainDelegate: MainProtocol? = nil
    
    // MARK: - Initialization.
    
    /// Initializer.
    /// - Parameter frame: Frame of the view.
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
    
    /// Holds the one-time intialization completed flag.
    private var WasInitializedOnce = false
    
    /// Do the one-time initialization. This is the creation of the component elements of the UI.
    /// - Note: The elements are created and added to the parent view here, but only the text element will be visible at
    ///         creation time. All elements will be positioned (and optionally have their visibility set) in `Initialize`.
    private func OneTimeInitialization()
    {
        if WasInitializedOnce
        {
            return
        }
        WasInitializedOnce = true
        BottomPercent = LinearPercent()
        BottomPercent.isHidden = true
        self.addSubview(BottomPercent)
        TextBox = FloatingText()
        TextBox.isHidden = false
        self.addSubview(TextBox)
        PercentView = PiePercent()
        PercentView.isHidden = true
        self.addSubview(PercentView)
        WaitingIndicator = UIActivityIndicatorView()
        WaitingIndicator.hidesWhenStopped = true
        WaitingIndicator.style = .large
        WaitingIndicator.color = UIColor.systemYellow
        WaitingIndicator.layer.zPosition = 500
        WaitingIndicator.stopAnimating()
        self.addSubview(WaitingIndicator)
        SettingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        SettingsButton.addTarget(self, action: #selector(ShowContextMenu), for: UIControl.Event.touchUpInside)
        SettingsButton.setImage(UIImage(systemName: "gear",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30.0, weight: .bold)),
                            for: .normal)
        SettingsButton.tintColor = UIColor.white
        SettingsButton.isUserInteractionEnabled = false
        SettingsButton.alpha = 0.0
        SettingsButton.layer.zPosition = -1000
        self.addSubview(SettingsButton)
        self.clipsToBounds = true
    }
    
    // MARK: - Help display.
    
    @objc func ShowContextMenu(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        MainDelegate?.ShowProcessedImageMenu(From: SettingsButton)
    }
    
    // MARK: - Initialization and run-time updating.
    
    /// Initialize the class. Also updates the class when the caller changes certain properties.
    private func Initialize()
    {
        OneTimeInitialization()
        let Margin: CGFloat = 4.0
        let LinePercentThickness =  ShowBottomPercent ? TotalPercentThickness : 0.0
        let TextHeight = self.frame.height - ((Margin * 2) + LinePercentThickness)
        let PercentWidth = ShowTaskPercentage ? TextHeight : 0.0
        let TextWidth = self.frame.width - ((Margin * 3) + PercentWidth)
        
        TextBox.frame = CGRect(x: Margin, y: Margin,
                               width: TextWidth, height: TextHeight)
        TextBox.layer.borderWidth = 0.5
        TextBox.layer.cornerRadius = 5.0
        TextBox.layer.borderColor = UIColor.black.cgColor
        
        SettingsButton.frame = CGRect(x: (Margin * 2.0) + TextWidth,
                                  y: Margin,
                                  width: PercentWidth, height: PercentWidth)
        
        if ShowTaskPercentage
        {
            PercentView.frame = CGRect(x: (Margin * 2.0) + TextWidth,
                                       y: Margin,
                                       width: PercentWidth, height: PercentWidth)
            PercentView.isHidden = false
        }
        else
        {
            PercentView.isHidden = true
        }
        PercentView.Color = _TaskPercentColor
        PercentView.IncompleteColor = UIColor.clear
        
        if ShowIndefiniteIndicator
        {
            WaitingIndicator.frame = CGRect(x: (Margin * 2.0) + TextWidth,
            y: Margin,
            width: PercentWidth,
            height: PercentWidth)
            WaitingIndicator.startAnimating()
        }
        else
        {
            WaitingIndicator.stopAnimating()
        }
        
        if ShowBottomPercent
        {
            BottomPercent.Thickness = LinePercentThickness
            BottomPercent.frame = CGRect(x: 0, y: self.frame.height - LinePercentThickness,
                                         width: self.frame.width, height: LinePercentThickness)
            BottomPercent.isHidden = false
        }
        else
        {
            BottomPercent.isHidden = true
        }
        
        self.layer.sublayers?.forEach
            {
                if $0.name == "GradientBackground"
                {
                    $0.removeFromSuperlayer()
                }
        }
        self.layer.addSublayer(Colors.GetCompositeStatusGradient(Container: self.bounds))
    }
    
    // MARK: - Controlling functions.
    
    /// Add text to the text view. The old text is scrolled out of the view.
    /// - Parameter AddMe: The text to add. Text that is too long will be truncated.
    public func AddText(_ AddMe: String)
    {
        DispatchQueue.main.async
            {
                self.TextBox.ShowLabel(AddMe)
        }
    }
    
    /// Add text to the text view. The old text is scrolled out of the view.
    /// - Parameter AddMe: The text to add. Text that is too long will be truncated.
    /// - Parameter HideAfter: Number of seconds to wait until the text is scrolled clear of the box.
    public func AddText(_ AddMe: String, HideAfter Duration: Double)
    {
        DispatchQueue.main.async
            {
                self.TextBox.ShowLabel(AddMe, Hide: Duration)
        }
    }
    
    /// Animate the bottom percent to the passed value.
    /// - Parameter To: The new percentage. Value must be in the range 0.0 to 1.0. If not, control is returned
    ///                 immediately with no action taken.
    /// - Parameter Duration: Number of seconds for the animation.
    public func AnimatePercent(To: Double, Duration: Double)
    {
        if To < 0.0 || To > 1.0
        {
            return
        }
        BottomPercent.AnimateTo(To, WithDuration: Duration)
    }
    
    /// Show the settings button.
    public func ShowSettingsButton()
    {
        SettingsButton.isUserInteractionEnabled = true
        SettingsButton.alpha = 1.0
        SettingsButton.layer.zPosition = 1000
    }
    
    /// Hide the settings button.
    public func HideSettingsButton()
    {
        SettingsButton.isUserInteractionEnabled = false
        SettingsButton.alpha = 0.0
        SettingsButton.layer.zPosition = -1000
    }
    
    // MARK: - Controlling properties.
    
    /// Holds the current thickness of the overall task complete bar.
    private var _TotalPercentThickness: CGFloat = 10.0
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the thickness of the overall task complete bar.
    @IBInspectable public var TotalPercentThickness: CGFloat
        {
        get
        {
            return _TotalPercentThickness
        }
        set
        {
            _TotalPercentThickness = newValue
        }
    }
    
    /// Holds the show task percentage flag.
    private var _ShowTaskPercentage: Bool = true
    {
        didSet
        {
            Initialize()
            HideSettingsButton()
        }
    }
    /// Get or set the show task percentage flag.
    @IBInspectable public var ShowTaskPercentage: Bool
        {
        get
        {
            return _ShowTaskPercentage
        }
        set
        {
            _ShowTaskPercentage = newValue
        }
    }
    
    /// Holds the show indefinite indicator flag.
    private var _ShowIndefiniteIndicator: Bool = false
    {
        didSet
        {
            Initialize()
            HideSettingsButton()
        }
    }
    /// Get or set the show indefinite indicator flag.
    @IBInspectable public var ShowIndefiniteIndicator: Bool
    {
        get
        {
            return _ShowIndefiniteIndicator
        }
        set
        {
            _ShowIndefiniteIndicator = newValue
        }
    }
    
    /// Holds the color of the task percent indicator.
    private var _TaskPercentColor = UIColor.white
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the color of the task indicator.
    @IBInspectable public var TaskPercentColor: UIColor
    {
        get
        {
            return _TaskPercentColor
        }
        set
        {
            _TaskPercentColor = newValue
        }
    }
    
    /// Holds the show bottom, overall percentage flag.
    private var _ShowBottomPercent: Bool = true
    {
        didSet
        {
            Initialize()
        }
    }
    /// Get or set the show bottom, overall percentage flag.
    @IBInspectable public var ShowBottomPercent: Bool
        {
        get
        {
            return _ShowBottomPercent
        }
        set
        {
            _ShowBottomPercent = newValue
        }
    }
    
    // MARK: - Sub-properties for components.
    
    /// Get or set the task percent completed value. If nil returned, the control is not showing the task percent value.
    public var TaskPercentValue: Double?
    {
        get
        {
            if ShowTaskPercentage
            {
                return Double(PercentView.CurrentPercent)
            }
            else
            {
                return nil
            }
        }
        set
        {
            if let PercentValue = newValue
            {
                if ShowTaskPercentage
                {
                    PercentView.CurrentPercent = CGFloat(PercentValue)
                }
            }
        }
    }
    
    /// Get or set the total, overall completed value. If nil returned, the control is not showing the overall percent value.
    public var TotalPercentValue: Double?
    {
        get
        {
            if ShowBottomPercent
            {
                return BottomPercent.PercentValue
            }
            else
            {
                return nil
            }
        }
        set
        {
            if let PercentValue = newValue
            {
                if ShowBottomPercent
                {
                    BottomPercent.PercentValue = PercentValue
                }
            }
        }
    }
    
    // MARK: - UI elements of the class.
    
    private var PercentView: PiePercent!
    private var BottomPercent: LinearPercent!
    private var TextBox: FloatingText!
    private var WaitingIndicator: UIActivityIndicatorView!
    public var SettingsButton: UIButton!
}
