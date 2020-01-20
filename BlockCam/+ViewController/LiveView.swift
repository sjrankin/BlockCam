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

extension ViewController
{
    /// Called every time a new live-view frame is available. The first few frames are always very dark until the camera figures
    /// out the proper exposure.
    /// - Note:
    ///    - The code in this delegate function is not used unless `CurrentViewMode` is `.ProcessedView`.
    ///    - The code to create 3D views is very slow compared to how quickly frames are made available. It is best to use
    ///      settings that don't strain things too much when using data from this function.
    ///    - This function assumes the live view is not visible but the 3D view is.
    ///    - `InitializeProcessedLiveView` must be called in order for this function to receive frames.
    /// - Parameter output: Not used.
    /// - Parameter didOutput: The frame from the live view.
    /// - Parameter from: Not used.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        if let Buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        {
            let CIImg: CIImage = CIImage(cvPixelBuffer: Buffer)
            //let Image: UIImage = ConvertToUIImage(CIImg)
            let Image: UIImage = CIImg.AsUIImage()
            FrameCount = FrameCount + 1
            /*
             if UserDefaults.standard.bool(forKey: "ShowHistogram")
             {
             #if true
             let Histo = Histogram()
             if let HImage = Histo.Generate(Image)
             {
             OperationQueue.main.addOperation
             {
             self.HistogramView.layer.sublayers?.removeAll()
             let HLayer = CALayer()
             HLayer.frame = self.HistogramView.frame
             HLayer.contents = HImage
             self.HistogramView.layer.addSublayer(HLayer)
             }
             }
             #else
             let Histo = Histogram(Image)
             OperationQueue.main.addOperation
             {
             self.PopulateHistogram(Histo, InView: self.HistogramView)
             }
             #endif
             }
             */
            if CurrentViewMode == .ProcessedView
            {
                BackgroundThread.async
                    {
                        [weak self] in
                        self!.OutputView.Clear()
                        self!.OutputView.ProcessImage(Image, BlockSize: 32.0)
                }
            }
        }
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
        ShowStatusLayer()
        ShowMessage("Please Wait", TextColor: UIColor.systemYellow, StrokeColor: UIColor.white)
        BackgroundThread.async
            {
                self.OutputView.ProcessImage(SavedImage!)
        }
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
        VideoPreviewLayer = AVCaptureVideoPreviewLayer(session: CaptureSession)
        VideoPreviewLayer.videoGravity = .resizeAspect
        VideoPreviewLayer.connection?.videoOrientation = .portrait
        LiveView.layer.addSublayer(VideoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async
            {
                [weak self] in
                self!.CaptureSession.startRunning()
                DispatchQueue.main.async
                    {
                        self!.VideoPreviewLayer.frame = self!.LiveView.bounds
                }
        }
    }
    
    /// Initialize the live view.
    /// - Parameter UseBackCamera: If true, the back camera is used. If false, the front (selfie) camera is used.
    func InitializeLiveView(UseBackCamera: Bool = true)
    {
        CaptureSession = AVCaptureSession()
        CaptureSession.sessionPreset = .photo
        let PreferredPosition: AVCaptureDevice.Position!
        PreferredPosition = UseBackCamera ? .back : .front
        let PreferredDevice: AVCaptureDevice.DeviceType!
        PreferredDevice = UseBackCamera ? .builtInDualCamera : .builtInTrueDepthCamera
        let Devices = self.VideoDeviceDiscoverySession.devices
        var NewDevice: AVCaptureDevice? = nil
        if let Device = Devices.first(where: {$0.position == PreferredPosition && $0.deviceType == PreferredDevice})
        {
            NewDevice = Device
        }
        else
            if let Device = Devices.first(where: {$0.position == PreferredPosition})
            {
                NewDevice = Device
        }
        
        guard let InputCamera = NewDevice else
        {
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
