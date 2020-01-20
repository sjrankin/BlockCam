//
//  VideoMaker.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

class VideoMaker
{
    /// Resize an image such that the maximum dimension is no larger than `MaxDimension`. If the original dimensions of the
    /// image are less than `MaxDimension`, the original image is returned unchanged.
    /// - Parameter Image: The image to potentially resize.
    /// - Parameter MaxDimension: The maximum allowable size of the image.
    /// - Returns: Potentially resized image.
    static func ResizeToMaxDimension(_ Image: UIImage, _ MaxDimension: Int) -> UIImage
    {
        let OldMax = max(Image.size.width, Image.size.height)
        if OldMax < CGFloat(MaxDimension)
        {
            return Image
        }
        return Generator.ResizeImage(Image: Image, Longest: CGFloat(MaxDimension))
    }
    
    public static func CreateVideosFromSceneFrames(Parent: UIViewController,
                                                   StatusHandler: ((Double, UIColor) -> ())? = nil,
                                                   Completed: ((Bool) -> ())? = nil)
    {
        if var FileNames = FileIO.ContentsOfSpecialDirectory(FileIO.SceneFrames)
        {
            FileNames.sort()
            var Frames = [UIImage]()
            var ImageSize: CGSize? = nil
            for Name in FileNames
            {
                autoreleasepool
                    {
                        if var Image = FileIO.LoadImage(Name, InDirectory: FileIO.SceneFrames)
                        {
                            Image = ResizeToMaxDimension(Image, 1080)
                            if ImageSize == nil
                            {
                                ImageSize = Image.size
                            }
                            else
                            {
                                if ImageSize != Image.size
                                {
                                    Log.AbortMessage("Variant image size found.")
                                    {
                                        Message in
                                        fatalError(Message)
                                    }
                                }
                            }
                            Frames.append(Image)
                        }
                }
            }
            CreateVideo(From: Frames, Parent: Parent, StatusHandler: StatusHandler, Completed: Completed)
        }
        else
        {
            Log.Message("Error getting contents of \(FileIO.SceneFrames).")
        }
    }
    
    public static func CreateVideo(From: [UIImage], Parent: UIViewController,
                                   StatusHandler: ((Double, UIColor) -> ())? = nil,
                                   Completed: ((Bool) -> ())? = nil)
    {
        let SaveSettings = RenderSettings()
        SaveSettings.Size = From[0].size
        let Combine = Combiner(SaveSettings)
        Combine.Images = From
        Combine.Render(Completion: nil)
        Combiner.SaveToLibrary(VideoURL: SaveSettings.OutputURL!)
    }
}

class RenderSettings
{
    var Size: CGSize = .zero
    var FPS: Int32 = 6
    var AVCodecKey = AVVideoCodecType.h264
    var VideoExt = "mov"
    var OutputURL = FileIO.GetDirectoryURL(DirectoryName: FileIO.ScratchDirectory)
}

class Combiner
{
    static let TimeScale: Int32 = 600
    var Settings: RenderSettings!
    var VWriter: VideoWriter? = nil
    var Images: [UIImage]? = nil
    {
        didSet
        {
            VWriter = VideoWriter(Settings, Images!)
        }
    }
    var FrameNumber = 0
    
    init(_ Settings: RenderSettings)
    {
        self.Settings = Settings
    }
    
    class func SaveToLibrary(VideoURL: URL)
    {
        PHPhotoLibrary.requestAuthorization
            {
                status in
                guard status == .authorized else
                {
                    return
                }
                PHPhotoLibrary.shared().performChanges(
                    {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: VideoURL)
                }
                )
                {
                    success, error in
                    if !success
                    {
                        print("could not save video to photo library: \((error?.localizedDescription)!)")
                    }
                }
        }
    }
    
    class func RemoveFileAtURL(_ FileURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(atPath: FileURL.path)
        }
        catch
        {
            return
        }
    }
    
    func Render(Completion: (() -> Void)?)
    {
        Combiner.RemoveFileAtURL(Settings.OutputURL!)
        VWriter?.Start()
        VWriter?.Render(AppendBuffers)
        {
            Combiner.SaveToLibrary(VideoURL: self.Settings.OutputURL!)
        }
    }
    
    func AppendBuffers(Writer: VideoWriter) -> Bool
    {
        let FrameDuration = CMTimeMake(value: Int64(Combiner.TimeScale / Settings.FPS), timescale: Combiner.TimeScale)
        while !Images!.isEmpty
        {
            if !Writer.IsReadyForData
            {
                return false
            }
            let ImageToAdd = Images!.removeFirst()
            let PTime = CMTimeMultiply(FrameDuration, multiplier: Int32(FrameNumber))
            let Success = VWriter?.AddImage(Image: ImageToAdd, WithTime: PTime)
            if !Success!
            {
                fatalError("Add image failed.")
            }
            FrameNumber = FrameNumber + 1
        }
        return true
    }
}

class VideoWriter
{
    let Settings: RenderSettings!
    var VWriter: AVAssetWriter!
    var VWriterInput: AVAssetWriterInput!
    var PixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    init(_ Settings: RenderSettings, _ ImageSet: [UIImage])
    {
        self.Settings = Settings
    }
    
    var IsReadyForData: Bool
    {
        return VWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    class func PixelBufferFromImage(Image: UIImage, PixelBufferPool: CVPixelBufferPool, Size: CGSize) -> CVPixelBuffer
    {
        var Buffer: CVPixelBuffer? = nil
        let Status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, PixelBufferPool, &Buffer)
        if Status != kCVReturnSuccess
        {
            fatalError("CVPixelBufferPoolCreatePixelBuffer failed.")
        }
        let PixelBuffer = Buffer!
        CVPixelBufferLockBaseAddress(PixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let PixelData = CVPixelBufferGetBaseAddress(PixelBuffer)
        let ColorSpace = CGColorSpaceCreateDeviceRGB()
        let Context = CGContext(data: PixelData, width: Int(Size.width), height: Int(Size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(PixelBuffer),
                                space: ColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        Context!.clear(CGRect(x: 0, y: 0, width: Size.width, height: Size.height))
        let HRatio = Size.width / Image.size.width
        let VRatio = Size.height / Image.size.height
        let AspectRatio = min(HRatio, VRatio)
        let NewSize = CGSize(width: Image.size.width * AspectRatio, height: Image.size.height * AspectRatio)
        let X = NewSize.width < Size.width ? (Size.width - NewSize.width) / 2 : 0
        let Y = NewSize.height < Size.height ? (Size.height - NewSize.height) / 2 : 0
        Context?.draw(Image.cgImage!, in: CGRect(x: X, y: Y, width: NewSize.width, height: NewSize.height))
        CVPixelBufferUnlockBaseAddress(PixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return PixelBuffer
    }
    
    func Start()
    {
        let OutputSettings: [String: Any] =
        [
            AVVideoCodecKey: Settings.AVCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(Settings.Size.width)),
            AVVideoHeightKey: NSNumber(value: Float(Settings.Size.height))
        ]
        
        func CreateBufferAdaptor()
        {
            print("Buffer size: \(Settings.Size)")
            let SourceAttributes =
            [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ABGR),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(Settings.Size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(Settings.Size.height))
            ]
            PixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: VWriterInput,
                                                                      sourcePixelBufferAttributes: SourceAttributes)
        }
        
        func CreateAssetWriter(OutputURL: URL) -> AVAssetWriter
        {
            guard let AWriter = try? AVAssetWriter(outputURL: OutputURL, fileType: AVFileType.mov) else
            {
                fatalError("AVAssetWriter failed.")
            }
            guard AWriter.canApply(outputSettings: OutputSettings, forMediaType: AVMediaType.video) else
            {
                fatalError("Unable to apply settings for video file.")
            }
            return AWriter
        }
        
        VWriter = CreateAssetWriter(OutputURL: Settings.OutputURL!)
        VWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: OutputSettings)
        if VWriter.canAdd(VWriterInput)
        {
            VWriter.add(VWriterInput)
        }
        else
        {
            fatalError("Error adding video writer input.")
        }
        
        CreateBufferAdaptor()
        if !VWriter.startWriting()
        {
            var Status = ""
            switch VWriter.status
            {
                case .cancelled:
                Status = "Cancelled"
                case .completed:
                Status = "Complted"
                case .failed:
                Status = "Failed"
                case .unknown:
                Status = "Unknown"
                case .writing:
                Status = "Writing"
                @unknown default:
                Status = "Who knows?"
            }
            fatalError("Error returned by startWriting: \((VWriter.error?.localizedDescription)!), \(Status)")
        }
        VWriter.startSession(atSourceTime: CMTime.zero)
        precondition(PixelBufferAdaptor.pixelBufferPool != nil, "Buffer pool failed nil check")
    }
    
    func Render(_ AppendBuffers: ((VideoWriter) -> Bool)?, Completion: (() -> Void)?)
    {
        precondition(VWriter != nil, "Call Start first.")
        let Queue = DispatchQueue(label: "VideoWriterQueue2")
        VWriterInput.requestMediaDataWhenReady(on: Queue)
        {
            let IsFinished = AppendBuffers?(self) ?? false
            if IsFinished
            {
                self.VWriterInput.markAsFinished()
                self.VWriter.finishWriting()
                    {
                        DispatchQueue.main.async
                            {
                            Completion?()
                        }
                }
            }
            else
            {
                //Do nothing
            }
        }
    }
    
    func AddImage(Image: UIImage, WithTime: CMTime) -> Bool
    {
        precondition(PixelBufferAdaptor != nil, "Call start first.")
        let PixelBuffer = VideoWriter.PixelBufferFromImage(Image: Image, PixelBufferPool: PixelBufferAdaptor.pixelBufferPool!,
                                                           Size: Settings.Size)
        return PixelBufferAdaptor.append(PixelBuffer, withPresentationTime: WithTime)
    }
}
