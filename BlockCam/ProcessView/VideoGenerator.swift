//
//  VideoGenerator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//https://stackoverflow.com/questions/28968322/how-would-i-put-together-a-video-using-the-avassetwriter-in-swift
class VideoGenerator
{
    public static var OutputURL: URL!
    
    public static func CombineIntoVideo(_ FileNames: [String])
    {
        if FileNames.count < 1
        {
            return
        }
        var ImageSize: CGSize? = nil
        var ImageList = [UIImage]()
        let FileList = FileNames.sorted{$0 < $1}
        for Name in FileList
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
                        ImageList.append(Image)
                    }
            }
        }
        if ImageList.count < 1
        {
            return
        }
        CombineIntoVideo(ImageList)
    }
    
    /// Combine the passed set of images into a single video.
    /// - Parameter Frames: The set of images to combine into a video. Each image must have the same dimensions.
    public static func CombineIntoVideo(_ Frames: [UIImage])
    {
        let ImageSize = Frames[0].size
        let TheURL = FileIO.GetScratchDirectory()!.appendingPathComponent("Scratch.mp4")
        FileIO.DeleteIfPresent(TheURL)
        OutputURL = TheURL
        print(">> CreateWriter")
        CreateWriter(Size: ImageSize)
        print(">> CreateBuffer")
        CreateBuffer(Size: ImageSize)
        print(">> InitializeWriter")
        InitializeWriter()
        print(">> WriteImages")
        WriteImages(Frames, Size: ImageSize)
    }
    
    /// Write a set of images to a video, one image per frame.
    /// - Parameter Frames: Set of images. Each image is written in order, and all images must have the same dimensions.
    /// - Parameter Size: The size (dimensions) fo all images in `Frames`.
    static func WriteImages(_ Frames: [UIImage], Size: CGSize)
    {
        var LocalFrames = Frames
        let WritingQueue = DispatchQueue(label: "VideoWriteQueue")
        WriterInput?.requestMediaDataWhenReady(on: WritingQueue)
        {
            let FPS: Int32 = 1
            let FrameDuration = CMTimeMake(value: 1, timescale: FPS)
            var FrameCount: Int64 = 0
            var AppendedOK = false
            while !LocalFrames.isEmpty
            {
                autoreleasepool
                    {
                        if WriterInput!.isReadyForMoreMediaData
                        {
                            let Working = LocalFrames.removeFirst()
                            let LastFrameTime = CMTimeMake(value: FrameCount, timescale: FPS)
                            let PresentationTime = FrameCount == 0 ? LastFrameTime : CMTimeAdd(LastFrameTime, FrameDuration)
                            var PixelBuffer: CVPixelBuffer? = nil
                            let Status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,
                                                                                      BufferAdaptor!.pixelBufferPool!, &PixelBuffer)
                            if PixelBuffer != nil && Status == 0
                            {
                                let ManagedBuffer = PixelBuffer!
                                CVPixelBufferLockBaseAddress(ManagedBuffer, CVPixelBufferLockFlags(rawValue: 0))
                                let PixelData = CVPixelBufferGetBaseAddress(ManagedBuffer)
                                let ColorSpace = CGColorSpaceCreateDeviceRGB()
                                let Context = CGContext(data: PixelData,
                                                        width: Int(Size.width),
                                                        height: Int(Size.height),
                                                        bitsPerComponent: 8,
                                                        bytesPerRow: CVPixelBufferGetBytesPerRow(ManagedBuffer),
                                                        space: ColorSpace,
                                                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
                                Context?.clear(CGRect(origin: CGPoint.zero, size: Size))
                                Context?.draw(Working.cgImage!, in: CGRect(origin: CGPoint.zero, size: Size))
                                CVPixelBufferUnlockBaseAddress(ManagedBuffer, CVPixelBufferLockFlags(rawValue: 0))
                                AppendedOK = BufferAdaptor!.append(ManagedBuffer, withPresentationTime: PresentationTime)
                            }
                            else
                            {
                                Log.Message("Failed to allocate pixel buffer.")
                                AppendedOK = false
                            }
                            FrameCount = FrameCount + 1
                        }
                }
            }
        }
        WriterInput?.markAsFinished()
        Writer?.finishWriting
            {
                Log.Message("Video written OK.")
        }
    }
    
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
    
    private static var Writer: AVAssetWriter? = nil
    private static var WriterInput: AVAssetWriterInput? = nil
    private static var BufferAdaptor: AVAssetWriterInputPixelBufferAdaptor? = nil
    
    /// Initialized the buffer writer.
    public static func InitializeWriter()
    {
        if Writer!.canAdd(WriterInput!)
        {
            Writer!.add(WriterInput!)
        }
        /*
        if Writer!.startWriting()
        {
            Writer?.startSession(atSourceTime: CMTime.zero)
            assert(BufferAdaptor?.pixelBufferPool != nil)
        }
        else
        {
            fatalError("startWriting failed.")
        }
 */
    }
    
    /// Create an asset writer pixel buffer used by AVFoundation when creating videos from a series of images.
    /// - Parameter Size: Size (dimensions) of each image.
    public static func CreateBuffer(Size: CGSize)
    {
        let BufferSettings: [String: Any] =
            [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(Size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(Size.height))
        ]
        BufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: WriterInput!, sourcePixelBufferAttributes: BufferSettings)
        

    }
    
    public static func CreateWriter(Size: CGSize)
    {
        do
        {
            Writer = try AVAssetWriter(outputURL: OutputURL, fileType: AVFileType.mp4)
            let Settings: [String: Any] =
                [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: NSNumber(value: Int(Size.width)),
                    AVVideoHeightKey: NSNumber(value: Int(Size.height)),
                    AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
            ]
            guard (Writer?.canApply(outputSettings: Settings, forMediaType: AVMediaType.video))! else
            {
                fatalError("Cannot apply settings to video writer.")
            }
            WriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: Settings)
            if (Writer?.canAdd(WriterInput!))!
            {
                Writer?.add(WriterInput!)
            }
            else
            {
                fatalError("Error adding writer input.")
            }
            let StartedOK = Writer?.startWriting()
            if !StartedOK!
            {
                fatalError("Error starting writing")
            }
        }
        catch
        {
            fatalError("Error creating writer: \(error.localizedDescription)")
        }
    }
}
