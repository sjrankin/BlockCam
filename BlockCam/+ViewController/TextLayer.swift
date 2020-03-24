//
//  TextLayer.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    func InitializeTextLayer()
    {
        TextPleaseWait.isHidden = true
        TextPleaseWait.alpha = 0.0
        TextPleaseWait.backgroundColor = UIColor.clear
        TextTooLong.isHidden = true
        TextTooLong.alpha = 0.0
        TextTooLong.backgroundColor = UIColor.white
        TextTooLong.layer.borderWidth = 1.5
        TextTooLong.layer.borderColor = UIColor.red.cgColor
        TextTooLong.layer.cornerRadius = 5.0
        TextTooLong.isHidden = true
    }
    
    func ShowTextLayerMessage(_ Message: TextLayerMessages,
                              FillColor: UIColor = UIColor.systemYellow,
                              StrokeColor: UIColor = UIColor.systemRed)
    {
        TextLayerView.layer.zPosition = 10000
        switch Message
        {
            case .PleaseWait:
                let Text = MakeAttributedText(Message: "Please Wait",
                                              TextColor: UIColor.white,
                                              StrokeColor: UIColor.systemBlue,
                                              StrokeWidth: -2,
                                              FontSize: 52.0)
                TextPleaseWait.attributedText = Text
                TextPleaseWait.isHidden = false
                TextPleaseWait.layer.zPosition = 1000
                UIView.animate(withDuration: 0.1)
                {
                    self.TextPleaseWait.alpha = 1.0
            }
            
            case .TooLong:
                let Text = MakeAttributedText(Message: "This is taking longer than expected.",
                                              TextColor: UIColor.black,
                                              StrokeColor: UIColor.black,
                                              StrokeWidth: 0,
                                              FontSize: 20.0)
                TextTooLong.attributedText = Text
                TextTooLong.isHidden = false
                UIView.animate(withDuration: 0.1)
                {
                    self.TextTooLong.alpha = 1.0
            }
        }
    }
    
    func HideTextLayerMessage(_ Message: TextLayerMessages)
    {
       switch Message
       {
        case .PleaseWait:
            if TextPleaseWait.isHidden
            {
                return
            }
            UIView.animate(withDuration: 0.2,
                           animations:
                {
                    self.TextPleaseWait.alpha = 0.0
            },
                           completion:
                {
                    _ in
                    self.TextPleaseWait.isHidden = true
            })
        
        case .TooLong:
            if TextTooLong.isHidden
            {
                return
            }
            UIView.animate(withDuration: 0.2,
                           animations:
                {
                    self.TextTooLong.alpha = 0.0
            },
                           completion:
                {
                    _ in
                    self.TextTooLong.isHidden = true
            })
        }
    }
    
    /// Create an attributed text string to display.
    /// - Parameter Message: The text to apply visual attributes to.
    /// - Parameter TextColor: The text foreground color. Defaults to black.
    /// - Parameter StrokeColor: The text stroke color. Defaults to white.
    /// - Parameter StrokeWidth: The width of the stroke. Defaults to -3. (Stroke widths are negative.)
    /// - Parameter FontSize: The size of the font. Defaults to 54.0
    /// - Returns: `NSAttributedString` with the passed `Message` value.
    private func MakeAttributedText(Message: String, TextColor: UIColor = UIColor.black,
                                    StrokeColor: UIColor = UIColor.white,
                                    StrokeWidth: Int = -3,
                                    FontSize: CGFloat = 54.0) -> NSAttributedString
    {
        let Font = UIFont.boldSystemFont(ofSize: FontSize)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: Font as Any,
                .foregroundColor: TextColor as Any,
                .strokeColor: StrokeColor as Any,
                .strokeWidth: StrokeWidth as Any
        ]
        return NSAttributedString(string: Message, attributes: Attributes)
    }
}

enum TextLayerMessages: String, CaseIterable
{
    case PleaseWait = "PleaseWait"
    case TooLong = "TooLong"
}
