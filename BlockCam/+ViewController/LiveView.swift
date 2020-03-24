//
//  LiveView.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Accelerate
import CoreImage

extension ViewController
{
    /// Called every time a new live-view frame is available. The first few frames are always very dark until the camera figures
    /// out the proper exposure.
    /// - Note:
    ///    - The code to create 3D views is very slow compared to how quickly frames are made available. It is best to use
    ///      settings that don't strain things too much when using data from this function.
    ///    - `InitializeProcessedLiveView` must be called in order for this function to receive frames.
    ///    - Control returnes immediately if the user has disabled the histogram or the histogram display is not visible.
    ///    - To save battery power, the user may change how often the histogram is updated.
    /// - Parameter output: Not used.
    /// - Parameter didOutput: The frame from the live view.
    /// - Parameter from: Not used.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        FrameCount = FrameCount + 1
        if !DeviceHasCamera
        {
            print("Device has no camera")
            return
        }
        #if false
        if !HistogramIsVisible
        {
            return
        }
        if !Settings.GetBoolean(ForKey: .ShowHistogram)
        {
            return
        }
        #endif
        if !Settings.GetBoolean(ForKey: .ShowHUDHistogram)
        {
            return
        }
        if CurrentViewMode != .LiveView
        {
            return
        }
        if let RawSpeed = Settings.GetString(ForKey: .HistogramCreationSpeed)
        {
            if let Speed = HistogramCreationSpeeds(rawValue: RawSpeed)
            {
                if let FrameMultiplier = HistogramSpeedTable[Speed]
                {
                    if !FrameCount.isMultiple(of: FrameMultiplier)
                    {
                        print("Invalid frame multiplier")
                        return
                    }
                }
            }
        }
        if let Buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        {
            let CIImg: CIImage = CIImage(cvPixelBuffer: Buffer)
            let Image: UIImage? = CIImg.AsUIImage()
            if Image == nil
            {
                Log.Message("Nil image returned by UIImage.AsUIImage")
                return
            }
            DisplayHistogram(For: Image!)
            if Settings.GetBoolean(ForKey: .ShowMeanColor)
            {
            let (Red, Green, Blue, Alpha) = GetImageMean(CIImg)
                let FinalMean = UIColor(red: CGFloat(Red) / 255.0,
                                        green: CGFloat(Green) / 255.0,
                                        blue: CGFloat(Blue) / 255.0,
                                        alpha: CGFloat(Alpha) / 255.0)
                UpdateHUDView(.MeanColor, With: FinalMean as Any)
                var Hue: CGFloat = 0.0
                var Saturation: CGFloat = 0.0
                var Brightness: CGFloat = 0.0
                var HSBAlpha: CGFloat = 0.0
                FinalMean.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &HSBAlpha)
                if Settings.GetBoolean(ForKey: .ShowHue)
                {
                    UpdateHUDView(.Hue, With: Hue)
                }
                if Settings.GetBoolean(ForKey: .ShowSaturation)
                {
                    UpdateHUDView(.Saturation, With: Saturation)
                }
                if Settings.GetBoolean(ForKey: .ShowLightMeter)
                {
                    UpdateHUDView(.Brightness, With: Brightness)
                }
            }
        }
    }

    /// Returns the mean color of the passed image.
    /// - Note:
    ///   - Uses CIAreaAverage to get the mean color.
    ///   - See [How to read the average color of a UIImage](https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage)
    /// - Parameter Image: The image whose mean color will be returned.
    /// - Returns: Tupel with unnormalized channel data in red, green, blue, alpha order.
    func GetImageMean(_ Image: CIImage) -> (UInt8, UInt8, UInt8, UInt8)
    {
        let Extent = Image.extent
        let FullImage = CIVector(x: Extent.origin.x, y: Extent.origin.y,
                                 z: Extent.size.width, w: Extent.size.height)
        let Filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: Image, kCIInputExtentKey: FullImage])
        let Output = Filter?.outputImage!
        var Bitmap = [UInt8](repeating: 0, count: 4)
        let Context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        Context.render(Output!, toBitmap: &Bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8, colorSpace: nil)
        return (Bitmap[0], Bitmap[1], Bitmap[2], Bitmap[3])
    }
    
    /// Called when AVFoundation has an image for use (most likely due to the user pressing the camera button).
    /// - Parameter output: Not used.
    /// - Parameter didFinishProcessingPhoto: The image from the live view.
    /// - Parameter error: If present, an error.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let error = error
        {
            Log.Message("Error capturing image: \(error.localizedDescription)")
            return
        }
        guard let ImageData = photo.fileDataRepresentation() else
        {
            Log.Message("Error getting file representation of image.")
            return
        }
        let SavedImage = UIImage(data: ImageData)
        
        if Settings.GetString(ForKey: .SaveOriginalImageAction) == SaveOriginalImageActions.Always.rawValue
        {
            if let SaveMe = SavedImage
            {
                SavingOriginalImage = true
                UIImageWriteToSavedPhotosAlbum(SaveMe, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        ImageToProcess = SavedImage
        OutputView.Clear()
        #if true
        ProcessImageWrapper(SavedImage!)
        #else
        BackgroundThread.async
            {
                self.OutputView.ProcessImage(SavedImage!, CalledFrom: "photoOutput")
        }
        #endif
    }
    
    /// Delegate handler for saving an image. Called by the PhotoKit API.
    /// - Note: The "Image saved OK" message does not appear when saving the original image from pressing the camera button.
    /// - Parameter image: The image that was saved.
    /// - Parameter didFinishSavingWithError: Error message if appropriate.
    /// - Parameter contextInfo: Not used.
    @objc public func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let SomeError = error
        {
            Log.Message("Error from saving image: \(SomeError)")
        }
        else
        {
            if !SavingOriginalImage
            {
                CompositeStatus.AddText("Image saved OK", HideAfter: 5.0)
            }
            SavingOriginalImage = false
        }
    }
    
    /// Set up the live view.
    func SetupLiveView()
    {
        CaptureSession.beginConfiguration()
        VideoPreviewLayer = AVCaptureVideoPreviewLayer(session: CaptureSession)
        VideoPreviewLayer.videoGravity = .resizeAspect
        VideoPreviewLayer.connection?.videoOrientation = .portrait
        CaptureSession.commitConfiguration()
        LiveView.layer.addSublayer(VideoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async
            {
                [weak self] in
                self!.CaptureSession.startRunning()
                DispatchQueue.main.async
                    {
                        self!.VideoPreviewLayer.frame = self!.LiveView.bounds
                        let VideoPreviewLayerFrame = self!.VideoPreviewLayer.frame
                        self!.PreviewSize = CGSize(width: VideoPreviewLayerFrame.height * 0.75,
                                                   height: VideoPreviewLayerFrame.height)
                        let HOffset = (VideoPreviewLayerFrame.width - self!.PreviewSize.width) / 2.0
                        let VOffset = (VideoPreviewLayerFrame.height - self!.PreviewSize.height) / 2.0
                        self!.GridView.SetPreviewOffsets(LeftOffset: HOffset, RightOffset: HOffset,
                                                         TopOffset: VOffset, BottomOffset: VOffset)
                }
        }
    }
    
    /// Initialize the live view.
    /// - Parameter UseBackCamera: If true, the back camera is used. If false, the front (selfie) camera is used.
    func InitializeLiveView(UseBackCamera: Bool = true)
    {
        CaptureSession = AVCaptureSession()
        CameraHasDepth = SupportsDepthData()
        print("Camera supports depth data: \(CameraHasDepth)")
        CaptureSession.sessionPreset = .photo
        let PreferredPosition: AVCaptureDevice.Position!
        PreferredPosition = UseBackCamera ? .back : .front
        let PreferredDevice: AVCaptureDevice.DeviceType!
        PreferredDevice = UseBackCamera ? .builtInDualCamera : .builtInTrueDepthCamera
        let Devices = self.VideoDeviceDiscoverySession.devices
        CaptureDevice = nil
        if let Device = Devices.first(where: {$0.position == PreferredPosition && $0.deviceType == PreferredDevice})
        {
            CaptureDevice = Device
        }
        else
            if let Device = Devices.first(where: {$0.position == PreferredPosition})
            {
                CaptureDevice = Device
        }
        
        DeviceHasCamera = true
        guard let InputCamera = CaptureDevice else
        {
            DeviceHasCamera = false 
            Log.Message("Unable to access input camera.")
            return
        }
        do
        {
            let Input = try AVCaptureDeviceInput(device: InputCamera)
            StillImageOutput = AVCapturePhotoOutput()
            if CaptureSession.canAddInput(Input) && CaptureSession.canAddOutput(StillImageOutput)
            {
                CaptureSession.addInput(Input)
                CaptureSession.addOutput(StillImageOutput)
                SetupLiveView()
            }
        }
        catch
        {
            Log.Message("Input camera initialization error: \(error.localizedDescription)")
        }
    }
    
    /// Initialize AVFoundation such that it provides frames for what it sees - in other words, every frame displayed to the user
    /// is sent to us as well. This is necessary for histogram functions and for the processed live view.
    /// - Note: The frame does not have to be shown to the user, which is how the processed live view works.
    func InitializeProcessedLiveView()
    {
        if !DeviceHasCamera
        {
            return
        }
        let VideoOut = AVCaptureVideoDataOutput()
        VideoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        VideoOut.alwaysDiscardsLateVideoFrames = true
        VideoOut.setSampleBufferDelegate(self, queue: VOQueue)
        guard CaptureSession.canAddOutput(VideoOut) else
        {
            Log.Message("Error adding video output to capture session.")
            return
        }
        CaptureSession.addOutput(VideoOut)
        VideoConnection = VideoOut.connection(with: .video)
        ProcessedViewInitialized = true
    }
}
