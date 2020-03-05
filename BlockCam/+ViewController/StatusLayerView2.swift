//
//  StatusLayerView2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a simple status view layer with a main label, percent complete indicator, and minor label.
/// - Note: All accesses to the user interface are done on the main, UI queue meaning background threads can call these functions
///         without worrying about which thread is which.
extension ViewController
{
    /// Initialize the status layer.
    func InitializeStatusLayer()
    {
        StatusLayer.backgroundColor = UIColor.clear
        HideStatusLayer()
        InitializeControls()
        StatusMainLabel.backgroundColor = UIColor.clear
    }
    
    /// Initialize controls and set up visuals.
    func InitializeControls()
    {
    }
    
    /// Hide the status layer.
    func HideStatusLayer()
    {
        OperationQueue.main.addOperation
            {
                if self.StatusLayer.alpha == 0.0
                {
                    return
                }
                self.view.sendSubviewToBack(self.StatusLayer)
                self.StatusLayer.alpha = 0.0
        }
    }
    
    /// Show the status layer.
    /// - Parameter Reset: If true, controls are reset to default states (meaning no text and percent of 0.0). Default value is true.
    func ShowStatusLayer(Reset: Bool = true)
    {
        OperationQueue.main.addOperation
            {
                if self.StatusLayer.alpha == 1.0
                {
                    return
                }
                self.view.bringSubviewToFront(self.StatusLayer)
                self.StatusLayer.alpha = 1.0
                if Reset
                {
                    self.StatusMainLabel.text = ""
                }
        }
    }
    
    /// Set the main message.
    /// - Note:
    ///   - If the layer is not visible, nothing will appear.
    ///   - If the main label was previously hidden, it will be shown here (by setting its alpha to 1.0).
    /// - Parameter Message: The text to display. This label is very large so short text is best.
    /// - Parameter TextColor: The color of the text. Defaults to UIColor.black.
    /// - Parameter StrokeColor: The color of the text stroke. Defaults to UIColor.white.
    func ShowMessage(_ Message: String, TextColor: UIColor = UIColor.black, StrokeColor: UIColor = UIColor.white)
    {
        OperationQueue.main.addOperation
            {
                self.StatusMainLabel.alpha = 1.0
                self.StatusMainLabel.attributedText = self.MakeAttributedText(Message: Message, TextColor: TextColor, StrokeColor: StrokeColor)
        }
    }
    
    /// Set the main message.
    /// - Note:
    ///   - If the layer is not visible, nothing will appear.
    ///   - If the main label was previously hidden, it will be shown here (by setting its alpha to 1.0).
    /// - Parameter Message: The text to display. This label is very large so short text is best.
    /// - Parameter TextColor: The color of the text. Defaults to UIColor.black.
    /// - Parameter StrokeColor: The color of the text stroke. Defaults to UIColor.white.
    /// - Parameter Duration: How long to show the message for.
    func ShowMessage(_ Message: String, TextColor: UIColor = UIColor.black, StrokeColor: UIColor = UIColor.white, Duration: Double)
    {
        OperationQueue.main.addOperation
            {
                self.StatusMainLabel.alpha = 1.0
                self.StatusMainLabel.attributedText = self.MakeAttributedText(Message: Message, TextColor: TextColor, StrokeColor: StrokeColor)
                UIView.animate(withDuration: 0.5, delay: Duration,
                               options: .curveEaseIn,
                               animations:
                    {
                        self.StatusMainLabel.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        self.StatusMainLabel.alpha = 0.0
                        self.HideStatusLayer()
                })
        }
    }
    
    /// Hide the main message by animating its alpha to 0.0.
    func HideMessage()
    {
            OperationQueue.main.addOperation
                {
                    UIView.animate(withDuration: 0.1, animations:
                        {
                            self.StatusMainLabel.alpha = 0.0
                    },
                                   completion:
                        {
                            _ in
                            self.StatusMainLabel.alpha = 0.0
                    }
                    )
            }
    }
    
    /// Create an attributed text string to display.
    /// - Parameter Message: The text to apply visual attributes to.
    /// - Parameter TextColor: The text foreground color. Defaults to black.
    /// - Parameter StrokeColor: The text stroke color. Defaults to white.
    /// - Returns: `NSAttributedString` with the passed `Message` value.
    private func MakeAttributedText(Message: String, TextColor: UIColor = UIColor.black,
                                    StrokeColor: UIColor = UIColor.white) -> NSAttributedString
    {
        let Font = UIFont.boldSystemFont(ofSize: 54.0)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: Font as Any,
                .foregroundColor: TextColor as Any,
                .strokeColor: StrokeColor as Any,
                .strokeWidth: -3 as Any
        ]
        return NSAttributedString(string: Message, attributes: Attributes)
    }
}
