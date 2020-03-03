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
    /// Show the main title/splash screen.
    /// - Parameter Name: The name of the application to display.
    /// - Parameter Version: The version string to display.
    /// - Parameter VersionBackground: The color to use for the version string background.
    /// - Parameter AnimateTime: How long to run main title animation.
    /// - Parameter ShowDuration: How long to show the main title before dismissing it.
    /// - Parameter Completed: Completion closure. The boolean value indicates whether the splash screen was actually
    ///                        shown or not.
    func ShowMainTitle(_ Name: String, Version: String, VersionBackground: UIColor, AnimateTime: Double, ShowDuration: Double,
                       Completed: ((Bool) -> ())? = nil)
    {
        if !Settings.GetBoolean(ForKey: .ShowSplashScreen)
        {
            Completed?(false)
            return
        }
        TitleClosure = Completed
        let TitleView = MakeTitle(Name, Version: Version, AnimateTime: AnimateTime, VersionBackground: VersionBackground)
        #if true
        self.view.addSubview(TitleView)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTitleTap))
        Tap.cancelsTouchesInView = false
        Tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(Tap)
        #else
        Wrapper = UIView(frame: CGRect(origin: CGPoint.zero, size:
            CGSize(width: TitleView.frame.width, height: TitleView.frame.height)))
        Wrapper.backgroundColor = UIColor.black
        #if true
        Wrapper.layer.shadowColor = UIColor.black.cgColor
        Wrapper.layer.shadowOpacity = 1.0
        Wrapper.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        Wrapper.layer.shadowRadius = 10.0
        #endif
        Wrapper.addSubview(TitleView)
        self.view.addSubview(Wrapper)
        Wrapper.isUserInteractionEnabled = true
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTitleTap))
        Tap.cancelsTouchesInView = false
        Tap.numberOfTapsRequired = 1
        Wrapper.addGestureRecognizer(Tap)
        self.view.addGestureRecognizer(Tap)
        #endif
        HideTitle(After: ShowDuration, HideDuration: 0.8, HideHow: .ZoomRight)
        TitleBox.alpha = 1.0
    }
    
    /// Make the actual title here.
    /// - Notes:
    ///   - The title text is displayed as extruded 3D text that has the extrusion changed over time.
    ///   - See [Center SCNText in SceneKit](https://stackoverflow.com/questions/45168896/scenekit-scntext-centering-incorrectly)
    /// - Parameter Title: The title string to display.
    /// - Parameter Version: The version string to display.
    /// - Parameter AnimateTime: The amount of time to animte the title text. Animation occurs once.
    /// - Parameter VersionBackground: The background color for the version text.
    func MakeTitle(_ Title: String, Version: String, AnimateTime: Double, VersionBackground: UIColor) -> SCNView
    {
        ParentWidth = view.frame.width
        ParentHeight = view.frame.height
        let TitleWidth = ParentWidth * 0.80
        let TitleHeight = ParentHeight * 0.2
        TitleCenter = CGPoint(x: TitleWidth / 2,
                              y: ParentHeight * 0.33 - (TitleHeight / 2))
        TitleBox = SCNView(frame: CGRect(x: (ParentWidth / 2) - (TitleWidth / 2),
                                         y: ParentHeight * 0.33,
                                         width: TitleWidth,
                                         height: TitleHeight))
        TitleBox.isUserInteractionEnabled = true
        TitleBox.layer.borderWidth = 5.0
        TitleBox.layer.borderColor = UIColor.systemPink.cgColor
        TitleBox.layer.cornerRadius = 10.0
        TitleBox.layer.zPosition = 100000
        TitleBox.clipsToBounds = true
        
        TitleBox.scene = SCNScene()
        TitleBox.scene?.background.contents = UIColor.black
        
        let TitleCamera = SCNCamera()
        TitleCamera.fieldOfView = 90.0
        let CameraNode = SCNNode()
        CameraNode.camera = TitleCamera
        CameraNode.position = SCNVector3(0.0, 0.0, 10.0)
        TitleBox.scene?.rootNode.addChildNode(CameraNode)
        let TitleLight = SCNLight()
        TitleLight.type = .omni
        TitleLight.color = UIColor.white
        TitleLight.castsShadow = true
        TitleLight.shadowColor = UIColor.black.withAlphaComponent(0.8)
        TitleLight.shadowRadius = 10.0
        TitleLight.shadowMode = .forward
        let LightNode = SCNNode()
        LightNode.light = TitleLight
        LightNode.position = SCNVector3(-2.0, 2.0, 10.0)
        TitleBox.scene?.rootNode.addChildNode(LightNode)
        
        let TextNode = SCNText(string: Title, extrusionDepth: 2.0)
        TextNode.flatness = 0.0
        TextNode.font = UIFont.boldSystemFont(ofSize: 18.0)
        TextNode.firstMaterial?.specular.contents = UIColor.white
        TextNode.firstMaterial?.diffuse.contents = UIColor.systemYellow
        TextNode.firstMaterial?.lightingModel = .blinn
        TitleNode = SCNNode(geometry: TextNode)
        TitleNode?.castsShadow = true
        let (MinTextBox, MaxTextBox) = TitleNode!.boundingBox
        let TextWidth = MaxTextBox.x - MinTextBox.x
        TitleNode?.position = SCNVector3(0.0, 0.0, 0.0)
        TitleNode?.pivot = SCNMatrix4MakeTranslation(TextWidth / 2, 0, 0)
        TitleNode?.scale = SCNVector3(0.4, 0.4, 0.4)
        TitleBox.scene?.rootNode.addChildNode(TitleNode!)
        
        let ExAnim = CABasicAnimation(keyPath: "geometry.extrusionDepth")
        ExAnim.isRemovedOnCompletion = false
        ExAnim.fillMode = .forwards
        ExAnim.fromValue = 2.0
        ExAnim.toValue = 0.0
        ExAnim.duration = AnimateTime
        ExAnim.autoreverses = false
        ExAnim.repeatCount = 0
        TitleNode?.addAnimation(ExAnim, forKey: "extrude")
        
        let VerWidth = TitleWidth * 0.8
        let VerHeight: CGFloat = 30.0
        let VerBlock = UIView(frame: CGRect(x: (TitleWidth / 2) - (VerWidth / 2),
                                            y: TitleHeight * 0.6,
                                            width: VerWidth,
                                            height: VerHeight))
        VerBlock.layer.borderColor = UIColor.white.cgColor
        VerBlock.layer.borderWidth = 1.0
        VerBlock.layer.cornerRadius = 5.0
        VerBlock.backgroundColor = VersionBackground
        TitleBox.addSubview(VerBlock)
        let VerLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: VerWidth, height: VerHeight)))
        VerLabel.text = Version
        VerLabel.textAlignment = .center
        VerLabel.textColor = UIColor.white
        VerLabel.font = UIFont.systemFont(ofSize: 17.0)
        VerBlock.addSubview(VerLabel)
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTitleTap))
        Tap.numberOfTapsRequired = 1
        TitleBox.addGestureRecognizer(Tap)
        
        return TitleBox
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
        switch HideHow
        {
            case .FadeOut:
                UIView.animate(withDuration: HideDuration, delay: After,
                               options: [.allowUserInteraction, .curveEaseIn], animations:
                    {
                        self.TitleBox.alpha = 0.0
                }, completion:
                    {
                        _ in
                        if self.Wrapper != nil
                        {
                            self.Wrapper.layer.removeAllAnimations()
                            self.Wrapper.removeFromSuperview()
                            self.Wrapper = nil
                            self.TitleClosure?(true)
                            self.TitleBox.removeFromSuperview()
                            self.TitleBox = nil
                        }
                })
            
            case .ZoomLeft:
                UIView.animate(withDuration: HideDuration, delay: After,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 5,
                               options: [.allowUserInteraction, .curveEaseIn],
                               animations:
                    {
                        self.TitleBox.frame = CGRect(x: 0.0 - (self.TitleBox.frame.width + 40.0),
                                                     y: self.TitleBox.frame.minY,
                                                     width: self.TitleBox.frame.width,
                                                     height: self.TitleBox.frame.height)
                        self.TitleBox.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        if self.Wrapper != nil
                        {
                            self.Wrapper.layer.removeAllAnimations()
                            self.Wrapper.removeFromSuperview()
                            self.Wrapper = nil
                            self.TitleClosure?(true)
                            self.TitleBox.removeFromSuperview()
                            self.TitleBox = nil
                        }
                })
            
            case .ZoomRight:
                UIView.animate(withDuration: HideDuration, delay: After,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 5,
                               options: [.allowUserInteraction, .curveEaseIn],
                               animations:
                    {
                        self.TitleBox.frame = CGRect(x: self.ParentWidth + 40.0,
                                                     y: self.TitleBox.frame.minY,
                                                     width: self.TitleBox.frame.width,
                                                     height: self.TitleBox.frame.height)
                        self.TitleBox.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        if self.Wrapper != nil
                        {
                            self.Wrapper.layer.removeAllAnimations()
                            self.Wrapper.removeFromSuperview()
                            self.Wrapper = nil
                            self.TitleClosure?(true)
                            self.TitleBox.removeFromSuperview()
                            self.TitleBox = nil
                        }
                })
            
            case .ZoomUp:
                UIView.animate(withDuration: HideDuration, delay: After,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 5,
                               options: [.allowUserInteraction, .curveEaseIn],
                               animations:
                    {
                        self.TitleBox.frame = CGRect(x: self.TitleBox.frame.minX,
                                                     y: 0.0 - (self.TitleBox.frame.height + 50.0),
                                                     width: self.TitleBox.frame.width,
                                                     height: self.TitleBox.frame.height)
                        self.TitleBox.alpha = 0.0
                },
                               completion:
                    {
                        _ in
                        if self.Wrapper != nil
                        {
                            self.Wrapper.layer.removeAllAnimations()
                            self.Wrapper.removeFromSuperview()
                            self.Wrapper = nil
                            self.TitleClosure?(true)
                            self.TitleBox.removeFromSuperview()
                            self.TitleBox = nil
                        }
                })
        }
    }
}
