//
//  LiveViewFeedback.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    /// Show feedback on the live view to indicate where the user tapped to focus/set the exposure.
    /// - Parameter At: The point on the live view where the user tapped.
    func ShowLiveViewTapFeedback(At Point: CGPoint)
    {
        let TapRadius: CGFloat = 30.0
        let TapIndicator = CAShapeLayer()
        TapIndicator.name = "TapLayer"
        TapIndicator.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: TapRadius * 2.0, height: TapRadius * 2.0))
        TapIndicator.frame = CGRect(x: Point.x - TapRadius,
                                    y: Point.y - TapRadius,
                                    width: TapRadius * 2.0,
                                    height: TapRadius * 2.0)
        let Path = UIBezierPath(ovalIn: TapIndicator.bounds)
        TapIndicator.fillColor = UIColor.clear.cgColor
        TapIndicator.strokeColor = UIColor.systemYellow.cgColor
        TapIndicator.lineWidth = 5.0
        TapIndicator.path = Path.cgPath
        LiveView.layer.addSublayer(TapIndicator)
        let _ = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(RemoveTap),
                                     userInfo: ["IndicatorLayer": TapIndicator],
                                     repeats: false)
    }
    
    /// Remove the tap indicator from the live view.
    @objc func RemoveTap(timer: Timer)
    {
        let UserInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let LayerToRemove = UserInfo["IndicatorLayer"] as? CAShapeLayer
        if let RemoveMe = LayerToRemove
        {
            CATransaction.begin()
            let FadeAnimation = CABasicAnimation(keyPath: "strokeColor")
            FadeAnimation.duration = 0.5
            FadeAnimation.fromValue = UIColor.systemYellow.cgColor
            FadeAnimation.toValue = UIColor.clear.cgColor
            FadeAnimation.repeatCount = 0
            FadeAnimation.fillMode = .forwards
            FadeAnimation.isRemovedOnCompletion = false
            FadeAnimation.autoreverses = false
            CATransaction.setCompletionBlock
                {
                    [weak self] in
                    RemoveMe.removeFromSuperlayer()
            }
            RemoveMe.add(FadeAnimation, forKey: nil)
            CATransaction.commit()
        }
    }
}
