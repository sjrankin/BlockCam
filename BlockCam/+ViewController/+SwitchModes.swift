//
//  +SwitchModes.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/11/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    // MARK: - Code to move buttons to relative locations in bottom tool bars.
    
    /// Creates a new CGRect to be used for a location for the passed button based on a horizontal location expressed in terms
    /// of percent from left to right.
    /// - Note: This function does *not* apply the new rectangle to the button - that is the responsibility of the caller.
    /// - Parameter Button: The button whose new frame rectangle will be created.
    /// - Parameter To: Determines how far from the left edge of the button's container to move the button. Value must be in normal
    ///                 form (eg, 0.0 to 1.0). Invalid values will cause nil to be returned.
    /// - Returns: Rectangle that can be used as the source of the button's frame property. Nil if `To` is invalid.
    func MoveButton(_ Button: UIButton, To Percent: CGFloat) -> CGRect?
    {
        if Percent < 0.0 || Percent > 1.0
        {
            Log.Message("Invalid location for button (\(Percent)) - must be in range 0.0 to 1.0")
            return nil
        }
        let ScreenWidth = self.view.bounds.width
        var X: CGFloat = 0.0
        if Percent == 0.0
        {
            X = 8.0
        }
        else
        {
            if Percent == 1.0
            {
                X = ScreenWidth - Button.frame.width - 8
            }
            else
            {
                X = (ScreenWidth * Percent) - (Button.frame.width / 2.0)
            }
        }
        let NewY = 35.0 - Button.frame.height / 2.0
        let NewRect = CGRect(x: X, y: NewY, width: Button.frame.width, height: Button.frame.height)
        return NewRect
    }
    
    // MARK: - Code for the initialization of bottom tool bars.
    
    /// Update the locations of the various UI elements depending on the safe area as represented by the
    /// passed Insets structure.
    func UpdateUIForInsets(_ Insets: UIEdgeInsets)
    {
        let ViewFrame = self.view.frame
        let FrameHeight = UIScreen.main.bounds.height - (Insets.bottom + Insets.top + 70)
        let Frame = CGRect(x: 0, y: Insets.top, width: ViewFrame.width, height: FrameHeight)
        LiveView.frame = Frame
        StatusLayer.frame = Frame
        OutputView.frame = Frame
        HistogramView.frame = CGRect(x: HistogramView.frame.minX,
                                     y: Insets.top,
                                     width: ViewFrame.width,
                                     height: 100.0)
        
        MainBottomBar.frame = CGRect(x: 0,
                                     y: Frame.maxY,
                                     width: self.view.frame.width,
                                     height: 70.0)
        
        ImageBottomBar.frame = CGRect(x: 0,
                                      y: Frame.maxY,
                                      width: self.view.frame.width,
                                      height: 70.0)
        
        SceneMotionRecorderView.frame = CGRect(x: 0,
                                               y: Frame.maxY,
                                               width: self.view.frame.width,
                                               height: 70.0)
        
    }
    
    /// Initialize the UI mode. Initial mode is for live view. Initializes button locations for all bottom tool bars.
    func InitializeModeUIs(With: UIEdgeInsets)
    {
        if With.bottom > 0.0 || With.top > 0.0
        {
            UpdateUIForInsets(With)
        }
        OutputView.scene?.background.contents = UIColor.black
        let ScreenHeight = self.view.bounds.height
        let ScreenWidth = self.view.bounds.width
        OutputView.alpha = 0.0
        LiveView.alpha = 1.0
        //Initialize the bottom tool bar.
        ImageBottomBar.frame = CGRect(x: 0,
                                      y: ScreenHeight,
                                      width: ScreenWidth,
                                      height: ImageBottomBar.frame.height)
        ImageBottomBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        ImageBottomBar.layer.cornerRadius = 5.0
        if let NewRect = MoveButton(CameraButton, To: 0.5)
        {
            CameraButton.frame = NewRect
        }
        if let NewRect = MoveButton(SwitchModeButton, To: 1.0)
        {
            SwitchModeButton.frame = NewRect
        }
        let SwitchLocation: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.28 : 0.25
        if let NewRect = MoveButton(SwitchCameraButton, To: SwitchLocation)
        {
            SwitchCameraButton.frame = NewRect
        }
        if let NewRect = MoveButton(SettingsButton, To: 0.0)
        {
            SettingsButton.frame = NewRect
        }
        
        //Initialize the bottom live view bar.
        //The location of the bottom live view bar is set in UpdateUIForInsets.
        MainBottomBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        MainBottomBar.layer.cornerRadius = 5.0
        if let NewRect = MoveButton(DoneButton, To: 0.0)
        {
            DoneButton.frame = NewRect
        }
        if let NewRect = MoveButton(SaveButton, To: 1.0)
        {
            SaveButton.frame = NewRect
        }
        let CompositeWidth = (SaveButton.frame.minX - DoneButton.frame.maxX) - 40.0
        CompositeStatus.frame = CGRect(x: DoneButton.frame.maxX + 20,
                                       y: 5.0,
                                       width: CompositeWidth,
                                       height: MainBottomBar.frame.height - 10.0)
        CompositeStatus.backgroundColor = UIColor.clear
        CompositeStatus.layer.borderWidth = 0.5
        CompositeStatus.layer.borderColor = UIColor.blue.cgColor
        CompositeStatus.layer.cornerRadius = 5.0
        CompositeStatus.ShowBottomPercent = true
        CompositeStatus.ShowTaskPercentage = true
        CompositeStatus.MainDelegate = self
        
        //Initialize the scene moview view.
        SceneMotionRecorderView.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: SceneMotionRecorderView.frame.height)
        SceneMotionRecorderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        SceneMotionRecorderView.layer.cornerRadius = 5.0
        if let NewRect = MoveButton(CloseSceneRecorderViewButton, To: 0.0)
        {
            CloseSceneRecorderViewButton.frame = NewRect
        }
        if let NewRect = MoveButton(SceneRecorderButton, To: 0.5)
        {
            SceneRecorderButton.frame = NewRect
        }
        if let NewRect = MoveButton(SceneRecordInfoButton, To: 1.0)
        {
            SceneRecordInfoButton.frame = NewRect
        }
        SceneMotionRecorderView.layer.addSublayer(Colors.GetSceneRecordGradient(Container: SceneMotionRecorderView.bounds))
    }
    
    // MARK: - Code for switching between live view and edit view.
    
    /// Switch to live view mode - the live view control is visible and assumed to be running.
    func SwitchToLiveViewMode()
    {
        LiveView.isUserInteractionEnabled = true
        GridView.isUserInteractionEnabled = false
        GridView.ShowGrid()
        let Insets = self.view.safeAreaInsets
        let FrameHeight = UIScreen.main.bounds.height - (Insets.bottom + Insets.top + 70)
        let Frame = CGRect(x: 0, y: Insets.top, width: self.view.frame.width, height: FrameHeight)
        if Settings.GetBoolean(ForKey: .ShowHistogram)
        {
            ShowHistogramView()
        }
        else
        {
            HideHistogramView()
        }
        InProcessView = false
        let ScreenHeight = self.view.bounds.height
        let ScreenWidth = self.view.bounds.width
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.OutputView.alpha = 0.0
                self.LiveView.alpha = 1.0
        }
        )
        UIView.animate(withDuration: 0.35,
                       animations:
            {
                if Insets.bottom > 0
                {
                    //Hide the image bar.
                    self.ImageBottomBar.frame = CGRect(x: ScreenWidth,
                                                       y: self.ImageBottomBar.frame.minY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                    self.ImageBottomBar.alpha = 0.0
                    //Show the main bar.
                    self.MainBottomBar.frame = CGRect(x: 0,
                                                      y: Frame.maxY,
                                                      width: ScreenWidth,
                                                      height: self.MainBottomBar.frame.height)
                    self.MainBottomBar.alpha = 1.0
                }
                else
                {
                    //Hide the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: ScreenHeight,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                    self.ImageBottomBar.alpha = 0.0
                    //Show the main bar.
                    self.MainBottomBar.frame = CGRect(x: 0,
                                                      y: Frame.maxY,
                                                      width: ScreenWidth,
                                                      height: self.MainBottomBar.frame.height)
                    self.MainBottomBar.alpha = 1.0
                }
        }
        )
        self.view.bringSubviewToFront(LiveView)
    }
    
    /// Switch to the 3D scene mode.
    func SwitchToImageMode()
    {
        GridView.HideGrid()
        let Insets = self.view.safeAreaInsets
        let FrameHeight = UIScreen.main.bounds.height - (Insets.bottom + Insets.top + 70)
        let Frame = CGRect(x: 0, y: Insets.top, width: self.view.frame.width, height: FrameHeight)
        HideHistogramView()
        InProcessView = true
        let ScreenHeight = self.view.bounds.height
        let ScreenWidth = self.view.bounds.width
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.OutputView.alpha = 1.0
                self.LiveView.alpha = 0.0
        }
        )
        UIView.animate(withDuration: 0.35,
                       animations:
            {
                if Insets.bottom > 0
                {
                    //Show the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: Frame.maxY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                    self.ImageBottomBar.alpha = 1.0
                    //Hide the main bar.
                    self.MainBottomBar.frame = CGRect(x: ScreenWidth,
                                                      y: self.MainBottomBar.frame.minY,
                                                      width: ScreenWidth,
                                                      height: self.MainBottomBar.frame.height)
                    self.MainBottomBar.alpha = 0.0
                }
                else
                {
                    //Show the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: Frame.maxY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                    self.ImageBottomBar.alpha = 1.0
                    //Hide the main bar.
                    self.MainBottomBar.frame = CGRect(x: 0,
                                                      y: ScreenHeight,
                                                      width: ScreenWidth,
                                                      height: self.MainBottomBar.frame.height)
                    self.MainBottomBar.alpha = 0.0
                }
        }
        )
        self.view.bringSubviewToFront(OutputView)
    }
    
    // MARK: - Code for displaying various bottom tool bars.
    
    /// Hide the image bottom tool bar. Show the record scene menu bar.
    func ShowRecordSceneBar()
    {
        GridView.HideGrid()
        let Insets = self.view.safeAreaInsets
        let FrameHeight = UIScreen.main.bounds.height - (Insets.bottom + Insets.top + 70)
        let Frame = CGRect(x: 0, y: Insets.top, width: self.view.frame.width, height: FrameHeight)
        let ScreenHeight = self.view.bounds.height
        let ScreenWidth = self.view.bounds.width
        SceneMotionRecorderView.layer.zPosition = 1000
        ImageBottomBar.layer.zPosition = 0
        UIView.animate(withDuration: 0.35,
                       animations:
            {
                if Insets.bottom > 0
                {
                    //Show the recorder bar.
                    self.SceneMotionRecorderView.frame = CGRect(x: 0,
                                                                y: Frame.maxY,
                                                                width: ScreenWidth,
                                                                height: self.SceneMotionRecorderView.frame.height)
                    //Hide the image bar.
                    self.ImageBottomBar.frame = CGRect(x: ScreenWidth,
                                                       y: self.ImageBottomBar.frame.minY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                }
                else
                {
                    //Show the recorder bar.
                    self.SceneMotionRecorderView.frame = CGRect(x: 0,
                                                                y: Frame.maxY,
                                                                width: ScreenWidth,
                                                                height: self.SceneMotionRecorderView.frame.height)
                    //Hide the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: ScreenHeight,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                }
        }
        )
    }
    
    /// Hide the record scene menu bar. Restore the normal image bottom tool bar.
    func HideRecordSceneBar()
    {
        let Insets = self.view.safeAreaInsets
        let FrameHeight = UIScreen.main.bounds.height - (Insets.bottom + Insets.top + 70)
        let Frame = CGRect(x: 0, y: Insets.top, width: self.view.frame.width, height: FrameHeight)
        let ScreenHeight = self.view.bounds.height
        let ScreenWidth = self.view.bounds.width
        SceneMotionRecorderView.layer.zPosition = 0
        ImageBottomBar.layer.zPosition = 1000
        UIView.animate(withDuration: 0.35,
                       animations:
            {
                if Insets.bottom > 0
                {
                    //Hide the recorder bar.
                    self.SceneMotionRecorderView.frame = CGRect(x: ScreenWidth,
                                                                y: self.SceneMotionRecorderView.frame.minY,
                                                                width: ScreenWidth,
                                                                height: self.SceneMotionRecorderView.frame.height)
                    //Show the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: Frame.maxY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                }
                else
                {
                    //Hide the recorder bar.
                    self.SceneMotionRecorderView.frame = CGRect(x: 0,
                                                                y: ScreenHeight,
                                                                width: ScreenWidth,
                                                                height: self.SceneMotionRecorderView.frame.height)
                    //Show the image bar.
                    self.ImageBottomBar.frame = CGRect(x: 0,
                                                       y: Frame.maxY,
                                                       width: ScreenWidth,
                                                       height: self.ImageBottomBar.frame.height)
                }
        }
        )
    }
    
    /// Switch to the photo picker/processor mode.
    func SwitchToPhotoPickerMode()
    {
        GridView.HideGrid()
        HideHistogramView()
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.OutputView.alpha = 1.0
                self.LiveView.alpha = 0.0
        }
        )
        self.view.bringSubviewToFront(OutputView)
    }
    
    /// Rotate a button to the specified angle.
    /// - Parameter Angle: The angle (in degrees) to rotate the button.
    /// - Parameter Button: The button to rotate.
    func RotateButtonTo(_ Angle: Double, Button: UIButton)
    {
        Button.transform = CGAffineTransform(rotationAngle: CGFloat(Angle) * CGFloat.pi / 180.0)
    }
    
    /// Update the rotational angle of all UI buttons.
    /// - Parameter NewAngle: The new angle to use to derive the new rotation of all buttons. Value
    ///                       is in degrees.
    func UpdateButtonAngle(_ NewAngle: Double)
    {
        RotateButtonTo(NewAngle, Button: SettingsButton)
        RotateButtonTo(NewAngle, Button: SceneRecordInfoButton)
        RotateButtonTo(NewAngle, Button: SceneRecorderButton)
        RotateButtonTo(NewAngle, Button: CloseSceneRecorderViewButton)
        RotateButtonTo(NewAngle, Button: SwitchCameraButton)
        RotateButtonTo(NewAngle, Button: SwitchModeButton)
        RotateButtonTo(NewAngle, Button: CameraButton)
        RotateButtonTo(NewAngle, Button: SwitchModeButton)
        RotateButtonTo(NewAngle, Button: CompositeStatus.SettingsButton)
        RotateButtonTo(NewAngle, Button: DoneButton)
        RotateButtonTo(NewAngle, Button: SaveButton)
    }
}
