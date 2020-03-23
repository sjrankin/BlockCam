//
//  MainTitle.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension ViewController
{
    func ShowMainTitle(Version: String, VersionBackground: UIColor, ShowDuration: Double,
                       Completed: ((Bool) -> ())? = nil)
    {
        TitleClosure = Completed
        let MainWidth = UIScreen.main.bounds.width
        let MainHeight = UIScreen.main.bounds.height
        let TitleViewWidth = MainWidth * 0.7
        let MainBoxHeight: CGFloat = 140.0
        let TitleBoxHeight: CGFloat = 30.0
        MainTitleView = UIView(frame: CGRect(x: (MainWidth / 2.0) - (TitleViewWidth / 2.0),
                                             y: MainHeight * 0.33,
                                             width: TitleViewWidth,
                                             height: MainBoxHeight))
        MainTitleView.isHidden = true
        MainTitleView.layer.borderColor = UIColor.red.cgColor
        MainTitleView.layer.borderWidth = 2.0
        MainTitleView.layer.cornerRadius = 5.0
        MainTitleView.backgroundColor = UIColor.black
        self.view.addSubview(MainTitleView)
        TitleImage = UIImageView(image: UIImage(named: "TitleImage"))
        TitleImage.backgroundColor = UIColor.black
        TitleImage.frame = CGRect(x: 10, y: 10,
                                  width: TitleViewWidth - 20,
                                  height: 72)
        TitleImage.contentMode = .scaleAspectFit
        MainTitleView.addSubview(TitleImage)
        TitleVersionBox = UIView(frame: CGRect(x: 10, y: MainBoxHeight - 40,
                                               width: TitleViewWidth - 20,
                                               height: TitleBoxHeight))
        TitleVersionBox.backgroundColor = VersionBackground
        TitleVersionBox.layer.borderWidth = 1.0
        TitleVersionBox.layer.cornerRadius = 5.0
        TitleVersionBox.layer.borderColor = UIColor.white.cgColor
        MainTitleView.addSubview(TitleVersionBox)
        TitleVersionLabel = UILabel(frame: CGRect(x: 10, y: 5,
                                                  width: TitleViewWidth - 20 - 20,
                                                  height: 20))
        TitleVersionLabel.textAlignment = .center
        TitleVersionLabel.backgroundColor = UIColor.clear
        TitleVersionLabel.textColor = UIColor.white
        TitleVersionLabel.text = Version
        TitleVersionBox.addSubview(TitleVersionLabel)
        MainTitleView.isHidden = false
        MainTitleView.isUserInteractionEnabled = true
        MainTitleView.layer.shadowColor = UIColor.black.cgColor
        MainTitleView.layer.shadowOpacity = 1.0
        MainTitleView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        MainTitleView.layer.shadowRadius = 10.0
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTitleTap))
        Tap.cancelsTouchesInView = false
        Tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(Tap)
        
        HideTitle(After: ShowDuration, HideDuration: 0.8, HideHow: .ZoomRight)
    }
    
    /// Handle taps from the title to dismiss it early.
    @objc func HandleTitleTap(Recognizer: UITapGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            ShowingTitle = false
            HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        }
    }
    
    /// Hide the main title.
    /// - Parameter After: How long to wait (in seconds) before hiding the title.
    /// - Parameter HideDuration: Length of time (in seconds) for the animation used to hide the title.
    /// - Parameter HideHow: Determines the method used to hide the title. Defaults to `.FadeOut`.
    /// - Parameter HideEarly: If true, the splash screen was hidden early.
    func HideTitle(After: Double, HideDuration: Double, HideHow: HideMethods = .FadeOut)
    {
        if !Settings.GetBoolean(ForKey: .ShowSplashScreen)
        {
            return
        }
        let ParentWidth = UIScreen.main.bounds.width
        switch HideHow
        {
            case .FadeOut:
                UIView.animate(withDuration: HideDuration, delay: After,
                               options: [.allowUserInteraction, .curveEaseIn], animations:
                    {
                        self.MainTitleView.alpha = 0.0
                }, completion:
                    {
                        _ in
                        self.MainTitleView.removeFromSuperview()
                        self.TitleClosure?(true)
                })
            
            case .ZoomRight:
                /*
                UIView.animate(withDuration: HideDuration, delay: After,
                               options: [.allowUserInteraction],
                               animations:
                    {
                        self.MainTitleView.frame = CGRect(x: ParentWidth + 40.0,
                                                          y: self.MainTitleView.frame.minY,
                                                          width: self.MainTitleView.frame.width,
                                                          height: self.MainTitleView.frame.height)
                        //self.MainTitleView.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        self.MainTitleView.removeFromSuperview()
                        self.MainTitleView = nil
                        self.TitleClosure?(true)
                })
 */
                
                UIView.animate(withDuration: HideDuration, delay: After,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 5,
                               options: [.allowUserInteraction, .curveEaseIn],
                               animations:
                    {
                        self.MainTitleView.frame = CGRect(x: ParentWidth + 40.0,
                                                          y: self.MainTitleView.frame.minY,
                                                          width: self.MainTitleView.frame.width,
                                                          height: self.MainTitleView.frame.height)
                        self.MainTitleView.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        self.MainTitleView.removeFromSuperview()
                        self.MainTitleView = nil
                        self.TitleClosure?(true)
                })

            
            case .ZoomLeft:
                UIView.animate(withDuration: HideDuration, delay: After,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 5,
                               options: [.allowUserInteraction, .curveEaseIn],
                               animations:
                    {
                        self.MainTitleView.frame = CGRect(x: -(self.MainTitleView.frame.width + 40.0),
                                                          y: self.MainTitleView.frame.minY,
                                                          width: self.MainTitleView.frame.width,
                                                          height: self.MainTitleView.frame.height)
                        self.MainTitleView.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        self.MainTitleView.removeFromSuperview()
                        self.MainTitleView = nil
                        self.TitleClosure?(true)
                })
            
            default:
                self.MainTitleView.isHidden = true
                self.MainTitleView = nil
                self.TitleClosure?(true)
        }
    }
}
