//
//  MainProtocolFunctions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

extension ViewController: MainProtocol
{
    /// Update the status on the status layer.
    /// - Paremeter Percent: The percent complete value.
    /// - Parameter Color: Color of the percent complete indicator.
    /// - Parameter Message: Text for the action message.
    func Status(_ Percent: Double, _ Color: UIColor, _ Message: String)
    {
        ShowStatusLayer()
        DispatchQueue.main.async
            {
                self.CompositeStatus.AddText(Message)
                self.CompositeStatus.TotalPercentValue = Percent
        }
    }
    
    /// Show a status sub-percent value.
    /// - Parameter SubPercent: The sub-percent value to show.
    /// - Parameter Color: The color of the indicator.
    func SubStatus(_ SubPercent: Double, _ Color: UIColor)
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.TaskPercentColor = Color
                self.CompositeStatus.ShowTaskPercentage = true
                self.CompositeStatus.TaskPercentValue = SubPercent
        }
    }
    
    /// Call to show the indefinite indicator.
    func ShowIndefiniteIndicator()
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.ShowIndefiniteIndicator = true
        }
    }
    
    /// Hides the indefinite indicator.
    func HideIndefiniteIndicator()
    {
        DispatchQueue.main.async
            {
                self.CompositeStatus.ShowIndefiniteIndicator = false
        }
    }
    
    /// Handle completed events.
    /// - Parameter Success: The event successfully completed flag.
    func Completed(_ Success: Bool)
    {
        DispatchQueue.main.async
            {
                let RandomDuration = Utilities.GetMeanRandomCharacterDurations()
                if RandomDuration > 0
                {
                    print("Mean random character generation duration: \(RandomDuration), Cache count: \(Utilities.CharSetCache.count)")
                }
                self.HideStatusLayer()
                self.CompositeStatus.AnimatePercent(To: 0.0, Duration: 1.0)
                self.CompositeStatus.TaskPercentValue = 0.0
                #if false
                if Settings.GetBoolean(ForKey: .ShowHistogram)
                {
                    if Settings.GetBoolean(ForKey: .ShowProcessedHistogram)
                    {
                        self.DisplayHistogram(For: self.OutputView.snapshot())
                    }
                }
                #endif
                if self.InitialProcessedImage
                {
                    self.InitialProcessedImage = false
                    if Settings.GetBoolean(ForKey: .AutoSaveProcessedImage)
                    {
                        let SourceSize = "\(Generator.OriginalImageSize)"
                        let ReducedSize = "\(Generator.ReducedImageSize)"
                        let UserData = CurrentSettings.KVPs(AppendWith: [("Original size", SourceSize), ("Reduced size", ReducedSize)])
                        FileIO.SaveImageWithMetaData(self.OutputView.snapshot(), KeyValueString: UserData, SaveInCameraRoll: true)
                        {
                            Successful in
                            if Successful
                            {
                                self.CompositeStatus.AddText("Image automatically saved.", HideAfter: 5.0)
                            }
                        }
                    }
                }
                self.CompositeStatus.ShowSettingsButton()
        }
    }
    
    /// Return the main view.
    func MainView() -> UIView
    {
        return self.view
    }
    
    /// Returns the source of the processed image, if it exists.
    /// - Returns: Source image for processing. Nil if no image is available.
    func GetSourceImage() -> UIImage?
    {
        return ImageToProcess
    }
    
    /// Shows the processed image context menu.
    /// - Parameter From: The source object the menu will point to.
    func ShowProcessedImageMenu(From SourceObject: UIView)
    {
        ShowProcessedViewMenu(From: SourceObject)
    }
    
    /// Returns the current program mode.
    /// - Returns: Returns the current program mode.
    func GetCurrentMode() -> ProgramModes
    {
        return CurrentViewMode
    }
    
    /// Run the shape menu.
    /// - Parameter SourceView: The UI element that servers as the source.
    /// - Parameter ShapeList: List of shapes to display.
    /// - Parameter Selected: The Currently selected shape (nil if none).
    /// - Parameter MenuDelegate: The delegate that receives menu commands.
    /// - Parameter WindowDelegate: The delegate responsible to act as the window for the popover.
    /// - Parameter WindowActual: The view controller that will present the menu.
    func RunShapeMenu(SourceView: UIView, ShapeList: [NodeShapes], Selected: NodeShapes?,
                      MenuDelegate: ContextMenuProtocol,
                      WindowDelegate: UIPopoverPresentationControllerDelegate,
                      WindowActual: UIViewController)
    {
        ShowShapeSelectionMenu(From: SourceView, ShapeList: ShapeList, Selected: Selected,
                               MenuDelegate: MenuDelegate, WindowDelegate: WindowDelegate,
                               WindowActual: WindowActual)
    }
    
    /// Run the shape menu.
    /// - Parameter SourceView: The UI element that servers as the source.
    /// - Parameter ShapeGroup: Grouped shape list.
    /// - Parameter Selected: The Currently selected shape (nil if none).
    /// - Parameter MenuDelegate: The delegate that receives menu commands.
    /// - Parameter WindowDelegate: The delegate responsible to act as the window for the popover.
    /// - Parameter WindowActual: The view controller that will present the menu.
    func RunShapeMenu(SourceView: UIView, ShapeGroup: [(GroupName: String, GroupShapes: [NodeShapes])],
                      Selected: NodeShapes?, MenuDelegate: ContextMenuProtocol,
                      WindowDelegate: UIPopoverPresentationControllerDelegate,
                      WindowActual: UIViewController)
    {
        ShowShapeSelectionMenu(From: SourceView, ShapeList: ShapeGroup, Selected: Selected,
                               MenuDelegate: MenuDelegate, WindowDelegate: WindowDelegate,
                               WindowActual: WindowActual)
    }
    
    /// Displays the histogram for the passed image. If the histogram is not visible, no action is taken.
    /// - Parameter For: The image whose histogram will be calculated and displayed.
    func DisplayHistogram(For Image: UIImage)
    {
        #if false
        if !HistogramIsVisible
        {
            return
        }
        #endif
        let CImage: CGImage = Image.cgImage!
        let ImageFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                               bitsPerPixel: 32,
                                               colorSpace: CGColorSpaceCreateDeviceRGB(),
                                               bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                               renderingIntent: .defaultIntent)!
        guard var SourceBuffer = try? vImage_Buffer(cgImage: CImage,
                                                    format: ImageFormat) else
        {
            Log.Message("Error creating vImage_Buffer")
            return
        }
        defer {SourceBuffer.free()}
        
        let Alpha = [UInt](repeating: 0, count: 256)
        let Red = [UInt](repeating: 0, count: 256)
        let Green = [UInt](repeating: 0, count: 256)
        let Blue = [UInt](repeating: 0, count: 256)
        let AlphaPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Alpha) as UnsafeMutablePointer<vImagePixelCount>?
        let RedPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Red) as UnsafeMutablePointer<vImagePixelCount>?
        let GreenPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Green) as UnsafeMutablePointer<vImagePixelCount>?
        let BluePtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Blue) as UnsafeMutablePointer<vImagePixelCount>?
        let ARGB = [AlphaPtr, RedPtr, GreenPtr, BluePtr]
        let Histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>?>(mutating: ARGB)
        let error = vImageHistogramCalculation_ARGB8888(&SourceBuffer, Histogram, UInt32(kvImageNoFlags))
        if error != kvImageNoError
        {
            Log.Message("Histogram error: \(error). Unable to display histogram.")
        }
        else
        {
            let MaxValue = max(max(Int(Red.max()!), Int(Green.max()!)), Int(Blue.max()!))
            HistogramView.ShowHistogram((Red, Green, Blue), UInt(MaxValue))
        }
    }
}
